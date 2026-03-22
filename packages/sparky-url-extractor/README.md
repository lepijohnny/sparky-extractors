# sparky-url-extractor

URL extractor plugin for Sparky — crawls web pages and extracts clean, structured markdown.

## Features

- **Mozilla Readability** for main content detection (same algorithm as Firefox Reader View)
- **Markdown output** — preserves headings, links, code blocks, tables, lists, blockquotes
- **llms.txt support** — tries `/llms-full.txt` and `/llms.txt` before crawling
- **robots.txt** — respects Disallow rules and Crawl-delay
- **Sitemap discovery** — parses `sitemap.xml` (including sitemap indexes) to seed the crawl queue
- **BFS crawling** — follows same-origin links up to configurable depth and page limit

## How It Works

1. If the URL is a root domain, tries `/llms-full.txt` then `/llms.txt` (AI-friendly content)
2. Parses `robots.txt` for rules and sitemap references
3. Parses `sitemap.xml` to discover pages
4. BFS crawls same-origin links (default: depth 3, max 200 pages)
5. For each page:
   - Parses HTML with [linkedom](https://github.com/nicenemo/linkedom) (lightweight, no jsdom)
   - Extracts main content with [@mozilla/readability](https://github.com/nicenemo/readability)
   - Converts to clean markdown with preserved structure
   - Falls back to DOM walking if Readability can't parse

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `maxDepth` | number | 3 | Link-hops deep to follow |
| `maxPages` | number | 200 | Max pages to crawl |
| `timeout` | number | 10000 | Per-page fetch timeout (ms) |
| `respectRobots` | boolean | true | Obey robots.txt rules |
| `useLlmsTxt` | boolean | true | Try llms.txt before crawling |

## Dependencies

- `linkedom` — lightweight DOM parser
- `@mozilla/readability` — content extraction (Firefox Reader View algorithm)
