'use strict';
document.documentElement.classList.add('js');

// The module catalogue and tutorial remain readable without JavaScript.
const angle = document.getElementById('angle');
function drawRotation() {
  const a = Number(document.querySelector('input[name="hinge-mode"]:checked').value);
  const degrees = Number(angle.value);
  const p = RotationModel.point(degrees, a);
  const cx = 270, cy = 190, scale = 135;
  const x = cx + p.x * scale, y = cy - p.y * scale;
  document.getElementById('orbit-path').setAttribute('ry', String(scale/a));
  document.getElementById('orbit-point').setAttribute('cx', String(x));
  document.getElementById('orbit-point').setAttribute('cy', String(y));
  document.getElementById('orbit-radius').setAttribute('x2', String(x));
  document.getElementById('orbit-radius').setAttribute('y2', String(y));
  document.getElementById('angle-value').textContent = degrees + '°';
  document.getElementById('norm-value').textContent = p.euclideanSquared.toFixed(3);
  document.getElementById('adapted-value').textContent = p.adaptedSquared.toFixed(3);
  document.getElementById('metric-label').textContent = a === 1 ? 'Adapted metric: x² + y²' : 'Adapted metric: x² + 4y²';
  document.getElementById('plot-description').textContent = 'At ' + degrees + ' degrees with a = ' + a + ', the point is (' + p.x.toFixed(3) + ', ' + p.y.toFixed(3) + '). Euclidean squared length is ' + p.euclideanSquared.toFixed(3) + '.';
  document.getElementById('metric-note').textContent = a === 1
    ? 'Here J preserves the Euclidean metric. The orbit is a unit circle and both squared lengths stay at 1.'
    : 'Here J² = −I still holds, but the Euclidean orbit is an ellipse. The adapted metric stays constant. At 90°, the Euclidean squared length is exactly 1/4.';
}
angle.addEventListener('input', drawRotation);
document.querySelectorAll('input[name="hinge-mode"]').forEach(el => el.addEventListener('change', drawRotation));
document.querySelectorAll('[data-angle]').forEach(el => el.addEventListener('click', () => {angle.value = el.dataset.angle; drawRotation();}));
drawRotation();

const lessons = [...document.querySelectorAll('.lesson')];
const lessonButtons = [...document.querySelectorAll('[data-lesson]')];
let lessonIndex = 0;
function showLesson(index) {
  lessonIndex = Math.min(lessons.length - 1, Math.max(0, index));
  lessons.forEach((el, i) => {el.hidden = i !== lessonIndex;});
  lessonButtons.forEach((el, i) => {if (i === lessonIndex) el.setAttribute('aria-current', 'step'); else el.removeAttribute('aria-current');});
  document.getElementById('lesson-count').textContent = 'Step ' + (lessonIndex + 1) + ' of ' + lessons.length;
  document.getElementById('lesson-prev').disabled = lessonIndex === 0;
  document.getElementById('lesson-next').disabled = lessonIndex === lessons.length - 1;
}
lessonButtons.forEach(el => el.addEventListener('click', () => showLesson(Number(el.dataset.lesson))));
document.getElementById('lesson-prev').addEventListener('click', () => showLesson(lessonIndex - 1));
document.getElementById('lesson-next').addEventListener('click', () => showLesson(lessonIndex + 1));
showLesson(0);

const search = document.getElementById('module-search');
const family = document.getElementById('module-family');
const moduleRows = [...document.querySelectorAll('#module-table tbody tr')];
function filterModules() {
  const query = search.value.trim().toLowerCase();
  let visible = 0;
  moduleRows.forEach(row => {
    const match = row.dataset.search.includes(query) && (!family.value || row.dataset.family === family.value);
    row.hidden = !match;
    if (match) visible++;
  });
  document.getElementById('module-count').textContent = visible + ' of ' + moduleRows.length + ' modules shown';
  document.getElementById('module-empty').hidden = visible !== 0;
}
search.addEventListener('input', filterModules);
family.addEventListener('change', filterModules);

const copyButton = document.getElementById('copy-command');
copyButton.addEventListener('click', async () => {
  const status = document.getElementById('copy-status');
  try {
    await navigator.clipboard.writeText(document.getElementById('reproduce-command').textContent);
    status.textContent = 'Commands copied.';
  } catch (_) {
    status.textContent = 'Select the commands above and copy them manually.';
  }
});

// Live API state is deliberately separate from the immutable verification record.
const statusBox = document.getElementById('live-status');
const statusButton = document.getElementById('refresh-status');
async function refreshStatus() {
  statusButton.disabled = true;
  const title = document.getElementById('live-status-title');
  const detail = document.getElementById('live-status-detail');
  const link = document.getElementById('live-status-link');
  title.textContent = 'Checking latest main run…';
  statusBox.dataset.state = 'pending';
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), 8000);
  try {
    const response = await fetch('https://api.github.com/repos/enuminous/Aristotle-Ramtastic-Audit/actions/workflows/verify.yml/runs?branch=main&event=push&per_page=1', {cache:'no-store', signal:controller.signal, headers:{'Accept':'application/vnd.github+json'}});
    if (!response.ok) throw new Error('Status unavailable');
    const data = await response.json();
    const run = data.workflow_runs && data.workflow_runs[0];
    if (!run || !run.head_sha || typeof run.html_url !== 'string' || !run.html_url.startsWith('https://github.com/enuminous/Aristotle-Ramtastic-Audit/actions/runs/')) throw new Error('No valid run');
    const state = run.status === 'completed' ? run.conclusion : run.status;
    const labels = {success:'Latest main run passed', failure:'Latest main run failed', cancelled:'Latest main run was cancelled', timed_out:'Latest main run timed out', in_progress:'Latest main run is running', queued:'Latest main run is queued', waiting:'Latest main run is waiting', action_required:'Latest main run needs action', skipped:'Latest main run was skipped'};
    title.textContent = labels[state] || 'Latest main run: ' + state;
    statusBox.dataset.state = state === 'success' ? 'success' : (['failure','timed_out','action_required'].includes(state) ? 'failure' : 'pending');
    detail.textContent = 'Commit ' + run.head_sha.slice(0,7) + ' · attempt ' + run.run_attempt + ' · checked ' + new Date().toLocaleTimeString([], {hour:'2-digit',minute:'2-digit'}) + '. This live result is separate from the reference snapshot above.';
    link.href = run.html_url;
    link.textContent = 'Open this workflow run ↗';
  } catch (_) {
    title.textContent = 'Live status unavailable';
    detail.textContent = 'GitHub may be offline or rate-limiting requests. The recorded passing run above remains linked; no current result is being assumed.';
    statusBox.dataset.state = 'unknown';
    link.href = 'https://github.com/enuminous/Aristotle-Ramtastic-Audit/actions/workflows/verify.yml';
    link.textContent = 'Check GitHub Actions directly ↗';
  } finally {
    clearTimeout(timer);
    statusButton.disabled = false;
  }
}
statusButton.addEventListener('click', refreshStatus);
refreshStatus();
