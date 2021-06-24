import axios from "axios";
import { useEffect, useState } from "react";

interface User {
  id: number;
  following_count: number;
  followers_count: number;
}

const Stats = () => {
  const [user, setUser] = useState<User>();
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const fetchUser = async () => {
      const res = await axios.get<User>("/me.json");
      setUser(res.data);
      setIsLoading(false);
    };

    fetchUser();
  }, []);

  if (isLoading) {
    return <>ローディング中</>;
  }

  if (!user) {
    return <></>;
  }

  return (
    <div className="stats">
      <a href={`/users/${user.id}/following`}>
        <strong id="following" className="stat">
          {user.following_count}
        </strong>
        following
      </a>
      <a href={`/users/${user.id}/followers`}>
        <strong id="followers" className="stat">
          {user.followers_count}
        </strong>
        followers
      </a>
    </div>
  );
};

export default Stats;
