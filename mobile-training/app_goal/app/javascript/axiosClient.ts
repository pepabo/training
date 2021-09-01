import axios from "axios";

const client = axios.create();

client.interceptors.request.use(
  (config) => {
    const token = document.querySelector<HTMLMetaElement>(
      'meta[name="csrf-token"]'
    )?.content;

    config.headers["X-CSRF-Token"] = token;
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

export default client;
