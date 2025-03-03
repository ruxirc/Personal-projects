import React, { useState, useEffect } from "react";
import "./Login.css";

const Login = () => {
  const [isLogin, setIsLogin] = useState(true);
  const [formData, setFormData] = useState({
    firstName: "",
    lastName: "",
    email: "",
    password: "",
    gender: "M", // Default gender
    profilePicture: "",
    phone: "",
  });
  const [message, setMessage] = useState(""); // Starea pentru mesajul afișat

  useEffect(() => {
    document.body.classList.add("login");
    document.body.classList.add("background-image");
    return () => {
      document.body.classList.remove("login");
      document.body.classList.remove("background-image");
    };
  }, []);

  const handleToggle = (formType) => {
    setIsLogin(formType === "login");
  };

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData({
      ...formData,
      [name]: value,
    });
  };

  const handleLogin = async () => {
    const { email, password } = formData;

    // Verificăm dacă email-ul și parola sunt completate
    if (!email || !password) {
      setMessage("Please fill in all fields.");
      return;
    }

    try {
      // Construim URL-ul
      const url = "http://localhost:18080/login";

      // Trimitere request POST cu body
      const response = await fetch(url, {
        method: "POST",
        credentials: "include",
        body: JSON.stringify({ email, password }), // Body-ul cererii
      });

      // Verificăm răspunsul serverului
      if (!response.ok) {
        const errorData = await response.json();
        setMessage(errorData.message || "Login failed. Please try again.");
        return;
      }

      const data = await response;
      setMessage(`Login successful! Welcome, ${data.body}.`);
      console.log("User data:", data); // Logare date utilizator primite de la server

      // Poți adăuga aici logica suplimentară, cum ar fi salvarea unui token
    } catch (error) {
      console.error("Error during login:", error);
    }
  };

  const handleSignup = async () => {
    const { firstName, lastName, email, password, phone, profilePicture } =
      formData;

    // Verificăm dacă datele sunt complete
    if (
      !firstName ||
      !lastName ||
      !email ||
      !password ||
      !phone ||
      !profilePicture
    ) {
      setMessage("Please fill in all fields.");
      return;
    }

    try {
      // Construim URL-ul
      const url = "http://localhost:18080/signup";

      // Trimitere request GET cu body
      const response = await fetch(url, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          firstName,
          lastName,
          email,
          password,
          phone,
          profilePicture,
        }), // Body-ul cererii
      });

      // Verificăm răspunsul serverului
      if (!response.ok) {
        const errorData = await response;
        setMessage(errorData.message || "Signup failed. Please try again.");
        return;
      }

      const data = await response;
      setMessage(`Signup successful! Welcome, ${data.body}.`);
      console.log("User data:", data); // Logare date utilizator primite de la server

      // Poți adăuga aici logica suplimentară, cum ar fi salvarea unui token
    } catch (error) {
      console.error("Error during signup:", error);
    }
  };

  return (
    <div className="container">
      <div className="btn">
        <button
          className={`login ${isLogin ? "active" : ""}`}
          onClick={() => handleToggle("login")}
        >
          Login
        </button>
        <button
          className={`signup ${!isLogin ? "active" : ""}`}
          onClick={() => handleToggle("signup")}
        >
          Signup
        </button>
        <div
          className={`slider ${isLogin ? "move-login" : "move-signup"}`}
        ></div>{" "}
      </div>

      <div className={`form-section`}>
        {/* Afișează mesajul pe ecran */}
        {message && <div className="message-box">{message}</div>}

        {/* Login Form */}
        {isLogin && (
          <div className="login-box">
            <input
              type="email"
              className="email ele"
              placeholder="youremail@email.com"
              name="email"
              value={formData.email}
              onChange={handleChange}
            />
            <input
              type="password"
              className="password ele"
              placeholder="password"
              name="password"
              onChange={handleChange}
            />
            <button className="clkbtn" onClick={handleLogin}>
              Login
            </button>
          </div>
        )}

        {/* Signup Form */}
        {!isLogin && (
          <div className="signup-box">
            <input
              type="text"
              className="firstName ele"
              placeholder="First Name"
              name="firstName"
              value={formData.firstName}
              onChange={handleChange}
            />
            <input
              type="text"
              className="lastName ele"
              placeholder="Last Name"
              name="lastName"
              value={formData.lastName}
              onChange={handleChange}
            />
            <input
              type="email"
              className="email ele"
              placeholder="youremail@email.com"
              name="email"
              value={formData.email}
              onChange={handleChange}
            />
            <input
              type="password"
              className="password ele"
              placeholder="password"
              name="password"
              onChange={handleChange}
            />
            <input
              type="password"
              className="password ele"
              placeholder="Confirm password"
              name="confirmPassword"
              onChange={handleChange}
            />
            <input
              type="text"
              className="phone ele"
              placeholder="Phone Number"
              name="phone"
              value={formData.phone}
              onChange={handleChange}
            />
            <input
              type="text"
              className="profilePicture ele"
              placeholder="Profile Picture URL"
              name="profilePicture"
              value={formData.profilePicture}
              onChange={handleChange}
            />
            <button className="clkbtn" onClick={handleSignup}>
              Signup
            </button>
          </div>
        )}
      </div>
    </div>
  );
};

export default Login;
