<template>
  <div class="app-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>员工积分兑换审核</span>
        </div>
      </template>

      <!-- 过滤区 -->
      <div class="filter-container">
        <el-form :inline="true" :model="queryParams" class="demo-form-inline" v-show="showSearch">
          <el-form-item label="状态筛选">
            <el-select v-model="queryParams.status" placeholder="请选择状态" clearable style="width: 150px">
              <el-option label="全部" value="" />
              <el-option label="待审核" value="0" />
              <el-option label="已通过" value="1" />
              <el-option label="已驳回" value="2" />
            </el-select>
          </el-form-item>
          <el-form-item>
            <el-button type="primary" icon="Search" @click="handleQuery">查询</el-button>
            <el-button icon="Refresh" @click="resetQuery">重置</el-button>
          </el-form-item>
        </el-form>
      </div>

      <!-- 工具栏 -->
      <el-row :gutter="10" class="mb8">
        <el-col :span="1.5">
          <el-button type="warning" plain icon="Download" @click="handleExport">导出</el-button>
        </el-col>
        <right-toolbar v-model:showSearch="showSearch" @queryTable="getList"></right-toolbar>
      </el-row>

      <!-- 数据表格 -->
      <el-table
        v-loading="loading"
        :data="tableData"
        style="width: 100%"
        border
        fit
        highlight-current-row
      >
        <el-table-column prop="applyTime" label="申请时间" width="180" align="center" />
        <el-table-column label="员工姓名与部门" width="200" align="center">
          <template #default="{ row }">
            {{ row.userName }} - {{ row.deptName }}
          </template>
        </el-table-column>
        <el-table-column prop="productName" label="商品兑换" min-width="150" align="center" />
        <el-table-column prop="pointsCost" label="消耗积分" width="120" align="center">
          <template #default="{ row }">
            <span class="points-text">{{ row.pointsCost }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="120" align="center">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.status)">
              {{ getStatusLabel(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" align="center">
          <template #default="{ row }">
            <template v-if="row.status === '0'">
              <el-button
                type="success"
                size="small"
                @click="handleApprove(row)"
              >
                通过
              </el-button>
              <el-button
                type="danger"
                size="small"
                @click="handleReject(row)"
              >
                驳回
              </el-button>
            </template>
            <template v-else-if="row.status === '2' && row.rejectReason">
               <el-tooltip
                  effect="dark"
                  :content="'驳回理由: ' + row.rejectReason"
                  placement="top"
                >
                  <el-button type="info" size="small" plain>查看理由</el-button>
                </el-tooltip>
            </template>
            <span v-else>-</span>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <pagination
        v-show="total > 0"
        :total="total"
        v-model:page="queryParams.pageNum"
        v-model:limit="queryParams.pageSize"
        @pagination="getList"
      />
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { listRedemptions, approveRedemption, rejectRedemption } from '@/api/hr/redemption'

// 数据列表
const tableData = ref([])
const loading = ref(true)
const showSearch = ref(true)
const total = ref(0)

// 查询参数
const queryParams = ref({
  pageNum: 1,
  pageSize: 10,
  status: ''
})

/** 查询列表 */
function getList() {
  loading.value = true
  listRedemptions(queryParams.value).then(response => {
    tableData.value = response.rows
    total.value = response.total
    loading.value = false
  }).catch(() => {
    loading.value = false
  })
}

/** 搜索按钮操作 */
function handleQuery() {
  queryParams.value.pageNum = 1
  getList()
}

/** 重置按钮操作 */
function resetQuery() {
  queryParams.value.status = ''
  queryParams.value.pageNum = 1
  getList()
}

/** 导出按钮操作 */
function handleExport() {
  ElMessage.info('导出功能开发中...')
}

// 获取状态对应的 Tag 类型（后端 status: "0"待审核, "1"已通过, "2"已驳回）
const getStatusType = (status) => {
  const statusMap = {
    '0': 'warning',
    '1': 'success',
    '2': 'danger'
  }
  return statusMap[status] || 'info'
}

// 获取状态对应的显示文本
const getStatusLabel = (status) => {
  const labelMap = {
    '0': '待审核',
    '1': '已通过',
    '2': '已驳回'
  }
  return labelMap[status] || '未知状态'
}

// 处理通过操作
const handleApprove = (row) => {
  ElMessageBox.confirm(
    `确认通过员工【${row.userName}】的【${row.productName}】兑换申请吗？`,
    '审核确认',
    {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'success',
    }
  ).then(() => {
    approveRedemption(row.id).then(() => {
      ElMessage({
        type: 'success',
        message: '已通过该申请!',
      })
      getList()
    })
  }).catch(() => {
    // 取消操作
  })
}

// 处理驳回操作
const handleReject = (row) => {
  ElMessageBox.prompt('请输入驳回理由', '审核驳回', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    inputPattern: /\S+/,
    inputErrorMessage: '驳回理由不能为空',
    type: 'warning'
  }).then(({ value }) => {
    rejectRedemption(row.id, { rejectReason: value }).then(() => {
      ElMessage({
        type: 'success',
        message: '已驳回该申请',
      })
      getList()
    })
  }).catch(() => {
    // 取消操作
  })
}

onMounted(() => {
  getList()
})
</script>

<style scoped>
.app-container {
  padding: 20px;
}
.box-card {
  width: 100%;
}
.card-header {
  font-size: 18px;
  font-weight: bold;
}
.filter-container {
  margin-bottom: 20px;
}
.points-text {
  color: #f56c6c;
  font-weight: bold;
  font-size: 16px;
}
:deep(.el-table tbody tr:hover > td) {
  background-color: #f5f7fa !important;
}
.mb8 {
  margin-bottom: 8px;
}
</style>
