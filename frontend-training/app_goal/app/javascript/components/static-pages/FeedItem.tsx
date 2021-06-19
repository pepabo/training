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
  user: User;
}

interface Props {
  feed: Feed;
}

const FeedItem = (props: Props) => {
  return (
    <>
      <GravatarImage user={props.feed.user} />
      <span className="user">
        <a href={`/users/${props.feed.user.id}`}>{props.feed.user.name}</a>
      </span>
      <span className="content">
        {props.feed.content}
        {props.feed.image_url && <img src={props.feed.image_url} />}
      </span>
      <span className="timestamp">
        Posted {props.feed.created_at_time_ago_in_words} ago.{" "}
        {props.feed.user.is_current_user && <a>delete</a>}
      </span>
    </>
  );
};

export default FeedItem;
