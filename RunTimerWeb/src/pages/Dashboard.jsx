import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { motion } from "framer-motion";
import {
  Activity,
  Bell,
  LayoutDashboard,
  Settings,
  Timer,
  Trophy,
  Users,
  Wifi,
  X,
  ChevronRight,
  Calendar
} from "lucide-react";
import logo from "../assets/logo.svg";

import { useAuth } from "../context/AuthContext";
import { logoutUser } from "../services/authService";
import { db, database } from "../firebase/firebase";
import { collection, onSnapshot, query } from "firebase/firestore";
import { ref, onValue } from "firebase/database";

function Dashboard() {
  const navigate = useNavigate();
  const [isAnimating, setAnimating] = useState(false);
  const [competitions, setCompetitions] = useState([]);
  const [showNotifications, setShowNotifications] = useState(false);
  const { currentUser, userData } = useAuth();

  const [esp32Data, setEsp32Data] = useState({
    online: false,
    mejorTiempo: "0.00s",
    sensoresActivos: "0",
    participantes: "0",
  });

  useEffect(() => {
    const q = query(collection(db, "competitions"));

    const unsubscribeFirestore = onSnapshot(
      q,
      (snapshot) => {
        const data = [];
        snapshot.forEach((doc) => {
          data.push({ id: doc.id, ...doc.data() });
        });
        setCompetitions(data);
        console.log("Competitions actualizadas en tiempo real:", data);
      },
      (error) => {
        console.error("Error cargando competitions realtime:", error);
      },
    );

    const esp32Ref = ref(database, "hardware/esp32");

    const unsubscribeRTDB = onValue(
      esp32Ref,
      (snapshot) => {
        const value = snapshot.val();
        if (value) {
          setEsp32Data({
            online: value.online ?? false,
            mejorTiempo: value.mejor_tiempo
              ? `${value.mejor_tiempo}s`
              : "0.00s",
            sensoresActivos: value.sensores_count ?? "0",
            participantes: value.participantes_count ?? "0",
          });
          console.log("Datos de hardware actualizados en tiempo real:", value);
        }
      },
      (error) => {
        console.error("Error en RTDB:", error);
      },
    );

    return () => {
      unsubscribeFirestore();
      unsubscribeRTDB();
    };
  }, []);

  const goTo = (route) => {
    setAnimating(true);
    setTimeout(() => {
      navigate(route);
    }, 250);
  };

  const handleLogout = async () => {
    try {
      await logoutUser();
      navigate("/login");
    } catch (error) {
      console.error(error);
    }
  };

  const handleSelectCompetition = (id) => {
    goTo(`/competitions/${id}`);
  };

  const formatCompetitionDate = (dateField) => {
    if (!dateField) return "Sin fecha";
    if (dateField && typeof dateField.toDate === "function") {
      return dateField.toDate().toLocaleDateString();
    }
    return String(dateField);
  };

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: isAnimating ? 0 : 1 }}
      transition={{ duration: 0.2 }}
      className="min-h-screen bg-gray-50 dark:bg-black text-gray-900 dark:text-white flex transition-colors duration-300"
    >
      {/* SIDEBAR */}
      <aside className="w-72 bg-white dark:bg-zinc-950 border-r border-gray-200 dark:border-zinc-900 p-6 hidden md:flex flex-col transition-colors duration-300">
        <div className="flex items-center gap-4 mb-12">
          <div className="w-14 h-14 rounded-2xl bg-gray-50 dark:bg-zinc-900 border border-gray-200 dark:border-zinc-800 overflow-hidden flex items-center justify-center">
            <img
              src={logo}
              alt="RunTimer"
              className="w-full h-full object-cover"
            />
          </div>
          <div>
            <h1 className="text-2xl font-bold text-gray-900 dark:text-white">
              RunTimer
            </h1>
            <p className="text-gray-500 dark:text-gray-400 text-sm">
              Sistema de carreras
            </p>
          </div>
        </div>

        <nav className="flex flex-col gap-3">
          <button className="flex items-center gap-4 bg-red-500 text-white px-5 py-4 rounded-2xl font-semibold shadow-md shadow-red-500/10 text-left">
            <LayoutDashboard size={22} />
            Dashboard
          </button>
          <button
            onClick={() => goTo("/competitions")} // Ajusta a "/races" si usaste esa ruta en el App.jsx
            className="flex items-center gap-4 px-5 py-4 rounded-2xl bg-gray-100/70 dark:bg-zinc-900 hover:bg-gray-200/80 dark:hover:bg-zinc-800 text-gray-700 dark:text-gray-300 transition font-medium text-left"
          >
            <Trophy size={22} />
            Competencias
          </button>
          <button
            onClick={() => goTo("/results")}
            className="flex items-center gap-4 px-5 py-4 rounded-2xl bg-gray-100/70 dark:bg-zinc-900 hover:bg-gray-200/80 dark:hover:bg-zinc-800 text-gray-700 dark:text-gray-300 transition font-medium text-left"
          >
            <Activity size={22} />
            Resultados
          </button>
          <button
            onClick={() => goTo("/profile")}
            className="flex items-center gap-4 px-5 py-4 rounded-2xl bg-gray-100/70 dark:bg-zinc-900 hover:bg-gray-200/80 dark:hover:bg-zinc-800 text-gray-700 dark:text-gray-300 transition font-medium text-left"
          >
            <Users size={22} />
            Perfil
          </button>
          <button
            onClick={() => goTo("/settings")}
            className="flex items-center gap-4 px-5 py-4 rounded-2xl bg-gray-100/70 dark:bg-zinc-900 hover:bg-gray-200/80 dark:hover:bg-zinc-800 text-gray-700 dark:text-gray-300 transition font-medium text-left"
          >
            <Settings size={22} />
            Configuración
          </button>
        </nav>

        <div className="mt-auto pt-6 flex flex-col gap-4">
          <motion.button
            whileHover={{ scale: 1.02 }}
            whileTap={{ scale: 0.98 }}
            onClick={() => goTo("/podium")} // Normalizado a minúsculas para evitar fallos de rutas
            className="
              w-full
              relative
              overflow-hidden
              rounded-[28px]
              p-5
              text-left
              border
              border-red-500/20
              bg-gradient-to-br
              from-red-500/15
              via-zinc-900/10
              to-transparent
              dark:from-red-500/10
              dark:via-zinc-900/50
              dark:to-zinc-950
              hover:border-red-500/40
              transition-all
              duration-300
              group
            "
          >
            <div className="absolute inset-0 opacity-0 group-hover:opacity-100 transition duration-500 bg-gradient-to-r from-red-500/10 via-transparent to-transparent" />

            <div className="relative flex items-start justify-between">
              <div>
                <div className="flex items-center gap-2 mb-2">
                  <div className="w-10 h-10 rounded-2xl bg-red-500/10 flex items-center justify-center border border-red-500/20">
                    <Trophy size={20} className="text-red-500" />
                  </div>

                  <span className="text-xs font-bold uppercase tracking-[0.18em] text-red-500 flex items-center gap-1.5">
                    <span className="w-1.5 h-1.5 rounded-full bg-red-500 animate-pulse" />
                    Live
                  </span>
                </div>

                <h3 className="text-lg font-bold text-gray-900 dark:text-white mb-1">
                  Podio en Vivo
                </h3>

                <p className="text-sm text-gray-500 dark:text-gray-400 leading-relaxed">
                  Visualiza posiciones, tiempos y ganadores en tiempo real.
                </p>
              </div>
            </div>

            <div className="flex items-center justify-between mt-5">
              <span className="text-sm font-bold text-red-500 group-hover:text-red-600 transition-colors">
                Abrir podio →
              </span>

              <div className="flex items-end gap-1 h-8">
                <div className="w-2.5 h-4 bg-zinc-300 dark:bg-zinc-700 rounded-t-sm" />
                <div className="w-2.5 h-7 bg-red-500 rounded-t-sm" />
                <div className="w-2.5 h-2.5 bg-zinc-400 dark:bg-zinc-600 rounded-t-sm" />
              </div>
            </div>
          </motion.button>

          <button
            onClick={handleLogout}
            className="w-full bg-zinc-100 hover:bg-red-500 dark:bg-zinc-900 dark:hover:bg-red-600 text-gray-700 dark:text-zinc-300 hover:text-white dark:hover:text-white transition-all py-4 rounded-2xl font-semibold border border-transparent dark:border-zinc-800/60"
          >
            Cerrar sesión
          </button>
        </div>
      </aside>

      {/* MAIN CONTENT */}
      <main className="flex-1 p-6 md:p-10 overflow-y-auto relative">
        <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-6 mb-10">
          <div>
            <h1 className="text-4xl font-bold mb-2 text-gray-900 dark:text-white">
              Dashboard
            </h1>
            <p className="text-gray-500 dark:text-gray-400">
              Monitoreo en tiempo real de las carreras.
            </p>
          </div>

          <div className="flex items-center gap-4 relative">
            <button
              onClick={() => setShowNotifications(!showNotifications)}
              className="relative w-14 h-14 rounded-2xl bg-white dark:bg-zinc-900 border border-gray-200 dark:border-zinc-800 flex items-center justify-center hover:bg-gray-100 dark:hover:bg-zinc-800 text-gray-700 dark:text-gray-300 transition shadow-sm"
            >
              <Bell size={22} />
              <span className="absolute top-3 right-3 w-3 h-3 bg-red-500 rounded-full border-2 border-white dark:border-black" />
            </button>

            {showNotifications && (
              <div className="absolute top-20 right-0 w-[360px] bg-white dark:bg-zinc-950 border border-gray-200 dark:border-zinc-800 rounded-3xl shadow-xl z-50 overflow-hidden transition-colors duration-300">
                <div className="flex items-center justify-between p-5 border-b border-gray-100 dark:border-zinc-800">
                  <h2 className="font-bold text-lg text-gray-900 dark:text-white">
                    Notificaciones
                  </h2>
                  <button
                    className="text-gray-400 hover:text-gray-600 dark:hover:text-white"
                    onClick={() => setShowNotifications(false)}
                  >
                    <X size={20} />
                  </button>
                </div>
                <div className="max-h-[350px] overflow-y-auto">
                  <div className="p-4 hover:bg-gray-50 dark:hover:bg-zinc-900 transition cursor-pointer">
                    <p className="font-semibold text-gray-900 dark:text-white">
                      Sistema en línea
                    </p>
                    <p className="text-sm text-gray-500 dark:text-gray-400">
                      Listo para capturar tiempos de velocistas.
                    </p>
                  </div>
                </div>
              </div>
            )}

            <button
              onClick={() => goTo("/Editprofile")}
              className="bg-white dark:bg-zinc-900 border border-gray-200 dark:border-zinc-800 rounded-2xl px-5 py-3 flex items-center gap-4 hover:bg-gray-100 dark:hover:bg-zinc-800 transition cursor-pointer shadow-sm text-left"
            >
              <img
                src={
                  userData?.photoUrl ||
                  currentUser?.photoURL ||
                  "https://ui-avatars.com/api/?name=RunTimer"
                }
                alt="Perfil"
                className="w-12 h-12 rounded-full object-cover border border-gray-200 dark:border-zinc-700"
              />
              <div>
                <h2 className="font-bold text-gray-900 dark:text-white">
                  {userData?.nombre || currentUser?.displayName || "Usuario"}
                </h2>
                <p className="text-gray-500 dark:text-gray-400 text-sm">
                  {currentUser?.email}
                </p>
              </div>
            </button>
          </div>
        </div>

        {/* STATS */}
        <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 gap-6 mb-10">
          <Card
            icon={<Timer />}
            title="Mejor tiempo"
            value={esp32Data.mejorTiempo}
            isOnline={esp32Data.online}
          />
          <Card
            icon={<Trophy />}
            title="Competencias activas"
            value={competitions.length}
            isOnline={true}
          />
          <Card
            icon={<Users />}
            title="Participantes"
            value={esp32Data.participantes}
            isOnline={esp32Data.online}
          />
          <Card
            icon={<Wifi />}
            title="Sensores activos"
            value={esp32Data.sensoresActivos}
            isOnline={esp32Data.online}
          />
        </div>

        {/* LISTA DE CARRERAS */}
        <section className="bg-white dark:bg-zinc-950 border border-gray-200 dark:border-zinc-900 rounded-[32px] p-6 md:p-8 transition-colors duration-300 shadow-sm">
          <div className="flex items-center justify-between mb-6">
            <div>
              <h2 className="text-xl font-bold text-gray-900 dark:text-white">
                Carreras Registradas
              </h2>
              <p className="text-sm text-gray-500 dark:text-gray-400">
                Selecciona una competencia para ver detalles y clasificaciones.
              </p>
            </div>
            <span className="bg-red-500/10 text-red-500 px-3 py-1.5 rounded-xl font-bold text-xs tracking-wider uppercase">
              {competitions.length} Total
            </span>
          </div>

          {competitions.length === 0 ? (
            <div className="flex flex-col items-center justify-center py-12 text-center border-2 border-dashed border-gray-200 dark:border-zinc-900 rounded-2xl">
              <Trophy size={40} className="text-gray-300 dark:text-zinc-700 mb-3" />
              <p className="text-gray-500 dark:text-gray-400 font-medium">No hay carreras registradas todavía</p>
            </div>
          ) : (
            <div className="grid grid-cols-1 gap-3">
              {competitions.map((competition) => (
                <motion.div
                  key={competition.id}
                  whileHover={{ x: 4 }}
                  onClick={() => handleSelectCompetition(competition.id)}
                  className="w-full flex items-center justify-between p-4 rounded-2xl bg-gray-50 dark:bg-zinc-900/50 hover:bg-gray-100 dark:hover:bg-zinc-900 border border-gray-100 dark:border-zinc-900 cursor-pointer transition-all duration-200 group"
                >
                  <div className="flex items-center gap-4">
                    <div className="w-12 h-12 rounded-xl bg-red-500/10 flex items-center justify-center text-red-500 group-hover:bg-red-500 group-hover:text-white transition-all duration-300">
                      <Activity size={20} />
                    </div>
                    <div>
                      <h3 className="font-bold text-gray-900 dark:text-white text-base">
                        {competition.name || competition.nombre || "Carrera sin nombre"}
                      </h3>
                      <div className="flex items-center gap-3 mt-0.5 text-xs text-gray-500 dark:text-gray-400">
                        <span className="flex items-center gap-1">
                          <Calendar size={12} />
                          {formatCompetitionDate(competition.date || competition.fecha)}
                        </span>
                        {competition.type && (
                          <span className="bg-gray-200/60 dark:bg-zinc-800 px-2 py-0.5 rounded-md">
                            {competition.type}
                          </span>
                        )}
                      </div>
                    </div>
                  </div>
                  
                  <div className="flex items-center gap-3">
                    <span className="text-xs font-semibold text-gray-400 dark:text-zinc-500 group-hover:text-red-500 dark:group-hover:text-red-400 transition-colors hidden sm:inline">
                      Ver carrera
                    </span>
                    <ChevronRight size={18} className="text-gray-400 dark:text-zinc-600 group-hover:text-red-500 transition-colors" />
                  </div>
                </motion.div>
              ))}
            </div>
          )}
        </section>
      </main>
    </motion.div>
  );
}

function Card({ icon, title, value, isOnline }) {
  return (
    <div className="bg-white dark:bg-zinc-900 border border-gray-200 dark:border-zinc-800 rounded-3xl p-6 shadow-sm transition-colors duration-300">
      <div className="flex justify-between mb-5">
        <div className="w-14 h-14 rounded-2xl bg-red-500/10 flex items-center justify-center text-red-500">
          {icon}
        </div>
        <div className={`flex items-center gap-1 px-2 py-1 rounded-lg text-[10px] font-bold uppercase tracking-wider ${isOnline ? 'text-green-500 bg-green-500/10' : 'text-zinc-400 bg-zinc-500/10'}`}>
          <span className={`w-1.5 h-1.5 rounded-full ${isOnline ? 'bg-green-500 animate-pulse' : 'bg-zinc-400'}`} />
          {isOnline ? 'Live' : 'Offline'}
        </div>
      </div>
      <h2 className="text-gray-500 dark:text-gray-400 mb-2 font-medium">
        {title}
      </h2>
      <p className="text-4xl font-bold text-gray-900 dark:text-white tracking-tight">
        {value}
      </p>
    </div>
  );
}

export default Dashboard;