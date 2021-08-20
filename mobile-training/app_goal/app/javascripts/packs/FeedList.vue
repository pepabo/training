<template>
  <div>
    <h3>Micropost Feed</h3>
    <ol class="microposts" v-if="feeds.length > 0">
      <feed-item
        v-for="feed in feeds"
        :key="feed.id"
        :feed="feed"
        :user="feed.user"
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
    feeds: Array,
    onDelete: Function
  }
}
</script>
