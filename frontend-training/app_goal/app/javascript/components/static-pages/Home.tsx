import { useEffect, useState } from "react";
import FeedList from "./FeedList";

const Home = () => {
  return (
    <div className="row">
      <div className="col-mod-8">
        <FeedList />
      </div>
    </div>
  );
};

export default Home;
