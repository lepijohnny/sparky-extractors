/**
 * Sparky extractor plugin for PDF files.
 *
 * Uses unpdf (pdfjs-dist wrapper) to extract text from each page.
 * Yields a single ExtractionResult with all pages concatenated and
 * page boundaries as sections.
 */
const { readFile } = require("node:fs/promises");

const extensions = [".pdf"];

async function* extract(target, log, options = {}) {
  const { getDocumentProxy, extractText } = await import("unpdf");
  const preserveLayout = options.preserveLayout ?? false;

  log(`Reading ${target}`);
  const buffer = await readFile(target);
  const pdf = await getDocumentProxy(new Uint8Array(buffer));
  const totalPages = pdf.numPages;
  log(`${totalPages} page${totalPages === 1 ? "" : "s"}`);

  const pages = [];
  const sections = [];
  let offset = 0;

  for (let i = 1; i <= totalPages; i++) {
    const page = await pdf.getPage(i);
    const content = await page.getTextContent();

    let pageText;
    if (preserveLayout) {
      pageText = layoutText(content.items);
    } else {
      pageText = flowText(content.items);
    }

    if (pageText.trim().length === 0) continue;

    sections.push({ offset, label: `Page ${i}` });
    pages.push(pageText);
    offset += pageText.length + 1;
  }

  const text = pages.join("\n");
  if (text.trim().length === 0) {
    log("No text extracted (scanned PDF?)");
    return;
  }

  log(`Extracted ${text.length} chars from ${sections.length} pages`);
  yield { text, sections: sections.length > 1 ? sections : undefined };
}

/**
 * Flow text — join items into paragraphs, collapsing whitespace.
 */
function flowText(items) {
  const lines = [];
  let currentLine = "";
  let lastY = null;

  for (const item of items) {
    if (!item.str) continue;
    const y = item.transform ? item.transform[5] : null;

    if (lastY !== null && y !== null && Math.abs(y - lastY) > 2) {
      if (currentLine.trim()) lines.push(currentLine.trim());
      currentLine = "";
    }

    currentLine += (currentLine && !currentLine.endsWith(" ") ? " " : "") + item.str;
    lastY = y;
  }

  if (currentLine.trim()) lines.push(currentLine.trim());

  const paragraphs = [];
  let para = "";
  for (const line of lines) {
    if (line.length === 0) {
      if (para) { paragraphs.push(para); para = ""; }
    } else {
      para += (para ? " " : "") + line;
    }
  }
  if (para) paragraphs.push(para);

  return paragraphs.join("\n\n");
}

/**
 * Layout text — preserve spatial positioning using Y coordinates.
 */
function layoutText(items) {
  const lines = [];
  let currentLine = "";
  let lastY = null;

  for (const item of items) {
    if (!item.str) continue;
    const y = item.transform ? item.transform[5] : null;

    if (lastY !== null && y !== null && Math.abs(y - lastY) > 1) {
      lines.push(currentLine);
      currentLine = "";
    }

    currentLine += item.str;
    lastY = y;
  }

  if (currentLine) lines.push(currentLine);
  return lines.join("\n");
}

module.exports = { extensions, extract };
