import request from '@/api/request'

// 提交兑换申请
export function submitRedemption(data) {
  return request({
    url: '/system/redemption/submit',
    method: 'post',
    data: data
  })
}

// 查询我的兑换记录
export function getMyRedemptions() {
  return request({
    url: '/system/redemption/myList',
    method: 'get'
  })
}

// 查询我的积分余额
export function getMyPoints() {
  return request({
    url: '/system/redemption/myPoints',
    method: 'get'
  })
}

// 每日打卡增加积分
export function checkInAddPoints() {
  return request({
    url: '/system/pointsLog/checkIn',
    method: 'post'
  })
}
