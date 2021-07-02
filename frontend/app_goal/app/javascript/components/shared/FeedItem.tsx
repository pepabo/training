import axios from "axiosClient";
import * as React from "react";
import GravatarImage from "./GravatarImage";

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
}

interface Props {
  feed: Feed;
  user: User;
  onDelete: (id: number) => void;
}

const FeedItem = (props: Props) => {
  const handleClickDeleteButton = async (event: React.MouseEvent) => {
    event.preventDefault();

    if (confirm("You sure?")) {
      await axios.delete(`/microposts/${props.feed.id}.json`);

      props.onDelete(props.feed.id);
    }
  };

  return (
    <>
      <GravatarImage user={props.user} />
      <span className="user">
        <a href={`/users/${props.user.id}`}>{props.user.name}</a>
      </span>
      <span className="content">
        {props.feed.content}
        {props.feed.image_url && <img src={props.feed.image_url} />}
      </span>
      <span className="timestamp">
        Posted {props.feed.created_at_time_ago_in_words} ago.{" "}
        {props.user.is_current_user && (
          <a onClick={handleClickDeleteButton}>delete</a>
        )}
      </span>
    </>
  );
};

export default FeedItem;
