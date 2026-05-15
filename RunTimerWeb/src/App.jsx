import {
  BrowserRouter,
  Route,
  Routes,
  useLocation,
} from "react-router-dom";

import { AnimatePresence } from "framer-motion";

import Competitions from "./pages/Competitions";
import Dashboard from "./pages/Dashboard";
import Login from "./pages/Login";
import ParticipantProfile from "./pages/ParticipantProfile.jsx";
import Profile from "./pages/Profile.jsx";
import Register from "./pages/Register";
import Results from "./pages/Results";
import Settings from "./pages/Settings.jsx";

function AnimatedRoutes() {

  const location = useLocation();

  return (
    <AnimatePresence mode="wait">

      <Routes location={location} key={location.pathname}>
        <Route path="/" element={<Login />} />
        <Route path="/register" element={<Register />} />
        <Route path="/dashboard" element={<Dashboard />} />
        <Route path="/results" element={<Results />} />
        <Route path="/competitions" element={<Competitions />} />
        <Route path="/Settings" element={<Settings />} />
        <Route path="/Profile" element={<Profile />} />
        <Route path="/participanteProfile" element={<ParticipantProfile />} />
      </Routes>

    </AnimatePresence>
  );
}

function App() {
  return (
    <BrowserRouter>
      <AnimatedRoutes />
    </BrowserRouter>
  );
}

export default App;