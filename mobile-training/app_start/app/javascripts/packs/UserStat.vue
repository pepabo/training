<template>
  <div class="stats">
    <a :href="'/users/' + user.id + '/following'">
      <strong id="following" class="stat">
        {{ user.following_count }}
      </strong>
      following
    </a>
    <a :href="'/users/' + user.id + '/followers'">
      <strong id="followers" class="stat">
        {{ user.followers_count }}
      </strong>
      followers
    </a>
  </div>
</template>

<script>
export default {
  props: {
    user: Object
  }
}
</script>
