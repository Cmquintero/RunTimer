import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { db, auth } from "../services/authService";
import { doc, getDoc, collection, query, where, getDocs } from "firebase/firestore";
import { motion } from "framer-motion";
import {
  Trophy,
  Timer,
  Medal,
  Activity,
  MapPin,
  Calendar,
  ShieldCheck,
  TrendingUp,
  ArrowLeft,
} from "lucide-react";

function Profile() {
  const navigate = useNavigate();
  const [profileData, setProfileData] = useState({
    nombre: "",
    categoria: "Piloto",
    ubicacion: "No especificada",
    edad: "--",
  });
  const [photoUrl, setPhotoUrl] = useState(null); // Estado para capturar la foto de Google u otra fuente
  const [history, setHistory] = useState([]);
  const [stats, setStats] = useState({ bestTime: "--", wins: 0, total: 0, bestRanking: "--" });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchUserData = async () => {
      const user = auth.currentUser;
      if (!user) {
        navigate("/login");
        return;
      }

      // Capturar la foto de perfil del proveedor de autenticación (ej. Google)
      if (user.photoURL) {
        setPhotoUrl(user.photoURL);
      }

      try {
        // 1. Conseguir perfil de Firestore real
        const userDocRef = doc(db, "usuarios", user.uid);
        const userDoc = await getDoc(userDocRef);

        if (userDoc.exists()) {
          setProfileData(userDoc.data());
          // Por si acaso guardaste una URL de foto personalizada dentro de Firestore
          if (userDoc.data().photoURL) {
            setPhotoUrl(userDoc.data().photoURL);
          }
        } else {
          setProfileData((prev) => ({
            ...prev,
            nombre: user.displayName || "Usuario de RunTimer",
          }));
        }

        // 2. Traer todos los resultados para calcular estadísticas reales
        const q = query(
          collection(db, "resultados"),
          where("userId", "==", user.uid)
        );
        const querySnapshot = await getDocs(q);
        const userHistory = [];
        
        let best = Infinity;
        let wins = 0;
        let highestPodium = Infinity;

        querySnapshot.forEach((doc) => {
          const data = doc.data();
          
          const formattedDate = data.date?.seconds 
            ? new Date(data.date.seconds * 1000).toLocaleDateString()
            : String(data.date || "Sin fecha");

          userHistory.push({ id: doc.id, ...data, date: formattedDate });
          
          const numTime = parseFloat(data.time);
          if (!isNaN(numTime) && numTime < best) best = numTime;
          
          const cleanPosition = parseInt(String(data.position || "").replace("°", "").trim(), 10);
          
          if (!isNaN(cleanPosition) && cleanPosition > 0) {
            if (cleanPosition < highestPodium) {
              highestPodium = cleanPosition;
            }
            if (cleanPosition === 1) wins++;
          }
        });

        setHistory(userHistory);
        
        setStats({
          bestTime: best !== Infinity ? `${best}s` : "--",
          wins: wins,
          total: userHistory.length,
          bestRanking: highestPodium !== Infinity ? `#${highestPodium}` : "—",
        });

      } catch (error) {
        console.error("Error cargando perfil:", error);
      } finally {
        setLoading(false);
      }
    };

    fetchUserData();
  }, [navigate]);

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 dark:bg-black text-gray-900 dark:text-white flex items-center justify-center transition-colors duration-300">
        <div className="flex flex-col items-center gap-4">
          <div className="w-12 h-12 border-4 border-red-500 border-t-transparent rounded-full animate-spin" />
          <p className="text-xl text-gray-400 dark:text-gray-500 animate-pulse font-medium">Cargando perfil de competidor...</p>
        </div>
      </div>
    );
  }

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      transition={{ duration: 0.4 }}
      className="min-h-screen bg-gray-50 dark:bg-black text-gray-900 dark:text-white p-6 md:p-10 transition-colors duration-300"
    >
      {/* Botón Volver al Inicio */}
      <div className="flex justify-start mb-6">
        <button
          onClick={() => navigate("/dashboard")}
          className="flex items-center gap-2 px-4 py-2.5 rounded-xl bg-white dark:bg-zinc-900 border border-gray-200 dark:border-zinc-800 text-sm font-semibold hover:bg-gray-100 dark:hover:bg-zinc-800 text-gray-900 dark:text-white transition shadow-sm"
        >
          <ArrowLeft size={16} />
          Volver al inicio
        </button>
      </div>

      {/* BANNER / INFO PRINCIPAL */}
      <div className="bg-white dark:bg-zinc-900 border border-gray-200 dark:border-zinc-800 rounded-3xl p-8 mb-10 shadow-sm transition-colors duration-300">
        <div className="flex flex-col lg:flex-row lg:items-center gap-8">
          
          {/* FOTO DE PERFIL DINÁMICA */}
          <div className="w-36 h-36 rounded-full overflow-hidden bg-gradient-to-br from-red-500 to-red-600 flex items-center justify-center text-5xl font-bold text-white shadow-md border-4 border-gray-100 dark:border-zinc-800 shrink-0">
            {photoUrl ? (
              <img 
                src={photoUrl} 
                alt="Foto de perfil" 
                className="w-full h-full object-cover"
                referrerPolicy="no-referrer" // Evita bloqueos de carga de imágenes de Google
              />
            ) : (
              profileData.nombre ? profileData.nombre.charAt(0).toUpperCase() : "C"
            )}
          </div>

          <div className="flex-1">
            <div className="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-6">
              <div>
                <h1 className="text-4xl font-bold mb-3 text-gray-900 dark:text-white">{profileData.nombre}</h1>
                <div className="flex flex-wrap items-center gap-4 text-gray-500 dark:text-gray-400">
                  <div className="flex items-center gap-2">
                    <ShieldCheck size={18} />
                    <span>{profileData.categoria || "Piloto"}</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <MapPin size={18} />
                    <span>{profileData.ubicacion || "No especificada"}</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <Calendar size={18} />
                    <span>{profileData.edad || "--"} años</span>
                  </div>
                </div>
              </div>
              <div className="bg-green-500/10 text-green-600 dark:text-green-400 px-5 py-3 rounded-2xl font-semibold w-fit text-sm">
                Activo
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* METRICAS DE RENDIMIENTO */}
      <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 gap-6 mb-10">
        {/* Mejor tiempo */}
        <div className="bg-white dark:bg-zinc-900 border border-gray-200 dark:border-zinc-800 rounded-3xl p-6 shadow-sm transition-colors duration-300">
          <div className="flex justify-between items-center mb-5">
            <div className="w-14 h-14 rounded-2xl bg-red-500/10 text-red-500 flex items-center justify-center">
              <Timer size={22} />
            </div>
            <TrendingUp className="text-green-500 dark:text-green-400" size={20} />
          </div>
          <h2 className="text-gray-500 dark:text-gray-400 mb-2 font-medium">Mejor tiempo</h2>
          <p className="text-4xl font-bold text-gray-900 dark:text-white">{stats.bestTime}</p>
        </div>

        {/* Victorias */}
        <div className="bg-white dark:bg-zinc-900 border border-gray-200 dark:border-zinc-800 rounded-3xl p-6 shadow-sm transition-colors duration-300">
          <div className="flex justify-between items-center mb-5">
            <div className="w-14 h-14 rounded-2xl bg-red-500/10 text-red-500 flex items-center justify-center">
              <Trophy size={22} />
            </div>
          </div>
          <h2 className="text-gray-500 dark:text-gray-400 mb-2 font-medium">Victorias</h2>
          <p className="text-4xl font-bold text-gray-900 dark:text-white">{stats.wins}</p>
        </div>

        {/* Competencias */}
        <div className="bg-white dark:bg-zinc-900 border border-gray-200 dark:border-zinc-800 rounded-3xl p-6 shadow-sm transition-colors duration-300">
          <div className="flex justify-between items-center mb-5">
            <div className="w-14 h-14 rounded-2xl bg-red-500/10 text-red-500 flex items-center justify-center">
              <Activity size={22} />
            </div>
          </div>
          <h2 className="text-gray-500 dark:text-gray-400 mb-2 font-medium">Competencias</h2>
          <p className="text-4xl font-bold text-gray-900 dark:text-white">{stats.total}</p>
        </div>

        {/* Ranking Dinámico (Mejor Podio) */}
        <div className="bg-white dark:bg-zinc-900 border border-gray-200 dark:border-zinc-800 rounded-3xl p-6 shadow-sm transition-colors duration-300">
          <div className="flex justify-between items-center mb-5">
            <div className="w-14 h-14 rounded-2xl bg-red-500/10 text-red-500 flex items-center justify-center">
              <Medal size={22} />
            </div>
          </div>
          <h2 className="text-gray-500 dark:text-gray-400 mb-2 font-medium">Mejor Puesto</h2>
          <p className="text-4xl font-bold text-gray-900 dark:text-white">{stats.bestRanking}</p>
        </div>
      </div>

      {/* HISTORIAL RECIENTE */}
      <div className="bg-white dark:bg-zinc-900 border border-gray-200 dark:border-zinc-800 rounded-3xl p-6 shadow-sm transition-colors duration-300">
        <div className="mb-6">
          <h2 className="text-2xl font-bold mb-2 text-gray-900 dark:text-white">Historial reciente</h2>
          <p className="text-gray-500 dark:text-gray-400">Últimas competencias registradas en Firestore.</p>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full min-w-[800px]">
            <thead>
              <tr className="border-b border-gray-200 dark:border-zinc-800 text-left text-gray-500 dark:text-gray-400">
                <th className="pb-4 font-semibold">Competencia</th>
                <th className="pb-4 font-semibold">Fecha</th>
                <th className="pb-4 font-semibold">Tiempo</th>
                <th className="pb-4 font-semibold">Posición</th>
              </tr>
            </thead>
            <tbody>
              {history.slice(0, 3).map((item) => (
                <tr key={item.id} className="border-b border-gray-100 dark:border-zinc-800/60 hover:bg-gray-50 dark:hover:bg-zinc-800/40 text-gray-900 dark:text-white transition">
                  <td className="py-5 font-semibold">{item.competition}</td>
                  <td className="py-5 text-gray-500 dark:text-gray-400">{item.date}</td>
                  <td className="py-5 font-bold text-green-600 dark:text-green-400">{item.time}s</td>
                  <td className="py-5 font-medium">
                    {String(item.position).includes('°') ? item.position : `${item.position}°`}
                  </td>
                </tr>
              ))}
              {history.length === 0 && (
                <tr>
                  <td colSpan="4" className="py-10 text-center text-gray-400 dark:text-gray-500">
                    No se encontraron marcas de tiempo registradas para este piloto.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </motion.div>
  );
}

export default Profile;