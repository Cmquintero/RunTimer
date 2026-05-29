import { useEffect, useState, useMemo } from "react";
import { useNavigate } from "react-router-dom";
import { motion } from "framer-motion";
import { ChevronLeft, Award, Timer } from "lucide-react";
import { collection, onSnapshot, query, where, orderBy, doc, getDoc } from "firebase/firestore";
import { db } from "../firebase/firebase";

function Podium() {
  const navigate = useNavigate();
  const [competitions, setCompetitions] = useState([]);
  const [selectedCompId, setSelectedCompId] = useState("");
  const [raceTimes, setRaceTimes] = useState([]);
  const [robotsInfo, setRobotsInfo] = useState({});
  const [loading, setLoading] = useState(true);

  // 1. Cargar Competencias ACTIVAS
  useEffect(() => {
    const q = query(collection(db, "competitions"), where("status", "==", "active"));
    
    return onSnapshot(q, (snapshot) => {
      const comps = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
      console.log("🏆 Competencias activas encontradas:", comps.length);
      setCompetitions(comps);
      
      // Si hay comps pero no hemos seleccionado ninguna, tomamos la primera
      if (comps.length > 0 && !selectedCompId) {
        setSelectedCompId(comps[0].id);
      }
      setLoading(false);
    });
  }, []);

  // 2. Stream de Tiempos Realtime (DEBUGGING INCLUIDO)
  useEffect(() => {
    if (!selectedCompId) {
      console.log("⏳ Esperando selección de competencia...");
      return;
    }
    
    console.log("🔍 Buscando tiempos para compId:", selectedCompId);

    const q = query(
      collection(db, "race_times"),
      where("compId", "==", selectedCompId),
      orderBy("finalTimeMs", "asc")
    );

    return onSnapshot(q, (snapshot) => {
      console.log("📊 Documentos de tiempos recibidos:", snapshot.size);
      
      const times = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
      setRaceTimes(times);
    }, (error) => {
      console.error("❌ Error en el stream de tiempos:", error);
    });
  }, [selectedCompId]);

  // 3. Deduplicación
  const podiumData = useMemo(() => {
    const seen = new Set();
    return raceTimes.filter(time => {
      if (seen.has(time.robotId)) return false;
      seen.add(time.robotId);
      return true;
    });
  }, [raceTimes]);

  // 4. Cargar Info de Robots
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

  // --- Render ---
  return (
    <div className="min-h-screen bg-black text-white p-6">
      <header className="flex justify-between items-center mb-8 max-w-4xl mx-auto">
        <button onClick={() => navigate(-1)} className="p-3 bg-zinc-900 rounded-2xl border border-zinc-800"><ChevronLeft /></button>
        <h1 className="text-2xl font-bold flex items-center gap-2"><Award className="text-yellow-500"/> Podio en Vivo</h1>
        <select 
          value={selectedCompId} 
          onChange={(e) => setSelectedCompId(e.target.value)} 
          className="bg-zinc-900 p-3 rounded-xl border border-zinc-800"
        >
          {competitions.length === 0 ? <option>No hay activas</option> : null}
          {competitions.map(c => <option key={c.id} value={c.id}>{c.name}</option>)}
        </select>
      </header>

      {podiumData.length > 0 ? (
        <div className="flex justify-center items-end gap-4 h-64 mb-12">
          {podiumData[1] && <Bar time={podiumData[1]} pos={2} h={140} name={robotsInfo[podiumData[1].robotId]?.name} />}
          {podiumData[0] && <Bar time={podiumData[0]} pos={1} h={200} name={robotsInfo[podiumData[0].robotId]?.name} />}
          {podiumData[2] && <Bar time={podiumData[2]} pos={3} h={100} name={robotsInfo[podiumData[2].robotId]?.name} />}
        </div>
      ) : (
        <div className="text-center py-20 text-zinc-500">
            <Timer size={60} className="mx-auto mb-4"/> 
            <p>Aún no hay tiempos registrados en esta competencia.</p>
            <p className="text-xs mt-2 italic">Verifica en Firestore que la competencia tenga status "active" y el compId sea correcto.</p>
        </div>
      )}

      <div className="max-w-xl mx-auto space-y-3">
        {podiumData.map((time, i) => (
          <div key={time.id} className="bg-zinc-900 p-4 rounded-2xl flex justify-between items-center border border-zinc-800">
            <span className="font-bold">{i + 1}° {robotsInfo[time.robotId]?.name || "..."}</span>
            <span className="font-mono text-xl">{(time.finalTimeMs/1000).toFixed(2)}s</span>
          </div>
        ))}
      </div>
    </div>
  );
}

function Bar({ pos, h, name }) {
  const color = pos === 1 ? "bg-yellow-500" : pos === 2 ? "bg-zinc-400" : "bg-orange-600";
  return (
    <div className={`w-24 ${color} rounded-t-xl flex flex-col items-center pt-2`} style={{ height: h }}>
      <span className="font-bold text-lg">{pos}°</span>
      <span className="text-[10px] truncate w-20 text-center">{name}</span>
    </div>
  );
}

export default Podium;