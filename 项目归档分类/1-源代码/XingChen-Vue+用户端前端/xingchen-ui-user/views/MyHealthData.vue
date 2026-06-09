<template>
  <div class="user-layout">
    <!-- 左侧边栏 -->
    <div class="user-sidebar">
      <div class="logo-container">
        <img :src="logoSrc" class="user-logo" alt="logo" />
        <div class="logo-text">星辰 · 用户端</div>
      </div>
      <div class="menu">
        <div class="menu-item" @click="router.push('/')">首页</div>
        <div class="menu-item active">健康看板</div>
        <div class="menu-item" @click="router.push('/points-mall')">积分商城</div>
        <div class="menu-item" @click="router.push('/ai-assistant')">AI健康助手</div>
        <div class="menu-item" @click="router.push('/profile')">个人中心</div>
        <div class="menu-item" @click="handleLogout">退出登录</div>
      </div>
    </div>

    <!-- 主内容区 -->
    <div class="user-content">
      <div class="user-header">
        <div class="welcome">我的健康数据看板</div>
        <el-button
          type="primary"
          :icon="Download"
          :loading="isExporting"
          @click="exportToPDF"
          class="export-btn"
        >导出体检报告 (PDF)</el-button>
      </div>

      <div class="dashboard">
        <div id="pdf-content">
        <el-row :gutter="20">
          <!-- 左侧：雷达图 span=8 -->
          <el-col :span="8">
            <el-card class="chart-card">
              <template #header>
                <span class="card-title">近期健康综合评分</span>
              </template>
              <div ref="radarChartRef" class="chart-box"></div>
            </el-card>
          </el-col>

          <!-- 右侧：趋势组合图 span=16 -->
          <el-col :span="16">
            <el-card class="chart-card">
              <template #header>
                <span class="card-title">近7天睡眠与饮水趋势</span>
              </template>
              <div ref="trendChartRef" class="chart-box"></div>
            </el-card>
          </el-col>
        </el-row>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Download } from '@element-plus/icons-vue'
import * as echarts from 'echarts'
import html2canvas from 'html2canvas'
import { jsPDF } from 'jspdf'
import request from '@/api/request'
import logoSrc from '@/assets/logo.png'
import { healthData } from '@/utils/mockHealthData'

const router = useRouter()

// 导出状态
const isExporting = ref(false)

// 图表容器 DOM 引用
const radarChartRef = ref(null)
const trendChartRef  = ref(null)

// 图表实例（用于 resize 和销毁）
let radarChart = null
let trendChart  = null

// ─── 雷达图配置构建函数（每次 mount 时读取最新 healthData）──────
function buildRadarOption () {
  return {
    title: {
      text: '综合得分',
      left: 'center',
      top: 8,
      textStyle: { fontSize: 13, color: '#6B7A7A', fontWeight: 'normal' }
    },
    tooltip: { trigger: 'item' },
    radar: {
      indicator: [
        { name: '睡眠质量',   max: 100 },
        { name: '颈椎舒适度', max: 100 },
        { name: '饮水达标率', max: 100 },
        { name: '运动活力',   max: 100 },
        { name: '情绪状态',   max: 100 }
      ],
      center: ['50%', '55%'],
      radius: '62%',
      axisName: { color: '#2F3A3A', fontSize: 12 },
      splitArea: {
        areaStyle: { color: ['rgba(125,185,182,0.04)', 'rgba(125,185,182,0.08)'] }
      },
      axisLine:  { lineStyle: { color: '#EAE2D8' } },
      splitLine: { lineStyle: { color: '#EAE2D8' } }
    },
    series: [{
      type: 'radar',
      data: [{
        // 直接读取 healthData 中的最新评分
        value: [
          healthData.radarScores.sleep,
          healthData.radarScores.cervical,
          healthData.radarScores.water,
          healthData.radarScores.exercise,
          healthData.radarScores.mood
        ],
        name: '本周评分',
        areaStyle: { color: 'rgba(125,185,182,0.25)' },
        lineStyle: { color: '#7DB9B6', width: 2 },
        itemStyle: { color: '#7DB9B6' },
        symbol: 'circle',
        symbolSize: 6
      }]
    }]
  }
}

// ─── 动态获取近7天X轴标签 ──────────────────────────────────────
const getLast7DaysLabels = () => {
  const daysMap = ['周日', '周一', '周二', '周三', '周四', '周五', '周六']
  const result = []
  const today = new Date()
  for (let i = 6; i >= 0; i--) {
    if (i === 0) {
      result.push('今日')
    } else {
      const pastDate = new Date(today)
      pastDate.setDate(today.getDate() - i)
      result.push(daysMap[pastDate.getDay()])
    }
  }
  return result
}

// ─── 趋势组合图配置构建函数 ────────────────────────────────────
function buildTrendOption () {
  return {
    tooltip: {
      trigger: 'axis',
      axisPointer: { type: 'cross' }
    },
    legend: {
      data: ['睡眠时长(h)', '饮水量(ml)'],
      top: 4,
      right: 12,
      textStyle: { color: '#6B7A7A', fontSize: 12 }
    },
    grid: { left: 48, right: 56, bottom: 32, top: 48 },
    xAxis: {
      type: 'category',
      data: getLast7DaysLabels(),
      axisLine:  { lineStyle: { color: '#EAE2D8' } },
      axisLabel: { color: '#6B7A7A' }
    },
    yAxis: [
      {
        type: 'value',
        name: '小时',
        min: 0, max: 12,
        interval: 2,
        nameTextStyle: { color: '#6B7A7A', fontSize: 11 },
        axisLabel: { color: '#6B7A7A', formatter: '{value}h' },
        splitLine: { lineStyle: { color: '#EAE2D8', type: 'dashed' } },
        axisLine: { show: false }
      },
      {
        type: 'value',
        name: 'ml',
        min: 0, max: 2000,
        interval: 500,
        nameTextStyle: { color: '#6B7A7A', fontSize: 11 },
        axisLabel: { color: '#6B7A7A' },
        splitLine: { show: false },
        axisLine: { show: false }
      }
    ],
    series: [
      {
        name: '睡眠时长(h)',
        type: 'line',
        yAxisIndex: 0,
        data: [...healthData.sleepData], // 读取 healthData 最新睡眠数据
        smooth: true,
        symbol: 'circle',
        symbolSize: 7,
        lineStyle: { color: '#F2B880', width: 2.5 },
        itemStyle: { color: '#F2B880' },
        areaStyle: {
          color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
            { offset: 0, color: 'rgba(242,184,128,0.28)' },
            { offset: 1, color: 'rgba(242,184,128,0.02)' }
          ])
        },
        markLine: {
          silent: true,
          data: [{ yAxis: 5, name: '5h警戒线' }],
          lineStyle: { color: '#E57373', type: 'dashed', width: 1.5 },
          label: { formatter: '5h警戒', color: '#E57373', fontSize: 11 }
        }
      },
      {
        name: '饮水量(ml)',
        type: 'bar',
        yAxisIndex: 1,
        data: [...healthData.waterData], // 读取 healthData 最新饮水数据
        barMaxWidth: 32,
        itemStyle: {
          color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
            { offset: 0, color: '#91CCE8' },
            { offset: 1, color: '#C7E8F5' }
          ]),
          borderRadius: [4, 4, 0, 0]
        },
        markLine: {
          silent: true,
          data: [{ yAxis: 1500, name: '1500ml达标线' }],
          lineStyle: { color: '#7DB9B6', type: 'dashed', width: 1.5 },
          label: { formatter: '达标线', color: '#7DB9B6', fontSize: 11 }
        }
      }
    ]
  }
}

// ─── 初始化 & resize ─────────────────────────────────────────
const handleResize = () => {
  radarChart?.resize()
  trendChart?.resize()
}

onMounted(() => {
  radarChart = echarts.init(radarChartRef.value, null, { renderer: 'canvas' })
  trendChart  = echarts.init(trendChartRef.value,  null, { renderer: 'canvas' })
  // 每次进入页面时调用构建函数，确保拿到最新 healthData
  radarChart.setOption(buildRadarOption())
  trendChart.setOption(buildTrendOption())
  window.addEventListener('resize', handleResize)
})

onUnmounted(() => {
  window.removeEventListener('resize', handleResize)
  radarChart?.dispose()
  trendChart?.dispose()
})

// ─── 导出 PDF ────────────────────────────────────────────────
const exportToPDF = async () => {
  isExporting.value = true
  try {
    const el = document.getElementById('pdf-content')
    // html2canvas 截图：scale=2 保证清晰度，背景强制白色防黑底
    const canvas = await html2canvas(el, {
      scale: 2,
      useCORS: true,
      backgroundColor: '#ffffff'
    })
    const imgData = canvas.toDataURL('image/png')

    // A4 尺寸（mm）
    const pageWidth = 210
    const pageHeight = 297
    // 计算图片在 PDF 中的宽高（保持比例）
    const imgWidth = pageWidth
    const imgHeight = (canvas.height * pageWidth) / canvas.width

    const pdf = new jsPDF('p', 'mm', 'a4')

    // 如果图片高度超过一页，分页处理
    let position = 0
    let remainingHeight = imgHeight
    while (remainingHeight > 0) {
      pdf.addImage(imgData, 'PNG', 0, position, imgWidth, imgHeight)
      remainingHeight -= pageHeight
      if (remainingHeight > 0) {
        pdf.addPage()
        position -= pageHeight
      }
    }

    pdf.save('星辰健康报告_个人版.pdf')
    ElMessage.success('PDF 报告导出成功！')
  } catch (err) {
    console.error('[exportToPDF]', err)
    ElMessage.error('导出失败，请重试')
  } finally {
    isExporting.value = false
  }
}

// ─── 登出 ────────────────────────────────────────────────────
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

/* ── 侧边栏 ── */
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

/* ── 主内容 ── */
.user-content {
  flex: 1;
  background-color: var(--bg-0);
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.user-header {
  height: 80px;
  padding: 0 40px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  background-color: var(--bg-1);
  border-bottom: 1px solid var(--line);
  flex-shrink: 0;

  .welcome {
    font-size: 18px;
    color: var(--text-1);
    font-weight: 600;
  }

  .export-btn {
    border-radius: 8px;
  }
}

.dashboard {
  padding: 32px 40px;
  overflow-y: auto;
  flex: 1;
}

/* ── 图表卡片 ── */
.chart-card {
  .card-title {
    font-size: 15px;
    font-weight: 600;
    color: var(--text-1);
  }
}

/* 图表容器固定高度，ECharts 需要明确高度才能渲染 */
.chart-box {
  height: 350px;
  width: 100%;
}

/* PDF 截图区域：强制白底，防止 html2canvas 输出黑底 */
#pdf-content {
  background-color: #ffffff;
  padding: 4px 0;
}
</style>
