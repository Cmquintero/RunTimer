import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { motion } from "framer-motion";
import {
  Trophy,
  Calendar,
  Activity,
  ChevronRight,
  ArrowLeft,
  Search,
  Plus
} from "lucide-react";
import { db } from "../firebase/firebase";
import { collection, onSnapshot, query } from "firebase/firestore";

function Races() {
  const navigate = useNavigate();
  const [competitions, setCompetitions] = useState([]);
  const [searchTerm, setSearchTerm] = useState("");
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // ESCUCHA EN TIEMPO REAL DESDE FIRESTORE
    const q = query(collection(db, "competitions"));

    const unsubscribeFirestore = onSnapshot(
      q,
      (snapshot) => {
        const data = [];
        snapshot.forEach((doc) => {
          data.push({ id: doc.id, ...doc.data() });
        });
        setCompetitions(data);
        setLoading(false);
      },
      (error) => {
        console.error("Error cargando competitions en Races:", error);
        setLoading(false);
      }
    );

    return () => unsubscribeFirestore();
  }, []);

  // Función auxiliar para formatear la fecha de Firestore de forma segura
  const formatRaceDate = (dateField) => {
    if (!dateField) return "Sin fecha";
    if (typeof dateField.toDate === "function") {
      return dateField.toDate().toLocaleDateString();
    }
    return String(dateField);
  };

  // Filtrar carreras según lo que el usuario escriba en el buscador
  const filteredCompetitions = competitions.filter((race) => {
    const name = race.name || race.nombre || "";
    return name.toLowerCase().includes(searchTerm.toLowerCase());
  });

  if (loading) {
    return (
      <div className="min-h-screen bg-black flex items-center justify-center text-white">
        <div className="flex flex-col items-center gap-4">
          <div className="w-12 h-12 border-4 border-red-500 border-t-transparent rounded-full animate-spin" />
          <p className="text-zinc-400 animate-pulse font-medium">Cargando competencias...</p>
        </div>
      </div>
    );
  }

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      className="min-h-screen bg-gray-50 dark:bg-black text-gray-900 dark:text-white p-6 md:p-10 transition-colors duration-300"
    >
      <div className="max-w-5xl mx-auto">
        
        {/* ENCABEZADO Y BOTÓN VOLVER */}
        <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-6 mb-10">
          <div>
            <button
              onClick={() => navigate("/")}
              className="flex items-center gap-2 text-zinc-500 hover:text-red-500 dark:text-zinc-400 dark:hover:text-red-400 transition font-medium mb-4 group text-sm"
            >
              <ArrowLeft size={16} className="group-hover:-translate-x-1 transition-transform" />
              Volver al Dashboard
            </button>
            <h1 className="text-4xl font-bold mb-2 text-gray-900 dark:text-white tracking-tight">
              Competencias
            </h1>
            <p className="text-gray-500 dark:text-gray-400">
              Historial y gestión de todas las carreras del sistema.
            </p>
          </div>

          {/* Botón opcional por si a futuro agregas la función de crear carreras */}
          <button 
            onClick={() => navigate("/competitions/new")} 
            className="flex items-center gap-2 bg-red-500 hover:bg-red-600 text-white px-5 py-3 rounded-2xl font-semibold shadow-md shadow-red-500/10 transition-all self-start md:self-auto"
          >
            <Plus size={20} />
            Nueva Carrera
          </button>
        </div>

        {/* BARRA DE BÚSQUEDA Y CONTADOR */}
        <div className="flex flex-col sm:flex-row items-center justify-between gap-4 mb-6">
          <div className="relative w-full sm:max-w-md">
            <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400 dark:text-zinc-500" size={20} />
            <input
              type="text"
              placeholder="Buscar carrera por nombre..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full bg-white dark:bg-zinc-900 border border-gray-200 dark:border-zinc-800 rounded-2xl pl-12 pr-4 py-3.5 text-gray-900 dark:text-white placeholder-gray-400 dark:placeholder-zinc-500 focus:outline-none focus:border-red-500 transition-colors shadow-sm"
            />
          </div>
          
          <span className="bg-red-500/10 text-red-500 px-4 py-2 rounded-xl font-bold text-xs tracking-wider uppercase self-end sm:self-auto">
            {filteredCompetitions.length} Encontradas
          </span>
        </div>

        {/* CONTENEDOR PRINCIPAL DE LA LISTA */}
        <section className="bg-white dark:bg-zinc-950 border border-gray-200 dark:border-zinc-900 rounded-[32px] p-6 md:p-8 transition-colors duration-300 shadow-sm">
          {filteredCompetitions.length === 0 ? (
            <div className="flex flex-col items-center justify-center py-16 text-center border-2 border-dashed border-gray-200 dark:border-zinc-900 rounded-2xl">
              <Trophy size={44} className="text-gray-300 dark:text-zinc-700 mb-4" />
              <p className="text-gray-500 dark:text-gray-400 font-medium text-lg">
                {searchTerm ? "No se encontraron resultados para tu búsqueda" : "No hay carreras registradas todavía"}
              </p>
            </div>
          ) : (
            <div className="grid grid-cols-1 gap-3.5">
              {filteredCompetitions.map((race) => (
                <motion.div
                  key={race.id}
                  whileHover={{ x: 6 }}
                  onClick={() => navigate(`/competitions/${race.id}`)}
                  className="w-full flex items-center justify-between p-5 rounded-2xl bg-gray-50 dark:bg-zinc-900/40 hover:bg-gray-100 dark:hover:bg-zinc-900 border border-gray-100 dark:border-zinc-900/80 cursor-pointer transition-all duration-200 group"
                >
                  <div className="flex items-center gap-4">
                    {/* Icono animado con hover */}
                    <div className="w-12 h-12 rounded-xl bg-red-500/10 flex items-center justify-center text-red-500 group-hover:bg-red-500 group-hover:text-white transition-all duration-300 shadow-sm">
                      <Trophy size={20} />
                    </div>
                    <div>
                      <h3 className="font-bold text-gray-900 dark:text-white text-lg tracking-tight group-hover:text-red-500 dark:group-hover:text-red-400 transition-colors">
                        {race.name || race.nombre || "Carrera sin nombre"}
                      </h3>
                      
                      <div className="flex flex-wrap items-center gap-y-1 gap-x-4 mt-1 text-xs text-gray-500 dark:text-gray-400">
                        <span className="flex items-center gap-1.5">
                          <Calendar size={13} />
                          {formatRaceDate(race.date || race.fecha)}
                        </span>
                        
                        {race.type && (
                          <span className="bg-gray-200/70 dark:bg-zinc-800 px-2.5 py-0.5 rounded-md font-medium text-gray-600 dark:text-zinc-300">
                            {race.type}
                          </span>
                        )}

                        {/* Indicador visual por si la carrera tiene un límite o conteo de corredores asignado */}
                        {race.runners_count && (
                          <span className="text-zinc-400">
                            {race.runners_count} participantes
                          </span>
                        )}
                      </div>
                    </div>
                  </div>

                  <div className="flex items-center gap-3">
                    <span className="text-xs font-bold text-gray-400 dark:text-zinc-500 group-hover:text-red-500 dark:group-hover:text-red-400 transition-colors hidden sm:inline uppercase tracking-wider">
                      Ver Tabla
                    </span>
                    <ChevronRight
                      size={20}
                      className="text-gray-400 dark:text-zinc-600 group-hover:text-red-500 group-hover:translate-x-0.5 transition-all"
                    />
                  </div>
                </motion.div>
              ))}
            </div>
          )}
        </section>

      </div>
    </motion.div>
  );
}

export default Races;