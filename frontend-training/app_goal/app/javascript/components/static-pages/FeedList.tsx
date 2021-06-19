import axios from "axios";
import { useEffect, useState } from "react";
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

const FeedList = () => {
  const [feeds, setFeeds] = useState<Feed[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const fetchFeeds = async () => {
      const res = await axios.get<Feed[]>("/feeds.json");
      setFeeds(res.data);
      setIsLoading(false);
    };

    fetchFeeds();
  }, []);

  const deleteFeed = (id: number) => {
    setFeeds(feeds.filter((feed) => feed.id !== id));
  };

  return (
    <>
      <h3>Micropost Feed</h3>
      {isLoading ? (
        <div>ローディング中</div>
      ) : feeds.length > 0 ? (
        <ol className="microposts">
          {feeds.map((feed) => (
            <li key={feed.id}>
              <FeedItem feed={feed} onDelete={deleteFeed} />
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
