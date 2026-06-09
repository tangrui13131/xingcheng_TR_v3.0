import { createRouter, createWebHistory } from 'vue-router'

const routes = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/login.vue')
  },
  {
    path: '/register',
    name: 'Register',
    component: () => import('@/views/register.vue')
  },
  {
    path: '/',
    name: 'Index',
    component: () => import('@/views/index.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/profile',
    name: 'Profile',
    component: () => import('@/views/profile.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/health-data',
    name: 'MyHealthData',
    component: () => import('@/views/MyHealthData.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/points-mall',
    name: 'PointsMall',
    component: () => import('@/views/PointsMall.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/ai-assistant',
    name: 'AiHealthAssistant',
    component: () => import('@/views/AiHealthAssistant.vue'),
    meta: { requiresAuth: true }
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach((to, from, next) => {
  const token = localStorage.getItem('token')
  if (to.meta.requiresAuth && !token) {
    // 需要登录的页面且未登录，跳到登录页
    next('/login')
  } else if ((to.path === '/login' || to.path === '/register') && token) {
    // 已登录用户访问登录/注册页，直接跳首页
    next('/')
  } else {
    next()
  }
})

export default router