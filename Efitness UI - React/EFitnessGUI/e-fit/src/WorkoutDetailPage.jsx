import React, { useEffect, useState } from "react";
import { useLocation, useNavigate } from "react-router-dom";
import "./WorkoutDetailPage.css";

const WorkoutDetailPage = () => {
  const location = useLocation();
  const navigate = useNavigate();
  const [exercise, setExercise] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [allExercises, setAllExercises] = useState([]); // Pentru a păstra toate exercițiile

  // Preluăm exerciseId din state-ul trimis de la WorkoutPage
  const exerciseId = location.state?.exerciseId;

  // Funcția pentru a prelua toate exercițiile (la fel ca în WorkoutPage)
  useEffect(() => {
    const fetchAllExercises = async () => {
      const muscleIds = [1, 2, 3, 4, 5];
      const fetchedExercises = [];
      try {
        for (let id of muscleIds) {
          const response = await fetch(`http://localhost:18082/muscle/${id}`);
          if (!response.ok) {
            throw new Error(`Failed to fetch muscle group with ID ${id}`);
          }
          const data = await response.json();
          fetchedExercises.push(...data.workedBy); // Adăugăm toate exercițiile
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

  // Funcția pentru a prelua detaliile exercițiului curent
  useEffect(() => {
    const fetchExerciseDetails = async () => {
      if (!exerciseId) {
        setError("Invalid exercise ID.");
        setLoading(false);
        return;
      }

      try {
        const response = await fetch(
          `http://localhost:18082/exercise/${exerciseId}`
        );
        if (!response.ok) {
          throw new Error(`Failed to fetch exercise with ID ${exerciseId}`);
        }
        const data = await response.json();
        setExercise(data); // Setăm detaliile exercițiului
      } catch (err) {
        console.error("Error fetching exercise details:", err);
        setError("Failed to load exercise details. Please try again later.");
      } finally {
        setLoading(false);
      }
    };

    fetchExerciseDetails();
  }, [exerciseId]);

  // Funcția pentru a naviga la un exercițiu aleatoriu
  const handleRandomNavigation = () => {
    if (allExercises.length > 0) {
      // Selectăm aleatoriu un exercițiu din lista de exerciții
      const randomExercise =
        allExercises[Math.floor(Math.random() * allExercises.length)];
      navigate(`/workout/${randomExercise.id}`, {
        state: { exerciseId: randomExercise.id },
      });
    }
  };

  if (loading) {
    return <div className="loading">Loading...</div>;
  }

  if (error) {
    return <div className="error">{error}</div>;
  }

  if (!exercise) {
    return (
      <div className="workout-detail-page">
        <h2>No exercise found</h2>
        <button onClick={() => navigate(-1)}>Back</button>
      </div>
    );
  }

  return (
    <div className="workout-detail-page">
      <h1>{exercise.name.replace(/-/g, " ")}</h1>
      <p>
        <strong>Type:</strong> {exercise.type}
      </p>
      <p>
        <strong>Primer:</strong> {exercise.primer}
      </p>
      <h3>Steps:</h3>
      <pre className="steps">{exercise.steps}</pre>

      <div className="navigation">
        <button onClick={() => navigate(-1)}>Back</button>
        <button onClick={handleRandomNavigation}>
          Next Suggested Exercise
        </button>
      </div>
    </div>
  );
};

export default WorkoutDetailPage;
