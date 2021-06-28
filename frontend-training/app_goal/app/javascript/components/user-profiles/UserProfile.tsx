import axios from "axios";
import { FeedItem, Stats, GravatarImage } from "components/shared";
import { useEffect, useState } from "react";
import { useParams } from "react-router-dom";

interface Micropost {
  id: number;
  content: string;
  image_url?: string;
  created_at_time_ago_in_words: string;
}

interface User {
  id: number;
  name: string;
  gravatar_url: string;
  microposts_count: number;
  following_count: number;
  followers_count: number;
  is_current_user: boolean;
  microposts: Micropost[];
}

interface Params {
  id: string;
}

const UserProfle = () => {
  const [user, setUser] = useState<User>();
  const [isLoadingUser, setIsLoadingUser] = useState(true);
  const { id } = useParams<Params>();

  useEffect(() => {
    const fetchUser = async () => {
      try {
        const res = await axios.get<User>(`/user_profiles/${id}.json`);
        setUser(res.data);
        setIsLoadingUser(false);
      } catch (error) {
        console.log(error);
      }
    };

    fetchUser();
  }, [id]);

  if (isLoadingUser) {
    return <p>ローディング中</p>;
  }

  if (!user) {
    return <p>表示できるユーザが存在しません</p>;
  }

  const onDeleteMicropost = (id: number) => {
    setUser({
      ...user,
      microposts: user.microposts.filter((micropost) => micropost.id !== id),
    });
  };

  return (
    <div className="row">
      <aside className="col-md-4">
        <section className="user_info">
          <h1>
            <GravatarImage user={user}></GravatarImage>
            {user.name}
          </h1>
        </section>
        <section className="stats">
          <Stats user={user}></Stats>
        </section>
      </aside>
      <div className="col-md-8">
          {user.microposts.length > 0 && (
            <>
              <h3>Microposts ({user.microposts.length})</h3>
              <ol className="microposts">
                {user.microposts.map((micropost) => (
                  <li key={micropost.id}>
                    <FeedItem
                      feed={micropost}
                      user={user}
                      onDelete={onDeleteMicropost}
                    ></FeedItem>
                  </li>
                ))}
              </ol>
            </>
          )}
      </div>
    </div>
  );
};

export default UserProfle;
