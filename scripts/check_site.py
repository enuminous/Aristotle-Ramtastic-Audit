"""Validate the static entry point, source catalogue, and local navigation."""
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import unquote, urlparse
import re

ROOT = Path(__file__).resolve().parents[1]
SNAPSHOT = "03ac2c354b532a93d27e43187c6e2d02a7cd3b59"
REPOSITORY = "/enuminous/Aristotle-Ramtastic-Audit/"


class Page(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.ids = set()
        self.links = []
        self.rows = 0
        self.stack = []

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if "id" in attrs:
            if attrs["id"] in self.ids:
                raise SystemExit(f"Duplicate id: {attrs['id']}")
            self.ids.add(attrs["id"])
        for key in ("href", "src"):
            if attrs.get(key):
                self.links.append(attrs[key])
        if tag == "tr" and "data-family" in attrs:
            self.rows += 1
        if tag not in {"area", "base", "br", "col", "embed", "hr", "img", "input", "link", "meta", "param", "source", "track", "wbr"}:
            self.stack.append(tag)

    def handle_endtag(self, tag):
        if not self.stack or self.stack[-1] != tag:
            raise SystemExit(f"Unbalanced HTML at </{tag}>; stack={self.stack[-5:]}")
        self.stack.pop()

    def handle_startendtag(self, tag, attrs):
        self.handle_starttag(tag, attrs)
        if self.stack and self.stack[-1] == tag:
            self.stack.pop()


page = Page()
text = (ROOT / "index.html").read_text()
page.feed(text)
if page.stack:
    raise SystemExit(f"Unclosed HTML elements: {page.stack}")
modules = {p.relative_to(ROOT).as_posix() for ns in ("Ramtastic", "RamtasticAudit")
           for p in (ROOT / ns).rglob("*.lean")}
catalogue = set()
for link in page.links:
    parsed = urlparse(link)
    if parsed.scheme and parsed.scheme not in {"https", "http"}:
        raise SystemExit(f"Unexpected URL scheme: {link}")
    if not parsed.scheme and not parsed.netloc:
        if parsed.path and not (ROOT / unquote(parsed.path)).is_file():
            raise SystemExit(f"Missing static asset: {link}")
        if not parsed.path and parsed.fragment and parsed.fragment not in page.ids:
            raise SystemExit(f"Broken page anchor: {link}")
    if parsed.netloc == "github.com" and parsed.path.startswith(REPOSITORY):
        relative = parsed.path[len(REPOSITORY):]
        for prefix in ("blob/main/", "tree/main/", f"blob/{SNAPSHOT}/"):
            if relative.startswith(prefix):
                target = unquote(relative[len(prefix):])
                if not (ROOT / target).exists():
                    raise SystemExit(f"Missing repository target: {link}")
                if prefix == f"blob/{SNAPSHOT}/" and target.endswith(".lean"):
                    catalogue.add(target)
if catalogue != modules or page.rows != len(modules):
    raise SystemExit(f"Catalogue mismatch: missing={modules-catalogue}, extra={catalogue-modules}, rows={page.rows}")
for filename in ("site-assets/site.js",):
    for element_id in re.findall(r"getElementById\('([^']+)'\)", (ROOT / filename).read_text()):
        if element_id not in page.ids:
            raise SystemExit(f"Script references missing element: {element_id}")
if "<!-- MODULE_" in text:
    raise SystemExit("Unfilled module catalogue placeholder")
print(f"SITE_CHECK_PASS {len(modules)} source links; {len(page.ids)} unique IDs; {len(page.links)} links/assets checked")
