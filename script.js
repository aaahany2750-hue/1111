/*
  Study Legends
  -------------
  A pure JavaScript gamified study tracker. The app intentionally avoids a
  backend or account system; every piece of progress is serialized into
  LocalStorage so the experience works as a private, single-device quest log.
*/

const STORAGE_KEY = 'studyLegendsSaveV1';
const XP_PER_MINUTE = 10;
const GOLD_PER_MINUTE = 3;
const BOSS_DAMAGE_PER_MINUTE = 10;
const BASE_BOSS_HP = 1000;
const TIMER_TICK_MS = 1000;

const bossNames = [
  'The Deadline Wraith',
  'The Procrastination Drake',
  'The Chaos Lich',
  'The Exam Hydra',
  'The Distractor Demon',
];

const achievements = [
  {
    id: 'first_quest',
    icon: '⚔️',
    title: 'First Quest',
    description: 'Complete your first study session.',
    isUnlocked: (state) => state.sessions >= 1,
  },
  {
    id: 'apprentice_focus',
    icon: '📜',
    title: 'Apprentice Focus',
    description: 'Study for 30 total minutes.',
    isUnlocked: (state) => state.totalStudySeconds >= 30 * 60,
  },
  {
    id: 'gold_hoarder',
    icon: '🪙',
    title: 'Gold Hoarder',
    description: 'Collect 100 gold.',
    isUnlocked: (state) => state.gold >= 100,
  },
  {
    id: 'level_five',
    icon: '🧙',
    title: 'Arcane Adept',
    description: 'Reach level 5.',
    isUnlocked: (state) => state.level >= 5,
  },
  {
    id: 'streak_three',
    icon: '🔥',
    title: 'Three-Day Flame',
    description: 'Build a 3-day study streak.',
    isUnlocked: (state) => state.streak >= 3,
  },
  {
    id: 'boss_slayer',
    icon: '🐉',
    title: 'Boss Slayer',
    description: 'Defeat one weekly boss.',
    isUnlocked: (state) => state.bossesDefeated >= 1,
  },
  {
    id: 'deep_work',
    icon: '🔮',
    title: 'Deep Work Ritual',
    description: 'Complete a session of at least 60 minutes.',
    isUnlocked: (state) => state.longestSessionSeconds >= 60 * 60,
  },
  {
    id: 'legendary_scholar',
    icon: '👑',
    title: 'Legendary Scholar',
    description: 'Study for 10 total hours.',
    isUnlocked: (state) => state.totalStudySeconds >= 10 * 60 * 60,
  },
];

const defaultState = {
  level: 1,
  xp: 0,
  totalXp: 0,
  gold: 0,
  totalStudySeconds: 0,
  todayStudySeconds: 0,
  bestDaySeconds: 0,
  sessions: 0,
  longestSessionSeconds: 0,
  streak: 0,
  lastStudyDate: null,
  currentDate: getDateKey(),
  weekKey: getWeekKey(),
  bossHp: BASE_BOSS_HP,
  bossesDefeated: 0,
  unlockedAchievements: [],
  soundEnabled: true,
};

let state = loadState();
let timer = {
  isRunning: false,
  startedAt: null,
  accumulatedSeconds: 0,
  intervalId: null,
};

const elements = {
  soundToggle: document.getElementById('soundToggle'),
  resetButton: document.getElementById('resetButton'),
  heroTitle: document.getElementById('heroTitle'),
  levelBadge: document.getElementById('levelBadge'),
  xpText: document.getElementById('xpText'),
  xpBar: document.getElementById('xpBar'),
  goldValue: document.getElementById('goldValue'),
  streakValue: document.getElementById('streakValue'),
  totalStudyValue: document.getElementById('totalStudyValue'),
  sessionsValue: document.getElementById('sessionsValue'),
  timerDisplay: document.getElementById('timerDisplay'),
  timerStatus: document.getElementById('timerStatus'),
  startButton: document.getElementById('startButton'),
  pauseButton: document.getElementById('pauseButton'),
  stopButton: document.getElementById('stopButton'),
  sessionStudyValue: document.getElementById('sessionStudyValue'),
  projectedRewardValue: document.getElementById('projectedRewardValue'),
  bossName: document.getElementById('bossName'),
  weekLabel: document.getElementById('weekLabel'),
  bossHpText: document.getElementById('bossHpText'),
  bossHpBar: document.getElementById('bossHpBar'),
  bossMessage: document.getElementById('bossMessage'),
  todayStudyValue: document.getElementById('todayStudyValue'),
  bestDayValue: document.getElementById('bestDayValue'),
  averageSessionValue: document.getElementById('averageSessionValue'),
  bossesDefeatedValue: document.getElementById('bossesDefeatedValue'),
  achievementCount: document.getElementById('achievementCount'),
  achievementsList: document.getElementById('achievementsList'),
  toast: document.getElementById('toast'),
};

/** Reads the saved game and repairs older or malformed values defensively. */
function loadState() {
  try {
    const saved = JSON.parse(localStorage.getItem(STORAGE_KEY));
    if (!saved || typeof saved !== 'object') return { ...defaultState };
    return normalizeState({ ...defaultState, ...saved });
  } catch {
    return { ...defaultState };
  }
}

/** Ensures daily and weekly counters are current whenever the app opens. */
function normalizeState(nextState) {
  const today = getDateKey();
  const week = getWeekKey();

  if (nextState.currentDate !== today) {
    nextState.bestDaySeconds = Math.max(nextState.bestDaySeconds || 0, nextState.todayStudySeconds || 0);
    nextState.todayStudySeconds = 0;
    nextState.currentDate = today;
  }

  // A streak is only active when the learner studied today or yesterday.
  if (nextState.lastStudyDate && ![today, getYesterdayKey()].includes(nextState.lastStudyDate)) {
    nextState.streak = 0;
  }

  if (nextState.weekKey !== week) {
    nextState.weekKey = week;
    nextState.bossHp = BASE_BOSS_HP;
  }

  nextState.unlockedAchievements = Array.isArray(nextState.unlockedAchievements)
    ? nextState.unlockedAchievements
    : [];

  return nextState;
}

/** Persists the entire quest log to LocalStorage. */
function saveState() {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
}

/** Formats the user's local day as YYYY-MM-DD for streak logic. */
function getDateKey(date = new Date()) {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
}

/** Returns an ISO-like week key so a fresh boss appears every Monday. */
function getWeekKey(date = new Date()) {
  const copy = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()));
  const dayNumber = copy.getUTCDay() || 7;
  copy.setUTCDate(copy.getUTCDate() + 4 - dayNumber);
  const yearStart = new Date(Date.UTC(copy.getUTCFullYear(), 0, 1));
  const weekNumber = Math.ceil((((copy - yearStart) / 86400000) + 1) / 7);
  return `${copy.getUTCFullYear()}-W${String(weekNumber).padStart(2, '0')}`;
}

function getYesterdayKey() {
  const yesterday = new Date();
  yesterday.setDate(yesterday.getDate() - 1);
  return getDateKey(yesterday);
}

function xpForLevel(level) {
  return Math.round(100 * Math.pow(level, 1.35));
}

function getHeroTitle(level) {
  if (level >= 20) return 'Mythic Lorekeeper';
  if (level >= 15) return 'Archmage Scholar';
  if (level >= 10) return 'Runebound Sage';
  if (level >= 5) return 'Arcane Adept';
  return 'Novice Scribe';
}

function getCurrentSessionSeconds() {
  if (!timer.isRunning || !timer.startedAt) return timer.accumulatedSeconds;
  return timer.accumulatedSeconds + Math.floor((Date.now() - timer.startedAt) / 1000);
}

function formatClock(totalSeconds) {
  const hours = Math.floor(totalSeconds / 3600);
  const minutes = Math.floor((totalSeconds % 3600) / 60);
  const seconds = totalSeconds % 60;
  return [hours, minutes, seconds].map((part) => String(part).padStart(2, '0')).join(':');
}

function formatDuration(totalSeconds) {
  const hours = Math.floor(totalSeconds / 3600);
  const minutes = Math.floor((totalSeconds % 3600) / 60);
  const seconds = totalSeconds % 60;

  if (hours > 0) return `${hours}h ${minutes}m`;
  if (minutes > 0) return `${minutes}m ${seconds}s`;
  return `${seconds}s`;
}

function formatWholeMinutes(totalSeconds) {
  const minutes = Math.floor(totalSeconds / 60);
  const hours = Math.floor(minutes / 60);
  const remainingMinutes = minutes % 60;
  return hours > 0 ? `${hours}h ${remainingMinutes}m` : `${minutes}m`;
}

function getRewardPreview(seconds) {
  const minutes = Math.floor(seconds / 60);
  return {
    xp: minutes * XP_PER_MINUTE,
    gold: minutes * GOLD_PER_MINUTE,
    damage: minutes * BOSS_DAMAGE_PER_MINUTE,
  };
}

function startTimer() {
  if (timer.isRunning) return;

  timer.isRunning = true;
  timer.startedAt = Date.now();
  timer.intervalId = window.setInterval(renderTimer, TIMER_TICK_MS);

  elements.timerStatus.textContent = timer.accumulatedSeconds > 0 ? 'Quest resumed' : 'Studying...';
  elements.startButton.disabled = true;
  elements.pauseButton.disabled = false;
  elements.stopButton.disabled = false;
  playTone(540, 0.08, 'sine');
  renderTimer();
}

function pauseTimer() {
  if (!timer.isRunning) return;

  timer.accumulatedSeconds = getCurrentSessionSeconds();
  timer.isRunning = false;
  timer.startedAt = null;
  window.clearInterval(timer.intervalId);

  elements.timerStatus.textContent = 'Paused';
  elements.startButton.disabled = false;
  elements.pauseButton.disabled = true;
  elements.stopButton.disabled = false;
  playTone(330, 0.08, 'triangle');
  renderTimer();
}

function stopTimer() {
  const sessionSeconds = getCurrentSessionSeconds();
  window.clearInterval(timer.intervalId);

  timer = {
    isRunning: false,
    startedAt: null,
    accumulatedSeconds: 0,
    intervalId: null,
  };

  elements.startButton.disabled = false;
  elements.pauseButton.disabled = true;
  elements.stopButton.disabled = true;

  if (sessionSeconds < 1) {
    elements.timerStatus.textContent = 'Ready to begin';
    renderTimer();
    return;
  }

  completeStudySession(sessionSeconds);
  elements.timerStatus.textContent = 'Quest completed';
  renderTimer();
}

/** Converts real elapsed seconds into XP, gold, boss damage, stats, and streaks. */
function completeStudySession(sessionSeconds) {
  refreshCalendarBoundaries();

  const rewards = getRewardPreview(sessionSeconds);
  state.sessions += 1;
  state.totalStudySeconds += sessionSeconds;
  state.todayStudySeconds += sessionSeconds;
  state.bestDaySeconds = Math.max(state.bestDaySeconds, state.todayStudySeconds);
  state.longestSessionSeconds = Math.max(state.longestSessionSeconds, sessionSeconds);
  state.gold += rewards.gold;
  state.xp += rewards.xp;
  state.totalXp += rewards.xp;

  updateStreak();
  applyBossDamage(rewards.damage);
  applyLevelUps();

  saveState();
  renderAll();
  checkAchievements();
  showToast(`Quest complete: ${formatDuration(sessionSeconds)} studied, +${rewards.xp} XP, +${rewards.gold} gold.`);
  playTone(740, 0.09, 'sine');
  setTimeout(() => playTone(930, 0.11, 'sine'), 90);
}

function refreshCalendarBoundaries() {
  state = normalizeState(state);
}

function updateStreak() {
  const today = getDateKey();
  const yesterday = getYesterdayKey();

  if (state.lastStudyDate === today) {
    return;
  }

  state.streak = state.lastStudyDate === yesterday ? state.streak + 1 : 1;
  state.lastStudyDate = today;
}

function applyBossDamage(damage) {
  if (damage <= 0) return;

  state.bossHp = Math.max(0, state.bossHp - damage);

  if (state.bossHp === 0) {
    state.bossesDefeated += 1;
    state.gold += 100;
    state.xp += 150;
    state.totalXp += 150;
    state.bossHp = BASE_BOSS_HP;
    showToast('Weekly boss defeated! Bonus reward: +150 XP and +100 gold.');
  }
}

function applyLevelUps() {
  let requiredXp = xpForLevel(state.level);
  let leveledUp = false;

  while (state.xp >= requiredXp) {
    state.xp -= requiredXp;
    state.level += 1;
    requiredXp = xpForLevel(state.level);
    leveledUp = true;
  }

  if (leveledUp) {
    showToast(`Level up! You are now level ${state.level}: ${getHeroTitle(state.level)}.`);
    playTone(1040, 0.14, 'triangle');
  }
}

function checkAchievements() {
  const newlyUnlocked = achievements.filter((achievement) => (
    !state.unlockedAchievements.includes(achievement.id) && achievement.isUnlocked(state)
  ));

  if (newlyUnlocked.length === 0) {
    renderAchievements();
    saveState();
    return;
  }

  newlyUnlocked.forEach((achievement, index) => {
    state.unlockedAchievements.push(achievement.id);
    setTimeout(() => showToast(`Achievement unlocked: ${achievement.title}!`), index * 500);
  });

  saveState();
  renderAchievements();
}

function renderTimer() {
  const sessionSeconds = getCurrentSessionSeconds();
  const preview = getRewardPreview(sessionSeconds);

  elements.timerDisplay.textContent = formatClock(sessionSeconds);
  elements.sessionStudyValue.textContent = formatDuration(sessionSeconds);
  elements.projectedRewardValue.textContent = `+${preview.xp} XP · +${preview.gold} Gold`;
}

function renderAll() {
  refreshCalendarBoundaries();

  const requiredXp = xpForLevel(state.level);
  const xpPercent = Math.min(100, (state.xp / requiredXp) * 100);
  const bossPercent = Math.max(0, Math.min(100, (state.bossHp / BASE_BOSS_HP) * 100));
  const averageSession = state.sessions > 0 ? state.totalStudySeconds / state.sessions : 0;
  const bossIndex = Math.abs(hashString(state.weekKey)) % bossNames.length;

  elements.heroTitle.textContent = getHeroTitle(state.level);
  elements.levelBadge.textContent = `Lv. ${state.level}`;
  elements.xpText.textContent = `${state.xp.toLocaleString()} / ${requiredXp.toLocaleString()} XP`;
  elements.xpBar.style.width = `${xpPercent}%`;
  elements.xpBar.parentElement.setAttribute('aria-valuenow', Math.round(xpPercent));

  elements.goldValue.textContent = `${state.gold.toLocaleString()} 🪙`;
  elements.streakValue.textContent = `${state.streak} ${state.streak === 1 ? 'day' : 'days'} 🔥`;
  elements.totalStudyValue.textContent = formatWholeMinutes(state.totalStudySeconds);
  elements.sessionsValue.textContent = state.sessions.toLocaleString();

  elements.bossName.textContent = bossNames[bossIndex];
  elements.weekLabel.textContent = state.weekKey;
  elements.bossHpText.textContent = `${state.bossHp.toLocaleString()} / ${BASE_BOSS_HP.toLocaleString()} HP`;
  elements.bossHpBar.style.width = `${bossPercent}%`;
  elements.bossHpBar.parentElement.setAttribute('aria-valuenow', state.bossHp);
  elements.bossMessage.textContent = state.bossHp === BASE_BOSS_HP
    ? 'Every focused minute deals 10 damage. Defeat the boss before the week resets!'
    : `The boss has taken ${(BASE_BOSS_HP - state.bossHp).toLocaleString()} damage this week.`;

  elements.todayStudyValue.textContent = formatWholeMinutes(state.todayStudySeconds);
  elements.bestDayValue.textContent = formatWholeMinutes(state.bestDaySeconds);
  elements.averageSessionValue.textContent = formatWholeMinutes(averageSession);
  elements.bossesDefeatedValue.textContent = state.bossesDefeated.toLocaleString();

  elements.soundToggle.textContent = state.soundEnabled ? '🔊 Sound On' : '🔇 Sound Off';
  elements.soundToggle.setAttribute('aria-pressed', String(state.soundEnabled));

  renderAchievements();
  renderTimer();
  saveState();
}

function renderAchievements() {
  elements.achievementsList.innerHTML = '';

  achievements.forEach((achievement) => {
    const unlocked = state.unlockedAchievements.includes(achievement.id) || achievement.isUnlocked(state);
    const item = document.createElement('article');
    item.className = `achievement${unlocked ? ' unlocked' : ''}`;
    item.innerHTML = `
      <span class="achievement-icon" aria-hidden="true">${achievement.icon}</span>
      <div>
        <h3>${achievement.title}</h3>
        <p>${achievement.description}</p>
      </div>
      <span class="achievement-state">${unlocked ? '✓' : '—'}</span>
    `;
    elements.achievementsList.appendChild(item);
  });

  const unlockedCount = achievements.filter((achievement) => (
    state.unlockedAchievements.includes(achievement.id) || achievement.isUnlocked(state)
  )).length;

  elements.achievementCount.textContent = `${unlockedCount} / ${achievements.length}`;
}

function hashString(value) {
  return value.split('').reduce((hash, character) => ((hash << 5) - hash) + character.charCodeAt(0), 0);
}

let toastTimeout;
function showToast(message) {
  elements.toast.textContent = message;
  elements.toast.classList.add('show');
  window.clearTimeout(toastTimeout);
  toastTimeout = window.setTimeout(() => elements.toast.classList.remove('show'), 3800);
}

/** Tiny generated audio cues avoid external files and respect the sound toggle. */
function playTone(frequency, duration, type = 'sine') {
  if (!state.soundEnabled) return;

  const AudioContext = window.AudioContext || window.webkitAudioContext;
  if (!AudioContext) return;

  const context = new AudioContext();
  const oscillator = context.createOscillator();
  const gain = context.createGain();

  oscillator.type = type;
  oscillator.frequency.value = frequency;
  gain.gain.setValueAtTime(0.0001, context.currentTime);
  gain.gain.exponentialRampToValueAtTime(0.08, context.currentTime + 0.01);
  gain.gain.exponentialRampToValueAtTime(0.0001, context.currentTime + duration);

  oscillator.connect(gain);
  gain.connect(context.destination);
  oscillator.start();
  oscillator.stop(context.currentTime + duration + 0.02);
  oscillator.addEventListener('ended', () => context.close());
}

function toggleSound() {
  state.soundEnabled = !state.soundEnabled;
  saveState();
  renderAll();
  if (state.soundEnabled) playTone(620, 0.08, 'sine');
}

function resetProgress() {
  const confirmed = window.confirm('Reset all Study Legends progress on this device? This cannot be undone.');
  if (!confirmed) return;

  window.clearInterval(timer.intervalId);
  timer = {
    isRunning: false,
    startedAt: null,
    accumulatedSeconds: 0,
    intervalId: null,
  };
  state = { ...defaultState, currentDate: getDateKey(), weekKey: getWeekKey() };
  saveState();

  elements.startButton.disabled = false;
  elements.pauseButton.disabled = true;
  elements.stopButton.disabled = true;
  elements.timerStatus.textContent = 'Ready to begin';
  renderAll();
  showToast('Quest log reset. A new legend begins.');
}

function bindEvents() {
  elements.startButton.addEventListener('click', startTimer);
  elements.pauseButton.addEventListener('click', pauseTimer);
  elements.stopButton.addEventListener('click', stopTimer);
  elements.soundToggle.addEventListener('click', toggleSound);
  elements.resetButton.addEventListener('click', resetProgress);

  document.addEventListener('visibilitychange', () => {
    // Real study time keeps accruing while the tab is hidden; this redraws the
    // timer immediately when the learner returns instead of relying on old ticks.
    if (!document.hidden) renderTimer();
  });

  window.addEventListener('beforeunload', () => {
    if (timer.isRunning) {
      timer.accumulatedSeconds = getCurrentSessionSeconds();
      timer.startedAt = Date.now();
    }
  });
}

bindEvents();
renderAll();
checkAchievements();
