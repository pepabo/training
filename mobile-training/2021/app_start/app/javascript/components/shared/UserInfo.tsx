import GravatarImage from "./GravatarImage";

interface User {
  id: number;
  name: string;
  gravatar_url: string;
  microposts_count: number;
}

interface Props {
  user: User;
}

const pluralizeMicroposts = (microposts_count: number) => {
  return `${microposts_count} ${
    microposts_count > 1 ? "microposts" : "micropost"
  }`;
};

const UserInfo = (props: Props) => {
  return (
    <>
      <GravatarImage user={props.user}></GravatarImage>
      <h1>{props.user.name}</h1>
      <span>
        <a href={`/users/${props.user.id}`}>view my profile</a>
      </span>
      <span>{pluralizeMicroposts(props.user.microposts_count)}</span>
    </>
  );
};

export default UserInfo;
