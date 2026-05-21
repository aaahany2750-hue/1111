const displayEl = document.getElementById('display');
const expressionEl = document.getElementById('expression');

let expression = '';
let lastAnswer = 0;
let angleMode = 'DEG';

function toRadians(x) {
  return angleMode === 'DEG' ? (x * Math.PI) / 180 : x;
}

function fromRadians(x) {
  return angleMode === 'DEG' ? (x * 180) / Math.PI : x;
}

function factorial(n) {
  if (!Number.isFinite(n) || n < 0 || !Number.isInteger(n)) throw new Error('Invalid factorial');
  let result = 1;
  for (let i = 2; i <= n; i += 1) result *= i;
  return result;
}

function replaceOperators(input) {
  let out = input;
  out = out.replace(/Ans/g, `(${lastAnswer})`);
  out = out.replace(/PI/g, 'Math.PI');
  out = out.replace(/\bE\b/g, 'Math.E');

  out = out.replace(/sin\(([^()]*)\)/g, (_, a) => `Math.sin(toRadians(${a}))`);
  out = out.replace(/cos\(([^()]*)\)/g, (_, a) => `Math.cos(toRadians(${a}))`);
  out = out.replace(/tan\(([^()]*)\)/g, (_, a) => `Math.tan(toRadians(${a}))`);
  out = out.replace(/asin\(([^()]*)\)/g, (_, a) => `fromRadians(Math.asin(${a}))`);
  out = out.replace(/acos\(([^()]*)\)/g, (_, a) => `fromRadians(Math.acos(${a}))`);
  out = out.replace(/atan\(([^()]*)\)/g, (_, a) => `fromRadians(Math.atan(${a}))`);
  out = out.replace(/log\(([^()]*)\)/g, (_, a) => `Math.log10(${a})`);
  out = out.replace(/ln\(([^()]*)\)/g, (_, a) => `Math.log(${a})`);
  out = out.replace(/sqrt\(([^()]*)\)/g, (_, a) => `Math.sqrt(${a})`);
  out = out.replace(/abs\(([^()]*)\)/g, (_, a) => `Math.abs(${a})`);
  out = out.replace(/exp\(([^()]*)\)/g, (_, a) => `Math.pow(10,${a})`);

  out = out.replace(/(\d+(?:\.\d+)?)!/g, (_, a) => `factorial(${a})`);
  out = out.replace(/\^/g, '**');
  out = out.replace(/%/g, '/100');
  return out;
}

function safeEval(input) {
  const transformed = replaceOperators(input);
  const evaluator = new Function('toRadians', 'fromRadians', 'factorial', `return (${transformed});`);
  const result = evaluator(toRadians, fromRadians, factorial);
  if (!Number.isFinite(result)) throw new Error('Math error');
  return result;
}

function render(value = null) {
  expressionEl.textContent = `${angleMode}  ${expression}`;
  displayEl.textContent = value ?? (expression || '0');
}

function append(text) {
  expression += text;
  render();
}

function evaluate() {
  try {
    const result = safeEval(expression);
    lastAnswer = result;
    render(Number(result.toFixed(12)).toString());
    expression = Number(result.toFixed(12)).toString();
  } catch {
    render('خطأ');
  }
}

document.querySelector('.controls').addEventListener('click', (e) => {
  const btn = e.target.closest('button');
  if (!btn) return;

  if (btn.dataset.digit) return append(btn.dataset.digit);
  if (btn.dataset.value) return append(btn.dataset.value);
  if (btn.dataset.op) return append(btn.dataset.op);
  if (btn.dataset.const) return append(btn.dataset.const);
  if (btn.dataset.func) return append(`${btn.dataset.func}(`);

  const action = btn.dataset.action;
  if (action === 'clear') { expression = ''; return render(); }
  if (action === 'delete') { expression = expression.slice(0, -1); return render(); }
  if (action === 'equals') return evaluate();
  if (action === 'ans') return append('Ans');
  if (action === 'mode-deg') { angleMode = 'DEG'; return render(); }
  if (action === 'mode-rad') { angleMode = 'RAD'; return render(); }
});

window.addEventListener('keydown', (e) => {
  if (/^[0-9.+\-*/()%^]$/.test(e.key)) append(e.key);
  if (e.key === 'Enter') evaluate();
  if (e.key === 'Backspace') { expression = expression.slice(0, -1); render(); }
  if (e.key === 'Escape') { expression = ''; render(); }
});

render();
