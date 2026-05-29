import { useEffect, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { db } from "../firebase/firebase";
import { 
  doc, 
  onSnapshot, 
  collection, 
  query, 
  where, 
  getDoc
} from "firebase/firestore";
import { motion } from "framer-motion";
import { ArrowLeft, Trophy, Calendar, Clock, User, Cpu } from "lucide-react";

function CompetitionDetail() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [competition, setCompetition] = useState(null);
  const [participants, setParticipants] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!id) return;

    // 1. OBTENER DATOS DE LA COMPETENCIA / CARRERA
    const competitionRef = doc(db, "competitions", id);
    const unsubscribeComp = onSnapshot(competitionRef, (docSnap) => {
      if (docSnap.exists()) {
        const data = docSnap.data();
        const dateField = data.date || data.fecha;
        let formattedDate = "Sin fecha";
        
        if (dateField?.seconds) {
          formattedDate = new Date(dateField.seconds * 1000).toLocaleDateString();
        } else if (dateField instanceof Date) {
          formattedDate = dateField.toLocaleDateString();
        } else if (typeof dateField === "string") {
          formattedDate = dateField.split("T")[0];
        }

        setCompetition({ 
          id: docSnap.id, 
          ...data,
          formattedDate 
        });
      } else {
        console.error("No se encontró la competencia en Firebase");
      }
    });

    // 2. ESCUCHA TELEMETRÍA EN VIVO (Mapeo por Robot para listar todos de forma independiente)
    console.log(`[RunTimer] Sincronizando todos los robots para la competencia: ${id}`);
    const timesRef = collection(db, "race_times");
    const q = query(timesRef, where("compId", "==", id));

    const unsubscribeTimes = onSnapshot(q, async (snapshot) => {
      try {
        const bestTimesByRobot = {};

        // Agrupamos y filtramos los mejores tiempos por cada ID de Robot único
        snapshot.forEach((timeDoc) => {
          const tData = timeDoc.data();
          
          const pilotUid = tData.userId || tData.uid || tData.captainUid || tData.registeredByUid;
          const rId = tData.robotId || "Desconocido";
          const rawTimeMs = parseFloat(tData.finalTimeMs || tData.timeMs || 0);
          const runTimeSeconds = rawTimeMs / 1000;

          if (rId && rawTimeMs > 0 && tData.status !== "dnf" && tData.status !== "dq") {
            if (!bestTimesByRobot[rId] || runTimeSeconds < bestTimesByRobot[rId].minTime) {
              bestTimesByRobot[rId] = { 
                minTime: runTimeSeconds, 
                timeUid: pilotUid 
              };
            }
          }
        });

        // Resolvemos en paralelo las referencias de Usuarios y Robots desde Firestore
        const leaderboardPromises = Object.keys(bestTimesByRobot).map(async (robotId) => {
          const telemetry = bestTimesByRobot[robotId];
          let pilotName = "Piloto RunTimer";
          let robotName = "Robot Velocista";
          let finalPilotUid = telemetry.timeUid;

          try {
            // 🤖 1. Consultamos el documento del Robot para asegurar su nombre y dueño
            if (robotId && robotId !== "Desconocido") {
              const robotDocSnap = await getDoc(doc(db, "robots", robotId));
              if (robotDocSnap.exists()) {
                const rData = robotDocSnap.data();
                robotName = rData.nombre || rData.name || rData.robotName || "Velocista";
                
                if (rData.userId || rData.uid || rData.captainUid || rData.registeredByUid) {
                  finalPilotUid = rData.userId || rData.uid || rData.captainUid || rData.registeredByUid;
                }
              } else {
                if (robotId === "fHKh7lujT9u3UMmQjsma") robotName = "Ñengo 🏎️";
                else if (robotId === "IPvq84K3V1oZ7gqdnWbA") robotName = "Jaiderbot 🤖";
                else robotName = `Robot (${robotId.substring(0, 5)})`;
              }
            }

            // 👤 2. Consultamos el nombre del Capitán real en la colección 'users'
            if (finalPilotUid) {
              const userDocSnap = await getDoc(doc(db, "users", finalPilotUid));
              if (userDocSnap.exists()) {
                const uData = userDocSnap.data();
                
                pilotName = uData.nombre || 
                            uData.name || 
                            uData.displayName || 
                            uData.username || 
                            uData.usuario ||
                            uData.email?.split('@')[0] || 
                            "Piloto";
              } else {
                if (finalPilotUid === "l0JywtlIIVSxFBWEEPoCi5NqxjA2") {
                  pilotName = "Juez de Pista";
                }
              }
            }
          } catch (fetchError) {
            console.error(`Error al cruzar datos de Firestore para el robot ${robotId}:`, fetchError);
          }

          return {
            id: robotId, // Clave única real
            name: pilotName,
            robotName: robotName,
            time: `${telemetry.minTime.toFixed(3)}s`,
            numericTime: telemetry.minTime
          };
        });

        const leaderboard = await Promise.all(leaderboardPromises);

        // Ordenamos la clasificación de menor a mayor tiempo
        leaderboard.sort((a, b) => a.numericTime - b.numericTime);
        setParticipants(leaderboard);
        
      } catch (err) {
        console.error("Error general procesando cruce de telemetría:", err);
      } finally {
        setLoading(false);
      }
    }, (error) => {
      console.error("Error en el canal en vivo de Firebase (race_times):", error);
      setLoading(false);
    });

    return () => {
      unsubscribeComp();
      unsubscribeTimes();
    };
  }, [id]);

  if (loading) {
    return (
      <div className="min-h-screen bg-black flex items-center justify-center text-white">
        <div className="w-12 h-12 border-4 border-red-500 border-t-transparent rounded-full animate-spin" />
      </div>
    );
  }

  if (!competition) {
    return (
      <div className="min-h-screen bg-black text-white flex flex-col items-center justify-center gap-4">
        <p className="text-zinc-400">La competencia no existe o fue eliminada en Firebase.</p>
        <button onClick={() => navigate("/competitions")} className="bg-red-500 px-4 py-2 rounded-xl">Volver</button>
      </div>
    );
  }

  return (
    <motion.div 
      initial={{ opacity: 0 }} 
      animate={{ opacity: 1 }} 
      className="min-h-screen bg-gray-50 dark:bg-black text-gray-900 dark:text-white p-6 md:p-10"
    >
      <div className="max-w-5xl mx-auto">
        <button
          onClick={() => navigate("/competitions")}
          className="flex items-center gap-2 text-zinc-500 hover:text-red-500 dark:text-zinc-400 dark:hover:text-red-400 transition font-medium mb-6 group text-sm"
        >
          <ArrowLeft size={16} className="group-hover:-translate-x-1 transition-transform" />
          Volver a Competencias
        </button>

        {/* TARJETA DE INFORMACIÓN DE LA CARRERA */}
        <div className="bg-white dark:bg-zinc-950 border border-gray-200 dark:border-zinc-900 rounded-[32px] p-6 md:p-8 mb-8 shadow-sm">
          <div className="flex items-center gap-4 mb-4">
            <div className="w-14 h-14 rounded-2xl bg-red-500/10 flex items-center justify-center text-red-500">
              <Trophy size={28} />
            </div>
            <div>
              <h1 className="text-3xl font-bold tracking-tight">{competition.name || competition.nombre || "Circuito Activo"}</h1>
              <p className="text-zinc-400 text-sm flex items-center gap-1.5 mt-1">
                <Calendar size={14} /> 
                {competition.formattedDate}
              </p>
            </div>
          </div>
        </div>

        {/* TABLA DE CLASIFICACIONES EN TIEMPO REAL */}
        <div className="bg-white dark:bg-zinc-950 border border-gray-200 dark:border-zinc-900 rounded-[32px] p-6 md:p-8 shadow-sm">
          <h2 className="text-xl font-bold mb-6 flex items-center gap-2">
            <Clock size={20} className="text-red-500" /> Clasificación en Tiempo Real
          </h2>

          {participants.length === 0 ? (
            <p className="text-zinc-500 text-center py-10 border border-dashed border-zinc-200 dark:border-zinc-800 rounded-2xl">
              Sin tiempos registrados para esta competencia todavía. ¡Dispara los sensores!
            </p>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full text-left border-collapse">
                <thead>
                  <tr className="border-b border-gray-100 dark:border-zinc-900 text-zinc-400 text-xs uppercase font-bold tracking-wider">
                    <th className="py-3 px-4">Pos</th>
                    <th className="py-3 px-4">Carro Velocista</th>
                    <th className="py-3 px-4">Capitán</th>
                    <th className="py-3 px-4 text-right">Mejor Tiempo</th>
                  </tr>
                </thead>
                <tbody>
                  {participants.map((player, index) => (
                    <tr key={player.id} className="border-b border-gray-50 dark:border-zinc-900/50 hover:bg-gray-50/50 dark:hover:bg-zinc-900/30 transition-colors">
                      <td className="py-4 px-4 font-bold text-red-500">#{index + 1}</td>
                      <td className="py-4 px-4 font-semibold flex items-center gap-2">
                        <Cpu size={14} className="text-zinc-500" /> {player.robotName}
                      </td>
                      <td className="py-4 px-4 text-zinc-400 font-medium">
                        <User size={14} className="inline mr-1.5 text-zinc-600" />
                        {player.name}
                      </td>
                      <td className="py-4 px-4 text-right font-mono font-bold text-emerald-500 bg-emerald-500/5 dark:bg-emerald-500/10 rounded-lg">
                        {player.time}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>
      </div>
    </motion.div>
  );
}

export default CompetitionDetail;