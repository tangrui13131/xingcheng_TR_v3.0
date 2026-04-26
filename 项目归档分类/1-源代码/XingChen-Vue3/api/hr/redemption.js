import request from '@/utils/request'

// 查询兑换审核列表
export function listRedemptions(query) {
  return request({
    url: '/system/redemption/list',
    method: 'get',
    params: query
  })
}

// 通过兑换审核
export function approveRedemption(id) {
  return request({
    url: '/system/redemption/approve/' + id,
    method: 'put'
  })
}

// 驳回兑换审核
export function rejectRedemption(id, data) {
  return request({
    url: '/system/redemption/reject/' + id,
    method: 'put',
    data: data
  })
}
