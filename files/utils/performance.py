#!/usr/bin/env python3

import argparse
import csv
import http.server
import os
import socket
import socketserver
import tempfile
import threading
import time
import urllib.request
from dataclasses import dataclass
from typing import List, Tuple


# Stats-reading utilities
@dataclass
class CpuTimes:
    idle: int
    total: int


def read_cpu_times() -> CpuTimes:
    with open("/proc/stat", "r", encoding="utf-8") as f:
        parts = f.readline().split()
    vals = [int(x) for x in parts[1:]]
    idle = vals[3] + (vals[4] if len(vals) > 4 else 0)
    return CpuTimes(idle=idle, total=sum(vals))


def cpu_percent(prev: CpuTimes, cur: CpuTimes) -> float:
    delta_total = cur.total - prev.total
    delta_idle = cur.idle - prev.idle
    if delta_total <= 0:
        return 0.0
    percent = (delta_total - delta_idle) / delta_total * 100.0
    return max(0.0, min(100.0, percent))


# Static content HTTP server
class QuietHandler(http.server.SimpleHTTPRequestHandler):
    def log_message(self, format: str, *args: object) -> None:
        return


class ThreadingServer(socketserver.ThreadingMixIn, socketserver.TCPServer):
    daemon_threads = True
    allow_reuse_address = True


def free_port(bind: str) -> int:
    with socket.socket() as s:
        s.bind((bind, 0))
        return int(s.getsockname()[1])


def server(bind: str, port: int, directory: str) -> ThreadingServer:
    def handler(*args: object, **kwargs: object) -> QuietHandler:
        return QuietHandler(*args, directory=directory, **kwargs)

    httpd = ThreadingServer((bind, port), handler)
    thread = threading.Thread(target=httpd.serve_forever, daemon=True)
    thread.start()
    return httpd


# Generating load
def worker(url: str, stop_at: float, counts: List[int], latency: List[float], index: int) -> None:
    requests = 0
    total_latency = 0.0

    while time.monotonic() < stop_at:
        start = time.perf_counter()
        try:
            with urllib.request.urlopen(url, timeout=2.0) as r:
                r.read()
            total_latency += time.perf_counter() - start
            requests += 1
        except Exception:
            pass

    counts[index] = requests
    latency[index] = total_latency


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--seconds", type=float, default=30.0)
    ap.add_argument("--clients", type=int, default=8)
    ap.add_argument("--sample", type=float, default=1.0, help="sampling interval seconds")
    ap.add_argument("--out", type=str, default="stats.csv")
    args = ap.parse_args()

    root = tempfile.mkdtemp(prefix="content-")
    with open(os.path.join(root, "index.html"), "w", encoding="utf-8") as f:
        f.write("ok\n")

    bind = "127.0.0.1"
    port = free_port(bind)
    httpd = server(bind, port, root)
    url = f"http://{bind}:{port}/index.html"

    stop_at = time.monotonic() + float(args.seconds)

    counts = [0] * args.clients
    latency = [0.0] * args.clients

    threads = [
        threading.Thread(
            target=worker,
            args=(url, stop_at, counts, latency, i),
            daemon=True,
        )
        for i in range(args.clients)
    ]
    for t in threads:
        t.start()

    samples: List[List[str]] = []
    prev = read_cpu_times()
    time.sleep(0.05)

    while time.monotonic() < stop_at:
        cur = read_cpu_times()
        cpu = cpu_percent(prev, cur)
        prev = cur

        samples.append([f"{time.time():.6f}", f"{cpu:.2f}"])
        time.sleep(args.sample)

    for t in threads:
        t.join()

    httpd.shutdown()
    httpd.server_close()

    with open(args.out, "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["ts", "cpu"])
        w.writerows(samples)

    total_requests = sum(counts)
    total_latency = sum(latency)
    avg_latency = (total_latency / total_requests * 1000.0) if total_requests > 0 else 0.0

    print(
        f"url={url} clients={args.clients} seconds={args.seconds} "
        f"requests={total_requests} avg_latency={avg_latency:.3f} "
        f"csv={args.out}"
    )

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
