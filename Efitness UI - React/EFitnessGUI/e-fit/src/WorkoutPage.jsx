import React, { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import "./WorkoutPage.css";

const WorkoutPage = () => {
  const [allExercises, setAllExercises] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    const fetchAllExercises = async () => {
      const muscleIds = Array.from({ length: 35 }, (_, i) => i + 1);
      const fetchedExercises = [];
      try {
        for (let id of muscleIds) {
          const response = await fetch(`http://localhost:18082/muscle/${id}`);
          if (!response.ok) {
            throw new Error(`Failed to fetch muscle group with ID ${id}`);
          }
          const data = await response.json();
          fetchedExercises.push(...data.workedBy); // Adaugăm toate exercițiile
        }
        setAllExercises(fetchedExercises);
      } catch (err) {
        console.error("Error fetching exercises:", err);
        setError("Failed to load exercises. Please try again later.");
      } finally {
        setLoading(false);
      }
    };

    fetchAllExercises();
  }, []);

  if (loading) {
    return <div className="loading">Loading...</div>;
  }

  if (error) {
    return <div className="error">{error}</div>;
  }

  // Selectăm random 7 exerciții
  const randomExercises = allExercises
    .sort(() => Math.random() - 0.5)
    .slice(0, 7);

  return (
    <div className="workout-page">
      <h2>Explore Exercises</h2>
      <div className="exercise-list-horizontal">
        {randomExercises.map((exercise) => (
          <Link
            key={exercise.id}
            to={`/workout/${exercise.id}`} // Folosim ID-ul exercițiului
            state={{ exerciseId: exercise.id }}
            className="exercise-card"
          >
            <div>
              <h4>{exercise.name.replace(/-/g, " ")}</h4>
              <p>Type: {exercise.type}</p>
            </div>
          </Link>
        ))}
      </div>
      {/* Butonul pentru trainer */}
      <div className="trainer-button-container">
        <Link to="/trainer" className="trainer-button">
          Trainer
        </Link>
      </div>
    </div>
  );
};

export default WorkoutPage;
