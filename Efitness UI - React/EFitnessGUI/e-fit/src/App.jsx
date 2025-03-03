import React from "react";
import {
  BrowserRouter as Router,
  Route,
  Routes,
  useLocation,
} from "react-router-dom";
import "./App.css";
import Menu from "./Menu";
import WeightChart from "./WeightChart";
import WorkoutPage from "./WorkoutPage";
import WorkoutPlanner from "./WorkoutPlanner";
import MealPage from "./MealPage";
import Login from "./Login";
import WorkoutDetailPage from "./WorkoutDetailPage";

// Helper Component to add class based on route
const BackgroundWrapper = ({ children }) => {
  const location = useLocation();

  let backgroundClass = "";

  if (location.pathname === "/") {
    backgroundClass = "main-page-background";
  }

  return <div className={backgroundClass}>{children}</div>;
};

function App() {
  return (
    <Router>
      <BackgroundWrapper>
        <div className="App">
          <Menu />
          <Routes>
            <Route path="/" element={<WeightChart />} />
            <Route path="/workout" element={<WorkoutPage />} />
            <Route path="/trainer" element={<WorkoutPlanner />} />
            <Route path="/meal" element={<MealPage />} />
            <Route path="/settings" element={<Login />} />
            <Route path="/workout/:muscleId" element={<WorkoutDetailPage />} />
          </Routes>
        </div>
      </BackgroundWrapper>
    </Router>
  );
}

export default App;
