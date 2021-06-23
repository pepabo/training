import { useParams } from "react-router-dom";

interface Params {
  id: string;
}

const UserProfle = () => {
  const { id } = useParams<Params>();

  return <>User id: {id}</>;
};

export default UserProfle;
