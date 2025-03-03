import React, { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import "./WorkoutPlanner.css";

const WorkoutPlanner = () => {
  const [randomMuscles, setRandomMuscles] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    const fetchRandomMuscles = async () => {
      try {
        const muscleIds = Array.from({ length: 35 }, (_, i) => i + 1); // ID-uri de la 1 la 35
        const shuffledMuscles = muscleIds.sort(() => Math.random() - 0.5); // Amestecare
        const selectedMuscles = shuffledMuscles.slice(0, 5); // Selectăm 5 mușchi random

        const fetchedMuscles = await Promise.all(
          selectedMuscles.map(async (id) => {
            const response = await fetch(`http://localhost:18082/muscle/${id}`);
            if (!response.ok) {
              throw new Error(`Failed to fetch muscle with ID ${id}`);
            }
            const data = await response.json();
            return { id, name: data.name || `Muscle ${id}` };
          })
        );

        setRandomMuscles(fetchedMuscles);
      } catch (err) {
        console.error("Error fetching muscles:", err);
        setError("Failed to load suggested muscles. Please try again later.");
      } finally {
        setLoading(false);
      }
    };

    fetchRandomMuscles();
  }, []);

  if (loading) {
    return <div className="loading">Loading suggested muscles...</div>;
  }

  if (error) {
    return <div className="error">{error}</div>;
  }

  return (
    <div className="workout-planner">
      <h2>Workout Planner</h2>
      <p>Here are 5 muscles we suggest you work on:</p>
      <ul className="muscle-list">
        {randomMuscles.map((muscle) => (
          <li key={muscle.id} className="muscle-item">
            {muscle.name} (ID: {muscle.id})
          </li>
        ))}
      </ul>
      <Link to="/" className="back-button">
        Back to Exercises
      </Link>
    </div>
  );
};

export default WorkoutPlanner;
