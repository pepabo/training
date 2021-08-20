<template>
  <div>
    <h3>Microposts ({{ user.microposts_count }})</h3>
    <ol class="microposts" v-if="user.microposts.length > 0">
      <feed-item
        v-for="feed in user.microposts"
        :key="feed.id"
        :feed="feed"
        :user="user"
        :on-delete="onDelete"
      ></feed-item>
    </ol>
  </div>
</template>

<script>
import FeedItem from './FeedItem.vue'

export default {
  components: { FeedItem },
  props: {
    user: Object,
    onDelete: Function
  }
}
</script>
