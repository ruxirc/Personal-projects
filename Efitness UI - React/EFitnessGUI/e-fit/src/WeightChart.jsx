import React, { useEffect, useState } from "react";
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
} from "recharts";
import "./WeightChart.css";

const WorkoutChart = () => {
  const [workouts, setWorkouts] = useState([]);
  const [error, setError] = useState("");

  useEffect(() => {
    const fetchData = async () => {
      try {
        console.log("Start fetching data...");
        const response = await fetch("http://localhost:18082", {
          method: "GET",
          credentials: "include",
        });

        if (!response.ok) {
          console.error(`Error: Status code ${response.status}`);
          setError(`Failed to fetch data. Status: ${response.status}`);
          return;
        }

        const data = await response.json();
        console.log("Server response:", data);

        if (data.workouts && Array.isArray(data.workouts)) {
          const formattedData = data.workouts.map((workout) => ({
            x: new Date(workout.datetime).toLocaleDateString(),
            y: workout.reps,
            description: workout.description,
            exercise: workout.exercise.name,
          }));
          setWorkouts(formattedData);
        } else {
          console.warn("No valid workout data found.");
          setWorkouts([]);
        }

        setError("");
      } catch (error) {
        console.error("Fetch error:", error);
        setError("Failed to load data. Please try again later.");
      }
    };

    fetchData();
  }, []);

  return (
    <div className="chart-container">
      <h2 className="chart-title">Workout Progress</h2>

      {error && <div className="error">{error}</div>}

      {workouts.length > 0 ? (
        <ResponsiveContainer width="100%" height={300}>
          <LineChart
            data={workouts}
            margin={{ top: 20, right: 20, left: 20, bottom: 5 }}
          >
            <CartesianGrid strokeDasharray="3 3" stroke="#e0e0e0" />
            <XAxis dataKey="x" stroke="#46494c" />
            <YAxis stroke="#46494c" />
            <Tooltip
              contentStyle={{ backgroundColor: "#4c5c68", color: "#dcdcdd" }}
              formatter={(value, name, props) => {
                if (name === "y") return [`${value} reps`, "Reps"];
                return [value, name];
              }}
              labelFormatter={(label) => `Date: ${label}`}
            />
            <Legend wrapperStyle={{ color: "#4c5c68" }} />
            <Line
              type="monotone"
              dataKey="y"
              stroke="#1985a1"
              strokeWidth={3}
              activeDot={{
                r: 8,
                stroke: "#1985a1",
                strokeWidth: 2,
                fill: "#fff",
              }}
              dot={{ r: 6, fill: "#1985a1" }}
            />
          </LineChart>
        </ResponsiveContainer>
      ) : (
        <p className="no-data">No workout data available.</p>
      )}
    </div>
  );
};

export default WorkoutChart;
