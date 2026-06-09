<template>
  <div class="app-container chat-page">
    <el-card class="chat-container" shadow="hover">
      <template #header>
        <div class="chat-header">
          <div class="header-title">
            <el-icon class="mr-2"><ChatDotRound /></el-icon>
            <span>多模态 AI 助手</span>
          </div>
          <el-tag type="success" effect="light" size="small">在线</el-tag>
        </div>
      </template>
      
      <div class="chat-history" ref="chatHistoryRef">
        <div v-if="messages.length === 0" class="empty-state">
          <el-icon class="empty-icon"><ChatLineSquare /></el-icon>
          <p>你好！我是 AI 助手，有什么可以帮到您的吗？</p>
          <p class="empty-hint">支持文本对话和图片分析，试着上传一张图片并向我提问吧。</p>
        </div>
        
        <div v-for="(msg, index) in messages" :key="index" :class="['message-wrapper', msg.role]">
          <el-avatar v-if="msg.role === 'assistant'" class="avatar" style="background: #409EFF">
            <el-icon><Service /></el-icon>
          </el-avatar>
          
          <div class="message-content">
            <div class="message-bubble">
              <el-image 
                v-if="msg.image" 
                :src="msg.image" 
                class="msg-image" 
                :preview-src-list="[msg.image]"
                :initial-index="0"
                fit="cover"
                preview-teleported
              />
              <div class="text-content" v-html="formatContent(msg.content)"></div>
            </div>
          </div>
          
          <el-avatar v-if="msg.role === 'user'" class="avatar" style="background: #67C23A">
            <el-icon><User /></el-icon>
          </el-avatar>
        </div>
        
        <!-- Loading state -->
        <div v-if="loading" class="message-wrapper assistant">
          <el-avatar class="avatar" style="background: #409EFF">
            <el-icon><Service /></el-icon>
          </el-avatar>
          <div class="message-content">
            <div class="message-bubble loading-bubble">
              <span class="dot"></span><span class="dot"></span><span class="dot"></span>
            </div>
          </div>
        </div>
      </div>

      <div class="input-container">
        <!-- Image Preview Area -->
        <div v-if="selectedImageBase64" class="image-preview-wrapper">
          <div class="image-preview">
            <img :src="selectedImageBase64" />
            <div class="remove-btn" @click="removeImage">
              <el-icon><Close /></el-icon>
            </div>
          </div>
        </div>
        
        <div class="input-area">
          <el-upload
            class="upload-btn"
            action="#"
            :auto-upload="false"
            :show-file-list="false"
            :on-change="handleImageChange"
            accept="image/*"
          >
            <el-tooltip content="上传图片分析" placement="top">
              <el-button circle icon="Picture" type="info" plain></el-button>
            </el-tooltip>
          </el-upload>
          
          <el-input
            v-model="inputText"
            type="textarea"
            :autosize="{ minRows: 1, maxRows: 5 }"
            placeholder="输入您的问题，或者上传图片让 AI 分析（按 Enter 发送，Shift+Enter 换行）..."
            class="chat-input"
            @keydown.enter.prevent="handleEnter"
          />
          
          <el-button 
            type="primary" 
            class="send-btn" 
            @click="sendMessage" 
            :disabled="(!inputText && !selectedImageBase64) || loading"
            icon="Position"
            circle
          >
          </el-button>
        </div>
      </div>
    </el-card>
  </div>
</template>

<script setup name="AiChat">
import { ref, nextTick, watch } from 'vue';
import { sendAiMessage } from '@/api/ai/chat';
import { ElMessage } from 'element-plus';
import { ChatDotRound, ChatLineSquare, Service, User, Picture, Close, Position } from '@element-plus/icons-vue';

const messages = ref([]);
const inputText = ref('');
const selectedImageBase64 = ref(null);
const loading = ref(false);
const chatHistoryRef = ref(null);

// 监听消息变化，自动滚动到底部
watch(messages, () => {
  scrollToBottom();
}, { deep: true });

// 监听加载状态，自动滚动
watch(loading, (newVal) => {
  if (newVal) {
    scrollToBottom();
  }
});

const scrollToBottom = async () => {
  await nextTick();
  if (chatHistoryRef.value) {
    chatHistoryRef.value.scrollTop = chatHistoryRef.value.scrollHeight;
  }
};

// 格式化文本内容，处理换行
const formatContent = (content) => {
  if (!content) return '';
  return content.replace(/\n/g, '<br/>');
};

// 处理图片上传并转为 Base64
const handleImageChange = (file) => {
  const isImage = file.raw.type.startsWith('image/');
  if (!isImage) {
    ElMessage.error('只能上传图片文件！');
    return;
  }
  
  const isLt5M = file.raw.size / 1024 / 1024 < 5;
  if (!isLt5M) {
    ElMessage.error('图片大小不能超过 5MB！');
    return;
  }

  const reader = new FileReader();
  reader.readAsDataURL(file.raw);
  reader.onload = () => {
    selectedImageBase64.value = reader.result;
    ElMessage.success('图片已选择，请输入问题后发送');
  };
};

const removeImage = () => {
  selectedImageBase64.value = null;
};

// 处理回车发送
const handleEnter = (e) => {
  if (e.shiftKey) {
    // Shift + Enter 换行，不做拦截
    return;
  }
  // 只有 Enter 则发送
  sendMessage();
};

// 发送消息
const sendMessage = async () => {
  if ((!inputText.value.trim() && !selectedImageBase64.value) || loading.value) return;

  const currentText = inputText.value.trim();
  const currentImage = selectedImageBase64.value;

  // 1. 将用户输入推入聊天记录
  messages.value.push({
    role: 'user',
    content: currentText,
    image: currentImage
  });
  
  // 清空输入框
  inputText.value = '';
  selectedImageBase64.value = null;
  loading.value = true;

  try {
    // 2. 调用真实 AI 接口
    const response = await sendAiMessage({
      message: currentText,
      image: currentImage
    });
    
    // 3. 将 AI 回复推入聊天记录
    messages.value.push({
      role: 'assistant',
      content: response.data || response.msg || '抱歉，AI 没有返回内容',
      image: null
    });
    
  } catch (error) {
    console.error("AI 请求失败", error);
    ElMessage.error('AI 服务调用失败，请稍后重试');
    
    // 添加错误提示
    messages.value.push({
      role: 'assistant',
      content: '⚠️ 抱歉，AI 服务暂时不可用，请检查网络或后端状态。',
      image: null
    });
  } finally {
    loading.value = false;
  }
};
</script>

<style scoped lang="scss">
.chat-page {
  padding: 20px;
  background-color: #f0f2f5;
  min-height: calc(100vh - 84px);
}

.chat-container {
  height: calc(100vh - 120px);
  display: flex;
  flex-direction: column;
  border-radius: 12px;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.05);
  
  :deep(.el-card__body) {
    flex: 1;
    display: flex;
    flex-direction: column;
    padding: 0;
    overflow: hidden;
  }
  
  :deep(.el-card__header) {
    padding: 15px 20px;
    border-bottom: 1px solid #ebeef5;
    background-color: #fafafa;
  }
}

.chat-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  
  .header-title {
    display: flex;
    align-items: center;
    font-size: 16px;
    font-weight: 600;
    color: #303133;
    
    .mr-2 {
      margin-right: 8px;
      font-size: 20px;
      color: #409EFF;
    }
  }
}

.chat-history {
  flex: 1;
  overflow-y: auto;
  padding: 20px;
  background: #f5f7fa;
  scroll-behavior: smooth;
  
  /* 自定义滚动条 */
  &::-webkit-scrollbar {
    width: 6px;
  }
  &::-webkit-scrollbar-thumb {
    background: #dcdfe6;
    border-radius: 3px;
  }
  &::-webkit-scrollbar-track {
    background: transparent;
  }
}

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100%;
  color: #909399;
  
  .empty-icon {
    font-size: 64px;
    color: #c0c4cc;
    margin-bottom: 16px;
  }
  
  p {
    margin: 8px 0;
    font-size: 16px;
  }
  
  .empty-hint {
    font-size: 14px;
    color: #a8abb2;
  }
}

.message-wrapper {
  display: flex;
  margin-bottom: 24px;
  align-items: flex-start;
  
  &.user {
    flex-direction: row-reverse;
    
    .message-content {
      margin-right: 12px;
      margin-left: 48px;
      align-items: flex-end;
    }
    
    .message-bubble {
      background: #95ec69;
      color: #333;
      border-radius: 12px 2px 12px 12px;
    }
  }
  
  &.assistant {
    flex-direction: row;
    
    .message-content {
      margin-left: 12px;
      margin-right: 48px;
      align-items: flex-start;
    }
    
    .message-bubble {
      background: #ffffff;
      color: #303133;
      border-radius: 2px 12px 12px 12px;
      box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.05);
    }
  }
}

.avatar {
  flex-shrink: 0;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.message-content {
  display: flex;
  flex-direction: column;
  max-width: 100%;
}

.message-bubble {
  padding: 12px 16px;
  position: relative;
  word-break: break-word;
  font-size: 15px;
  line-height: 1.6;
  
  .text-content {
    white-space: pre-wrap;
  }
  
  .msg-image {
    max-width: 240px;
    max-height: 240px;
    border-radius: 8px;
    margin-bottom: 8px;
    cursor: pointer;
    border: 1px solid #ebeef5;
    object-fit: cover;
    transition: transform 0.2s;
    
    &:hover {
      transform: scale(1.02);
    }
  }
}

.loading-bubble {
  display: flex;
  align-items: center;
  height: 44px;
  padding: 0 16px;
  
  .dot {
    display: inline-block;
    width: 6px;
    height: 6px;
    margin: 0 3px;
    background-color: #909399;
    border-radius: 50%;
    animation: bounce 1.4s infinite ease-in-out both;
    
    &:nth-child(1) { animation-delay: -0.32s; }
    &:nth-child(2) { animation-delay: -0.16s; }
  }
}

@keyframes bounce {
  0%, 80%, 100% { transform: scale(0); }
  40% { transform: scale(1); }
}

.input-container {
  background: #fff;
  border-top: 1px solid #ebeef5;
  padding: 16px 20px;
  position: relative;
}

.image-preview-wrapper {
  margin-bottom: 12px;
  display: flex;
  
  .image-preview {
    position: relative;
    display: inline-block;
    border-radius: 8px;
    border: 1px solid #dcdfe6;
    padding: 4px;
    background: #fafafa;
    
    img {
      height: 80px;
      width: auto;
      border-radius: 4px;
      display: block;
    }
    
    .remove-btn {
      position: absolute;
      top: -8px;
      right: -8px;
      width: 20px;
      height: 20px;
      background: #f56c6c;
      color: #fff;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      cursor: pointer;
      font-size: 12px;
      box-shadow: 0 2px 4px rgba(0,0,0,0.2);
      
      &:hover {
        background: #f78989;
      }
    }
  }
}

.input-area {
  display: flex;
  align-items: flex-end;
  gap: 12px;
  
  .upload-btn {
    flex-shrink: 0;
    margin-bottom: 4px;
  }
  
  .chat-input {
    flex: 1;
    
    :deep(.el-textarea__inner) {
      border-radius: 8px;
      padding: 10px 15px;
      background-color: #f5f7fa;
      border: 1px solid transparent;
      transition: all 0.3s;
      font-size: 15px;
      
      &:focus {
        background-color: #fff;
        border-color: #409EFF;
        box-shadow: 0 0 0 1px #409EFF inset;
      }
      
      &::-webkit-scrollbar {
        width: 6px;
      }
      &::-webkit-scrollbar-thumb {
        background: #dcdfe6;
        border-radius: 3px;
      }
    }
  }
  
  .send-btn {
    flex-shrink: 0;
    margin-bottom: 4px;
    width: 40px;
    height: 40px;
    font-size: 18px;
    transition: all 0.3s;
    
    &:hover:not(:disabled) {
      transform: translateY(-2px);
      box-shadow: 0 4px 12px rgba(64, 158, 255, 0.4);
    }
  }
}
</style>
