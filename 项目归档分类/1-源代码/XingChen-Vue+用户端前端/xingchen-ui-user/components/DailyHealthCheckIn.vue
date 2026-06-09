<template>
  <div class="daily-health-check-in">
    <el-card class="game-card" shadow="hover">
      <!-- 进度提示 -->
      <div class="header-progress">
        <span>今日健康充电站</span>
        <span class="step-indicator">
          {{ Math.min(currentStep + 1, questionList.length) }} / {{ questionList.length }}
        </span>
      </div>

      <!-- 渐进式进度条 -->
      <el-progress 
        :percentage="(Math.min(currentStep + 1, questionList.length) / questionList.length) * 100" 
        :show-text="false"
        color="#409EFF"
        class="progress-bar"
      />

      <!-- 内容展示区：包含淡入淡出过渡动画 -->
      <div class="content-wrapper">
        <transition name="fade" mode="out-in">
          
          <!-- 问题展示区 -->
          <div class="question-container" v-if="currentQuestion" :key="currentQuestion.id">
            <h2 class="question-title">{{ currentQuestion.title }}</h2>
            
            <!-- 选项按钮组 -->
            <div class="options-wrapper">
              <el-button 
                v-for="(option, index) in currentQuestion.options" 
                :key="index"
                class="option-btn"
                :class="{ 'is-selected': selectedOptionIndex === index }"
                size="large"
                plain
                :disabled="isAnswering"
                @click="handleOptionClick(option, index)"
              >
                {{ option.label }}
              </el-button>
            </div>

            <!-- 即时反馈区域：渐显动画 -->
            <div class="feedback-wrapper">
              <transition name="fade-up">
                <div v-if="feedbackText" class="feedback-text" :class="feedbackType">
                  {{ feedbackText }}
                </div>
              </transition>
            </div>
          </div>
          
          <!-- 结束状态 -->
          <div v-else key="finish" class="finish-container">
            <el-result 
              icon="success" 
              title="完成打卡" 
              sub-title="今日健康值已充满！感谢您的记录。"
            >
              <template #extra>
                <el-button type="primary" plain @click="resetCheckIn">再测一次</el-button>
              </template>
            </el-result>
          </div>
          
        </transition>
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ElNotification } from 'element-plus'
import { submitCheckIn, addPoints, healthData } from '@/utils/mockHealthData'
import { checkInAddPoints } from '@/api/redemption'

// 向父组件上抛打卡完成事件
const emit = defineEmits(['checkin-complete'])

// 饮水量选项 → ml 展示值映射
const waterDisplayMap = { good: '1500ml+', normal: '750ml', bad: '< 200ml' }

// 状态管理
const currentStep = ref(0)
const isAnswering = ref(false) // 是否正在展示反馈（锁定点击）
const selectedOptionIndex = ref(null) // 选中的选项索引
const feedbackText = ref('') // 当前显示的反馈文案
const feedbackType = ref('') // 反馈的样式类型 (success, warning, danger)

// 记录每道题的选择结果（value + label 均保存）
const answers = ref({
  sleep:    { value: 'normal', label: '未记录' },
  cervical: { value: 'normal', label: '' },
  water:    { value: 'normal', label: '未记录' }
})

/** 挂载时：若今天已经打卡完成，直接跳到结束画面 */
onMounted(() => {
  const today = new Date().toLocaleDateString()
  if (localStorage.getItem('xingchen_checkin_completed_date') === today) {
    // questionList 长度为 3，currentStep = 3 则 currentQuestion 为 undefined 展示结束页
    currentStep.value = 3
  }
})

// 游戏化题库数据 (补充了交互反馈语)
const questionList = ref([
  {
    id: 1,
    title: '昨晚的“系统休眠”（睡眠）质量如何？',
    options: [
      { label: '深度睡眠', value: 'good', feedback: '太棒了！今天一定是个高产出的一天！🌟', type: 'success' },
      { label: '间歇唤醒', value: 'normal', feedback: '辛苦了！今天允许自己摸鱼半小时吧☕', type: 'warning' },
      { label: '严重失眠', value: 'bad', feedback: '抱抱！中午一定要补个觉，别太拼了🛌', type: 'danger' }
    ]
  },
  {
    id: 2,
    title: '现在你的颈椎感觉怎么样？',
    options: [
      { label: '灵活自如', value: 'good', feedback: '保持这个姿势！你就是办公室最靓的仔😎', type: 'success' },
      { label: '有点僵硬', value: 'normal', feedback: '起来倒杯水，顺便做个“米”字操吧🔄', type: 'warning' },
      { label: '急需救援', value: 'bad', feedback: '快站起来！扭脖子活动一下！立刻！马上！🚨', type: 'danger' }
    ]
  },
  {
    id: 3,
    title: '今天的水分补充进度？',
    options: [
      { label: '水杯已空', value: 'good', feedback: '吨吨吨！你的肾脏和皮肤都在感谢你💧', type: 'success' },
      { label: '喝了一半', value: 'normal', feedback: '再喝两口，离目标只有一步之遥啦💪', type: 'warning' },
      { label: '完全忘记', value: 'bad', feedback: '身体拉响干旱警报，带薪接水去！🏃‍♂️', type: 'danger' }
    ]
  }
])

// 计算属性：当前应该显示的题目
const currentQuestion = computed(() => {
  return questionList.value[currentStep.value]
})

/**
 * 处理选项点击逻辑
 */
const handleOptionClick = (option, index) => {
  // 1. 锁定界面，防止重复点击
  if (isAnswering.value) return
  isAnswering.value = true
  selectedOptionIndex.value = index

  // 2. 按题序记录答案（同时保存 label，供父组件展示用）
  const stepMap = ['sleep', 'cervical', 'water']
  if (stepMap[currentStep.value]) {
    answers.value[stepMap[currentStep.value]] = { value: option.value, label: option.label }
  }

  // 3. 显示即时反馈
  feedbackText.value = option.feedback
  feedbackType.value = option.type

  // 4. 延迟 1.5 秒后切换下一题
  const wasLastQuestion = currentStep.value === questionList.value.length - 1
  setTimeout(() => {
    // 清除状态
    feedbackText.value = ''
    selectedOptionIndex.value = null
    isAnswering.value = false

    // 进度自动 +1
    currentStep.value++

    // 最后一题完成 → 同步数据到健康看板 + 积分奖励 + 通知父组件
    if (wasLastQuestion) {
      submitCheckIn(answers.value.sleep.value, answers.value.cervical.value, answers.value.water.value)
      addPoints(10)
      // 异步同步到后端数据库（失败不影响前端体验）
      checkInAddPoints().catch(err => console.error('[checkInAddPoints]', err))
      ElNotification({
        title: '🎉 打卡成功！',
        message: `今日健康值已满，积分+10！您当前总积分为 ${healthData.userPoints} 分。可以去积分商城兑换福利啦！`,
        type: 'success',
        duration: 5000
      })
      // 向父组件 index.vue 上抛打卡结果，驱动顶部数据卡联动
      emit('checkin-complete', {
        sleep: answers.value.sleep.label,
        water: waterDisplayMap[answers.value.water.value] ?? answers.value.water.label
      })
      // 记录今日已完成，防止页面切换回来后重刷
      localStorage.setItem('xingchen_checkin_completed_date', new Date().toLocaleDateString())
    }
  }, 1500)
}

/**
 * 重置打卡流程 (方便演示与测试)
 */
const resetCheckIn = () => {
  currentStep.value = 0
  isAnswering.value = false
  feedbackText.value = ''
  selectedOptionIndex.value = null
  answers.value = { sleep: 'normal', cervical: 'normal', water: 'normal' }
}
</script>

<style lang="scss" scoped>
.daily-health-check-in {
  width: 100%;

  .game-card {
    border-radius: 16px;
    padding: 20px;
    
    .header-progress {
      display: flex;
      justify-content: space-between;
      align-items: center;
      font-size: 14px;
      color: #909399;
      margin-bottom: 20px;

      .step-indicator {
        font-weight: bold;
        color: #409EFF;
      }
    }

    .progress-bar {
      margin-bottom: 30px;
    }

    /* 固定内容区最小高度，防止切换动画时卡片高度跳动 */
    .content-wrapper {
      min-height: 420px;
      position: relative;
    }

    .question-container {
      text-align: center;
      padding: 10px 0;

      .question-title {
        font-size: 22px;
        color: #303133;
        margin-bottom: 30px;
        line-height: 1.5;
        font-weight: 600;
      }

      .options-wrapper {
        display: flex;
        flex-direction: column;
        gap: 16px;
        padding: 0 20px;

        .option-btn {
          width: 100%;
          margin: 0;
          height: 60px;
          font-size: 17px;
          border-radius: 12px;
          color: #606266;
          transition: all 0.3s;

          &:hover:not(:disabled) {
            border-color: #409EFF;
            color: #409EFF;
            background-color: rgba(64, 158, 255, 0.05);
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(64, 158, 255, 0.1);
          }
          
          /* 被选中的选项高亮 */
          &.is-selected {
            border-color: #409EFF;
            color: #409EFF;
            background-color: rgba(64, 158, 255, 0.1);
            font-weight: bold;
          }
          
          /* 禁用状态优化 */
          &:disabled {
            cursor: not-allowed;
            opacity: 0.7;
          }
        }
      }

      /* 反馈文字包装器：保持固定高度防止挤压布局 */
      .feedback-wrapper {
        height: 60px;
        margin-top: 25px;
        display: flex;
        justify-content: center;
        align-items: flex-start;
      }

      /* 反馈文字样式 */
      .feedback-text {
        padding: 12px 24px;
        border-radius: 8px;
        font-size: 15px;
        font-weight: bold;
        display: inline-block;
        box-shadow: 0 2px 10px rgba(0,0,0,0.05);
        
        &.success {
          background-color: #f0f9eb;
          color: #67C23A;
          border: 1px solid #e1f3d8;
        }
        &.warning {
          background-color: #fdf6ec;
          color: #E6A23C;
          border: 1px solid #faecd8;
        }
        &.danger {
          background-color: #fef0f0;
          color: #F56C6C;
          border: 1px solid #fde2e2;
        }
      }
    }

    .finish-container {
      padding: 60px 0;
      text-align: center;
      display: flex;
      flex-direction: column;
      justify-content: center;
      align-items: center;
      height: 100%;
    }
  }
}

/* ==============================
   Vue Transition 动画样式
   ============================== */

/* 题目淡入淡出切换动画 */
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.4s ease, transform 0.4s ease;
}
.fade-enter-from {
  opacity: 0;
  transform: translateX(30px);
}
.fade-leave-to {
  opacity: 0;
  transform: translateX(-30px);
}

/* 反馈文字向上浮现动画 */
.fade-up-enter-active,
.fade-up-leave-active {
  transition: all 0.3s cubic-bezier(0.68, -0.55, 0.265, 1.55);
}
.fade-up-enter-from,
.fade-up-leave-to {
  opacity: 0;
  transform: translateY(15px);
}
</style>
