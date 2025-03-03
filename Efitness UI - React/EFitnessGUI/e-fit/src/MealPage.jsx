import React, { useEffect, useState } from "react";
import "./MealPage.css";

function MealsPage() {
  const [meals, setMeals] = useState([]);
  const [waters, setWaters] = useState([]);
  const [error, setError] = useState("");

  useEffect(() => {
    const fetchData = async () => {
      try {
        console.log("Start fetching data...");
        const response = await fetch("http://localhost:18082", {
          method: "GET",
          credentials: "include",
        });

        // Verificăm statusul răspunsului HTTP
        if (!response.ok) {
          console.error(`Error: Status code ${response.status}`);
          setError(`Failed to fetch data. Status: ${response.status}`);
          return;
        }

        // Extragem datele din răspuns
        const data = await response.json();
        console.log("Răspunsul de la server:", data); // Logăm răspunsul serverului pentru debugging

        // Verificăm dacă există date pentru meals și waters
        if (data.meals && Array.isArray(data.meals)) {
          setMeals(data.meals);
        } else {
          console.warn("Nu au fost găsite date valide pentru meals.");
          setMeals([]);
        }

        if (data.waters && Array.isArray(data.waters)) {
          setWaters(data.waters);
        } else {
          console.warn("Nu au fost găsite date valide pentru waters.");
          setWaters([]);
        }

        setError(""); // Resetăm eroarea dacă datele au fost încărcate corect
      } catch (error) {
        console.error("A apărut o eroare la fetch:", error);
        setError("Failed to load data. Please try again later.");
      }
    };

    fetchData(); // Apelăm funcția fetchData
  }, []); // Se execută doar o singură dată când componenta se montează

  return (
    <div>
      <h1>Meals and Waters</h1>

      {/* Afișează mesajul de eroare, dacă există */}
      {error && <div className="error">{error}</div>}

      {/* Secțiunea pentru Meals */}
      <div className="meals">
        <h2>Meals</h2>
        {meals.length > 0 ? (
          meals.map((meal) => (
            <div key={meal.id} className="meal">
              <h3>{meal.description}</h3>
              <p>Calories: {meal.calories}</p>
              <p>Carbs: {meal.carbs}g</p>
              <p>Fats: {meal.fats}g</p>
              <p>Protein: {meal.protein}g</p>
              <p>Weight: {meal.weight}g</p>
              <p>Date: {new Date(meal.datetime).toLocaleString()}</p>
            </div>
          ))
        ) : (
          <p>No meals available.</p>
        )}
      </div>

      {/* Secțiunea pentru Waters */}
      <div className="waters">
        <h2>Waters</h2>
        {waters.length > 0 ? (
          waters.map((water) => (
            <div key={water.id} className="water">
              <h3>{water.description}</h3>
              <p>Quantity: {water.quantity} ml</p>
              <p>Sugar: {water.sugar}g</p>
              <p>Caffeine: {water.caffeine}mg</p>
              <p>Date: {new Date(water.datetime).toLocaleString()}</p>
            </div>
          ))
        ) : (
          <p>No water data available.</p>
        )}
      </div>
    </div>
  );
}

export default MealsPage;
