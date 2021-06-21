interface User {
  id: number;
  name: string;
  gravatar_url: string;
}

interface Props {
  user: User;
}

const GravatarImage = (props: Props) => {
  return (
    <a href={`/users/${props.user.id}`}>
      <img
        src={props.user.gravatar_url}
        alt={props.user.name}
        className="gravatar"
      />
    </a>
  );
};

export default GravatarImage;
