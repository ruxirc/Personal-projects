import React from "react";
import { Link } from "react-router-dom";
import "./Menu.css";

function Menu() {
  return (
    <div className="app-bar">
      <div className="app-bar-title">EFitness</div>
      <div className="menu">
        <Link to="/" className="menu-button">
          Home
        </Link>
        <Link to="/workout" className="menu-button">
          Workout
        </Link>
        <Link to="/meal" className="menu-button">
          Meal
        </Link>
        <Link to="/settings" className="menu-button">
          Login
        </Link>
      </div>
    </div>
  );
}

export default Menu;
