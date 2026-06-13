import { useEffect, useState, useMemo } from "react";
import { useNavigate } from "react-router-dom";
import { motion } from "framer-motion";
import { ChevronLeft, Award, Timer } from "lucide-react";
import { collection, onSnapshot, query, where, doc, getDoc } from "firebase/firestore";
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
      
      if (comps.length > 0 && !selectedCompId) {
        setSelectedCompId(comps[0].id);
      }
      setLoading(false);
    });
  }, []);

  // 2. Stream de Tiempos Realtime
  useEffect(() => {
    if (!selectedCompId) {
      console.log("⏳ Esperando selección de competencia...");
      return;
    }
    
    console.log("🔍 Buscando tiempos para compId:", selectedCompId);

    const q = query(
      collection(db, "race_times"),
      where("compId", "==", selectedCompId)
    );

    return onSnapshot(q, (snapshot) => {
      console.log("📊 Documentos de tiempos recibidos:", snapshot.size);
      const times = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
      setRaceTimes(times);
    }, (error) => {
      console.error("❌ Error en el stream de tiempos:", error);
    });
  }, [selectedCompId]);

  // 3. 🔥 LÓGICA CORREGIDA: Filtrar penalizaciones/DNFs, agrupar por Robot y buscar el mejor tiempo
  const podiumData = useMemo(() => {
    const bestTimesByRobot = {};

    raceTimes.forEach((tData) => {
      const rId = tData.robotId;
      const rawTimeMs = parseFloat(tData.finalTimeMs || tData.timeMs || 0);
      const status = tData.status;

      // Ignora robots desconocidos, tiempos en 0 y estados DNF / DQ
      if (rId && rId !== "Desconocido" && rawTimeMs > 0 && status !== "dnf" && status !== "dq") {
        // Si el robot no está registrado aún, o este tiempo es más rápido (menor) que el guardado
        if (!bestTimesByRobot[rId] || rawTimeMs < bestTimesByRobot[rId].finalTimeMs) {
          bestTimesByRobot[rId] = {
            ...tData,
            finalTimeMs: rawTimeMs // Nos aseguramos de guardar el valor numérico limpio
          };
        }
      }
    });

    // Convertimos el mapa a un array y lo ordenamos de MENOR a MAYOR tiempo (El más rápido va primero)
    return Object.values(bestTimesByRobot).sort((a, b) => a.finalTimeMs - b.finalTimeMs);
  }, [raceTimes]);

  // 4. Cargar Info de Robots (Soporta campos 'nombre', 'name' o 'robotName')
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

  // Helper conveniente para extraer el nombre del robot de forma segura
  const getRobotName = (robotId) => {
    const rData = robotsInfo[robotId];
    if (!rData) return "...";
    return rData.nombre || rData.name || rData.robotName || "Velocista";
  };

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
          {competitions.map(c => <option key={c.id} value={c.id}>{c.name || c.nombre}</option>)}
        </select>
      </header>

      {/* RENDER GRÁFICO DEL PODIO */}
      {podiumData.length > 0 ? (
        <div className="flex justify-center items-end gap-4 h-64 mb-12">
          {/* 2° Lugar */}
          {podiumData[1] && (
            <Bar 
              pos={2} 
              h={140} 
              name={getRobotName(podiumData[1].robotId)} 
              time={`${(podiumData[1].finalTimeMs / 1000).toFixed(3)}s`} 
            />
          )}
          {/* 1° Lugar */}
          {podiumData[0] && (
            <Bar 
              pos={1} 
              h={200} 
              name={getRobotName(podiumData[0].robotId)} 
              time={`${(podiumData[0].finalTimeMs / 1000).toFixed(3)}s`} 
            />
          )}
          {/* 3° Lugar */}
          {podiumData[2] && (
            <Bar 
              pos={3} 
              h={100} 
              name={getRobotName(podiumData[2].robotId)} 
              time={`${(podiumData[2].finalTimeMs / 1000).toFixed(3)}s`} 
            />
          )}
        </div>
      ) : (
        <div className="text-center py-20 text-zinc-500">
            <Timer size={60} className="mx-auto mb-4"/> 
            <p>Aún no hay tiempos válidos registrados en esta competencia.</p>
            <p className="text-xs mt-2 italic">Verifica en Firestore que los documentos en race_times tengan tiempos mayores a 0 y status 'completed'.</p>
        </div>
      )}

      {/* LISTA INFERIOR DEL CLASIFICATORIO */}
      <div className="max-w-xl mx-auto space-y-3">
        {podiumData.map((time, i) => (
          <div key={time.id} className="bg-zinc-900 p-4 rounded-2xl flex justify-between items-center border border-zinc-800">
            <span className="font-bold">{i + 1}° {getRobotName(time.robotId)}</span>
            <span className="font-mono text-xl text-emerald-400">{(time.finalTimeMs / 1000).toFixed(3)}s</span>
          </div>
        ))}
      </div>
    </div>
  );
}

// COMPONENTE DE LA BARRA DEL PODIO MODIFICADO (Muestra tiempo abajo de la posición)
function Bar({ pos, h, name, time }) {
  const color = pos === 1 ? "bg-yellow-500" : pos === 2 ? "bg-zinc-400" : "bg-orange-600";
  const textColor = pos === 1 ? "text-black" : "text-white";
  
  return (
    <div className={`w-28 ${color} ${textColor} rounded-t-2xl flex flex-col items-center justify-between py-3 px-1`} style={{ height: h }}>
      <div className="text-center flex flex-col items-center">
        <span className="font-extrabold text-2xl leading-none">{pos}°</span>
        <span className="text-[11px] font-mono font-bold mt-0.5">{time}</span>
      </div>
      <span className="text-xs font-bold truncate w-full text-center px-2">{name}</span>
    </div>
  );
}

export default Podium;