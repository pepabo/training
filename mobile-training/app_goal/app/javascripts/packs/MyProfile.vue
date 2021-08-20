<template>
  <div v-if="me">
    <user-info :user="me"></user-info>
  </div>
</template>

<script>
import axios from './axiosClient'
import UserInfo from './UserInfo.vue'

export default {
  components: { UserInfo },
  data() {
    return {
      me: null,
      loading: true
    }
  },
  async mounted() {
    const res = await axios.get('/me.json')
    this.me = res.data
    this.loading = false
  }
}
</script>
