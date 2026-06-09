import axios from 'axios'
import { ElMessage } from 'element-plus'

const service = axios.create({
  baseURL: import.meta.env.VITE_APP_BASE_API || '/dev-api',
  timeout: 10000
})

// 请求拦截器
service.interceptors.request.use(
  config => {
    const token = localStorage.getItem('token')
    if (token) {
      config.headers['Authorization'] = 'Bearer ' + token
    }
    return config
  },
  error => {
    return Promise.reject(error)
  }
)

// 响应拦截器
service.interceptors.response.use(
  response => {
    const res = response.data
    // 业务错误（如登录失败、权限不足等）
    if (res.code !== 200) {
      ElMessage.error(res.msg || 'Error')
      return Promise.reject(new Error(res.msg || 'Error'))
    }
    return res
  },
  error => {
    const status = error.response?.status
    if (status === 401) {
      // Token 失效或未登录：清除本地 token 并跳转登录页
      ElMessage.warning('登录已过期，请重新登录')
      localStorage.removeItem('token')
      // 避免重复跳转
      if (window.location.pathname !== '/login') {
        window.location.href = '/login'
      }
    } else {
      ElMessage.error(error.message || '网络请求异常')
    }
    return Promise.reject(error)
  }
)

export default service