import axios from "axios";
import { useEffect, useState } from "react";
import { FeedList, MicropostForm, Stats, UserInfo } from "components/shared";

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

const Home = () => {
  const [feeds, setFeeds] = useState<Feed[]>([]);
  const [isLoadingFeeds, setIsLoadingFeeds] = useState(true);

  useEffect(() => {
    const fetchFeeds = async () => {
      const res = await axios.get<Feed[]>("/feeds.json");
      setFeeds(res.data);
      setIsLoadingFeeds(false);
    };

    fetchFeeds();
  }, []);

  const concatNewFeed = (newFeed: Feed) => {
    setFeeds([newFeed].concat(feeds));
  };

  const deleteFeed = (id: number) => {
    setFeeds(feeds.filter((feed) => feed.id !== id));
  };

  return (
    <div className="row">
      <aside className="col-md-4">
        <section className="user_info">
          <UserInfo />
        </section>
        <section className="stats">
          <Stats />
        </section>
        <section className="micropost_form">
          <MicropostForm onCreateNewMicropost={concatNewFeed} />
        </section>
      </aside>
      <div className="col-md-8">
        {isLoadingFeeds ? (
          <div>ローディング中</div>
        ) : (
          <FeedList feeds={feeds} onDelete={deleteFeed} />
        )}
      </div>
    </div>
  );
};

export default Home;
