import fs from "node:fs";

const files = process.argv.slice(2);
let problems = 0;

function checkYaml(file) {
  const src = fs.readFileSync(file, "utf8");
  const lines = src.split("\n");
  const issues = [];
  const indentStack = [0];
  let inBlock = false;
  let blockIndent = 0;
  const keyStack = [];

  lines.forEach((raw, idx) => {
    const n = idx + 1;
    if (raw.includes("\t")) issues.push("line " + n + ": tab character");
    const line = raw.replace(/\s+$/, "");
    if (line.trim() === "" || line.trim().startsWith("#")) return;
    const indent = line.length - line.trimStart().length;

    if (inBlock) {
      if (indent > blockIndent) return;
      inBlock = false;
    }

    if (indent % 2 !== 0) issues.push("line " + n + ": indent " + indent + " is not a multiple of 2");

    while (indentStack.length > 1 && indent < indentStack[indentStack.length - 1]) indentStack.pop();
    if (indent > indentStack[indentStack.length - 1]) indentStack.push(indent);
    else if (indent !== indentStack[indentStack.length - 1]) {
      issues.push("line " + n + ": indent " + indent + " does not match any open level " + JSON.stringify(indentStack));
    }

    const body = line.trim();
    if (body.endsWith("|") || body.endsWith(">") || /:\s*[|>][-+]?$/.test(body)) {
      inBlock = true;
      blockIndent = indent;
    }

    if (body.startsWith("- ")) {
      keyStack.length = 0;
    }

    if (/^[^\s#:[].*:\s*$/.test(body) && !body.startsWith("- ")) {
      // mapping key at this level
      const key = body.replace(/:\s*$/, "");
      const atSame = keyStack.filter((k) => k.indent === indent);
      if (atSame.some((k) => k.key === key)) issues.push("line " + n + ": duplicate key '" + key + "'");
      keyStack.push({ key, indent });
    }
  });

  // required anchors for a GH Actions workflow
  if (!/^on:/m.test(src)) issues.push("missing top-level 'on:'");
  if (!/^jobs:/m.test(src)) issues.push("missing top-level 'jobs:'");
  if (!/runs-on:/.test(src)) issues.push("missing runs-on");
  if (!/steps:/.test(src)) issues.push("missing steps:");
  if (/\$\{\{/.test(src) === false) issues.push("no GitHub expression found (unexpected)");
  const unescaped = src.match(/(?<!\$)\$\{(?!\{)/g);
  if (unescaped) issues.push("found " + unescaped.length + " stray dollar-brace that is not a GitHub expression");

  return issues;
}

function extractRuns(src) {
  const lines = src.split("\n");
  const blocks = [];
  for (let i = 0; i < lines.length; i++) {
    const m = /^(\s*)run:\s*\|\s*$/.exec(lines[i]);
    if (!m) continue;
    const indent = m[1].length;
    const body = [];
    for (let j = i + 1; j < lines.length; j++) {
      const line = lines[j];
      if (line.trim() === "") { body.push(""); continue; }
      const ind = line.length - line.trimStart().length;
      if (ind <= indent) break;
      body.push(line.slice(indent + 2));
    }
    blocks.push({ line: i + 1, body: body.join("\n") });
  }
  return blocks;
}

function checkShell(name, script) {
  const issues = [];
  const lines = script.split("\n");
  lines.forEach((line, i) => {
    const code = line.replace(/#.*$/, "");
    const singles = (code.match(/'/g) || []).length;
    if (singles % 2 !== 0) {
      // allow escaped single quotes inside double quotes and apostrophes in words
      if (!/[\u4e00-\u9fff]/.test(code) && !/'\\''/.test(code)) {
        issues.push("line " + (i + 1) + ": odd number of single quotes: " + line.trim());
      }
    }
    if (/\\\$$/.test(code) === false && /^\s*(if|for|while)\b/.test(code)) {
      // track keywords loosely below
    }
  });
  const count = (re) => (script.match(re) || []).length;
  const ifCount = count(/^\s*if\b/gm);
  const fiCount = count(/^\s*fi\b/gm);
  if (ifCount !== fiCount) issues.push("if/fi mismatch: " + ifCount + " if vs " + fiCount + " fi");
  const forCount = count(/^\s*for\b/gm);
  const doneCount = count(/^\s*done\b/gm);
  if (forCount !== doneCount) issues.push("for/done mismatch: " + forCount + " for vs " + doneCount + " done");
  if (/set -e/.test(script) === false) issues.push("run block does not start with 'set -e'");
  return issues;
}

for (const file of files) {
  const src = fs.readFileSync(file, "utf8");
  const issues = checkYaml(file);
  const runs = extractRuns(src);
  let shellIssues = 0;
  for (const r of runs) {
    const si = checkShell(file, r.body);
    for (const s of si) { issues.push("[run @line " + r.line + "] " + s); }
    shellIssues += si.length;
  }
  console.log((issues.length ? "FAIL " : "ok   ") + file + "  (run blocks: " + runs.length + ")");
  for (const i of issues) console.log("   " + i);
  problems += issues.length;
}
console.log("---");
console.log("total issues: " + problems);
