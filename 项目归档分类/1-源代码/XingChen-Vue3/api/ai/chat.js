import request from '@/utils/request'

// 发送 AI 消息
export function sendAiMessage(data) {
  return request({
    url: '/ai/chat/send',
    method: 'post',
    data: data
  })
}
