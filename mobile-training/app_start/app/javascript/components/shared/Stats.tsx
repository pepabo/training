interface User {
  id: number;
  following_count: number;
  followers_count: number;
}

interface Props {
  user: User;
}

const Stats = (props: Props) => {
  return (
    <div className="stats">
      <a href={`/users/${props.user.id}/following`}>
        <strong id="following" className="stat">
          {props.user.following_count}
        </strong>
        following
      </a>
      <a href={`/users/${props.user.id}/followers`}>
        <strong id="followers" className="stat">
          {props.user.followers_count}
        </strong>
        followers
      </a>
    </div>
  );
};

export default Stats;
