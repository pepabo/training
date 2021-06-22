import axios from "axiosClient";
import * as React from "react";
import { useRef, useState } from "react";

interface User {
  id: number;
  name: string;
  gravatar_url: string;
  is_current_user: boolean;
}

interface Feed {
  id: number;
  content: string;
  image_url?: string;
  created_at_time_ago_in_words: string;
  user: User;
}

interface Props {
  onCreateNewMicropost: (newMicropost: Feed) => void;
}

const MicropostForm = (props: Props) => {
  const [content, setContent] = useState("");
  const inputFileElement = useRef<HTMLInputElement>(null);

  const handleChangeContent = (
    event: React.ChangeEvent<HTMLTextAreaElement>
  ) => {
    setContent(event.target.value);
  };

  const handleChangeInputFile = (
    event: React.ChangeEvent<HTMLInputElement>
  ) => {
    if (inputFileElement.current) {
      const size = inputFileElement.current.files?.item(0)?.size;

      if (size && size / 1024 / 1024 > 5) {
        alert("Maximum file size is 5MB. Please choose a smaller file.");
        inputFileElement.current.value = "";
        event.preventDefault();
      }
    }
  };

  const handleSubmit = async (event: React.FormEvent) => {
    event.preventDefault();
    if (content === "") {
      alert("Content can't be blank");
      return;
    }

    try {
      const data = new FormData();
      data.append("micropost[content]", content);
      const file = inputFileElement.current?.files?.item(0);
      if (file) {
        data.append("micropost[image]", file);
      }

      const res = await axios.post<Feed>("/microposts.json", data, {
        headers: {
          "Content-Type": "multipart/form-data",
        },
      });

      setContent("");
      if (inputFileElement.current) {
        inputFileElement.current.value = "";
      }

      props.onCreateNewMicropost(res.data);
    } catch (error) {
      console.log(error.message);
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <div className="field">
        <textarea
          placeholder="Compose new micropost..."
          value={content}
          onChange={handleChangeContent}
        ></textarea>
      </div>
      <input type="submit" value="Post" className="btn btn-primary"></input>
      <span className="image">
        <input
          type="file"
          ref={inputFileElement}
          onChange={handleChangeInputFile}
          accept="image/jpeg,image/gif,image/png"
        ></input>
      </span>
    </form>
  );
};

export default MicropostForm;
