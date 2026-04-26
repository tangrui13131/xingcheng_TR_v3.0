<template>
  <div class="user-layout">
    <div class="user-sidebar">
      <div class="logo-container">
        <img :src="logoSrc" class="user-logo" alt="logo" />
        <div class="logo-text">星辰 · 用户端</div>
      </div>
      <div class="menu">
        <div class="menu-item active">首页</div>
        <div class="menu-item" @click="router.push('/health-data')">健康看板</div>
        <div class="menu-item" @click="router.push('/points-mall')">积分商城</div>
        <div class="menu-item" @click="router.push('/ai-assistant')">AI健康助手</div>
        <div class="menu-item" @click="router.push('/profile')">个人中心</div>
        <div class="menu-item" @click="handleLogout">退出登录</div>
      </div>
    </div>
    <div class="user-content">
      <div class="user-header">
        <div class="welcome">你好，{{ username }}！祝你今天愉快。</div>
      </div>
      <div class="dashboard">
        <el-row :gutter="20">
          <el-col :span="8">
            <el-card class="stats-card">
              <template #header>本月打卡</template>
              <div class="stats-num">{{ monthlyCheckinDays }}</div>
              <div class="stats-desc">坚持就是胜利</div>
            </el-card>
          </el-col>
          <el-col :span="8">
            <el-card class="stats-card accent">
              <template #header>今日饮水量</template>
              <div
                class="stats-num"
                :style="todayWaterDisplay !== '未记录' ? 'color: var(--el-color-primary)' : ''"
              >{{ todayWaterDisplay }}</div>
              <div class="stats-desc">目标: 1500ml</div>
            </el-card>
          </el-col>
          <el-col :span="8">
            <el-card class="stats-card success">
              <template #header>今日睡眠</template>
              <div
                class="stats-num"
                :style="todaySleepDisplay !== '未记录' ? 'color: var(--el-color-primary)' : ''"
              >{{ todaySleepDisplay }}</div>
              <div class="stats-desc">昨晚休眠质量</div>
            </el-card>
          </el-col>
        </el-row>

        <el-row :gutter="20" class="mt-20">
          <el-col :span="12">
            <!-- 游戏化健康打卡组件 -->
            <DailyHealthCheckIn @checkin-complete="onCheckinComplete" />
          </el-col>
          <el-col :span="12">
            <el-card class="content-card no-margin">
              <template #header>
                <div class="card-header">
                  <span>最新公告</span>
                  <el-button type="primary" link>查看更多</el-button>
                </div>
              </template>
              <div class="news-list">
                <div class="news-item">
                  <span class="news-title">系统升级公告</span>
                  <span class="news-date">2024-03-20</span>
                </div>
                <div class="news-item">
                  <span class="news-title">温馨提示：保持良好心情哦</span>
                  <span class="news-date">2024-03-19</span>
                </div>
              </div>
            </el-card>

            <!-- 屏幕使用时长与久坐提醒 -->
            <el-card shadow="hover" class="screen-card mt-16">
              <template #header>
                <div class="card-header">
                  <span>👀 屏幕关注眼监控</span>
                  <el-button type="info" link size="small" class="demo-btn" @click="screenSeconds = 3595; localStorage.setItem('xingchen_screen_seconds', 3595)">[演示测试]</el-button>
                </div>
              </template>
              <div class="screen-dashboard">
                <el-progress
                  type="dashboard"
                  :percentage="progressPercentage"
                  :stroke-width="10"
                  :color="progressColor"
                >
                  <template #default>
                    <div class="screen-time-display">
                      <span class="time-value">{{ formattedTime }}</span>
                      <span class="time-label">连续用屏</span>
                    </div>
                  </template>
                </el-progress>
                <p class="screen-tip">每 60 分钟建议休息一次，保护颈椎与视力</p>
              </div>
            </el-card>
          </el-col>
        </el-row>

        <!-- AI私人健康顾问模块 -->
        <el-card class="ai-advisor-card mt-20">
          <template #header>
            <div class="card-header">
              <span>🤖AI私人健康顾问//我的独特周报</span>
            </div>
          </template>

          <!-- 初始状态：唤醒按钮 -->
          <div v-if="!aiGenerated" class="ai-advisor-init">
            <el-button
              type="primary"
              size="large"
              plain
              :loading="aiLoading"
              @click="handleGenerateAdvice"
            >
              ✨点击生成本周专属健康建议
            </el-button>
            <p class="ai-hint">基于你最近7天的打卡数据生成</p>
          </div>

          <!-- 结果展示区（默认隐藏） -->
          <div v-else class="ai-advisor-result">
            <div class="ai-result-content" v-html="aiAdviceDisplayHtml"></div>
            <div class="ai-result-footer">
              <el-button type="primary" link :disabled="aiTyping" @click="handleRegenerate">
                🔄 重新生成
              </el-button>
            </div>
          </div>
        </el-card>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import request from '@/api/request'
import { ElMessage, ElMessageBox } from 'element-plus'
import logoSrc from '@/assets/logo.png'
import DailyHealthCheckIn from '@/components/DailyHealthCheckIn.vue'
import { healthData } from '@/utils/mockHealthData'

// ─── Kimi API 配置 ────────────────────────────────────────────────
const KIMI_API_KEY = 'sk-V9DdTWM3uMpPXyq43WtfOmKIVhyCKEk2Zaoxmt9oqKDHuMJp'
const KIMI_API_URL = 'https://api.moonshot.cn/v1/chat/completions'

const router = useRouter()
const username = ref('用户')

// ─── 顶部数据卡响应式状态 ────────────────────────────────
// localStorage key 常量
const LS_DATE    = 'xingchen_checkin_date'
const LS_MONTHLY = 'xingchen_monthly_checkin'
const LS_WATER   = 'xingchen_today_water'
const LS_SLEEP   = 'xingchen_today_sleep'
const LS_DONE    = 'xingchen_has_checked_today'

// 从 localStorage 恢复，今天的数据才读取，跨天则仅保留累计天数
const _today        = new Date().toLocaleDateString()
const _storedDate   = localStorage.getItem(LS_DATE)
const _isToday      = _storedDate === _today
const _savedMonthly = parseInt(localStorage.getItem(LS_MONTHLY) || '20', 10)

const monthlyCheckinDays = ref(isNaN(_savedMonthly) ? 20 : _savedMonthly)
const todayWaterDisplay  = ref(_isToday ? (localStorage.getItem(LS_WATER)  || '未记录') : '未记录')
const todaySleepDisplay  = ref(_isToday ? (localStorage.getItem(LS_SLEEP)  || '未记录') : '未记录')
const hasCheckedInToday  = ref(_isToday && localStorage.getItem(LS_DONE) === 'true')

/**
 * DailyHealthCheckIn 打卡完成事件回调，同步写入 localStorage
 * @param {{ sleep: string, water: string }} data
 */
const onCheckinComplete = ({ sleep, water }) => {
  todaySleepDisplay.value = sleep
  todayWaterDisplay.value = water
  if (!hasCheckedInToday.value) {
    monthlyCheckinDays.value += 1
    hasCheckedInToday.value = true
  }
  const today = new Date().toLocaleDateString()
  localStorage.setItem(LS_DATE,    today)
  localStorage.setItem(LS_MONTHLY, String(monthlyCheckinDays.value))
  localStorage.setItem(LS_WATER,   todayWaterDisplay.value)
  localStorage.setItem(LS_SLEEP,   todaySleepDisplay.value)
  localStorage.setItem(LS_DONE,    'true')
}

// AI健康顾问相关状态
const aiLoading = ref(false)   // 按钮 loading（模拟思考中）
const aiGenerated = ref(false) // 是否切换到结果展示区
const aiTyping = ref(false)    // 打字机是否正在输出
const aiAdviceText = ref('')   // 已输出到界面的文本（逐字累加）
let aiTimer = null             // 打字机定时器句柄，用于清除

/**
 * 将原始文本转成 HTML（\n → <br>），并在打字机输出期间追加闪烁光标
 */
const aiAdviceDisplayHtml = computed(() => {
  // 转义 HTML 特殊字符，防止 XSS
  const escaped = aiAdviceText.value
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/\n/g, '<br>')
  // 打字机输出期间追加光标
  return escaped + (aiTyping.value ? '<span class="typing-cursor">|</span>' : '')
})

/** 启动打字机：每 30ms 输出一个字符 */
const startTypewriter = (fullText) => {
  let index = 0
  aiAdviceText.value = ''
  aiTyping.value = true

  aiTimer = setInterval(() => {
    if (index < fullText.length) {
      aiAdviceText.value += fullText[index]
      index++
    } else {
      // 全部输出完毕，停止打字机
      clearInterval(aiTimer)
      aiTimer = null
      aiTyping.value = false
    }
  }, 30)
}

/** 根据 healthData 构建发送给 Kimi 的 prompt */
const buildHealthPrompt = () => {
  const s = healthData.sleepData
  const w = healthData.waterData
  const r = healthData.radarScores
  const avg = arr => (arr.reduce((a, b) => a + b, 0) / arr.length).toFixed(1)
  const avgSleep = avg(s)
  const avgWater = avg(w)
  const poorSleepDays  = s.filter(v => v < 6).length
  const lowWaterDays   = w.filter(v => v < 1500).length
  const days = ['周一','周二','周三','周四','周五','周六','周日']
  const sleepList  = s.map((v, i) => `${days[i]}: ${v}h`).join('、')
  const waterList  = w.map((v, i) => `${days[i]}: ${v}ml`).join('、')
  return `以下是我近 7 天的真实健康打卡数据，请据此生成一份温暖、简洁的个人健康周报（250字以内）。\n要包含：本周亮点、存在的问题、3条可立即执行的改善建议，语气亲切。\n\n【睡眠时长】${sleepList}\n- 平均睡眠：${avgSleep}小时\n- 睡眠不足6小时的天数：${poorSleepDays}天\n\n【饮水量】${waterList}\n- 平均饮水：${avgWater}ml\n- 未达推荐量(1500ml)的天数：${lowWaterDays}天\n\n【健康评分（满分100）】\n- 睡眠质量：${r.sleep}分\n- 颈椎健康：${r.cervical}分\n- 饮水达标：${r.water}分\n- 运动情况：${r.exercise}分\n- 情绪状态：${r.mood}分`
}

/** 生成AI健康建议 —— 调用 Kimi API，结果交给打字机输出 */
const handleGenerateAdvice = async () => {
  aiLoading.value = true
  try {
    const response = await fetch(KIMI_API_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${KIMI_API_KEY}`
      },
      body: JSON.stringify({
        model: 'moonshot-v1-8k',
        stream: false,
        messages: [
          {
            role: 'system',
            content: '你是一个温暖专业的企业健康顾问，擅长根据打卡数据给出个性化健康建议。回复简洁、积极、可执行，禁止给出任何诊断或用药建议。'
          },
          { role: 'user', content: buildHealthPrompt() }
        ]
      })
    })
    if (!response.ok) throw new Error(`Kimi API 错误: ${response.status}`)
    const data = await response.json()
    const fullText = data.choices?.[0]?.message?.content || '暂时无法获取建议，请稍后重试'
    aiGenerated.value = true
    startTypewriter(fullText)
  } catch (error) {
    console.error(error)
    ElMessage.error('生成失败，请检查网络后重试')
  } finally {
    aiLoading.value = false
  }
}

/** 重新生成：清除打字机 → 重置状态 → 重新触发 */
const handleRegenerate = () => {
  if (aiTimer) {
    clearInterval(aiTimer)
    aiTimer = null
  }
  aiGenerated.value = false
  aiAdviceText.value = ''
  aiTyping.value = false
  handleGenerateAdvice()
}

// 组件卸载时清除定时器，防止内存泄漏
onUnmounted(() => {
  if (aiTimer) clearInterval(aiTimer)
  if (screenTimer) clearInterval(screenTimer)
})

// ─── 屏幕使用时长与久坐提醒 ──────────────────────────────────
const _savedScreenSeconds = parseInt(localStorage.getItem('xingchen_screen_seconds') || '0', 10)
const screenSeconds = ref(isNaN(_savedScreenSeconds) ? 0 : _savedScreenSeconds)
let screenTimer = null

/** 格式化为 HH:mm:ss */
const formattedTime = computed(() => {
  const h = Math.floor(screenSeconds.value / 3600)
  const m = Math.floor((screenSeconds.value % 3600) / 60)
  const s = screenSeconds.value % 60
  return `${String(h).padStart(2, '0')}:${String(m).padStart(2, '0')}:${String(s).padStart(2, '0')}`
})

/** 环形进度：60 分钟 (3600s) = 100% */
const progressPercentage = computed(() => {
  return Math.min(Math.round((screenSeconds.value / 3600) * 100), 100)
})

/** 进度条颜色渐变：绿 → 橙 → 红 */
const progressColor = computed(() => {
  if (progressPercentage.value < 50) return '#67C23A'
  if (progressPercentage.value < 80) return '#E6A23C'
  return '#F56C6C'
})

/** 监听秒数，满 60 分钟弹窗提醒 */
watch(screenSeconds, (val) => {
  if (val === 3600) {
    ElMessageBox.alert(
      '您已经连续面对屏幕 1 小时了！为了您的颈椎和视力，请站起来倒杯水，眺望远方 20 秒。',
      '🔔 护眼与久坐提醒',
      {
        confirmButtonText: '我这就去休息',
        type: 'warning',
        center: true
      }
    ).then(() => {
      screenSeconds.value = 0
      localStorage.removeItem('xingchen_screen_seconds')
    }).catch(() => {
      screenSeconds.value = 0
      localStorage.removeItem('xingchen_screen_seconds')
    })
  }
})

onMounted(async () => {
  // 启动屏幕使用计时器（每秒 +1）
  screenTimer = setInterval(() => {
    screenSeconds.value++
    localStorage.setItem('xingchen_screen_seconds', screenSeconds.value)
  }, 1000)

  try {
    const res = await request.get('/getInfo')
    username.value = res.user.nickName || res.user.userName
  } catch (error) {
    console.error(error)
  }
})

const handleLogout = async () => {
  try {
    await request.post('/logout')
    localStorage.removeItem('token')
    ElMessage.success('已安全退出')
    router.push('/login')
  } catch (error) {
    console.error(error)
  }
}
</script>

<style scoped lang="scss">
.user-layout {
  display: flex;
  height: 100vh;
}

.user-sidebar {
  width: 240px;
  background-color: var(--bg-1);
  border-right: 1px solid var(--line);
  padding: 40px 20px;
  display: flex;
  flex-direction: column;
  
  .logo-container {
    display: flex;
    flex-direction: column;
    align-items: center;
    margin-bottom: 60px;
    
    .user-logo {
      width: 64px;
      height: 64px;
      margin-bottom: 12px;
      object-fit: contain;
    }
    
    .logo-text {
      color: var(--primary);
      font-size: 20px;
      font-weight: bold;
      text-align: center;
    }
  }
  
  .menu-item {
    padding: 16px 24px;
    margin-bottom: 12px;
    border-radius: 12px;
    cursor: pointer;
    color: var(--text-2);
    font-weight: 500;
    transition: all 0.3s;
    
    &:hover {
      background-color: var(--primary-light);
      color: var(--primary);
    }
    
    &.active {
      background-color: var(--primary);
      color: #fff;
    }
  }
}

.user-content {
  flex: 1;
  background-color: var(--bg-0);
  display: flex;
  flex-direction: column;
}

.user-header {
  height: 80px;
  padding: 0 40px;
  display: flex;
  align-items: center;
  background-color: var(--bg-1);
  border-bottom: 1px solid var(--line);
  
  .welcome {
    font-size: 18px;
    color: var(--text-1);
    font-weight: 600;
  }
}

.dashboard {
  padding: 40px;
  overflow-y: auto;
}

.stats-card {
  text-align: center;
  margin-bottom: 24px;
  
  .stats-num {
    font-size: 36px;
    font-weight: bold;
    color: var(--primary);
    margin: 12px 0;
  }
  
  .stats-desc {
    color: var(--text-2);
    font-size: 14px;
  }
  
  &.accent .stats-num { color: var(--accent); }
  &.success .stats-num { color: var(--success); }
}

.content-card {
  margin-top: 20px;
  
  &.no-margin {
    margin-top: 0;
  }
  
  .card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    font-weight: 600;
  }
}

.mt-20 {
  margin-top: 20px;
}

.ai-advisor-card {
  border-radius: 12px;

  .card-header {
    font-weight: 600;
    font-size: 16px;
  }
}

.ai-advisor-init {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 40px 20px 32px;
  gap: 16px;

  .el-button {
    font-size: 16px;
    padding: 14px 36px;
    border-radius: 24px;
  }
}

.ai-hint {
  margin: 0;
  font-size: 13px;
  color: #909399;
}

.ai-advisor-result {
  padding: 4px 0 0;
}

.ai-result-content {
  background-color: #f5f7fa;
  border-radius: 10px;
  padding: 24px 28px;
  color: #303133;
  font-size: 15px;
  line-height: 1.8;
  min-height: 80px;
}

/* 打字机光标：竖线闪烁动画 */
:deep(.typing-cursor) {
  display: inline-block;
  width: 2px;
  height: 1em;
  background-color: #409eff;
  margin-left: 2px;
  vertical-align: text-bottom;
  animation: cursor-blink 0.8s step-end infinite;
}

@keyframes cursor-blink {
  0%, 100% { opacity: 1; }
  50%       { opacity: 0; }
}

.ai-result-footer {
  display: flex;
  justify-content: flex-end;
  margin-top: 12px;
}

.news-list {
  .news-item {
    display: flex;
    justify-content: space-between;
    padding: 16px 0;
    border-bottom: 1px solid var(--line);
    
    &:last-child {
      border-bottom: none;
    }
    
    .news-title {
      color: var(--text-1);
    }
    
    .news-date {
      color: var(--text-2);
      font-size: 14px;
    }
  }
}

/* ── 屏幕监控卡片 ── */
.mt-16 {
  margin-top: 16px;
}

.screen-card {
  border-radius: 12px;

  .demo-btn {
    font-size: 11px;
    color: #c0c4cc;
    padding: 0;
  }
}

.screen-dashboard {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 12px 0 4px;
}

.screen-time-display {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 2px;

  .time-value {
    font-size: 22px;
    font-weight: 700;
    color: #303133;
    font-variant-numeric: tabular-nums;
    letter-spacing: 1px;
  }

  .time-label {
    font-size: 12px;
    color: #909399;
  }
}

.screen-tip {
  margin: 12px 0 0;
  font-size: 12px;
  color: #909399;
  text-align: center;
}
</style>