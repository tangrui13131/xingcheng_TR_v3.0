<template>
  <div class="app-container home tech-dashboard">
    <!-- 顶部核心数据概览 -->
    <el-row :gutter="20" class="panel-group">
      <el-col :xs="24" :sm="12" :lg="6" v-for="(card, index) in statCards" :key="index" class="card-panel-col">
        <div class="cyber-card stat-card">
          <!-- 四个发光装饰角 -->
          <div class="corner top-left"></div>
          <div class="corner top-right"></div>
          <div class="corner bottom-left"></div>
          <div class="corner bottom-right"></div>
          
          <div class="card-content">
            <div class="icon-wrapper" :class="'icon-' + card.type">
              <el-icon class="card-icon"><component :is="card.icon" /></el-icon>
            </div>
            <div class="data-wrapper">
              <div class="data-title">{{ card.title }}</div>
              <div class="data-value">
                <count-to :start-val="0" :end-val="card.value" :duration="2600" />
              </div>
            </div>
          </div>
          <!-- 底部扫描线 -->
          <div class="scan-line"></div>
        </div>
      </el-col>
    </el-row>

    <el-row :gutter="20" class="main-content-row">
      <!-- 核心项目进度监控 -->
      <el-col :xs="24" :sm="24" :lg="16">
        <div class="cyber-card large-card">
          <div class="corner top-left"></div>
          <div class="corner top-right"></div>
          <div class="corner bottom-left"></div>
          <div class="corner bottom-right"></div>

          <div class="card-header">
            <div class="header-title">
              <span class="blink-dot"></span>
              CORE PROJECT MONITOR // 核心进度监控
            </div>
            <button class="cyber-btn-small">DETAILS</button>
          </div>
          
          <div class="card-body">
            <div class="progress-item" v-for="(item, index) in projectProgress" :key="index">
              <div class="progress-label">
                <span class="label-name">> {{ item.name }}</span>
                <span class="label-value" :style="{ color: item.color }">{{ item.percentage }}%</span>
              </div>
              <div class="cyber-progress">
                <div class="progress-bar" :style="{ width: item.percentage + '%', backgroundColor: item.color, boxShadow: `0 0 10px ${item.color}` }"></div>
              </div>
            </div>
          </div>
        </div>
      </el-col>

      <!-- 系统动态与通知 -->
      <el-col :xs="24" :sm="24" :lg="8">
        <div class="cyber-card large-card timeline-card">
          <div class="corner top-left"></div>
          <div class="corner top-right"></div>
          <div class="corner bottom-left"></div>
          <div class="corner bottom-right"></div>

          <div class="card-header">
            <div class="header-title">
              <span class="blink-dot warning"></span>
              SYSTEM LOGS // 动态与通知
            </div>
          </div>

          <div class="card-body">
            <el-timeline class="cyber-timeline">
              <el-timeline-item
                v-for="(activity, index) in activities"
                :key="index"
                :icon="activity.icon"
                :color="activity.color || '#42b983'"
                :timestamp="activity.timestamp"
                placement="top"
              >
                <div class="timeline-content" :class="{ 'is-danger': activity.type === 'danger' }">
                  {{ activity.content }}
                </div>
              </el-timeline-item>
            </el-timeline>
          </div>
        </div>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { User, ShoppingCart, Money, ChatDotRound, Warning } from '@element-plus/icons-vue'

// 简单的 CountTo 组件，用于展示数字
const CountTo = {
  props: ['endVal'],
  template: '<span>{{ endVal }}</span>'
}

// 1. 顶部统计卡片模拟数据
const statCards = ref([
  { title: 'NEW USERS (DAY)', value: 1256, icon: User, type: 'people' },
  { title: 'SYSTEM ALERTS', value: 83, icon: ChatDotRound, type: 'message' },
  { title: 'REVENUE (K)', value: 9240, icon: Money, type: 'money' },
  { title: 'ORDERS (MONTH)', value: 13600, icon: ShoppingCart, type: 'shopping' }
])

// 2. 项目进度模拟数据 (使用主题色)
const projectProgress = ref([
  { name: '华东区多模态 AI 接入项目', percentage: 78, color: '#42b983' },
  { name: '财务系统底层架构重构', percentage: 100, color: '#13ce66' },
  { name: '移动端小程序 UI 升级', percentage: 45, color: '#ffba00' },
  { name: '服务器集群容灾演练', percentage: 12, color: '#ff4949' },
  { name: '年度业务数据清洗', percentage: 60, color: '#909399' }
])

// 3. 系统动态时间轴模拟数据
const activities = ref([
  { content: '系统 V2.0 版本更新发布', timestamp: '今天 08:30', color: '#42b983', icon: Warning },
  { content: '管理员 王** 备份了数据库', timestamp: '昨天 23:15', color: '#13ce66' },
  { content: '检测到异常登录 IP，已拦截', timestamp: '昨天 14:20', color: '#ff4949', type: 'danger' },
  { content: '财务报表模块生成完毕', timestamp: '2026-04-03', color: '#909399' }
])
</script>

<style lang="scss" scoped>
$neon-cyan: #42b983;
$neon-green: #13ce66;
$neon-red: #ff4949;
$neon-yellow: #ffba00;
$bg-card: #ffffff;

.tech-dashboard {
  padding: 20px;
  background-color: transparent;
  min-height: calc(100vh - 84px);
  color: #333333;
}

/* ==============================
   常规卡片通用基类
   ============================== */
.cyber-card {
  position: relative;
  background: $bg-card;
  border: 1px solid #ebeef5;
  border-radius: 4px;
  box-shadow: 0 2px 12px 0 rgba(0,0,0,0.1);
  transition: all 0.3s;
  overflow: hidden;

  // 移除发光角
  .corner {
    display: none;
  }

  &:hover {
    box-shadow: 0 4px 16px 0 rgba(0,0,0,0.15);
    
    .corner {
      width: 25px; height: 25px;
      box-shadow: 0 0 10px $neon-cyan;
    }
  }
}

/* ==============================
   顶部四格统计卡片
   ============================== */
.panel-group {
  margin-bottom: 20px;

.stat-card {
    height: 110px;
    display: flex;
    align-items: center;
    padding: 0 20px;
    cursor: pointer;

    .card-content {
      width: 100%;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }

    .icon-wrapper {
      padding: 12px;
      border-radius: 8px;
      background: rgba(0, 0, 0, 0.05);
      border: 1px solid transparent;
      transition: all 0.3s;

      .card-icon {
        font-size: 40px;
        color: #909399;
        transition: all 0.3s;
      }
    }

    // 默认高亮效果
    &.card-panel-col:nth-child(1) .icon-wrapper .card-icon { color: $neon-cyan; }
    &.card-panel-col:nth-child(2) .icon-wrapper .card-icon { color: $neon-yellow; }
    &.card-panel-col:nth-child(3) .icon-wrapper .card-icon { color: $neon-green; }
    &.card-panel-col:nth-child(4) .icon-wrapper .card-icon { color: #9d00ff; }

    &:hover {
      .icon-wrapper {
        background: rgba(0, 0, 0, 0.08);
        transform: scale(1.1);
      }
    }

    .data-wrapper {
      text-align: right;
      
      .data-title {
        font-size: 12px;
        color: #909399;
        margin-bottom: 8px;
        letter-spacing: 1px;
        font-weight: bold;
      }

      .data-value {
        font-size: 28px;
        color: #333333;
        font-weight: bold;
      }
    }

    .scan-line {
      display: none;
    }
  }
}

/* ==============================
   主内容区域 (大卡片)
   ============================== */
.main-content-row {
  .large-card {
    height: 100%;
    min-height: 400px;
    padding: 20px;
    display: flex;
    flex-direction: column;
  }

  .card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding-bottom: 15px;
    border-bottom: 1px solid #ebeef5;
    margin-bottom: 20px;

    .header-title {
      font-size: 16px;
      color: #333333;
      font-weight: bold;
      letter-spacing: 2px;
      display: flex;
      align-items: center;

      .blink-dot {
        width: 8px; height: 8px;
        background: $neon-cyan;
        border-radius: 50%;
        margin-right: 10px;

        &.warning {
          background: $neon-yellow;
        }
      }
    }

    .cyber-btn-small {
      background: transparent;
      border: 1px solid $neon-cyan;
      color: $neon-cyan;
      padding: 4px 12px;
      font-size: 12px;
      cursor: pointer;
      font-family: inherit;
      border-radius: 4px;
      transition: all 0.3s;
      
      &:hover {
        background: $neon-cyan;
        color: #fff;
      }
    }
  }

  .card-body {
    flex: 1;
    overflow-y: auto;
    padding-right: 10px;
    
    &::-webkit-scrollbar { width: 4px; }
    &::-webkit-scrollbar-thumb { background: rgba(0, 0, 0, 0.2); border-radius: 2px; }
  }
}

/* ==============================
   自定义进度条
   ============================== */
.progress-item {
  margin-bottom: 25px;

  .progress-label {
    display: flex;
    justify-content: space-between;
    margin-bottom: 8px;
    font-size: 13px;
    
    .label-name { color: #606266; }
    .label-value { font-weight: bold; color: #333333; }
  }

  .cyber-progress {
    width: 100%;
    height: 8px;
    background: #ebeef5;
    border-radius: 4px;
    overflow: hidden;
    position: relative;

    .progress-bar {
      height: 100%;
      border-radius: 4px;
      position: relative;
    }
  }
}

/* ==============================
   时间轴样式
   ============================== */
.cyber-timeline {
  padding-left: 5px;

  :deep(.el-timeline-item__tail) {
    border-left: 2px solid #e4e7ed;
  }
  
  :deep(.el-timeline-item__timestamp) {
    color: #909399;
    font-size: 13px;
  }

  .timeline-content {
    color: #303133;
    font-size: 14px;
    padding: 8px 12px;
    background: #f4f4f5;
    border-radius: 4px;
    margin-top: 5px;

    &.is-danger {
      background: #fef0f0;
      color: #f56c6c;
    }
  }
}
</style>