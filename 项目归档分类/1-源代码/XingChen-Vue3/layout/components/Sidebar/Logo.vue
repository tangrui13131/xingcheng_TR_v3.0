<template>
  <div class="sidebar-logo-container" :class="{ 'collapse': collapse }">
    <transition name="sidebarLogoFade">
      <router-link v-if="collapse" key="collapse" class="sidebar-logo-link" to="/">
        <div class="logo-box">
          <img src="@/assets/logo/logo.png" class="sidebar-logo" v-if="true" />
          <span v-else class="sidebar-logo-text">XC</span>
        </div>
      </router-link>
      <router-link v-else key="expand" class="sidebar-logo-link" to="/">
        <div class="logo-box">
          <img src="@/assets/logo/logo.png" class="sidebar-logo" v-if="true" />
          <span v-else class="sidebar-logo-text">XC</span>
        </div>
        <h1 class="sidebar-title">{{ title }}</h1>
      </router-link>
    </transition>
  </div>
</template>

<script setup>
import useSettingsStore from '@/store/modules/settings'
import variables from '@/assets/styles/variables.module.scss'

defineProps({
  collapse: {
    type: Boolean,
    required: true
  }
})

const title = import.meta.env.VITE_APP_TITLE
const settingsStore = useSettingsStore()
const sideTheme = computed(() => settingsStore.sideTheme)

// 获取Logo背景色
const getLogoBackground = computed(() => {
  if (settingsStore.isDark) {
    return 'var(--sidebar-bg)'
  }
  if (settingsStore.navType == 3) {
    return variables.menuLightBg
  }
  return sideTheme.value === 'theme-dark' ? variables.menuBg : variables.menuLightBg
})

// 获取Logo文字颜色
const getLogoTextColor = computed(() => {
  if (settingsStore.isDark) {
    return 'var(--sidebar-text)'
  }
  if (settingsStore.navType == 3) {
    return variables.menuLightText
  }
  return sideTheme.value === 'theme-dark' ? '#fff' : variables.menuLightText
})
</script>

<style lang="scss" scoped>
.sidebarLogoFade-enter-active {
  transition: opacity 1.5s;
}

.sidebarLogoFade-enter,
.sidebarLogoFade-leave-to {
  opacity: 0;
}

.sidebar-logo-container {
  position: relative;
  height: 50px;
  line-height: 50px;
  background: v-bind(getLogoBackground);
  text-align: center;
  overflow: hidden;

  & .sidebar-logo-link {
      height: 100%;
      width: 100%;
      display: flex !important;
      flex-wrap: nowrap;
      align-items: center;
      justify-content: flex-start;
      padding-left: 20px;
      overflow: hidden;

      & .logo-box {
          width: 32px;
          min-width: 32px;
          height: 32px;
        border-radius: 6px;
        display: flex;
        align-items: center;
        justify-content: center;
        background: transparent;
        margin-right: 12px;
        transition: all 0.3s ease;

        & .sidebar-logo {
          width: 32px;
          height: 32px;
          vertical-align: middle;
          object-fit: contain;
        }
        
        & .sidebar-logo-text {
          color: #ffffff;
          font-weight: bold;
          font-size: 16px;
          line-height: 1;
          margin: 0;
          display: block;
        }
      }

      &:hover {
        & .logo-box {
          transform: scale(1.05);
        }
      }

    & .sidebar-title {
        display: inline-block;
        margin: 0;
        padding: 0;
        color: v-bind(getLogoTextColor);
        font-weight: 700;
        line-height: 50px;
        font-size: 16px;
        font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;
        vertical-align: middle;
        transition: all 0.3s ease;
        letter-spacing: 1px;
        white-space: nowrap;
      }
    
    &:hover .sidebar-title {
      color: #42b983;
    }
  }

  &.collapse {
    .sidebar-logo-link {
      padding-left: 0;
      justify-content: center;
    }
    
    .logo-box {
      margin-right: 0px;
    }
  }
}
</style>