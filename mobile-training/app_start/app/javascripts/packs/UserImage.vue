<template>
  <router-link :to="'/user_profiles/' + user.id">
    <img :src="user.gravatar_url" :alt="user.name" class="gravatar" />
  </router-link>
</template>

<script>
export default {
  props: {
    user: Object
  }
}
</script>
