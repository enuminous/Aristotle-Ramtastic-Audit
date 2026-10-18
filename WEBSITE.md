# Website

[index.html](index.html) is the buildless explainer, findings dashboard, rotation
lab, six-step tutorial, and searchable index of all 83 source/audit modules.
The [README](README.md) remains the GitHub project entry point.

## Publishing

The public address is
<https://enuminous.github.io/Aristotle-Ramtastic-Audit/>.
GitHub Pages is enabled with automatic branch publishing. The initial site
deployment for commit `31cb918` passed in
[run 39088335948](https://github.com/enuminous/Aristotle-Ramtastic-Audit/actions/runs/39088335948).
The root `.nojekyll` file makes this a static publication.

The separate
[Website checks and Pages deployment](https://github.com/enuminous/Aristotle-Ramtastic-Audit/actions/workflows/pages.yml)
workflow validates the website. In branch-publishing mode it leaves deployment
to GitHub's automatic Pages workflow. It can also deploy the site itself if
the repository's **Settings → Pages → Build and deployment → Source** is changed
to **GitHub Actions**; run the workflow once after changing that setting.
If Pages is disabled, it reports the required setup and skips deployment.
A successful preparation job alone does not mean a website has been deployed.

The standalone workflow deploys only `index.html`, `.nojekyll`, and
`site-assets/`. Branch publishing serves the configured repository source;
the website's proof and document links point to GitHub in either mode.
No build system, external font, tracking script, account, or application secret
is required.

## Evidence and interaction

The published verification snapshot is commit
`03ac2c354b532a93d27e43187c6e2d02a7cd3b59`, workflow run `39086806863`, attempt 1.
The module catalogue links to that immutable source. Most narrative links point
to current documentation. Historical counts remain explicitly dated.

JavaScript separately requests the latest `main` push run from GitHub's public
API, using `cache: no-store`. Running, cancelled, failed, unavailable, and passed
results have distinct labels. Network or rate-limit failures never become passes.
An existing successful reference run is never silently relabeled as a live result.

The rotation lab numerically illustrates `J_a(x,y)=(-ay,x/a)` for `a=1` or `2`.
For the starting vector `(1,0)`, its orbit is `(cos θ, sin θ/a)`. Euclidean
squared length is `cos² θ + sin² θ/a²`; the adapted squared length
`x² + a²y²` is 1. These browser calculations are illustrations, not Lean proofs.
The exact `a=2` quarter-turn counterexample is linked to `ZooProbes.lean`.

The tutorial and full source catalogue are present in the HTML without
JavaScript. JavaScript adds lesson navigation, search/filtering, copy controls,
the plot controls, and live workflow status. The layout includes responsive
breakpoints, keyboard focus styles, a skip link, and reduced-motion handling.

## Maintaining the site

Run:

```sh
python3 scripts/check_site.py
node --check site-assets/rotation.js
node --check site-assets/site.js
python3 scripts/check_project.py
```

The site check verifies unique IDs, balanced tags, local assets and anchors,
repository-relative file destinations, JavaScript element references, and exact
agreement between the 83-entry catalogue and source-module paths. When source
coverage changes, review the catalogue and verification snapshot together.

Original Ramtastic remains credited to Chris Forrester; the two-path rotation
paper is labeled a discussion draft with coauthorship approval unrecorded.
The separate 52-theorem BSD package remains outside this project's build totals.
