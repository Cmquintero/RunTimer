import React, { useEffect, lazy, Suspense } from "react";
import { Route, Routes, useLocation, Navigate } from "react-router-dom";
import { AnimatePresence } from "framer-motion";

import Competitions from "./pages/Competitions";
import Dashboard from "./pages/Dashboard";
import Login from "./pages/Login";
import ParticipantProfile from "./pages/ParticipantProfile";
import Profile from "./pages/Profile";
import Register from "./pages/Register";
import Results from "./pages/Results";
import Settings from "./pages/Settings";
import ProtectedRoute from "./components/ProtectedRoute";
import EditProfile from "./pages/EditProfile";
import Races from "./pages/Races"; 
import CompetitionDetail from "./pages/CompetitionDetail"; // 👈 IMPORTA TU NUEVO DETALLE AUTOMÁTICO

const Podium = lazy(() => import("./pages/Podium"));

function AnimatedRoutes() {
  const location = useLocation();

  return (
    <AnimatePresence mode="wait">
      <Routes location={location} key={location.pathname}>
        {/* Públicas */}
        <Route path="/login" element={<Login />} />
        <Route path="/register" element={<Register />} />

        <Route
          path="/"
          element={
            <ProtectedRoute>
              <Navigate to="/dashboard" replace />
            </ProtectedRoute>
          }
        />

        <Route
          path="/podium"
          element={
            <ProtectedRoute>
              <Suspense fallback={<div>Cargando...</div>}>
                <Podium />
              </Suspense>
            </ProtectedRoute>
          }
        />

        {/* Privadas */}
        <Route
          path="/dashboard"
          element={
            <ProtectedRoute>
              <Dashboard />
            </ProtectedRoute>
          }
        />

        {/* LISTA DE TODAS LAS CARRERAS (Con el buscador premium) */}
        <Route
          path="/competitions" 
          element={
            <ProtectedRoute>
              <Races /> {/* 👈 Reemplazamos la vieja vista estática por tu nuevo Races.jsx */}
            </ProtectedRoute>
          }
        />

        {/* VISTA AUTOMÁTICA DETALLADA DE CADA CARRERA */}
        <Route
          path="/competitions/:id" 
          element={
            <ProtectedRoute>
              <CompetitionDetail /> {/* 👈 Aquí es donde React Router captura el ID único */}
            </ProtectedRoute>
          }
        />

        <Route
          path="/results"
          element={
            <ProtectedRoute>
              <Results />
            </ProtectedRoute>
          }
        />

        <Route
          path="/settings"
          element={
            <ProtectedRoute>
              <Settings />
            </ProtectedRoute>
          }
        />

        <Route
          path="/profile"
          element={
            <ProtectedRoute>
              <Profile />
            </ProtectedRoute>
          }
        />

        <Route
          path="/participantProfile"
          element={
            <ProtectedRoute>
              <ParticipantProfile />
            </ProtectedRoute>
          }
        />

        <Route
          path="/editProfile"
          element={
            <ProtectedRoute>
              <EditProfile />
            </ProtectedRoute>
          }
        />

        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </AnimatePresence>
  );
}

function App() {
  useEffect(() => {
    const applyTheme = (theme) => {
      if (theme === "dark")
        document.documentElement.classList.add("dark");
      else
        document.documentElement.classList.remove("dark");
    };

    const saved = localStorage.getItem("theme") || "dark";
    applyTheme(saved);

    const handler = (e) => {
      if (e.key === "theme")
        applyTheme(e.newValue || "light");
    };

    window.addEventListener("storage", handler);
    return () =>
      window.removeEventListener("storage", handler);
  }, []);

  return (
    <div className="min-h-screen bg-gray-50 text-gray-900 dark:bg-black dark:text-white transition-colors duration-300">
      <AnimatedRoutes />
    </div>
  );
}

export default App;