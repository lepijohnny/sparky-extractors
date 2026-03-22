# sparky-extractors

Extractor plugins for [Sparky](https://getsparky.chat) — add new source types to the knowledge base.

## Packages

| Package | Description | Install |
|---------|-------------|---------|
| [`sparky-url-extractor`](./packages/sparky-url-extractor) | Crawls web pages and extracts clean markdown | `npm install sparky-url-extractor --prefix ~/.sparky/plugins/ext` |
| [`sparky-pdf-extractor`](./packages/sparky-pdf-extractor) | Extracts text and structure from PDF files | `npm install sparky-pdf-extractor --prefix ~/.sparky/plugins/ext` |

## How Extractors Work

Sparky discovers extractor plugins from `~/.sparky/plugins/ext/node_modules/`. Each package declares:

- **`extensions`** — file extensions it handles (e.g. `.pdf`, `.url`)
- **`extract(target, log, options)`** — async generator yielding `{ text, sections? }` results

Plugins are listed in the `package.json` `keywords` array with `"sparky-extractor"` and configured via the `sparky` field.

## License

[MIT](LICENSE)
