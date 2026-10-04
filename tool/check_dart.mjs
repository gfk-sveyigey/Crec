import fs from "node:fs";
import path from "node:path";

const root = process.argv[2];
const files = [];

function walk(dir) {
  for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
    const p = path.join(dir, e.name);
    if (e.isDirectory()) walk(p);
    else if (e.name.endsWith(".dart")) files.push(p);
  }
}
walk(root);

function check(src) {
  const errs = [];
  let i = 0;
  const n = src.length;
  let line = 1;
  const stack = [];
  const pairs = { ")": "(", "]": "[", "}": "{" };
  let state = "code";
  let stringStart = 0;

  function advance(ch) { if (ch === "\n") line++; }

  while (i < n) {
    const ch = src[i];
    const next = src[i + 1];
    if (state === "code") {
      if (ch === "/" && next === "/") { state = "lineComment"; i += 2; continue; }
      if (ch === "/" && next === "*") { state = "blockComment"; i += 2; continue; }
      if (ch === "'" || ch === '"') {
        const triple = src.slice(i, i + 3) === ch + ch + ch;
        state = triple ? (ch === "'" ? "tripleS" : "tripleD") : (ch === "'" ? "s" : "d");
        stringStart = line;
        i += triple ? 3 : 1;
        continue;
      }
      if (ch === "r" && (next === "'" || next === '"')) {
        const q = next;
        const triple = src.slice(i + 1, i + 4) === q + q + q;
        state = triple ? (q === "'" ? "tripleS" : "tripleD") : (q === "'" ? "s" : "d");
        stringStart = line;
        i += triple ? 4 : 2;
        continue;
      }
      if (ch === "{" || ch === "(" || ch === "[") stack.push({ ch, line });
      else if (ch === "}" || ch === ")" || ch === "]") {
        const top = stack.pop();
        if (!top) errs.push("line " + line + ": unmatched '" + ch + "'");
        else if (top.ch !== pairs[ch]) errs.push("line " + line + ": '" + ch + "' closes '" + top.ch + "' opened at line " + top.line);
      }
      advance(ch);
      i++;
      continue;
    }
    if (state === "lineComment") {
      if (ch === "\n") { state = "code"; line++; }
      i++;
      continue;
    }
    if (state === "blockComment") {
      if (ch === "*" && next === "/") { state = "code"; i += 2; continue; }
      advance(ch);
      i++;
      continue;
    }
    if (state === "tripleS" || state === "tripleD") {
      const q = state === "tripleS" ? "'" : '"';
      if (src.slice(i, i + 3) === q + q + q) { state = "code"; i += 3; continue; }
      advance(ch);
      i++;
      continue;
    }
    // single line string
    const q = state === "s" ? "'" : '"';
    if (ch === "\\") { i += 2; continue; }
    if (ch === q) { state = "code"; i++; continue; }
    if (ch === "\n") { errs.push("line " + stringStart + ": unterminated string literal"); state = "code"; line++; i++; continue; }
    i++;
  }
  if (state === "s" || state === "d") errs.push("EOF: unterminated string starting line " + stringStart);
  if (state === "tripleS" || state === "tripleD") errs.push("EOF: unterminated triple string starting line " + stringStart);
  if (state === "blockComment") errs.push("EOF: unterminated block comment");
  if (stack.length) errs.push("EOF: unclosed '" + stack[stack.length - 1].ch + "' from line " + stack[stack.length - 1].line);
  return errs;
}

let total = 0;
for (const f of files.sort()) {
  const src = fs.readFileSync(f, "utf8");
  const errs = check(src);
  const rel = path.relative(root, f).replace(/\\/g, "/");
  if (errs.length) { total += errs.length; console.log("FAIL " + rel); for (const e of errs) console.log("   " + e); }
}
console.log("---");
console.log("files: " + files.length + ", issues: " + total);
