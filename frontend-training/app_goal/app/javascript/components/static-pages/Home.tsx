import axios from "axios";
import { useEffect, useState } from "react";

interface Feed {
  id: number;
  content: string;
}

interface FeedsProps {
  feeds: Feed[];
}

const Feeds = (props: FeedsProps) =>
  props.feeds.length > 0 ? (
    <ol className="microposts">
      {props.feeds.map((feed) => (
        <li key={feed.id}>
          <span className="content">{feed.content}</span>
        </li>
      ))}
    </ol>
  ) : (
    <div>表示できるフィードはありません。</div>
  );

const Home = () => {
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

  return (
    <div className="row">
      <div className="col-mod-8">
        <h3>Micropost Feed</h3>
        {isLoading ? <div>ローディング中</div> : <Feeds feeds={feeds} />}
      </div>
    </div>
  );
};

export default Home;
