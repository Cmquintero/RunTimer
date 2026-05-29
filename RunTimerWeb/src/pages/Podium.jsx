import { useEffect, useState, useMemo } from "react";
import { useNavigate } from "react-router-dom";
import { motion } from "framer-motion";
import { ChevronLeft, Award, Timer, Flame, Trophy, Cpu } from "lucide-react";
import { collection, onSnapshot, query, where, orderBy, doc, getDoc } from "firebase/firestore";
import { db } from "../firebase/firebase";

function Podium() {
  const navigate = useNavigate();
  const [competitions, setCompetitions] = useState([]);
  const [selectedCompId, setSelectedCompId] = useState("");
  const [raceTimes, setRaceTimes] = useState([]);
  const [robotsInfo, setRobotsInfo] = useState({});
  const [loading, setLoading] = useState(true);

  // 1. Cargar Competencias Activas
  useEffect(() => {
    const q = query(collection(db, "competitions"), where("status", "==", "active"));
    return onSnapshot(q, (snapshot) => {
      const comps = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
      setCompetitions(comps);
      if (comps.length > 0 && !selectedCompId) setSelectedCompId(comps[0].id);
      setLoading(false);
    });
  }, []);

  // 2. Stream de Tiempos Realtime (Filtro por compId)
  useEffect(() => {
    if (!selectedCompId) return;
    
    // 🔥 CAMBIO CRÍTICO: Usamos 'compId' según tu estructura real en Firestore
    const q = query(
      collection(db, "race_times"),
      where("compId", "==", selectedCompId),
      orderBy("finalTimeMs", "asc")
    );

    return onSnapshot(q, (snapshot) => {
      const times = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
      setRaceTimes(times);
    });
  }, [selectedCompId]);

  // 3. Deduplicación: Obtener el mejor tiempo por robot
  const podiumData = useMemo(() => {
    const seen = new Set();
    return raceTimes.filter(time => {
      if (seen.has(time.robotId)) return false;
      seen.add(time.robotId);
      return true;
    });
  }, [raceTimes]);

  // 4. Cargar Info de Robots (Nombre y Categoría)
  useEffect(() => {
    const fetchRobotData = async () => {
      const newRobots = { ...robotsInfo };
      let changed = false;

      for (const time of podiumData) {
        if (!newRobots[time.robotId]) {
          const snap = await getDoc(doc(db, "robots", time.robotId));
          if (snap.exists()) {
            newRobots[time.robotId] = snap.data();
            changed = true;
          }
        }
      }
      if (changed) setRobotsInfo(newRobots);
    };

    if (podiumData.length > 0) fetchRobotData();
  }, [podiumData]);

  const getStyle = (pos) => {
    const styles = {
      1: { color: "text-yellow-400", border: "border-yellow-400", bg: "bg-yellow-500/10" },
      2: { color: "text-zinc-300", border: "border-zinc-300", bg: "bg-zinc-500/10" },
      3: { color: "text-orange-500", border: "border-orange-500", bg: "bg-orange-500/10" }
    };
    return styles[pos] || { color: "text-zinc-500", border: "border-zinc-800", bg: "bg-zinc-900" };
  };

  return (
    <div className="min-h-screen bg-black text-white p-6 font-sans">
      {/* Header */}
      <header className="flex justify-between items-center mb-8 max-w-4xl mx-auto">
        <button onClick={() => navigate(-1)} className="p-3 bg-zinc-900 rounded-2xl border border-zinc-800"><ChevronLeft /></button>
        <h1 className="text-2xl font-bold flex items-center gap-2"><Award className="text-yellow-500"/> Podio en Vivo</h1>
        <select value={selectedCompId} onChange={(e) => setSelectedCompId(e.target.value)} className="bg-zinc-900 p-3 rounded-xl border border-zinc-800">
          {competitions.map(c => <option key={c.id} value={c.id}>{c.name}</option>)}
        </select>
      </header>

      {/* Podium Visual */}
      {podiumData.length > 0 ? (
        <div className="flex justify-center items-end gap-4 h-64 mb-12 max-w-2xl mx-auto">
          {podiumData[1] && <PodiumBar time={podiumData[1]} pos={2} height={140} name={robotsInfo[podiumData[1].robotId]?.name} />}
          {podiumData[0] && <PodiumBar time={podiumData[0]} pos={1} height={200} name={robotsInfo[podiumData[0].robotId]?.name} />}
          {podiumData[2] && <PodiumBar time={podiumData[2]} pos={3} height={100} name={robotsInfo[podiumData[2].robotId]?.name} />}
        </div>
      ) : (
        <div className="text-center py-20 text-zinc-500"><Timer size={60} className="mx-auto mb-4"/> Sin tiempos registrados</div>
      )}

      {/* Lista completa */}
      <div className="max-w-xl mx-auto space-y-3">
        {podiumData.map((time, i) => (
          <div key={time.id} className="bg-zinc-900 p-4 rounded-2xl flex justify-between items-center border border-zinc-800">
            <span className={`font-bold ${getStyle(i + 1).color}`}>{i + 1}° {robotsInfo[time.robotId]?.name || "..."}</span>
            <span className="font-mono text-xl">{(time.finalTimeMs/1000).toFixed(2)}s</span>
          </div>
        ))}
      </div>
    </div>
  );
}

// Sub-componente del podio
function PodiumBar({ time, pos, height, name }) {
  const style = pos === 1 ? "bg-yellow-500/20 border-yellow-500 text-yellow-500" : 
                pos === 2 ? "bg-zinc-500/20 border-zinc-500 text-zinc-300" : "bg-orange-500/20 border-orange-500 text-orange-500";
  
  return (
    <motion.div initial={{height:0}} animate={{height}} className={`w-24 ${style} border-t-2 border-x-2 rounded-t-xl flex flex-col items-center pt-2`}>
      <span className="font-bold text-lg">{pos}°</span>
      <span className="text-[10px] text-center px-1 truncate w-full">{name || "..."}</span>
    </motion.div>
  );
}

export default Podium;