<template>
  <div class="app-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>员工积分管理</span>
        </div>
      </template>

      <!-- 搜索区 -->
      <div class="filter-container">
        <el-form :inline="true" :model="queryParams" class="demo-form-inline" v-show="showSearch">
          <el-form-item label="用户名">
            <el-input v-model="queryParams.userName" placeholder="请输入用户名" clearable style="width: 200px" @keyup.enter="handleQuery" />
          </el-form-item>
          <el-form-item>
            <el-button type="primary" icon="Search" @click="handleQuery">查询</el-button>
            <el-button icon="Refresh" @click="resetQuery">重置</el-button>
          </el-form-item>
        </el-form>
      </div>

      <!-- 工具栏 -->
      <el-row :gutter="10" class="mb8">
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
        <el-table-column prop="userId" label="用户ID" width="80" align="center" />
        <el-table-column prop="userName" label="用户名" width="120" align="center" />
        <el-table-column prop="nickName" label="昵称" width="120" align="center" />
        <el-table-column label="所属部门" width="150" align="center">
          <template #default="{ row }">
            {{ row.dept ? row.dept.deptName : '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="points" label="当前积分" width="120" align="center">
          <template #default="{ row }">
            <span class="points-text">{{ row.points || 0 }}</span>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="150" align="center">
          <template #default="{ row }">
            <el-button
              type="primary"
              size="small"
              @click="handleAddPoints(row)"
              v-hasPermi="['hr:points:add']"
            >
              增加积分
            </el-button>
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
import { listUserPoints, addUserPoints } from '@/api/hr/points'

// 数据列表
const tableData = ref([])
const loading = ref(true)
const showSearch = ref(true)
const total = ref(0)

// 查询参数
const queryParams = ref({
  pageNum: 1,
  pageSize: 10,
  userName: ''
})

/** 查询列表 */
function getList() {
  loading.value = true
  listUserPoints(queryParams.value).then(response => {
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
  queryParams.value.userName = ''
  queryParams.value.pageNum = 1
  getList()
}

/** 增加积分操作 */
function handleAddPoints(row) {
  ElMessageBox.confirm(
    `确认给用户【${row.nickName || row.userName}】增加 100 积分吗？`,
    '增加积分确认',
    {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'info',
    }
  ).then(() => {
    addUserPoints(row.userId).then(() => {
      ElMessage({
        type: 'success',
        message: '积分增加成功！',
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
  color: #409eff;
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
