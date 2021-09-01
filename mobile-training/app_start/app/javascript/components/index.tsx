import { BrowserRouter, Link, Switch, Route } from "react-router-dom";
import PageNotFound from "./PageNotFound";
import { Home } from "./static-pages";
import UserProfle from "./user-profiles/UserProfile";

const App = () => {
  return (
    <BrowserRouter>
      <Switch>
        <Route exact path="/">
          <Home></Home>
        </Route>
        <Route path="/user_profiles/:id">
          <UserProfle></UserProfle>
        </Route>
        <Route path="*">
          <PageNotFound></PageNotFound>
        </Route>
      </Switch>
    </BrowserRouter>
  );
};

export default App;
