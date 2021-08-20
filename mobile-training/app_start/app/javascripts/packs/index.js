import 'core-js/stable'
import 'regenerator-runtime/runtime'
import Vue from 'vue/dist/vue'
import VueRouter from 'vue-router'
import Home from './Home.vue'
import UserProfile from './UserProfile.vue'

Vue.use(VueRouter)

const routes = [
  { path: '/user_profiles/:id', component: UserProfile },
  { path: '/', component: Home }
]

const router = new VueRouter({
  routes,
  mode: 'history'
})

document.addEventListener('DOMContentLoaded', () => {
  new Vue({ router }).$mount('#app')
})
