import { BrowserRouter, Link, Switch, Route } from "react-router-dom";
import PageNotFound from "./PageNotFound";
import { Home } from "./static-pages";

const App = () => {
  return (
    <BrowserRouter>
      <Switch>
        <Route exact path="/">
          <Home></Home>
        </Route>
        <Route path="*">
          <PageNotFound></PageNotFound>
        </Route>
      </Switch>
    </BrowserRouter>
  );
};

export default App;
