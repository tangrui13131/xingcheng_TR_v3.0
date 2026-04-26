<template>
  <div style="padding: 30px; background: #fff; min-height: calc(100vh - 84px);">
    <div style="background: red; color: white; padding: 10px; text-align: center; margin-bottom: 20px;">
      警告：您当前正在查看的是 dashboard.vue 适配文件，而非主看板。
    </div>
    <el-result icon="success" title="模块加载成功" sub-title="HR健康看板入口已正确链接">
      <template #extra>
        <p>您现在看到的这个页面是 <b>src/views/hr/dashboard.vue</b>。</p>
        <p>如果能看到这个页面，说明路由匹配问题已彻底解决。</p>
      </template>
    </el-result>
  </div>
</template>

<script>
export default {
  name: 'HrDashboard'
}
</script>
