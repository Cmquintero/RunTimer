import { useEffect, useState } from "react";
import { db, auth } from "../services/authService";
import { 
  collection, 
  onSnapshot, 
  getDocs, 
  query, 
  where 
} from "firebase/firestore";
import { useNavigate } from "react-router-dom";
import { motion, AnimatePresence } from "framer-motion";
import {
  Trophy,
  CalendarDays,
  MapPin,
  Users,
  ArrowLeft,
  X,
  Timer,
  ChevronRight
} from "lucide-react";

function Competitions() {
  const navigate = useNavigate();
  const [competitions, setCompetitions] = useState([]);
  const [loading, setLoading] = useState(true);
  const [selectedComp, setSelectedComp] = useState(null); 
  const [competitorsList, setCompetitorsList] = useState([]); 
  const [loadingCompetitors, setLoadingCompetitors] = useState(false);
  const currentUser = auth.currentUser;

  useEffect(() => {
    if (!currentUser) {
      navigate("/login");
      return;
    }

    const unsubscribe = onSnapshot(collection(db, "competitions"), (snapshot) => {
      const compsArray = [];
      snapshot.forEach((doc) => {
        const data = doc.data();
        
        const dateField = data.date || data.fecha;
        let formattedDate = "Sin fecha";
        if (dateField?.seconds) {
          formattedDate = new Date(dateField.seconds * 1000).toLocaleDateString();
        } else if (dateField instanceof Date) {
          formattedDate = dateField.toLocaleDateString();
        } else if (typeof dateField === "string") {
          formattedDate = dateField.split("T")[0];
        }

        compsArray.push({
          id: doc.id,
          ...data,
          name: data.name || data.nombre || "Carrera sin nombre",
          location: data.location || data.lugar || "Ubicación no definida",
          date: formattedDate,
          category: data.category || data.categoria || "Velocistas",
          participants: data.participants || 0
        });
      });
      
      setCompetitions(compsArray);
      setLoading(false);
    }, (error) => {
      console.error("Error cargando competiciones:", error);
      setLoading(false);
    });

    return () => unsubscribe();
  }, [navigate, currentUser]);

  useEffect(() => {
    if (!selectedComp) return;

    const fetchLeaderboardFromTelemetry = async () => {
      setLoadingCompetitors(true);
      try {
        // 🔥 CORREGIDO AQUÍ: Cambiado "times" por "race_times" para acoplarse a tus reglas
        const timesQuery = query(
          collection(db, "race_times"),
          where("competitionId", "==", selectedComp.id)
        );
        const timesSnapshot = await getDocs(timesQuery);

        const bestTimesMap = {};

        timesSnapshot.forEach((timeDoc) => {
          const tData = timeDoc.data();
          const uid = tData.uid || tData.userId || tData.captainUid;
          const runTime = parseFloat(tData.time || tData.tiempo);
          const rName = tData.robotName || tData.robotId || "Robot Competidor";

          if (uid && !isNaN(runTime)) {
            if (!bestTimesMap[uid] || runTime < bestTimesMap[uid].minTime) {
              bestTimesMap[uid] = {
                minTime: runTime,
                robotName: rName
              };
            }
          }
        });

        const usersSnapshot = await getDocs(collection(db, "users"));
        const leaderBoardData = [];

        usersSnapshot.forEach((userDoc) => {
          const uData = userDoc.data();
          const uid = uData.uid || userDoc.id;
          const captainName = uData.nombre || uData.name || "Piloto RunTimer";
          const telemetry = bestTimesMap[uid];

          if (telemetry) {
            leaderBoardData.push({
              uid,
              nombreCapitan: captainName,
              nombreRobot: telemetry.robotName,
              tiempo: `${telemetry.minTime.toFixed(3)}s`,
              numericTime: telemetry.minTime
            });
          }
        });

        // Fallback por categoría
        if (leaderBoardData.length === 0) {
          // 🔥 CORREGIDO AQUÍ TAMBIÉN: Cambiado "times" por "race_times"
          const fallbackQuery = query(collection(db, "race_times"), where("category", "==", selectedComp.category));
          const fallbackSnapshot = await getDocs(fallbackQuery);
          
          fallbackSnapshot.forEach((fDoc) => {
            const fData = fDoc.data();
            const uid = fData.uid || fData.userId;
            const runTime = parseFloat(fData.time || fData.tiempo);
            if (uid && !isNaN(runTime) && (!bestTimesMap[uid] || runTime < bestTimesMap[uid].minTime)) {
              bestTimesMap[uid] = { minTime: runTime, robotName: fData.robotName || "Robot" };
            }
          });

          usersSnapshot.forEach((userDoc) => {
            const uData = userDoc.data();
            const uid = uData.uid || userDoc.id;
            if (bestTimesMap[uid]) {
              leaderBoardData.push({
                uid,
                nombreCapitan: uData.nombre || uData.name || "Piloto",
                nombreRobot: bestTimesMap[uid].robotName,
                tiempo: `${bestTimesMap[uid].minTime.toFixed(3)}s`,
                numericTime: bestTimesMap[uid].minTime
              });
            }
          });
        }

        leaderBoardData.sort((a, b) => a.numericTime - b.numericTime);
        setCompetitorsList(leaderBoardData);

      } catch (error) {
        console.error("Error procesando grilla RunTimer:", error);
      } finally {
        setLoadingCompetitors(false);
      }
    };

    fetchLeaderboardFromTelemetry();
  }, [selectedComp]);

  if (loading) {
    return (
      <div className="min-h-screen bg-zinc-950 text-white flex items-center justify-center">
        <p className="text-xl text-zinc-500 animate-pulse">Sincronizando con RunTimer Engine...</p>
      </div>
    );
  }

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      className="min-h-screen bg-black text-white p-6 md:p-10 relative"
    >
      <div className="flex justify-start mb-6">
        <button
          onClick={() => navigate("/dashboard")}
          className="flex items-center gap-2 px-4 py-2.5 rounded-xl bg-zinc-900 border border-zinc-800 text-sm font-semibold hover:bg-zinc-800 text-white transition shadow-sm"
        >
          <ArrowLeft size={16} /> Volver al panel
        </button>
      </div>

      <div className="mb-10">
        <h1 className="text-4xl font-bold mb-3 tracking-tight">Grilla de Competiciones</h1>
        <p className="text-zinc-400 text-lg">Monitoreo y registros de tiempos de pista integrados con la plataforma.</p>
      </div>

      {competitions.length === 0 ? (
        <div className="bg-zinc-900 border border-zinc-800 rounded-3xl p-10 text-center shadow-sm">
          <Trophy size={40} className="text-zinc-600 mx-auto mb-6" />
          <h2 className="text-2xl font-bold mb-3 text-white">No hay eventos en curso</h2>
          <p className="text-zinc-500">Crea o activa una competencia desde la app móvil para verla reflejada aquí.</p>
        </div>
      ) : (
        <div className="bg-zinc-900 border border-zinc-800 rounded-3xl p-6 shadow-sm">
          <div className="mb-6">
            <h2 className="text-2xl font-bold text-white">Eventos Activos</h2>
            <p className="text-zinc-400 text-sm mt-1">Haz clic sobre cualquier fila para desplegar la grilla clasificatoria de robots y marcas de tiempo.</p>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full min-w-[800px]">
              <thead>
                <tr className="border-b border-zinc-800 text-left text-zinc-400 text-sm">
                  <th className="pb-4 font-semibold">Nombre del Evento</th>
                  <th className="pb-4 font-semibold">Fecha</th>
                  <th className="pb-4 font-semibold">Ubicación</th>
                  <th className="pb-4 font-semibold">Categoría Admitida</th>
                  <th className="pb-4 font-semibold">Estado</th>
                </tr>
              </thead>
              <tbody>
                {competitions.map((comp) => (
                  <tr
                    key={comp.id}
                    onClick={() => setSelectedComp(comp)}
                    className="border-b border-zinc-800/50 hover:bg-zinc-800/30 text-white transition cursor-pointer group"
                  >
                    <td className="py-5">
                      <div className="flex items-center gap-4">
                        <div className="w-12 h-12 rounded-xl bg-red-500/10 text-red-500 flex items-center justify-center shadow-sm group-hover:bg-red-500 group-hover:text-white transition-all duration-300">
                          <Trophy size={20} />
                        </div>
                        <div>
                          <h2 className="font-bold text-base flex items-center gap-2">
                            {comp.name}
                            <ChevronRight size={14} className="text-zinc-500 opacity-0 group-hover:opacity-100 transition-opacity" />
                          </h2>
                          <p className="text-zinc-500 text-xs">ID: {comp.id.substring(0, 8)}...</p>
                        </div>
                      </div>
                    </td>
                    <td className="py-5 text-sm text-zinc-300">{comp.date}</td>
                    <td className="py-5 text-sm text-zinc-300">{comp.location}</td>
                    <td className="py-5">
                      <span className="bg-zinc-800 text-zinc-200 px-3 py-1 rounded-lg text-xs font-semibold tracking-wider border border-zinc-700/50">
                        {comp.category}
                      </span>
                    </td>
                    <td className="py-5">
                      <span className="text-xs text-green-400 bg-green-500/10 px-2.5 py-1 rounded-md font-medium border border-green-500/20">
                        Sincronizado
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      <AnimatePresence>
        {selectedComp && (
          <div className="fixed inset-0 bg-black/70 backdrop-blur-md z-50 flex items-center justify-center p-4">
            <motion.div
              initial={{ scale: 0.97, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              exit={{ scale: 0.97, opacity: 0 }}
              className="bg-zinc-950 border border-zinc-800 rounded-[24px] w-full max-w-2xl overflow-hidden shadow-2xl"
            >
              <div className="p-6 border-b border-zinc-900 flex items-center justify-between bg-zinc-900/40">
                <div>
                  <span className="text-xs font-bold text-red-500 uppercase tracking-widest">Leaderboard Oficial</span>
                  <h2 className="text-2xl font-bold text-white mt-1">{selectedComp.name}</h2>
                </div>
                <button
                  onClick={() => setSelectedComp(null)}
                  className="w-9 h-9 rounded-full bg-zinc-900 border border-zinc-800 flex items-center justify-center text-zinc-400 hover:text-white transition"
                >
                  <X size={18} />
                </button>
              </div>

              <div className="p-6 max-h-[400px] overflow-y-auto">
                {loadingCompetitors ? (
                  <p className="text-center py-8 text-zinc-500 animate-pulse text-sm font-mono">Escrutando telemetría de pista...</p>
                ) : competitorsList.length === 0 ? (
                  <div className="text-center py-10">
                    <Users size={32} className="text-zinc-700 mx-auto mb-3" />
                    <p className="text-zinc-400 text-sm font-medium">Aún no se registran pasadas por el sensor IR para esta pista.</p>
                    <p className="text-zinc-600 text-xs mt-1">Los tiempos se actualizarán automáticamente al cruzar la meta.</p>
                  </div>
                ) : (
                  <div className="flex flex-col gap-2.5">
                    {competitorsList.map((pilot, index) => (
                      <div
                        key={pilot.uid}
                        className={`flex items-center justify-between p-4 rounded-xl border transition-all ${
                          pilot.uid === currentUser?.uid
                            ? "bg-red-500/5 border-red-500/20"
                            : "bg-zinc-900/50 border-zinc-800/80"
                        }`}
                      >
                        <div className="flex items-center gap-4">
                          <div className={`w-7 h-7 rounded-lg flex items-center justify-center font-mono font-bold text-xs ${
                            index === 0 
                              ? "bg-amber-500 text-black" 
                              : "bg-zinc-800 text-zinc-400"
                          }`}>
                            P{index + 1}
                          </div>
                          <div>
                            <p className="font-bold text-white text-sm flex items-center gap-1.5">
                              {pilot.nombreRobot}
                              {pilot.uid === currentUser?.uid && <span className="text-[10px] bg-red-500/20 text-red-400 px-1.5 py-0.5 rounded">Tú</span>}
                            </p>
                            <p className="text-xs text-zinc-500 font-medium">Capitán: {pilot.nombreCapitan}</p>
                          </div>
                        </div>

                        <div className="flex items-center gap-2">
                          <Timer size={14} className="text-red-500" />
                          <span className="font-mono font-bold text-sm text-green-400 bg-green-500/5 px-2.5 py-1 rounded-md border border-green-500/10">
                            {pilot.tiempo}
                          </span>
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </div>
              <div className="p-3.5 bg-zinc-900/20 border-t border-zinc-900 text-center">
                <p className="text-[11px] text-zinc-600 font-medium tracking-wide">Clasificación gobernada por hardware en tiempo real.</p>
              </div>
            </motion.div>
          </div>
        )}
      </AnimatePresence>
    </motion.div>
  );
}

export default Competitions;