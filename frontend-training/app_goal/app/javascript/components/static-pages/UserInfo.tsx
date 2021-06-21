import axios from "axios";
import { useEffect, useState } from "react";
import GravatarImage from "./GravatarImage";

interface User {
  id: number;
  name: string;
  gravatar_url: string;
  microposts_count: number;
}

const pluralizeMicroposts = (microposts_count: number) => {
  return `${microposts_count} ${
    microposts_count > 1 ? "microposts" : "micropost"
  }`;
};

const UserInfo = () => {
  const [user, setUser] = useState<User>();
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const fetchUser = async () => {
      const res = await axios.get<User>("/account/profiles.json");
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
    <>
      <GravatarImage user={user}></GravatarImage>
      <h1>{user.name}</h1>
      <span>
        <a href={`/users/${user.id}`}>view my profile</a>
      </span>
      <span>{pluralizeMicroposts(user.microposts_count)}</span>
    </>
  );
};

export default UserInfo;
