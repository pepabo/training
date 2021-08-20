<template>
  <div class="row">
    <div class="col-md-12" v-if="loading">ロード中</div>
    <div user-info :user="user" v-else-if="user">
      <aside class="col-md-4">
        <user-info :user="user"></user-info>
      </aside>
      <section class="col-md-8">
        <user-micropost-list
          :user="user"
          :on-delete="handleDelete"
        ></user-micropost-list>
      </section>
    </div>
  </div>
</template>

<script>
import axios from './axiosClient'
import UserInfo from './UserInfo.vue'
import UserMicropostList from './UserMicropostList.vue'

export default {
  components: {
    UserInfo,
    UserMicropostList
  },
  data() {
    return {
      user: null,
      loading: true
    }
  },
  async mounted() {
    const res = await axios.get(`/users/${this.$route.params.id}.json`)
    this.user = res.data
    this.loading = false
  },
  methods: {
    handleDelete() {

    }
  }
}
</script>
