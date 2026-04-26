<template>
  <div class="app-container hr-dashboard">
    <!-- 调试信息 -->
    <div style="background: #409EFF; color: white; padding: 5px; text-align: center; border-radius: 4px; margin-bottom: 10px;">
      HR 健康管理看板 - V3.1 (已加载)
    </div>
    
    <!-- 顶部核心数据概览 -->
    <el-row :gutter="20" class="panel-group">
      <!-- AI 健康分析总结 -->
      <el-col :xs="24" :lg="12" class="card-panel-col">
        <el-card shadow="hover" class="stat-card ai-summary-card">
          <div class="card-content" style="flex-direction: column; align-items: flex-start; height: 100%;">
            <div class="data-wrapper" style="text-align: left; width: 100%;">
              <div class="data-title" style="margin-bottom: 15px; font-weight: bold; color: #303133;">
                AI 健康分析总结 // MOCKED DEMO
              </div>
              <div class="ai-text-content" style="color: #606266; font-size: 14px; flex: 1; min-height: 40px; line-height: 1.5;">
                {{ summaryText }}
              </div>
            </div>
            <div style="width: 100%; text-align: right; margin-top: auto;">
              <el-button type="primary" size="small" :loading="isGenerating" @click="generateSummary" :disabled="isTyping">生成健康总结</el-button>
            </div>
          </div>
        </el-card>
      </el-col>
      
      <!-- 异常预警部门数 -->
      <el-col :xs="24" :sm="12" :lg="4" class="card-panel-col">
        <el-card shadow="hover" class="stat-card">
          <div class="card-content">
            <div class="icon-wrapper icon-red">
              <el-icon class="card-icon"><Warning /></el-icon>
            </div>
            <div class="data-wrapper">
              <div class="data-title">异常预警部门数</div>
              <div class="data-value">{{ alertDepts }}</div>
            </div>
          </div>
        </el-card>
      </el-col>

      <el-col :xs="24" :sm="12" :lg="4" class="card-panel-col">
        <el-card shadow="hover" class="stat-card">
          <div class="card-content">
            <div class="icon-wrapper icon-orange">
              <el-icon class="card-icon"><AlarmClock /></el-icon>
            </div>
            <div class="data-wrapper">
              <div class="data-title">高压预警人数</div>
              <div class="data-value">{{ highPressureUsers }}</div>
            </div>
          </div>
        </el-card>
      </el-col>

      <el-col :xs="24" :sm="12" :lg="4" class="card-panel-col">
        <el-card shadow="hover" class="stat-card">
          <div class="card-content">
            <div class="icon-wrapper icon-green">
              <el-icon class="card-icon"><CircleCheck /></el-icon>
            </div>
            <div class="data-wrapper">
              <div class="data-title">打卡人数</div>
              <div class="data-value">{{ checkInUsers }}</div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 核心图表分析区域 -->
    <el-row :gutter="20">
      <!-- 核心部门健康画像 (雷达图) -->
      <el-col :xs="24" :lg="8" class="card-box">
        <el-card shadow="hover">
          <template #header>
            <div class="card-header">
              <span>核心部门健康画像</span>
            </div>
          </template>
          <div ref="radarChartRef" style="height: 350px; width: 100%;" />
        </el-card>
      </el-col>

      <!-- 全公司压力本周波动趋势 (折线图) -->
      <el-col :xs="24" :lg="16" class="card-box">
        <el-card shadow="hover">
          <template #header>
            <div class="card-header">
              <span>全公司压力本周波动趋势</span>
            </div>
          </template>
          <div ref="lineChartRef" style="height: 350px; width: 100%;" />
        </el-card>
      </el-col>
    </el-row>

    <!-- 实时健康预警动态区域 -->
    <el-row :gutter="20">
      <el-col :span="24" class="card-box">
        <el-card shadow="hover">
          <template #header>
            <div class="card-header">
              <span>系统警报 // 健康异常预警</span>
            </div>
          </template>
          <div class="timeline-wrapper">
            <el-timeline>
              <el-timeline-item
                v-for="(activity, index) in activities"
                :key="index"
                :type="activity.type"
                :color="activity.color"
                :size="activity.size"
                :timestamp="activity.timestamp"
                placement="top"
              >
                <div class="timeline-content" :class="`is-${activity.type || 'info'}`">
                  {{ activity.content }}
                </div>
              </el-timeline-item>
            </el-timeline>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, onMounted, onBeforeUnmount, watch } from 'vue'
import { PieChart, Warning, AlarmClock, CircleCheck } from '@element-plus/icons-vue'
import * as echarts from 'echarts'
import useAppStore from '@/store/modules/app'

console.log('HR Health Dashboard Component Loaded')

const appStore = useAppStore()

// 统计模拟数据
const healthScore = ref(87.5) // 调整为87.5配合提示文本
const alertDepts = ref(3)
const highPressureUsers = ref(12)
const checkInUsers = ref(456)

// AI 总结交互状态
const defaultText = '点击下方按钮，模拟生成本周健康数据分析汇总。'
const summaryText = ref(defaultText)
const isGenerating = ref(false)
const isTyping = ref(false)

const mockAnalysisText = '本周全公司平均健康评分为87.5分，状态良好。核心风险集中在研发部，其久坐时长与压力指数偏高，建议HR介入项目进展调整。系统检测到销售部颈椎反馈增加。由于周四、周五压力整体呈上升趋势，建议在周五下午安排工间延长活动。'

/**
 * 模拟生成健康总结并实现打字机效果
 */
const generateSummary = () => {
  if (isGenerating.value || isTyping.value) return
  
  // 1. 进入加载状态
  isGenerating.value = true
  summaryText.value = 'AI 正在深入分析本周健康数据，请稍候...'
  
  // 2. 模拟网络请求或 AI 计算耗时 (2秒)
  setTimeout(() => {
    isGenerating.value = false
    isTyping.value = true
    summaryText.value = '' // 清空当前文本准备打字
    
    // 3. 执行打字机效果
    let currentIndex = 0
    const typingInterval = setInterval(() => {
      if (currentIndex < mockAnalysisText.length) {
        summaryText.value += mockAnalysisText.charAt(currentIndex)
        currentIndex++
      } else {
        // 打字结束
        clearInterval(typingInterval)
        isTyping.value = false
      }
    }, 50) // 每个字间隔 50 毫秒
  }, 2000)
}

// 预警动态模拟数据
const activities = ref([
  {
    content: '检测到研发部前置组连续3天整体压力值超标，建议HR介入。',
    timestamp: '今天 09:30',
    type: 'danger',
    size: 'large',
    color: '#F56C6C'
  },
  {
    content: '销售部张**反馈严重颈椎不平衡。',
    timestamp: '昨天 18:00',
    type: 'warning',
    color: '#E6A23C'
  },
  {
    content: '办公室工间操活动参与率达85%。',
    timestamp: '2026-04-10',
    type: 'success',
    color: '#67C23A'
  }
])

// 图表 DOM 引用
const radarChartRef = ref(null)
const lineChartRef = ref(null)

let radarChart = null
let lineChart = null

/**
 * 初始化雷达图
 */
const initRadarChart = () => {
  if (!radarChartRef.value) return
  radarChart = echarts.init(radarChartRef.value)
  const option = {
    color: ['#409EFF', '#67C23A'],
    tooltip: {
      trigger: 'item'
    },
    legend: {
      data: ['研发部', '销售部'],
      bottom: '0'
    },
    radar: {
      indicator: [
        { name: '颈椎风险', max: 100 },
        { name: '眼部疲劳', max: 100 },
        { name: '压力指数', max: 100 },
        { name: '久坐时长', max: 100 },
        { name: '借款异常', max: 100 }
      ],
      radius: '65%'
    },
    series: [
      {
        name: '部门健康画像对比',
        type: 'radar',
        data: [
          {
            value: [85, 90, 75, 95, 20],
            name: '研发部',
            areaStyle: {
              color: 'rgba(64, 158, 255, 0.2)'
            }
          },
          {
            value: [60, 70, 85, 50, 40],
            name: '销售部',
            areaStyle: {
              color: 'rgba(103, 194, 58, 0.2)'
            }
          }
        ]
      }
    ]
  }
  radarChart.setOption(option)
}

/**
 * 初始化折线图
 */
const initLineChart = () => {
  if (!lineChartRef.value) return
  lineChart = echarts.init(lineChartRef.value)
  const option = {
    color: ['#409EFF'],
    tooltip: {
      trigger: 'axis',
      axisPointer: {
        type: 'cross',
        label: {
          backgroundColor: '#6a7985'
        }
      }
    },
    grid: {
      left: '3%',
      right: '4%',
      bottom: '3%',
      containLabel: true
    },
    xAxis: [
      {
        type: 'category',
        boundaryGap: false,
        data: ['周一', '周二', '周三', '周四', '周五'],
        axisLine: {
          lineStyle: { color: '#909399' }
        }
      }
    ],
    yAxis: [
      {
        type: 'value',
        min: 0,
        max: 100,
        name: '压力指数',
        axisLine: {
          lineStyle: { color: '#909399' }
        },
        splitLine: {
          lineStyle: { type: 'dashed', color: '#E4E7ED' }
        }
      }
    ],
    series: [
      {
        name: '全公司平均压力',
        type: 'line',
        smooth: true,
        lineStyle: {
          width: 3,
          color: '#409EFF'
        },
        showSymbol: false,
        areaStyle: {
          opacity: 0.3,
          color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
            { offset: 0, color: '#409EFF' },
            { offset: 1, color: '#fff' }
          ])
        },
        data: [45, 52, 48, 65, 58]
      }
    ]
  }
  lineChart.setOption(option)
}

/**
 * 处理窗口调整
 */
const handleResize = () => {
  radarChart && radarChart.resize()
  lineChart && lineChart.resize()
}

// 监听侧边栏变化，触发 resize
watch(() => appStore.sidebar.opened, () => {
  setTimeout(() => {
    handleResize()
  }, 300) // 等待动画结束
})

onMounted(() => {
  initRadarChart()
  initLineChart()
  window.addEventListener('resize', handleResize)
})

onBeforeUnmount(() => {
  window.removeEventListener('resize', handleResize)
  radarChart && radarChart.dispose()
  lineChart && lineChart.dispose()
})
</script>

<style lang="scss" scoped>
.hr-dashboard {
  padding: 20px;
  background-color: #f0f2f5;
  min-height: calc(100vh - 84px);

  .panel-group {
    margin-bottom: 20px;
  }

  .card-box {
    margin-bottom: 20px;
  }

  .stat-card {
    border: none;
    border-radius: 8px;
    
    :deep(.el-card__body) {
      padding: 20px;
    }

    .card-content {
      display: flex;
      align-items: center;
      justify-content: space-between;
    }

    .icon-wrapper {
      padding: 16px;
      border-radius: 12px;
      transition: all 0.3s;
      
      .card-icon {
        font-size: 32px;
      }
    }

    /* 指标颜色样式 */
    .icon-blue {
      background: rgba(64, 158, 255, 0.1);
      .card-icon { color: #409EFF; }
    }
    .icon-red {
      background: rgba(245, 108, 108, 0.1);
      .card-icon { color: #F56C6C; }
    }
    .icon-orange {
      background: rgba(230, 162, 60, 0.1);
      .card-icon { color: #E6A23C; }
    }
    .icon-green {
      background: rgba(103, 194, 58, 0.1);
      .card-icon { color: #67C23A; }
    }

    .data-wrapper {
      text-align: right;
      
      .data-title {
        font-size: 14px;
        color: #909399;
        margin-bottom: 8px;
      }

      .data-value {
        font-size: 24px;
        color: #303133;
        font-weight: bold;
      }
    }
  }

  .card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    font-weight: bold;
  }

  .timeline-wrapper {
    padding: 10px 5px 0;
    
    :deep(.el-timeline-item__timestamp) {
      color: #909399;
      font-size: 13px;
    }

    .timeline-content {
      color: #303133;
      font-size: 14px;
      padding: 10px 15px;
      background: #f4f4f5;
      border-radius: 4px;
      margin-top: 5px;

      &.is-danger {
        background: #fef0f0;
        color: #f56c6c;
      }
      
      &.is-warning {
        background: #fdf6ec;
        color: #e6a23c;
      }

      &.is-success {
        background: #f0f9eb;
        color: #67c23a;
      }
    }
  }
}
</style>
