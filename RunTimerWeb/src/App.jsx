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
import CompetitionDetail from "./pages/CompetitionDetail";
import ContactoCreadores from "./pages/ContactoCreadores";

const Podium = lazy(() => import("./pages/Podium"));

function AnimatedRoutes() {
  const location = useLocation();

  return (
    <AnimatePresence mode="wait">
      <Routes location={location} key={location.pathname}>
        {/* ───────────────────────── */}
        {/* RUTAS PÚBLICAS */}
        {/* ───────────────────────── */}
        <Route path="/login" element={<Login />} />
        <Route path="/register" element={<Register />} />
        {/* Redirect root */}
        <Route
          path="/"
          element={
            <ProtectedRoute>
              <Navigate to="/dashboard" replace />
            </ProtectedRoute>
          }
        />
        {/* ───────────────────────── */}
        {/* PODIUM (LAZY LOAD) */}
        {/* ───────────────────────── */}
        <Route
          path="/podium"
          element={
            <ProtectedRoute>
              <Suspense
                fallback={
                  <div className="min-h-screen bg-black text-white flex items-center justify-center">
                    Cargando podio...
                  </div>
                }
              >
                <Podium />
              </Suspense>
            </ProtectedRoute>
          }
        />
        {/* ───────────────────────── */}
        {/* PRIVADAS */}
        {/* ───────────────────────── */}
        // En tu archivo donde tienes las rutas (App.jsx o el archivo de rutas)
        <Route
          path="/contacto-creadores"
          element={
            <ProtectedRoute>
              <ContactoCreadores />
            </ProtectedRoute>
          }
        />
        <Route
          path="/dashboard"
          element={
            <ProtectedRoute>
              <Dashboard />
            </ProtectedRoute>
          }
        />
        {/* Lista de competencias */}
        <Route
          path="/competitions"
          element={
            <ProtectedRoute>
              <Races />
            </ProtectedRoute>
          }
        />
        {/* Detalle individual */}
        <Route
          path="/competitions/:id"
          element={
            <ProtectedRoute>
              <CompetitionDetail />
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
        {/* Ruta fallback */}
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </AnimatePresence>
  );
}

function App() {
  useEffect(() => {
    const applyTheme = (theme) => {
      if (theme === "dark") {
        document.documentElement.classList.add("dark");
      } else {
        document.documentElement.classList.remove("dark");
      }
    };

    const savedTheme = localStorage.getItem("theme") || "dark";

    applyTheme(savedTheme);

    const handleStorage = (e) => {
      if (e.key === "theme") {
        applyTheme(e.newValue || "light");
      }
    };

    window.addEventListener("storage", handleStorage);

    return () => {
      window.removeEventListener("storage", handleStorage);
    };
  }, []);

  return (
    <div className="min-h-screen bg-gray-50 text-gray-900 dark:bg-black dark:text-white transition-colors duration-300">
      <AnimatedRoutes />
    </div>
  );
}

export default App;
