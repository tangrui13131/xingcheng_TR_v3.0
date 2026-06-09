/**
 * 全局模拟健康数据中心
 * 响应式 + localStorage 持久化，防止页面刷新丢失
 */
import { reactive } from 'vue'

const STORAGE_KEY = 'xc_health_data'

// ─── 默认初始值（与 AI 周报文案完全对应）─────────────────────────
const DEFAULT_DATA = {
  // 近 7 天睡眠时长（h），平均 5.8h，有 3 天不足 5h
  sleepData: [6.5, 4.5, 7.0, 4.0, 5.5, 4.5, 8.6],
  // 近 7 天饮水量（ml），平均 1200ml
  waterData: [1100, 1300, 900, 1500, 1200, 1000, 1400],
  // 雷达图五维评分（0-100），初始与 AI 文案一致
  radarScores: {
    sleep:    58,   // 5.8h → 58分
    cervical: 64,   // 3.2/5 → 64分
    water:    80,   // 1200/1500 → 80分
    exercise: 70,   // 模拟
    mood:     75    // 模拟
  },
  // 今日是否已完成打卡（防止重复提交影响数据）
  lastCheckinDate: '',
  // 用户积分余额
  userPoints: 500
}

// ─── 从 localStorage 加载，不存在则用默认值 ─────────────────────
function loadFromStorage () {
  try {
    const raw = localStorage.getItem(STORAGE_KEY)
    if (raw) {
      const parsed = JSON.parse(raw)
      // 深度合并，防止旧结构缺少新字段
      return {
        ...DEFAULT_DATA,
        ...parsed,
        radarScores: { ...DEFAULT_DATA.radarScores, ...(parsed.radarScores || {}) }
      }
    }
  } catch (e) {
    console.warn('[mockHealthData] localStorage 读取失败，使用默认值', e)
  }
  return { ...DEFAULT_DATA, radarScores: { ...DEFAULT_DATA.radarScores } }
}

// ─── 响应式全局状态 ──────────────────────────────────────────────
export const healthData = reactive(loadFromStorage())

// ─── 打卡选项 → 具体数值 映射表 ────────────────────────────────────
const SLEEP_HOURS_MAP   = { good: 8.0,  normal: 5.5,  bad: 3.5  }
const SLEEP_SCORE_MAP   = { good: 88,   normal: 58,   bad: 30   }
const CERVICAL_SCORE_MAP= { good: 90,   normal: 64,   bad: 30   }
const WATER_ML_MAP      = { good: 1500, normal: 900,  bad: 400  }
const WATER_SCORE_MAP   = { good: 100,  normal: 60,   bad: 27   }

/**
 * 提交今日打卡数据 —— 由 DailyHealthCheckIn 在完成最后一题后调用
 * @param {'good'|'normal'|'bad'} sleepVal    睡眠质量选项
 * @param {'good'|'normal'|'bad'} cervicalVal 颈椎状态选项
 * @param {'good'|'normal'|'bad'} waterVal    饮水情况选项
 */
export function submitCheckIn (sleepVal, cervicalVal, waterVal) {
  const today = new Date().toDateString()

  // 滚动 sleepData：踢掉最早一天，推入今日数据，保持 7 天
  const newSleep = SLEEP_HOURS_MAP[sleepVal] ?? 6.0
  healthData.sleepData = [...healthData.sleepData.slice(1), newSleep]

  // 滚动 waterData：同理
  const newWater = WATER_ML_MAP[waterVal] ?? 1200
  healthData.waterData = [...healthData.waterData.slice(1), newWater]

  // 更新雷达图评分
  healthData.radarScores.sleep    = SLEEP_SCORE_MAP[sleepVal]    ?? 58
  healthData.radarScores.cervical = CERVICAL_SCORE_MAP[cervicalVal] ?? 64
  healthData.radarScores.water    = WATER_SCORE_MAP[waterVal]    ?? 80

  // 记录打卡日期
  healthData.lastCheckinDate = today

  // 持久化到 localStorage
  saveToStorage()
}

// ─── 持久化辅助函数 ────────────────────────────────────────────
function saveToStorage () {
  localStorage.setItem(STORAGE_KEY, JSON.stringify({
    sleepData: healthData.sleepData,
    waterData: healthData.waterData,
    radarScores: { ...healthData.radarScores },
    lastCheckinDate: healthData.lastCheckinDate,
    userPoints: healthData.userPoints
  }))
}

/**
 * 增加积分（打卡奖励等场景调用）
 * @param {number} amount 增加的积分数
 */
export function addPoints (amount) {
  healthData.userPoints += amount
  saveToStorage()
}

/**
 * 扣除积分（兑换商品时调用）
 * @param {number} amount 扣除的积分数
 * @returns {boolean} 是否扣除成功
 */
export function deductPoints (amount) {
  if (healthData.userPoints < amount) return false
  healthData.userPoints -= amount
  saveToStorage()
  return true
}

/**
 * 判断今天是否已打卡（用于防重）
 */
export function isTodayCheckedIn () {
  return healthData.lastCheckinDate === new Date().toDateString()
}
