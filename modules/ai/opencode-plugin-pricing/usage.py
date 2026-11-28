#!/usr/bin/env python3
"""Aggregate OpenCode's local session DB into per-day, per-model token usage.

Read-only and fast: session_v2 holds compact per-session totals (the raw
session_message blobs are multi-GB and far too slow for a slash command).
Prints JSON to stdout. Usage: python3 pricing-usage.py [days|month]  (default: month)

Caveat: a session is attributed to its start day (IST) and last recorded model.
"""

import collections
import datetime as dt
import json
import os
import sqlite3
import sys
from zoneinfo import ZoneInfo

DAYS = sys.argv[1] if len(sys.argv) > 1 else "month"
DB = os.path.expanduser("~/.local/share/opencode/opencode.db")
IST = ZoneInfo("Asia/Kolkata")
now_ist = dt.datetime.now(IST)
if DAYS == "month":
    since_dt = now_ist.replace(day=1, hour=0, minute=0, second=0, microsecond=0)
else:
    since_dt = now_ist - dt.timedelta(days=int(DAYS))
since = int(since_dt.astimezone(dt.timezone.utc).timestamp() * 1000)

agg = collections.defaultdict(
    lambda: dict(
        sessions=0,
        input=0,
        output=0,
        reasoning=0,
        cache_read=0,
        cache_write=0,
        cost=0.0,
    )
)

with sqlite3.connect(f"file:{DB}?mode=ro", uri=True) as db:
    rows = db.execute(
        """SELECT model, cost, tokens_input, tokens_output, tokens_reasoning,
                  tokens_cache_read, tokens_cache_write, time_created
           FROM session_v2 WHERE time_created >= ?""",
        (since,),
    )
    for model_json, cost, tin, tout, treason, cread, cwrite, created in rows:
        try:
            model = json.loads(model_json) if model_json else {}
        except (ValueError, TypeError):
            model = {}
        day = dt.datetime.fromtimestamp(created / 1000, IST).strftime("%Y-%m-%d")
        key = (day, model.get("providerID") or "?", model.get("id") or "?")
        row = agg[key]
        row["sessions"] += 1
        row["input"] += tin or 0
        row["output"] += tout or 0
        row["reasoning"] += treason or 0
        row["cache_read"] += cread or 0
        row["cache_write"] += cwrite or 0
        row["cost"] += cost or 0.0

out = [
    dict(day=day, provider=provider, model=model, **dict(values))
    for (day, provider, model), values in sorted(agg.items())
]
print(json.dumps(out))
