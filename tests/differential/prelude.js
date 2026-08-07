// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
// Minimal DOM stub so the game's script can be loaded and driven outside a
// browser. It is deliberately dumb: every element accepts every call and
// records nothing. We are testing the SIMULATION, not the rendering — if a
// paint path throws, that is a real failure and we want to see it, but we do
// not care what it drew.
const el = () => new Proxy({}, {
  get(t, k) {
    if (k === "classList") return { add(){}, remove(){}, toggle(){}, contains(){return false} };
    if (k === "style") return new Proxy({}, {get(){return ""}, set(){return true}});
    if (k === "dataset") return {};
    // paint() indexes ports.children[i] for all 20 regions, so this has to be
    // indexable and report a stable length — an empty array makes paint throw.
    if (k === "children" || k === "childNodes") {
      if (!t.__kids) t.__kids = Array.from({length: 20}, () => el());
      return t.__kids;
    }
    if (k in t) return t[k];
    if (k === "innerHTML" || k === "textContent" || k === "value") return "";
    return typeof k === "string" ? (()=>el()) : undefined;
  },
  set(t, k, v) { t[k] = v; return true; }
});
globalThis.document = {
  getElementById: () => el(),
  createElementNS: () => el(),
  createElement: () => el(),
  querySelectorAll: () => [],
  querySelector: () => el(),
  addEventListener(){},
};
globalThis.window = globalThis;
globalThis.location = { search: globalThis.__SEARCH__ || "" };
globalThis.requestAnimationFrame = () => 0;
globalThis.setInterval = () => 0;      // the driver ticks manually
globalThis.clearInterval = () => {};
globalThis.setTimeout = (f) => { return 0; };