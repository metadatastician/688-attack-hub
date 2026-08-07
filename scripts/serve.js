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

const PORT = Number(process.env.PORT) || 8000;
const ROOT = new URL("../", import.meta.url).pathname;

Bun.serve({
  port: PORT,
  async fetch(req) {
    let path = decodeURIComponent(new URL(req.url).pathname);
    if (path === "/" || path === "") path = "/688-attack-hub.html";
    // Refuse to serve outside the repo. A dev server is not a threat model,
    // but ".." traversal is one line to prevent and awkward to explain later.
    const resolved = ROOT + path.replace(/^\/+/, "");
    if (!resolved.startsWith(ROOT)) return new Response("no", { status: 403 });
    const file = Bun.file(resolved);
    if (!(await file.exists())) return new Response("not found", { status: 404 });
    return new Response(file);
  },
});

console.log(`688 Attack Hub — http://localhost:${PORT}`);
console.log("(you do not need this: 688-attack-hub.html opens fine from disk)");
