<template>
  <nav id="navbar" class="flex-center">
    <div id="navbar__wrapper">
      <div class="center divrow displaynone" style="gap: 15px;">
        <img src="@/assets/sources/logos/logo-navbar.svg" alt="Logo" class="mr-14">
        <span class="center nav-text" :class="{ 'lime': $route.path === '/dashboard' }" @click="$router.push('/dashboard')">
          <img v-if="$route.path != '/dashboard'" src="@/assets/sources/icons/home-white.svg" alt="Home" class="mr-2"> 
          <img v-if="$route.path == '/dashboard'" src="@/assets/sources/icons/home-green.svg" alt="Home" class="mr-2"> 
          Home
        </span>

        <span class="center nav-text" :class="{ 'lime': $route.path === '/my-portfolio' }" @click="$router.push('/my-portfolio')">
          <img v-if="$route.path != '/my-portfolio'" src="@/assets/sources/icons/wallet-white.svg" alt="Wallet" class="mr-2"> 
          <img v-if="$route.path == '/my-portfolio'" src="@/assets/sources/icons/wallet-green.svg" alt="Wallet" class="mr-2"> 
          My portfolio
        </span>

        <span class="center nav-text" :class="{ 'lime': $route.path === '/marketplace' }" @click="$router.push('/marketplace')">
          <img v-if="$route.path != '/marketplace'" src="@/assets/sources/icons/marketplace.svg" alt="marketplace" class="mr-2"> 
          <img v-if="$route.path == '/marketplace'" src="@/assets/sources/icons/marketplace-green.svg" alt="marketplace" class="mr-2"> 
          Marketplace
        </span>

        <span class="center nav-text" :class="{ 'lime': $route.path === '/settings' }" @click="$router.push('/settings')">
          <img v-if="$route.path != '/settings'" src="@/assets/sources/icons/config.svg" alt="settings" class="mr-2"> 
          <img v-if="$route.path == '/settings'" src="@/assets/sources/icons/config-green.svg" alt="settings" class="mr-2"> 
          Settings
        </span>

        <span class="center nav-text" :class="{ 'lime': $route.path === '/support' }" @click="$router.push('/support')">
          <img v-if="$route.path != '/support'" src="@/assets/sources/icons/support.svg" alt="support" class="mr-2"> 
          <img v-if="$route.path == '/support'" src="@/assets/sources/icons/support-green.svg" alt="support" class="mr-2"> 
          Support
        </span>
      </div>

      <div class="center divrow displaynone" style="gap: 20px;">
        <notifications-button />

        <v-menu location="bottom" style="border-radius: 12px !important;">
          <template #activator="{ props }">
            <v-sheet class="center divrow pointer" style="gap: 10px; background-color: transparent;" v-bind="props">
              <v-img-load :src="UserProfileModel.get().companyLogo" alt="Avatar" cover rounded="50%" sizes="35px" />
              <div class="divcol">
                <span style="font-weight: 700; color: #fff;">{{ UserProfileModel.get().companyName }}</span>
                <span style="color: #98A2B3;">{{ UserProfileModel.get().email }}</span>
              </div>
            </v-sheet>
          </template>

          <v-list>
            <v-list-item
              v-for="(item, i) in optionsMenu" :key="i"
              :title="item.name"
              :to="item.to"
            />
          </v-list>
        </v-menu>
      </div>

      <!-- Mobile Nav -->
      <img src="@/assets/sources/logos/logo-mobile.svg" alt="Logo" class="logo-mobile show-mobile">

      <div class="right-mobile" style="gap: 20px;">
        <v-img-load :src="UserProfileModel.get().companyLogo" alt="Avatar" cover rounded="50%" sizes="35px" class="pointer" @click="$router.push('/profile')" />
        <img src="@/assets/sources/icons/bell.svg" alt="bell icon">
        <img src="@/assets/sources/icons/menu-bars-mobile.svg" alt="Menu Bars" class="menu-bars show-mobile" @click.stop="drawer = !drawer">
      </div>
    </div>

    <!-- Menu Mobile -->
    <v-navigation-drawer
      v-model="drawer"
      temporary
      width="330"
    >
      <div class="center mt-10">
        <img src="@/assets/sources/logos/logo-navbar.svg" alt="Logo">
      </div>
      <div class="jcenter divcol mt-16" style="gap: 40px;">
        <span class="center nav-text" :class="{ 'lime': $route.path === '/dashboard' }" @click="$router.push('/dashboard')">
          <img v-if="$route.path != '/dashboard'" src="@/assets/sources/icons/home-white.svg" alt="Home" class="mr-2"> 
          <img v-if="$route.path == '/dashboard'" src="@/assets/sources/icons/home-green.svg" alt="Home" class="mr-2"> 
          Home
        </span>

        <span class="center nav-text" :class="{ 'lime': $route.path === '/my-portfolio' }" @click="$router.push('/my-portfolio')">
          <img v-if="$route.path != '/my-portfolio'" src="@/assets/sources/icons/wallet-white.svg" alt="Wallet" class="mr-2"> 
          <img v-if="$route.path == '/my-portfolio'" src="@/assets/sources/icons/wallet-green.svg" alt="Wallet" class="mr-2"> 
          My portfolio
        </span>

        <span class="center nav-text" :class="{ 'lime': $route.path === '/marketplace' }" @click="$router.push('/marketplace')">
          <img v-if="$route.path != '/marketplace'" src="@/assets/sources/icons/marketplace.svg" alt="marketplace" class="mr-2"> 
          <img v-if="$route.path == '/marketplace'" src="@/assets/sources/icons/marketplace-green.svg" alt="marketplace" class="mr-2"> 
          Marketplace
        </span>

        <span class="center nav-text" :class="{ 'lime': $route.path === '/settings' }" @click="$router.push('/settings')">
          <img v-if="$route.path != '/settings'" src="@/assets/sources/icons/config.svg" alt="settings" class="mr-2"> 
          <img v-if="$route.path == '/settings'" src="@/assets/sources/icons/config-green.svg" alt="settings" class="mr-2"> 
          Settings
        </span>

        <span class="center nav-text" :class="{ 'lime': $route.path === '/support' }" @click="$router.push('/support')">
          <img v-if="$route.path != '/support'" src="@/assets/sources/icons/support.svg" alt="support" class="mr-2"> 
          <img v-if="$route.path == '/support'" src="@/assets/sources/icons/support-green.svg" alt="support" class="mr-2"> 
          Support
        </span>
      </div>
      <template v-slot:append>
          <div class="pb-6 pl-3 pr-3">
            <v-btn class="btn bold width100" to="/auth/login">
              Logout
            </v-btn>
          </div>
        </template>
    </v-navigation-drawer>
  </nav>
</template>

<script setup>
import home from '@/assets/sources/icons/home-white.svg'
import wallet from '@/assets/sources/icons/wallet-white.svg'
import marketplace from '@/assets/sources/icons/marketplace.svg'
import config from '@/assets/sources/icons/config.svg'
import support from '@/assets/sources/icons/support.svg'
import home_green from '@/assets/sources/icons/home-green.svg'
import wallet_green from '@/assets/sources/icons/wallet-green.svg'
import marketplace_green from '@/assets/sources/icons/marketplace-green.svg'
import config_green from '@/assets/sources/icons/config-green.svg'
import support_green from '@/assets/sources/icons/support-green.svg'
import market_trends from '@/assets/sources/icons/market-trends.svg'
import { useToast } from 'vue-toastification';
import { useRouter } from 'vue-router'
import { ref } from 'vue'
import { UserProfileModel } from '@/models/user-profile-model'
import NotificationsButton from '@/components/notifications-button.vue'

const
  router = useRouter(),
  toast = useToast(),

drawer = ref(false),
dataNavbar = [
  {img: 'home', name: 'Home', link:'/dashboard', img_green: 'home_green'},
  {img: 'wallet', name: 'My portfolio', link: '/my-portfolio', img_green: 'wallet_green' },
  {img: 'marketplace', name: 'Marketplace', link:'marketplace', img_green: 'marketplace_green'},
  // {img: 'market_trends', name:'Market trends', link: '/market-trends'},
  {img: 'config', name:'Settings', link: '/settings', img_green: 'config_green'},
  {img: 'support', name:'Support', link: '/support', img_green: 'support_green'}
],
iconMap = {
  home,
  wallet,
  marketplace,
  market_trends,
  config,
  support,
  home_green,
  wallet_green,
  marketplace_green,
  config_green,
  support_green,
},
optionsMenu = [
  {
    name: "Profile",
    to: "/profile"
  },
  {
    name: "Logout",
    to: "/auth/login"
  },
]
</script>

<style scoped lang="scss">
@use '@/assets/styles/main.scss' as *;

#navbar {
  background-color: #101828;
  animation: movedown .5s $ease-return;
  transition: transform 0.4s ease-in-out;
  // @extend .margin-global;
  padding-inline: 30px;
  @extend .full-screen;
  height: var(--h-navbar);
  position: sticky;
  top: 0;
  z-index: 999;
  animation: none;
  transition: none;

  .width100{
    min-width: 100%!important;
  }

  .lime{
    color: #C6F221!important; 
  }

  .nav-text{
    color: #fff; 
    font-weight: 300!important; 
    cursor: pointer;
  }

  @include media(max, 960px){
    position: static;
    padding-inline: 20px;
  }

  .displaynone{
    @include media(max, 960px){
      display: none;
    }
  }

  .right-mobile{
    display: none;
    @include media(max, 960px){
      display: flex!important;
      flex-direction: row!important;;
      width: max-content;
      justify-content: center!important;
      align-items: center!important;
    }
  }

  .show-mobile{
    display: none!important;
    @include media(max, 960px){
      display: block!important;
    }
  }

  &__wrapper {
    @extend .parent;
    display: flex;
    justify-content: space-between;

    .chip-mobile{
      border-radius: 50%;
      border: 1px solid rgba(0,0,0,0.25);
      display: grid;
      place-items: center;
      width: 50px;
      height: 50px;
      .logo-mobile{
        padding: 5px;
        width: 45px;
      }
    }
  }

  .v-navigation-drawer{
    background-color: #101828!important;
  }
}
</style>
