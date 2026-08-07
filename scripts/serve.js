// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// A local static server, for when you want the game on http:// rather than
// file://. You usually do not need this at all — 688-attack-hub.html is
// self-contained and opens directly from disk.
//
// It exists because `package.json` used to run `python3 -m http.server`, and
// Python is banned estate-wide with no exceptions. Bun is the estate's
// first-choice runtime and ships a server, so this needs no dependency and
// keeps the repo's "nothing to install" claim true.
//
// Plain JavaScript, not TypeScript: also banned.
//
//   bun run serve            # then open http://localhost:8000
//   PORT=3000 bun run serve

import { resolve } from "node:path";

const PORT = Number(process.env.PORT) || 8000;
const ROOT = new URL("../", import.meta.url).pathname;

Bun.serve({
  port: PORT,
  async fetch(req) {
    let path;
    try { path = decodeURIComponent(new URL(req.url).pathname); }
    catch { return new Response("bad request", { status: 400 }); }
    if (path === "/" || path === "") path = "/688-attack-hub.html";

    // Traversal guard. The obvious version of this is WRONG and was shipped
    // here first: `ROOT + path` then `.startsWith(ROOT)` compares strings
    // without resolving `..`, so "ROOT/../../etc/passwd" passes the check and
    // then reads /etc/passwd. Worse, new URL() normalises literal dot-segments
    // but decodeURIComponent runs AFTER it, so "%2e%2e" survives normalisation
    // and becomes ".." only once the check is already behind you.
    //
    // Resolve first, compare second. A dev server is not a threat model, but
    // "it only listens on localhost" is not a reason to ship a broken check.
    const resolved = resolve(ROOT, "." + path);
    if (resolved !== ROOT.replace(/\/$/, "") && !resolved.startsWith(ROOT)) {
      return new Response("forbidden", { status: 403 });
    }
    const file = Bun.file(resolved);
    if (!(await file.exists())) return new Response("not found", { status: 404 });
    return new Response(file);
  },
});

console.log(`688 Attack Hub — http://localhost:${PORT}`);
console.log("(you do not need this: 688-attack-hub.html opens fine from disk)");
