<template>
  <div class="tech-login-container"> <!-- 主体登录框 -->
    <div class="tech-login-box">

      <div class="box-content">
        <!-- 左侧品牌展示区 -->
        <div class="brand-section">
          <div class="logo-wrapper">
            <img src="@/assets/logo/logo.png" alt="logo" class="logo" />
          </div>
          <h2 class="sys-title">星辰系统 <span class="version">v4.0</span></h2>
          <p class="sys-subtitle">ENTERPRISE DIGITAL CORE // NEON EDITION</p>
          
          <div class="status-lines">
            <div class="line"><span class="dot blink"></span> SYSTEM ONLINE</div>
            <div class="line"><span class="dot blink" style="animation-delay: 0.5s"></span> SECURE CONNECTION</div>
          </div>
        </div>

        <!-- 右侧表单区 -->
        <div class="form-section">
          <el-form ref="loginRef" :model="loginForm" :rules="loginRules" class="cyber-form">
            <div class="form-header">
              <h3 class="title">AUTH / 身份认证</h3>
              <div class="scan-line"></div>
            </div>
            
            <el-form-item prop="username">
              <div class="cyber-input-wrapper">
                <el-input
                  v-model="loginForm.username"
                  type="text"
                  autocomplete="off"
                  placeholder="USER ID"
                >
                  <template #prefix><el-icon><User /></el-icon></template>
                </el-input>
              </div>
            </el-form-item>
            
            <el-form-item prop="password">
              <div class="cyber-input-wrapper">
                <el-input
                  v-model="loginForm.password"
                  type="password"
                  autocomplete="off"
                  placeholder="ACCESS CODE"
                  show-password
                  @keyup.enter="handleLogin"
                >
                  <template #prefix><el-icon><Lock /></el-icon></template>
                </el-input>
              </div>
            </el-form-item>
            
            <el-form-item prop="code" v-if="captchaEnabled">
              <div class="captcha-wrapper">
                <div class="cyber-input-wrapper" style="width: 60%">
                  <el-input
                    v-model="loginForm.code"
                    autocomplete="off"
                    placeholder="VERIFY CODE"
                    @keyup.enter="handleLogin"
                  >
                    <template #prefix><el-icon><SafetyCertificate /></el-icon></template>
                  </el-input>
                </div>
                <div class="login-code">
                  <img :src="codeUrl" @click="getCode" class="login-code-img" title="点击刷新"/>
                </div>
              </div>
            </el-form-item>
            
            <div class="form-options">
              <el-checkbox v-model="loginForm.rememberMe" class="cyber-checkbox">
                KEEP ALIVE
              </el-checkbox>
            </div>
            
            <el-form-item style="width:100%; margin-top: 10px;">
              <button
                type="button"
                class="cyber-btn"
                :disabled="loading"
                @click.prevent="handleLogin"
              >
                <span class="btn-text" v-if="!loading">INITIALIZE LINK</span>
                <span class="btn-text" v-else>CONNECTING...</span>
                <div class="btn-glitch"></div>
              </button>
            </el-form-item>
          </el-form>
        </div>
      </div>
    </div>

    <div class="footer-info">
      <span>SECURE TERMINAL // [XINGCHEN] ALL RIGHTS RESERVED 2026</span>
    </div>
  </div>
</template>

<script setup>
import { getCodeImg } from "@/api/login"
import Cookies from "js-cookie"
import { encrypt, decrypt } from "@/utils/jsencrypt"
import useUserStore from '@/store/modules/user'

const userStore = useUserStore()
const route = useRoute()
const router = useRouter()
const { proxy } = getCurrentInstance()

const loginForm = ref({
  username: "admin",
  password: "admin123",
  rememberMe: false,
  code: "",
  uuid: ""
})

const loginRules = {
  username: [{ required: true, trigger: "blur", message: "ID is required" }],
  password: [{ required: true, trigger: "blur", message: "Code is required" }],
  code: [{ required: true, trigger: "change", message: "Verify is required" }]
}

const codeUrl = ref("")
const loading = ref(false)
const captchaEnabled = ref(true)
const redirect = ref(undefined)

watch(route, (newRoute) => {
    redirect.value = newRoute.query && newRoute.query.redirect
}, { immediate: true })

function handleLogin() {
  proxy.$refs.loginRef.validate(valid => {
    if (valid) {
      loading.value = true
      if (loginForm.value.rememberMe) {
        Cookies.set("username", loginForm.value.username, { expires: 30 })
        Cookies.set("password", encrypt(loginForm.value.password), { expires: 30 })
        Cookies.set("rememberMe", loginForm.value.rememberMe, { expires: 30 })
      } else {
        Cookies.remove("username")
        Cookies.remove("password")
        Cookies.remove("rememberMe")
      }
      userStore.login(loginForm.value).then(() => {
        const query = route.query
        const otherQueryParams = Object.keys(query).reduce((acc, cur) => {
          if (cur !== "redirect") acc[cur] = query[cur]
          return acc
        }, {})
        router.push({ path: redirect.value || "/", query: otherQueryParams })
      }).catch(() => {
        loading.value = false
        if (captchaEnabled.value) getCode()
      })
    }
  })
}

function getCode() {
  getCodeImg().then(res => {
    captchaEnabled.value = res.captchaEnabled === undefined ? true : res.captchaEnabled
    if (captchaEnabled.value) {
      codeUrl.value = "data:image/gif;base64," + res.img
      loginForm.value.uuid = res.uuid
    }
  })
}

function getCookie() {
  const username = Cookies.get("username")
  const password = Cookies.get("password")
  const rememberMe = Cookies.get("rememberMe")
  loginForm.value = {
    username: username === undefined ? loginForm.value.username : username,
    password: password === undefined ? loginForm.value.password : decrypt(password),
    rememberMe: rememberMe === undefined ? false : Boolean(rememberMe)
  }
}

getCode()
getCookie()
</script>

<style lang="scss" scoped>
// 主题风格变量 (黑白灰+绿)
$bg-color: #f0f2f5;
$neon-cyan: #42b983;
$neon-blue: #42b983;
$neon-purple: #42b983;
$text-main: #333333;
$text-muted: #999999;

.tech-login-container {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100vh;
  width: 100vw;
  background-color: $bg-color;
  position: relative;
  overflow: hidden;
  color: $text-main;
}



// 主体框
.tech-login-box {
  position: relative;
  z-index: 10;
  width: 850px;
  height: 480px;
  background: #ffffff;
  border-radius: 8px;
  border: 1px solid rgba($neon-cyan, 0.3);
  box-shadow: 0 0 20px rgba(0, 0, 0, 0.1);
  display: flex;
  padding: 0; // 为边角留空间

}

.box-content {
  display: flex;
  width: 100%;
  height: 100%;
  background: #ffffff;
  border: 1px solid rgba($neon-blue, 0.2);
}

// 左侧品牌区
.brand-section {
  flex: 1;
  padding: 40px;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  border-right: 1px dashed rgba($neon-cyan, 0.2);
  background: #fafafa;

  .logo-wrapper {
    position: relative;
    width: 120px;
    height: 120px;
    display: flex;
    justify-content: center;
    align-items: center;
    margin-bottom: 20px;

    .logo {
      width: 100px;
      height: 100px;
      object-fit: contain;
      z-index: 2;
    }
  }

  .sys-title {
    font-size: 28px;
    color: #333333;
    margin: 10px 0 5px;
    text-shadow: none;
    letter-spacing: 2px;
    text-align: center;
    
    .version {
      font-size: 12px;
      color: $neon-cyan;
      vertical-align: super;
      text-shadow: none;
    }
  }

  .sys-subtitle {
    font-size: 12px;
    color: $text-muted;
    letter-spacing: 1px;
    margin-bottom: 40px;
    text-align: center;
  }

  .status-lines {
    width: 100%;
    font-size: 12px;
    color: $text-muted;
    
    .line {
      display: flex;
      align-items: center;
      margin: 8px 0;
      
      .dot {
        width: 8px;
        height: 8px;
        background: $neon-cyan;
        border-radius: 50%;
        margin-right: 10px;
      }
    }
  }
}

@keyframes rotateBorder {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}
@keyframes blink {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.3; }
}
.blink { animation: blink 2s ease-in-out infinite; }

// 右侧表单区
.form-section {
  width: 400px;
  padding: 40px 50px;
  display: flex;
  flex-direction: column;
  justify-content: center;

  .form-header {
    margin-bottom: 30px;
    position: relative;
    
    .title {
      font-size: 20px;
      color: #333333;
      margin: 0;
      letter-spacing: 2px;
      font-weight: bold;
    }
    
    .scan-line {
      display: none;
    }
  }

  // 深度重写 Element Plus 输入框
  .cyber-input-wrapper {
    position: relative;
    
    &::after {
      display: none;
    }
    
    &:hover::after, &:focus-within::after {
      width: 100%;
    }

    :deep(.el-input__wrapper) {
      background-color: #ffffff !important;
      border: 1px solid rgba($neon-cyan, 0.5) !important;
      border-radius: 4px !important; // 直角更具科技感 -> 圆角黑白灰
      box-shadow: none !important;
      height: 44px;
      padding-left: 15px;
      
      &:hover, &.is-focus {
        background-color: #f5f7fa !important;
        border-color: $neon-cyan !important;
      }
    }

    :deep(.el-input__inner) {
      color: $text-main;
      font-family: inherit;
      letter-spacing: 1px;
      &::placeholder { color: $text-muted; }
    }

    :deep(.el-input__prefix-icon) {
      color: $neon-cyan;
    }
  }

  .captcha-wrapper {
    display: flex;
    justify-content: space-between;
    
    .login-code {
      width: 35%;
      height: 44px;
      border: 1px solid rgba($neon-cyan, 0.3);
      border-radius: 4px;
      
      img {
        width: 100%;
        height: 100%;
        cursor: pointer;
        transition: all 0.3s;
        
        &:hover { opacity: 0.8; }
      }
    }
  }

  .form-options {
    margin: 15px 0 25px;
    
    .cyber-checkbox {
      :deep(.el-checkbox__label) {
        color: $text-muted;
        font-family: inherit;
        font-size: 12px;
      }
      :deep(.el-checkbox__inner) {
        background-color: transparent;
        border-color: rgba($neon-cyan, 0.5);
        border-radius: 0;
      }
      &.is-checked :deep(.el-checkbox__label) { color: $neon-cyan; text-shadow: 0 0 5px $neon-cyan;}
      &.is-checked :deep(.el-checkbox__inner) {
        background-color: rgba($neon-cyan, 0.2);
        border-color: $neon-cyan;
        &::after { border-color: $neon-cyan; }
      }
    }
  }

  // 科技风按钮 -> 黑白灰+绿按钮
  .cyber-btn {
    position: relative;
    width: 100%;
    height: 48px;
    background: $neon-cyan;
    border: none;
    border-radius: 4px;
    color: #ffffff;
    font-family: inherit;
    font-size: 16px;
    font-weight: bold;
    letter-spacing: 4px;
    cursor: pointer;
    overflow: hidden;
    transition: all 0.3s;

    .btn-text { position: relative; z-index: 2; }
    
    &:hover {
      background: rgba($neon-cyan, 0.8);
      box-shadow: 0 4px 10px rgba($neon-cyan, 0.3);
    }

    &:disabled {
      background: #cccccc;
      color: #ffffff;
      cursor: not-allowed;
      box-shadow: none;
    }
  }
}

.footer-info {
  position: absolute;
  bottom: 20px;
  font-size: 12px;
  color: $text-muted;
  letter-spacing: 2px;
  opacity: 0.6;
}
</style>
