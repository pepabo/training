<template>
  <span class="name">
    <a :href="'/users/' + user.id">{{ user.name }}</a>
  </span>
</template>

<script>
export default {
  props: {
    user: Object
  }
}
</script>
