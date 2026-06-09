<template>
  <div class="ai-layout">
    <!-- 左侧边栏 -->
    <div class="user-sidebar">
      <div class="logo-container">
        <img :src="logoSrc" class="user-logo" alt="logo" />
        <div class="logo-text">星辰 · 用户端</div>
      </div>
      <div class="menu">
        <div class="menu-item" @click="router.push('/')">首页</div>
        <div class="menu-item" @click="router.push('/health-data')">健康看板</div>
        <div class="menu-item" @click="router.push('/points-mall')">积分商城</div>
        <div class="menu-item active">AI健康助手</div>
        <div class="menu-item" @click="router.push('/profile')">个人中心</div>
        <div class="menu-item" @click="handleLogout">退出登录</div>
      </div>
    </div>

    <!-- 主内容区 -->
    <div class="ai-main">
      <!-- 顶部标题栏 -->
      <div class="ai-header">
        <el-icon :size="22" color="var(--primary)"><Service /></el-icon>
        <span class="ai-title">AI 健康助手</span>
        <span class="ai-subtitle">由星辰大模型驱动，支持图文多模态识别</span>
      </div>

      <!-- 聊天主体卡片 -->
      <el-card shadow="hover" class="chat-card">
        <!-- 聊天记录区 -->
        <div class="message-area" ref="messageAreaRef">
          <div
            v-for="(msg, index) in messageList"
            :key="index"
            class="message-row"
            :class="msg.role === 'user' ? 'row-user' : 'row-assistant'"
          >
            <!-- AI 头像 -->
            <div v-if="msg.role === 'assistant'" class="avatar avatar-ai">
              <el-icon :size="20"><Service /></el-icon>
            </div>

            <!-- 气泡 -->
            <div class="bubble" :class="msg.role === 'user' ? 'bubble-user' : 'bubble-ai'">
              <span v-if="msg.loading" class="loading-dots">
                AI 正在思考<span class="dot">.</span><span class="dot">.</span><span class="dot">.</span>
              </span>
              <template v-else>
                <!-- 若消息带图片，先渲染图片 -->
                <img
                  v-if="msg.image"
                  :src="msg.image"
                  class="bubble-img"
                  alt="用户上传图片"
                />
                <!-- 文字内容 -->
                <span v-if="msg.content">{{ msg.content }}</span>
              </template>
            </div>

            <!-- 用户头像 -->
            <div v-if="msg.role === 'user'" class="avatar avatar-user">
              <el-icon :size="20"><User /></el-icon>
            </div>
          </div>
        </div>

        <!-- 分隔线 -->
        <el-divider style="margin: 0" />

        <!-- 输入区 -->
        <div class="input-area">
          <!-- 图片预览（有图时显示） -->
          <div v-if="selectedImageBase64" class="image-preview-wrap">
            <img :src="selectedImageBase64" class="image-preview" alt="待发送图片" />
            <el-icon class="image-remove" @click="clearImage"><Close /></el-icon>
          </div>

          <el-input
            v-model="inputText"
            type="textarea"
            :rows="3"
            placeholder="请输入您的健康问题，也可上传食物、坐姿、运动姿势等生活图片..."
            resize="none"
            class="chat-input"
            @keydown.enter.exact.prevent="handleSend"
          />
          <div class="input-actions">
            <!-- 隐藏的文件选择器 -->
            <input
              ref="fileInputRef"
              type="file"
              accept="image/*"
              style="display:none"
              @change="handleImageSelect"
            />
            <div class="left-actions">
              <el-tooltip content="上传图片（食物/坐姿/运动姿势等生活图片）" placement="top">
                <el-button
                  type="info"
                  link
                  size="small"
                  class="upload-btn"
                  @click="fileInputRef.click()"
                >
                  <el-icon :size="18"><Picture /></el-icon>
                </el-button>
              </el-tooltip>
              <span class="input-hint">按 Enter 发送，Shift+Enter 换行</span>
            </div>
            <el-button
              type="primary"
              :loading="sending"
              :disabled="!inputText.trim() && !selectedImageBase64"
              class="send-btn"
              @click="handleSend"
            >
              <el-icon v-if="!sending"><Promotion /></el-icon>
              发 送
            </el-button>
          </div>
        </div>
      </el-card>
    </div>
  </div>
</template>

<script setup>
import { ref, nextTick, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Service, User, Promotion, Picture, Close } from '@element-plus/icons-vue'
import logoSrc from '@/assets/logo.png'
import request from '@/api/request'

const router = useRouter()

// ─── Kimi API 配置 ────────────────────────────────────────────────────
const KIMI_API_KEY       = 'sk-3MHJIYHctRabxCRPkOprpbb9ATDmmjVNh1WLHwjdz1KvP2xX'
const KIMI_API_URL       = '/kimi-api/v1/chat/completions'
const KIMI_MODEL_TEXT    = 'moonshot-v1-8k'                  // 纯文本
const KIMI_MODEL_VISION  = 'moonshot-v1-8k-vision-preview'   // 视觉多模态

// ─── 系统提示词（System Prompt）──────────────────────────────────────
const SYSTEM_PROMPT =
  "你叫'星辰'，是星辰健康管理系统专属的企业员工私人健康助手。" +
  "你的主要职责是为办公室白领提供泛健康指导，包括久坐拉伸建议、睡眠优化、饮食建议和日常情绪疏导。" +
  "回复要求语气温暖、专业、简短（适合聊天框阅读）。\n\n" +
  "【绝对红线（最高优先级）】：\n" +
  "1. 你没有行医资格，严禁对用户的症状进行任何医疗诊断。\n" +
  "2. 严禁向用户推荐任何具体的处方药或非处方药（OTC）名称，严禁提供用药剂量建议。\n" +
  "3. 一旦用户的提问涉及具体的疾病确诊、寻求用药建议，或者描述了严重的身体不适，" +
  "你必须立即停止常规分析，并严格、只回复：" +
  "'作为一个健康管理助手，我无法为您开具处方或提供医疗诊断。" +
  "涉及到具体疾病或用药安全，请您务必及时前往正规医院就诊，遵循专业医师的指导。'\n" +
  "4. 严禁解读医疗影像：如果用户上传了 X 光片、化验单、B 超等专业医疗影像或体检报告，" +
  "你必须拒绝解读，并回复：'抱歉，我无法为您解读专业医疗报告，请咨询专业执业医师。'" +
  "你只能分析如食物热量、坐姿照片、运动姿势等生活类图片。"

// ─── 前端关键词强拦截 ─────────────────────────────────────────────────
const MEDICAL_KEYWORDS = [
  '处方', '药名', '用药', '剂量', '服药', '吃药', '药片', '药物',
  '诊断', '确诊', '病情', '病理', '治疗方案', '手术', '化疗', '放疗',
  '癌症', '肿瘤', '糖尿病', '高血压', '心脏病', '肝炎', '艾滋',
  '骨折', '脑梗', '中风', '猝死', '急救'
]
const SAFETY_REPLY =
  '作为一个健康管理助手，我无法为您开具处方或提供医疗诊断。' +
  '涉及到具体疾病或用药安全，请您务必及时前往正规医院就诊，遵循专业医师的指导。'
const isMedicalQuery = (text) => MEDICAL_KEYWORDS.some(kw => text.includes(kw))

// ─── 聊天数据 ──────────────────────────────────────────────────────
const messageList    = ref([])
const inputText      = ref('')
const sending        = ref(false)
const messageAreaRef = ref(null)

// ─── 图片相关状态 ─────────────────────────────────────────────────
const selectedImageBase64 = ref('')   // base64 data URL，用于预览和发送
const fileInputRef        = ref(null)

/**
 * 压缩图片：使用 Canvas 缩放并转为 JPEG，控制输出 ≤ 500KB 左右
 * @param {File} file 原始图片文件
 * @param {number} maxWidth 最大宽度，默认 800px
 * @param {number} quality JPEG 质量 0-1，默认 0.7
 * @returns {Promise<string>} 压缩后的 Base64 data URL
 */
const compressImage = (file, maxWidth = 800, quality = 0.7) => {
  return new Promise((resolve, reject) => {
    const img = new Image()
    img.onload = () => {
      let w = img.width
      let h = img.height
      if (w > maxWidth) {
        h = Math.round(h * maxWidth / w)
        w = maxWidth
      }
      const canvas = document.createElement('canvas')
      canvas.width = w
      canvas.height = h
      const ctx = canvas.getContext('2d')
      ctx.drawImage(img, 0, 0, w, h)
      resolve(canvas.toDataURL('image/jpeg', quality))
    }
    img.onerror = reject
    img.src = URL.createObjectURL(file)
  })
}

/** 用户选择图片后，压缩并读取为 Base64 */
const handleImageSelect = async (event) => {
  const file = event.target.files?.[0]
  if (!file) return

  // 限制大小：10 MB（压缩前）
  if (file.size > 10 * 1024 * 1024) {
    ElMessage.warning('图片大小不能超过 10 MB')
    event.target.value = ''
    return
  }

  try {
    // 压缩图片到 ≤ ~500KB
    selectedImageBase64.value = await compressImage(file, 800, 0.7)
    ElMessage.success('图片已压缩并选择')
  } catch {
    ElMessage.error('图片读取失败，请重试')
  }
  // 清空 input，允许重复选同一张图
  event.target.value = ''
}

/** 取消已选图片 */
const clearImage = () => {
  selectedImageBase64.value = ''
}

/** 滚动到底部 */
const scrollToBottom = async () => {
  await nextTick()
  if (messageAreaRef.value) {
    messageAreaRef.value.scrollTop = messageAreaRef.value.scrollHeight
  }
}

/** 初始化：推入 AI 开场白 */
onMounted(() => {
  messageList.value.push({
    role: 'assistant',
    content: '你好！我是星辰健康管理助手，你有什么健康问题都可以问我，也可以上传食物、坐姿等生活图片让我帮你分析。'
  })
  scrollToBottom()
})

// ─── 核心：调用 Kimi 流式接口（支持多模态）────────────────────────
/**
 * @param {number} loadingIndex  - loading 占位气泡在 messageList 中的下标
 * @param {boolean} hasImage     - 本次请求是否携带图片
 */
const callKimiStream = async (loadingIndex, hasImage) => {
  // 构造历史消息（不含 loading 占位），转换为 API 格式
  const historyMessages = messageList.value
    .slice(0, loadingIndex)
    .filter(m => !m.loading)
    .map(m => {
      if (m.image) {
        // 带图片的消息 → 多模态 content 数组
        const parts = [
          { type: 'image_url', image_url: { url: m.image } },
          { type: 'text', text: m.content || '请分析这张图片' }
        ]
        return { role: m.role, content: parts }
      }
      // 纯文本消息：确保 content 非空
      return { role: m.role, content: m.content || '你好' }
    })

  // 检查历史消息中是否包含图片
  const hasImageInHistory = historyMessages.some(m =>
    Array.isArray(m.content) && m.content.some(part => part.type === 'image_url')
  )
  // 模型选择应检查「当前消息或历史消息」中是否包含图片
  const useVisionModel = hasImage || hasImageInHistory

  const payload = {
    model: useVisionModel ? KIMI_MODEL_VISION : KIMI_MODEL_TEXT,
    stream: true,
    messages: [
      { role: 'system', content: SYSTEM_PROMPT },
      ...historyMessages
    ]
  }

  const response = await fetch(KIMI_API_URL, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${KIMI_API_KEY}`
    },
    body: JSON.stringify(payload)
  })

  if (!response.ok) {
    const errText = await response.text()
    throw new Error(`Kimi API 错误 ${response.status}: ${errText}`)
  }

  // ── SSE 流式读取 ──────────────────────────────────────────────
  const reader  = response.body.getReader()
  const decoder = new TextDecoder('utf-8')
  let fullText  = ''
  let buffer    = ''

  messageList.value[loadingIndex] = { role: 'assistant', content: '' }

  while (true) {
    const { done, value } = await reader.read()
    if (done) break

    buffer += decoder.decode(value, { stream: true })
    const lines = buffer.split('\n')
    buffer = lines.pop()

    for (const line of lines) {
      const trimmed = line.trim()
      if (!trimmed || !trimmed.startsWith('data:')) continue
      const dataStr = trimmed.slice(5).trim()
      if (dataStr === '[DONE]') return

      try {
        const parsed = JSON.parse(dataStr)
        const delta  = parsed.choices?.[0]?.delta?.content ?? ''
        if (delta) {
          fullText += delta
          messageList.value[loadingIndex] = { role: 'assistant', content: fullText }
          await scrollToBottom()
        }
      } catch {
        // 忽略不完整 JSON 片段
      }
    }
  }
}

// ─── 发送消息入口 ──────────────────────────────────────────────────
const handleSend = async () => {
  const text     = inputText.value.trim()
  const imageB64 = selectedImageBase64.value

  // 文字和图片至少有一个
  if (!text && !imageB64) return
  if (sending.value) return

  // 1. 推入用户消息（含可选图片）
  messageList.value.push({
    role: 'user',
    content: text,
    image: imageB64 || undefined
  })
  inputText.value = ''
  clearImage()
  await scrollToBottom()

  // 2. 前端关键词强拦截（仅文字触发，图片走模型层红线）
  if (text && isMedicalQuery(text)) {
    messageList.value.push({ role: 'assistant', content: SAFETY_REPLY })
    await scrollToBottom()
    return
  }

  // 3. 插入 loading 占位
  sending.value = true
  messageList.value.push({ role: 'assistant', content: '', loading: true })
  const loadingIndex = messageList.value.length - 1
  await scrollToBottom()

  try {
    await callKimiStream(loadingIndex, !!imageB64)
  } catch (error) {
    console.error('Kimi 请求失败:', error)
    messageList.value[loadingIndex] = {
      role: 'assistant',
      content: '抱歉，AI 助手暂时遇到了问题，请稍后再试。'
    }
    ElMessage.error('AI 助手请求失败，请检查网络后重试')
  } finally {
    sending.value = false
    await scrollToBottom()
  }
}

/** 退出登录 */
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
/* ── 整体布局 ─────────────────────────────────────── */
.ai-layout {
  display: flex;
  height: 100vh;
}

/* ── 左侧边栏 ────────────────────────────────────── */
.user-sidebar {
  width: 240px;
  background-color: var(--bg-1);
  border-right: 1px solid var(--line);
  padding: 40px 20px;
  display: flex;
  flex-direction: column;
  flex-shrink: 0;

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

/* ── 主内容 ──────────────────────────────────────── */
.ai-main {
  flex: 1;
  background-color: var(--bg-0);
  display: flex;
  flex-direction: column;
  padding: 32px 40px;
  overflow: hidden;
}

/* ── 顶部标题栏 ───────────────────────────────────── */
.ai-header {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 20px;

  .ai-title {
    font-size: 20px;
    font-weight: 700;
    color: var(--text-1);
  }

  .ai-subtitle {
    font-size: 13px;
    color: var(--text-2);
    margin-left: 4px;
  }
}

/* ── 聊天卡片 ────────────────────────────────────── */
.chat-card {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;

  :deep(.el-card__body) {
    flex: 1;
    display: flex;
    flex-direction: column;
    overflow: hidden;
    padding: 0;
  }
}

/* ── 消息滚动区 ───────────────────────────────────── */
.message-area {
  flex: 1;
  overflow-y: auto;
  padding: 24px 24px 16px;
  display: flex;
  flex-direction: column;
  gap: 16px;

  &::-webkit-scrollbar { width: 4px; }
  &::-webkit-scrollbar-thumb {
    background: var(--line);
    border-radius: 4px;
  }
}

/* ── 消息行 ──────────────────────────────────────── */
.message-row {
  display: flex;
  align-items: flex-end;
  gap: 10px;

  &.row-user { flex-direction: row-reverse; }
}

/* ── 头像 ────────────────────────────────────────── */
.avatar {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;

  &.avatar-ai   { background-color: var(--primary-light, #e8f4fd); color: var(--primary); }
  &.avatar-user { background-color: #f0f9eb; color: #67c23a; }
}

/* ── 气泡 ────────────────────────────────────────── */
.bubble {
  max-width: 60%;
  padding: 12px 16px;
  border-radius: 16px;
  font-size: 14px;
  line-height: 1.6;
  word-break: break-word;
  white-space: pre-wrap;
  display: flex;
  flex-direction: column;
  gap: 8px;

  &.bubble-ai   {
    background-color: var(--bg-1, #f5f7fa);
    color: var(--text-1);
    border-bottom-left-radius: 4px;
  }

  &.bubble-user {
    background-color: var(--primary, #409eff);
    color: #fff;
    border-bottom-right-radius: 4px;
  }
}

/* ── 气泡内图片 ──────────────────────────────────── */
.bubble-img {
  max-width: 220px;
  max-height: 180px;
  border-radius: 8px;
  object-fit: cover;
  display: block;
}

/* ── Loading 动画 ─────────────────────────────────── */
.loading-dots {
  display: flex;
  align-items: center;
  gap: 2px;

  .dot {
    animation: blink 1.2s infinite;
    font-size: 18px;
    line-height: 1;

    &:nth-child(2) { animation-delay: 0.2s; }
    &:nth-child(3) { animation-delay: 0.4s; }
  }
}

@keyframes blink {
  0%, 80%, 100% { opacity: 0.2; }
  40%           { opacity: 1; }
}

/* ── 输入区 ───────────────────────────────────────── */
.input-area {
  padding: 16px 24px 20px;
  display: flex;
  flex-direction: column;
  gap: 10px;

  .chat-input {
    :deep(.el-textarea__inner) {
      border-radius: 10px;
      font-size: 14px;
      resize: none;
    }
  }
}

/* ── 图片预览 ─────────────────────────────────────── */
.image-preview-wrap {
  position: relative;
  display: inline-block;
  align-self: flex-start;

  .image-preview {
    width: 80px;
    height: 80px;
    object-fit: cover;
    border-radius: 8px;
    border: 2px solid var(--primary-light, #e8f4fd);
    display: block;
  }

  .image-remove {
    position: absolute;
    top: -8px;
    right: -8px;
    width: 20px;
    height: 20px;
    background: #ff4d4f;
    color: #fff;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    font-size: 12px;
    transition: transform 0.2s;

    &:hover { transform: scale(1.15); }
  }
}

/* ── 输入操作栏 ───────────────────────────────────── */
.input-actions {
  display: flex;
  justify-content: space-between;
  align-items: center;

  .left-actions {
    display: flex;
    align-items: center;
    gap: 8px;

    .upload-btn {
      padding: 4px;
      color: var(--text-2);
      transition: color 0.2s;

      &:hover { color: var(--primary); }
    }

    .input-hint {
      font-size: 12px;
      color: var(--text-2);
    }
  }

  .send-btn {
    padding: 8px 24px;
    border-radius: 8px;
    font-weight: 600;
    display: flex;
    align-items: center;
    gap: 4px;
  }
}
</style>
