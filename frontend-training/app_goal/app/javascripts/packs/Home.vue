<template>
  <div class="row">
    <aside class="col-md-4">
      <my-profile></my-profile>
      <micropost-composer :on-create="handleCreateMicropost"></micropost-composer>
    </aside>
    <div class="col-md-8">
      <div v-if="loading">
        ロード中
      </div>
      <feed-list :feeds="feeds" :on-delete="handleDeleteFeed" v-else></feed-list>
    </div>
  </div>
</template>

<script>
import axios from './axiosClient'
import FeedList from './FeedList.vue'
import MyProfile from './MyProfile.vue'
import MicropostComposer from './MicropostComposer.vue'

export default {
  components: {
    FeedList,
    MyProfile,
    MicropostComposer
  },
  data() {
    return {
      feeds: [],
      loading: true
    }
  },
  async mounted() {
    const res = await axios.get('/feeds.json')
    this.feeds = res.data
    this.loading = false
  },
  methods: {
    handleCreateMicropost(micropost) {
      this.feeds.unshift(micropost)
    },
    handleDeleteFeed(id) {
      this.feeds = this.feeds.filter(feed => feed.id !== id)
    }
  }
}
</script>
