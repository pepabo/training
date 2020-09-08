import axios from 'axios'

const client = axios.create()

client.interceptors.request.use((config) => {
  const token = document.querySelector('meta[name="csrf-token"]').content
  config.headers['X-CSRF-Token'] = token
  return config
}, (error) => {
  return Promise.reject(error)
})

client.interceptors.response.use((response) => {
  const token = response.headers['X-CSRF-Token']
  if (token) {
    document.querySelector('meta[name="csrf-token"]').content = token
  }
  return response
}, (error) => {
  return Promise.reject(error)
})

export default client
