<template>
  <li :id="'micropost-' + feed.id">
    <user-image :user="user"></user-image>
    <user-name :user="user"></user-name>
    <span class="content">
      {{ feed.content }}
      <img :src="feed.picture_url" v-if="feed.picture_url" />
    </span>
    <span class="timestamp">
      Posted {{ feed.created_at_time_ago_in_words }} ago
      <a @click="deleteMicropost" v-if="user.is_current_user">
        delete
      </a>
    </span>
  </li>
</template>

<script>
import axios from './axiosClient'
import UserImage from './UserImage.vue'
import UserName from './UserName.vue'

export default {
  components: {
    UserImage,
    UserName
  },
  props: {
    feed: Object,
    user: Object,
    onDelete: Function
  },
  methods: {
    async deleteMicropost() {
      if (confirm('You sure?')) {
        await axios.delete(`/microposts/${this.feed.id}.json`)
        this.onDelete(this.feed.id)
      }
    }
  }
}
</script>
