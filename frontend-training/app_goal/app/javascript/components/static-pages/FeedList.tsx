import FeedItem from "./FeedItem";

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
  feeds: Feed[];
  onDelete: (id: number) => void;
}

const FeedList = (props: Props) => {
  return (
    <>
      <h3>Micropost Feed</h3>
      {props.feeds.length > 0 ? (
        <ol className="microposts">
          {props.feeds.map((feed) => (
            <li key={feed.id}>
              <FeedItem feed={feed} onDelete={props.onDelete} />
            </li>
          ))}
        </ol>
      ) : (
        <div>表示できるフィードはありません。</div>
      )}
    </>
  );
};

export default FeedList;
