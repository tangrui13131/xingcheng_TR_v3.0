<template>
  <div class="daily-health-check-in">
    <el-card class="game-card" shadow="hover">
      <!-- 进度提示 -->
      <div class="header-progress">
        <span>今日健康充电站</span>
        <span class="step-indicator">{{ currentStep + 1 }} / {{ questionList.length }}</span>
      </div>

      <!-- 渐进式进度条 -->
      <el-progress 
        :percentage="((currentStep) / questionList.length) * 100" 
        :show-text="false"
        color="#409EFF"
        class="progress-bar"
      />

      <!-- 问题展示区 (带淡入淡出动画) -->
      <transition name="fade" mode="out-in">
        <div class="question-container" v-if="currentQuestion" :key="currentStep">
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

          <!-- 即时反馈区域 -->
          <transition name="fade-up">
            <div v-if="feedbackText" class="feedback-text" :class="feedbackType">
              {{ feedbackText }}
            </div>
          </transition>
        </div>
        
        <!-- 结束状态 -->
        <div v-else-if="currentStep >= questionList.length" class="finish-container" key="finish">
          <el-result icon="success" title="完成打卡" sub-title="今日健康值已充满！感谢您的记录。">
            <template #extra>
              <el-button type="primary" @click="resetCheckIn">再测一次</el-button>
            </template>
          </el-result>
        </div>
      </transition>
    </el-card>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'

// 状态管理
const currentStep = ref(0)
const isAnswering = ref(false)
const selectedOptionIndex = ref(null)
const feedbackText = ref('')
const feedbackType = ref('')

// 游戏化题库数据 (补充反馈文案)
const questionList = ref([
  {
    id: 1,
    title: '昨晚的“系统休眠”（睡眠）质量如何？',
    options: [
      { label: '深度睡眠，满血复活', value: 'good', feedback: '太棒了！今天一定是个高产出的一天！🌟', type: 'success' },
      { label: '间歇唤醒，有点疲惫', value: 'normal', feedback: '辛苦了！今天允许自己摸鱼半小时吧☕', type: 'warning' },
      { label: '彻底失眠，电量见底', value: 'bad', feedback: '抱抱！中午一定要补个觉，别太拼了🛌', type: 'danger' }
    ]
  },
  {
    id: 2,
    title: '现在你的颈椎感觉怎么样？',
    options: [
      { label: '灵活自如，还能再战', value: 'good', feedback: '保持这个姿势！你就是办公室最靓的仔😎', type: 'success' },
      { label: '有点僵硬，需要转转', value: 'normal', feedback: '起来倒杯水，顺便做个“米”字操吧🔄', type: 'warning' },
      { label: '急需救援，已经卡死', value: 'bad', feedback: '快站起来！扭脖子活动一下！立刻！马上！🚨', type: 'danger' }
    ]
  },
  {
    id: 3,
    title: '今天的水分补充进度？',
    options: [
      { label: '水杯已空，补充完毕', value: 'good', feedback: '吨吨吨！你的肾脏和皮肤都在感谢你💧', type: 'success' },
      { label: '喝了一半，还在努力', value: 'normal', feedback: '再喝两口，离目标只有一步之遥啦💪', type: 'warning' },
      { label: '完全忘记，现在去倒', value: 'bad', feedback: '身体拉响干旱警报，带薪接水去！🏃‍♂️', type: 'danger' }
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

  // 2. 显示即时反馈
  feedbackText.value = option.feedback
  feedbackType.value = option.type

  // 3. 延迟 1.5 秒后切换下一题
  setTimeout(() => {
    // 清除状态
    feedbackText.value = ''
    selectedOptionIndex.value = null
    isAnswering.value = false
    
    // 进入下一步 (此时视图会通过 v-if 和 transition 自动过渡)
    currentStep.value++
  }, 1500)
}

/**
 * 重置打卡流程 (Demo 用)
 */
const resetCheckIn = () => {
  currentStep.value = 0
}
</script>

<style lang="scss" scoped>
.daily-health-check-in {
  padding: 20px;
  max-width: 600px;
  margin: 0 auto;

  .game-card {
    border-radius: 16px;
    padding: 10px;
    min-height: 450px; /* 保证高度稳定，防止动画跳动 */

    .header-progress {
      display: flex;
      justify-content: space-between;
      align-items: center;
      font-size: 14px;
      color: #909399;
      margin-bottom: 15px;

      .step-indicator {
        font-weight: bold;
        color: #409EFF;
      }
    }

    .progress-bar {
      margin-bottom: 40px;
    }

    .question-container {
      text-align: center;
      padding: 10px 0 30px;

      .question-title {
        font-size: 22px;
        color: #303133;
        margin-bottom: 40px;
        line-height: 1.4;
      }

      .options-wrapper {
        display: flex;
        flex-direction: column;
        gap: 20px;
        padding: 0 20px;

        .option-btn {
          width: 100%;
          margin: 0;
          height: 60px;
          font-size: 16px;
          border-radius: 12px;
          border: 2px solid #EBEEF5;
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

      /* 反馈文字样式 */
      .feedback-text {
        margin-top: 30px;
        padding: 12px 20px;
        border-radius: 8px;
        font-size: 15px;
        font-weight: bold;
        display: inline-block;
        
        &.success {
          background-color: #f0f9eb;
          color: #67C23A;
        }
        &.warning {
          background-color: #fdf6ec;
          color: #E6A23C;
        }
        &.danger {
          background-color: #fef0f0;
          color: #F56C6C;
        }
      }
    }

    .finish-container {
      padding: 40px 0;
      text-align: center;
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
  transform: translateX(20px);
}
.fade-leave-to {
  opacity: 0;
  transform: translateX(-20px);
}

/* 反馈文字向上浮现动画 */
.fade-up-enter-active,
.fade-up-leave-active {
  transition: all 0.3s cubic-bezier(0.68, -0.55, 0.265, 1.55);
}
.fade-up-enter-from {
  opacity: 0;
  transform: translateY(15px);
}
.fade-up-leave-to {
  opacity: 0;
  transform: translateY(-15px);
}
</style>

<!-- 暗色模式独立非-scoped块，避免 Vue scoped 封锁祖先选择器 -->
<style lang="scss">
html.dark,
body.dark {
  /* 打卡卡片容器 */
  .daily-health-check-in {
    .game-card {
      background-color: #1d1e2b !important;
      border-color: #363748 !important;

      .el-card__body {
        background-color: #1d1e2b !important;
      }

      /* 顶部标题文字 */
      .header-progress > span:first-child {
        color: #a0a3b1 !important;
      }
      .step-indicator {
        color: #409EFF !important;
      }

      /* 题目标题 */
      .question-title {
        color: #dde1ee !important;
      }

      /* 选项按钮 */
      .option-btn,
      .option-btn.el-button {
        color: #c4c8d8 !important;
        border-color: #404358 !important;
        background-color: #252636 !important;

        span {
          color: #c4c8d8 !important;
        }

        &:hover:not(.is-disabled) {
          color: #409EFF !important;
          border-color: #409EFF !important;
          background-color: rgba(64, 158, 255, 0.12) !important;
          box-shadow: 0 4px 12px rgba(64, 158, 255, 0.2) !important;

          span { color: #409EFF !important; }
        }

        &.is-selected {
          color: #409EFF !important;
          border-color: #409EFF !important;
          background-color: rgba(64, 158, 255, 0.15) !important;

          span { color: #409EFF !important; }
        }

        &.is-disabled {
          opacity: 0.45 !important;
        }
      }

      /* 反馈文字 */
      .feedback-text {
        &.success {
          background-color: rgba(103, 194, 58, 0.15) !important;
          color: #95d475 !important;
        }
        &.warning {
          background-color: rgba(230, 162, 60, 0.15) !important;
          color: #f0c060 !important;
        }
        &.danger {
          background-color: rgba(245, 108, 108, 0.15) !important;
          color: #f89898 !important;
        }
      }
    }
  }
}
</style>