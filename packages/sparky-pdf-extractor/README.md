# sparky-pdf-extractor

PDF extractor plugin for [Sparky](https://getsparky.chat) — extracts text and structure from PDF files.

## Features

- Extracts text from each page using [unpdf](https://github.com/nicenemo/unpdf) (pdfjs-dist wrapper)
- Optional layout preservation mode (columns, tables)
- Page boundaries as sections for targeted retrieval

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `preserveLayout` | boolean | false | Preserve original page layout instead of flowing text |

## Install

```bash
npm install sparky-pdf-extractor --prefix ~/.sparky/plugins/ext
```

## Dependencies

- `unpdf` — PDF text extraction (pdfjs-dist wrapper)
