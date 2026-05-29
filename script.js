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
  'شبح التسويف',
  'تنين المماطلة',
  'ساحر الفوضى',
  'هيدرا الامتحانات',
  'شيطان المشتتات',
];

const achievements = [
  {
    id: 'first_quest',
    icon: '⚔️',
    title: 'أول مهمة',
    description: 'أنهِ أول جلسة مذاكرة.',
    isUnlocked: (state) => state.sessions >= 1,
  },
  {
    id: 'apprentice_focus',
    icon: '📜',
    title: 'متدرب التركيز',
    description: 'ذاكر 30 دقيقة إجمالًا.',
    isUnlocked: (state) => state.totalStudySeconds >= 30 * 60,
  },
  {
    id: 'daily_champion',
    icon: '🎯',
    title: 'بطل الهدف اليومي',
    description: 'أكمل هدف المذاكرة اليومي مرة واحدة.',
    isUnlocked: (state) => state.dailyGoalCompletions >= 1,
  },
  {
    id: 'subject_master',
    icon: '📚',
    title: 'سيد المواد',
    description: 'سجّل جلسات في 3 مواد مختلفة.',
    isUnlocked: (state) => Object.keys(state.subjectTotals || {}).length >= 3,
  },
  {
    id: 'gold_hoarder',
    icon: '🪙',
    title: 'جامع الذهب',
    description: 'اجمع 100 قطعة ذهب.',
    isUnlocked: (state) => state.gold >= 100,
  },
  {
    id: 'level_five',
    icon: '🧙',
    title: 'بارع السحر',
    description: 'صل إلى المستوى 5.',
    isUnlocked: (state) => state.level >= 5,
  },
  {
    id: 'streak_three',
    icon: '🔥',
    title: 'شعلة ثلاثة أيام',
    description: 'كوّن سلسلة مذاكرة لمدة 3 أيام.',
    isUnlocked: (state) => state.streak >= 3,
  },
  {
    id: 'boss_slayer',
    icon: '🐉',
    title: 'قاهر الزعماء',
    description: 'اهزم زعيمًا أسبوعيًا واحدًا.',
    isUnlocked: (state) => state.bossesDefeated >= 1,
  },
  {
    id: 'deep_work',
    icon: '🔮',
    title: 'طقس العمل العميق',
    description: 'أنهِ جلسة مدتها 60 دقيقة على الأقل.',
    isUnlocked: (state) => state.longestSessionSeconds >= 60 * 60,
  },
  {
    id: 'legendary_scholar',
    icon: '👑',
    title: 'العالِم الأسطوري',
    description: 'ذاكر 10 ساعات إجمالًا.',
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
  dailyGoalMinutes: 120,
  dailyGoalCompletions: 0,
  lastDailyGoalCompletionDate: null,
  currentSubject: '',
  subjectTotals: {},
  sessionHistory: [],
};

function getFreshState() {
  return {
    ...defaultState,
    currentDate: getDateKey(),
    weekKey: getWeekKey(),
    unlockedAchievements: [],
    subjectTotals: {},
    sessionHistory: [],
  };
}

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
  subjectInput: document.getElementById('subjectInput'),
  dailyGoalInput: document.getElementById('dailyGoalInput'),
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
  dailyGoalText: document.getElementById('dailyGoalText'),
  dailyGoalBar: document.getElementById('dailyGoalBar'),
  historyList: document.getElementById('historyList'),
  historyEmpty: document.getElementById('historyEmpty'),
  achievementCount: document.getElementById('achievementCount'),
  achievementsList: document.getElementById('achievementsList'),
  toast: document.getElementById('toast'),
};

/** Reads the saved game and repairs older or malformed values defensively. */
function loadState() {
  try {
    const saved = JSON.parse(localStorage.getItem(STORAGE_KEY));
    if (!saved || typeof saved !== 'object') return getFreshState();
    return normalizeState({ ...getFreshState(), ...saved });
  } catch {
    return getFreshState();
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
  nextState.sessionHistory = Array.isArray(nextState.sessionHistory)
    ? nextState.sessionHistory.slice(0, 8)
    : [];
  nextState.subjectTotals = nextState.subjectTotals && typeof nextState.subjectTotals === 'object'
    ? nextState.subjectTotals
    : {};
  nextState.dailyGoalMinutes = clamp(Number(nextState.dailyGoalMinutes) || 120, 5, 720);

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
  if (level >= 20) return 'حافظ الأساطير';
  if (level >= 15) return 'ساحر المعرفة الأعظم';
  if (level >= 10) return 'حكيم الرونية';
  if (level >= 5) return 'بارع السحر';
  return 'كاتب مبتدئ';
}

function clamp(value, min, max) {
  return Math.min(max, Math.max(min, value));
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

  if (hours > 0) return `${hours}س ${minutes}د`;
  if (minutes > 0) return `${minutes}د ${seconds}ث`;
  return `${seconds}ث`;
}

function formatWholeMinutes(totalSeconds) {
  const minutes = Math.floor(totalSeconds / 60);
  const hours = Math.floor(minutes / 60);
  const remainingMinutes = minutes % 60;
  return hours > 0 ? `${hours}س ${remainingMinutes}د` : `${minutes}د`;
}

function getRewardPreview(seconds) {
  const minutes = Math.floor(seconds / 60);
  return {
    xp: minutes * XP_PER_MINUTE,
    gold: minutes * GOLD_PER_MINUTE,
    damage: minutes * BOSS_DAMAGE_PER_MINUTE,
  };
}

function getSessionSubject() {
  const rawSubject = elements.subjectInput.value.trim().replace(/\s+/g, ' ');
  return rawSubject || 'مذاكرة عامة';
}

function hasCompletedDailyGoal() {
  return state.todayStudySeconds >= state.dailyGoalMinutes * 60;
}

function applyDailyGoalCompletion(wasCompletedBeforeSession) {
  const today = getDateKey();
  if (wasCompletedBeforeSession || !hasCompletedDailyGoal() || state.lastDailyGoalCompletionDate === today) {
    return;
  }

  state.dailyGoalCompletions += 1;
  state.lastDailyGoalCompletionDate = today;
  state.gold += 25;
  state.xp += 50;
  state.totalXp += 50;
  showToast('اكتمل هدف اليوم! مكافأة إضافية: +50 XP و +25 ذهب.');
}

function startTimer() {
  if (timer.isRunning) return;

  timer.isRunning = true;
  timer.startedAt = Date.now();
  timer.intervalId = window.setInterval(renderTimer, TIMER_TICK_MS);

  elements.timerStatus.textContent = timer.accumulatedSeconds > 0 ? 'تم استئناف المهمة' : 'جاري المذاكرة...';
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

  elements.timerStatus.textContent = 'متوقف مؤقتًا';
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
    elements.timerStatus.textContent = 'جاهز للبدء';
    renderTimer();
    return;
  }

  completeStudySession(sessionSeconds);
  elements.timerStatus.textContent = 'تمت المهمة';
  renderTimer();
}

/** Converts real elapsed seconds into XP, gold, boss damage, stats, and streaks. */
function completeStudySession(sessionSeconds) {
  refreshCalendarBoundaries();

  const rewards = getRewardPreview(sessionSeconds);
  const subject = getSessionSubject();
  const completedGoalBefore = hasCompletedDailyGoal();

  state.sessions += 1;
  state.totalStudySeconds += sessionSeconds;
  state.todayStudySeconds += sessionSeconds;
  state.bestDaySeconds = Math.max(state.bestDaySeconds, state.todayStudySeconds);
  state.longestSessionSeconds = Math.max(state.longestSessionSeconds, sessionSeconds);
  state.gold += rewards.gold;
  state.xp += rewards.xp;
  state.totalXp += rewards.xp;
  state.subjectTotals[subject] = (state.subjectTotals[subject] || 0) + sessionSeconds;
  state.currentSubject = subject === 'مذاكرة عامة' ? '' : subject;
  state.sessionHistory = [
    {
      id: window.crypto?.randomUUID ? window.crypto.randomUUID() : `${Date.now()}`,
      subject,
      seconds: sessionSeconds,
      xp: rewards.xp,
      gold: rewards.gold,
      damage: rewards.damage,
      completedAt: new Date().toISOString(),
    },
    ...state.sessionHistory,
  ].slice(0, 8);

  updateStreak();
  applyBossDamage(rewards.damage);
  applyDailyGoalCompletion(completedGoalBefore);
  applyLevelUps();

  saveState();
  renderAll();
  checkAchievements();
  showToast(`تمت المهمة: ${formatDuration(sessionSeconds)} في ${subject}، +${rewards.xp} XP، +${rewards.gold} ذهب.`);
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
    showToast('تم هزيمة زعيم الأسبوع! مكافأة إضافية: +150 XP و +100 ذهب.');
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
    showToast(`ترقية مستوى! أصبحت الآن مستوى ${state.level}: ${getHeroTitle(state.level)}.`);
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
    setTimeout(() => showToast(`إنجاز جديد: ${achievement.title}!`), index * 500);
  });

  saveState();
  renderAchievements();
}

function renderTimer() {
  const sessionSeconds = getCurrentSessionSeconds();
  const preview = getRewardPreview(sessionSeconds);

  elements.timerDisplay.textContent = formatClock(sessionSeconds);
  elements.sessionStudyValue.textContent = formatDuration(sessionSeconds);
  elements.projectedRewardValue.textContent = `+${preview.xp} XP · +${preview.gold} ذهب`;
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
  elements.streakValue.textContent = `${state.streak} ${state.streak === 1 ? 'يوم' : 'أيام'} 🔥`;
  elements.totalStudyValue.textContent = formatWholeMinutes(state.totalStudySeconds);
  elements.sessionsValue.textContent = state.sessions.toLocaleString();
  elements.subjectInput.value = state.currentSubject;
  elements.dailyGoalInput.value = state.dailyGoalMinutes;

  elements.bossName.textContent = bossNames[bossIndex];
  elements.weekLabel.textContent = state.weekKey;
  elements.bossHpText.textContent = `${state.bossHp.toLocaleString()} / ${BASE_BOSS_HP.toLocaleString()} HP`;
  elements.bossHpBar.style.width = `${bossPercent}%`;
  elements.bossHpBar.parentElement.setAttribute('aria-valuenow', state.bossHp);
  elements.bossMessage.textContent = state.bossHp === BASE_BOSS_HP
    ? 'كل دقيقة تركيز تسبب 10 ضرر. اهزم الزعيم قبل بداية الأسبوع الجديد!'
    : `تلقى الزعيم ${(BASE_BOSS_HP - state.bossHp).toLocaleString()} ضرر هذا الأسبوع.`;

  elements.todayStudyValue.textContent = formatWholeMinutes(state.todayStudySeconds);
  elements.bestDayValue.textContent = formatWholeMinutes(state.bestDaySeconds);
  elements.averageSessionValue.textContent = formatWholeMinutes(averageSession);
  elements.bossesDefeatedValue.textContent = state.bossesDefeated.toLocaleString();

  elements.soundToggle.textContent = state.soundEnabled ? '🔊 الصوت يعمل' : '🔇 الصوت متوقف';
  elements.soundToggle.setAttribute('aria-pressed', String(state.soundEnabled));

  renderDailyGoal();
  renderHistory();
  renderAchievements();
  renderTimer();
  saveState();
}

function renderDailyGoal() {
  const goalSeconds = state.dailyGoalMinutes * 60;
  const completedSeconds = Math.min(state.todayStudySeconds, goalSeconds);
  const goalPercent = goalSeconds > 0 ? (completedSeconds / goalSeconds) * 100 : 0;

  elements.dailyGoalText.textContent = `${Math.floor(state.todayStudySeconds / 60)} / ${state.dailyGoalMinutes} دقيقة`;
  elements.dailyGoalBar.style.width = `${Math.min(100, goalPercent)}%`;
  elements.dailyGoalBar.parentElement.setAttribute('aria-valuenow', Math.round(Math.min(100, goalPercent)));
}

function renderHistory() {
  elements.historyList.innerHTML = '';
  elements.historyEmpty.hidden = state.sessionHistory.length > 0;

  state.sessionHistory.forEach((session) => {
    const completedDate = new Date(session.completedAt);
    const item = document.createElement('article');
    item.className = 'history-item';
    item.innerHTML = `
      <strong>${session.subject}</strong>
      <span>${formatDuration(session.seconds)}</span>
      <div class="history-meta">
        <span>${completedDate.toLocaleDateString('ar')}</span>
        <span>+${session.xp} XP</span>
        <span>+${session.gold} ذهب</span>
        <span>${session.damage} ضرر</span>
      </div>
    `;
    elements.historyList.appendChild(item);
  });
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
  const confirmed = window.confirm('هل تريد حذف كل تقدم Study Legends على هذا الجهاز؟ لا يمكن التراجع.');
  if (!confirmed) return;

  window.clearInterval(timer.intervalId);
  timer = {
    isRunning: false,
    startedAt: null,
    accumulatedSeconds: 0,
    intervalId: null,
  };
  state = getFreshState();
  saveState();

  elements.startButton.disabled = false;
  elements.pauseButton.disabled = true;
  elements.stopButton.disabled = true;
  elements.timerStatus.textContent = 'جاهز للبدء';
  renderAll();
  showToast('تمت إعادة ضبط سجل الرحلة. أسطورة جديدة تبدأ الآن.');
}

function bindEvents() {
  elements.startButton.addEventListener('click', startTimer);
  elements.pauseButton.addEventListener('click', pauseTimer);
  elements.stopButton.addEventListener('click', stopTimer);
  elements.soundToggle.addEventListener('click', toggleSound);
  elements.resetButton.addEventListener('click', resetProgress);
  elements.subjectInput.addEventListener('input', () => {
    state.currentSubject = elements.subjectInput.value.trim();
    saveState();
  });
  elements.dailyGoalInput.addEventListener('change', () => {
    state.dailyGoalMinutes = clamp(Number(elements.dailyGoalInput.value) || 120, 5, 720);
    elements.dailyGoalInput.value = state.dailyGoalMinutes;
    saveState();
    renderDailyGoal();
  });

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
