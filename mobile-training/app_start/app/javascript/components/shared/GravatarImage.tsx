import { Link } from "react-router-dom";

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
    <Link to={`/user_profiles/${props.user.id}`}>
      <img
        src={props.user.gravatar_url}
        alt={props.user.name}
        className="gravatar"
      />
    </Link>
  );
};

export default GravatarImage;
