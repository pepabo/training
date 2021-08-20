<template>
  <section class="user_info">
    <user-image :user="user"></user-image>
    <h1>{{ user.name }}</h1>
    <div v-if="isMe">
      <span>
        <router-link :to="'/user_profiles/' + user.id">
          view my profile
        </router-link>
      </span>
      <span>
        {{ micropostsCount }}
      </span>
    </div>
    <user-stat :user="user"></user-stat>
  </section>
</template>

<script>
import pluralize from 'pluralize'
import UserImage from './UserImage.vue'
import UserStat from './UserStat.vue'

export default {
  components: {
    UserImage,
    UserStat
  },
  props: {
    user: Object
  },
  computed: {
    micropostsCount() {
      return pluralize(
        'micropost',
        this.user.microposts_count,
        true
      )
    },
    isMe() {
      return !this.$route.params.id
    }
  }
}
</script>
