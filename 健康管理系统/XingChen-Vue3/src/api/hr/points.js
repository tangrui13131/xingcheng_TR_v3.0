import request from '@/utils/request'

// 分页查询用户积分列表
export function listUserPoints(query) {
  return request({
    url: '/system/points/userList',
    method: 'get',
    params: query
  })
}

// 给指定用户增加100积分
export function addUserPoints(userId) {
  return request({
    url: '/system/points/add/' + userId,
    method: 'put'
  })
}
