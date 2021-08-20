<template>
  <section class="micropost_form">
    <div class="field">
      <textarea
        placeholder="Compose new micropost..."
        id="micropost_content"
        v-model="content"
      >
      </textarea>
    </div>
    <input type="submit" value="Post" class="btn btn-primary" @click="createMicropost">
    <span class="picture">
      <input
        accept="image/jpeg,image/gif,image/png"
        type="file"
        id="micropost_picture"
        @change.prevent="handlePictureChange"
      >
    </span>
  </section>
</template>

<script>
import axios from './axiosClient'

export default {
  props: {
    onCreate: Function
  },
  data() {
    return {
      content: '',
      picture: null
    }
  },
  methods: {
    handlePictureChange(event) {
      this.picture = event.target.files[0]
    },
    async createMicropost() {
      const data = new FormData()
      data.append('micropost[content]', this.content)
      data.append('micropost[picture]', this.picture)
      const res = await axios.post('/microposts.json', data, {
        headers: {
          'Content-Type': 'multipart/form-data'
        }
      })
      this.content = ''
      this.picture = null
      this.onCreate(res.data)
    }
  }
}
</script>
