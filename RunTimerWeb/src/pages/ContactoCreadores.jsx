import { motion } from "framer-motion";
import { Mail, Instagram, Facebook, Linkedin, ArrowLeft } from "lucide-react";
import { useNavigate } from "react-router-dom";

export default function ContactoCreadores() {
  const navigate = useNavigate();

  // He añadido las URLs completas para que los botones funcionen
  const creators = [
    { 
      name: "Brayan Enrique Bonilla Carmona", 
      role: "Estudiante De Ingeniería En Sistemas", 
      gmail: "bebonillac@ufpso.edu.co", 
      insta: "https://instagram.com/bonilla18b", 
      facebook: "https://facebook.com/profile.php?id=TU_ID", // Reemplaza con el link real
      linkedin: "https://linkedin.com/in/tu-perfil",
      img: import.meta.env.VITE_IMG_BRAYAN // Define esto en tu .env
    },
    { 
      name: "Carlos Quintero", 
      role: "Estudiante De Ingeniería En Sistemas", 
      gmail: "cmquinterot@ufpso.edu.co", 
      insta: "https://instagram.com/cm_quintero", 
      facebook: "https://facebook.com/profile.php?id=TU_ID", // Reemplaza con el link real
      linkedin: "https://linkedin.com/in/tu-perfil",
      img: import.meta.env.VITE_IMG_CARLOS // Define esto en tu .env
    }
  ];

  return (
    <motion.div 
      initial={{ opacity: 0 }} animate={{ opacity: 1 }} 
      className="min-h-screen bg-black text-white p-6 md:p-12 flex flex-col items-center"
    >
      <button onClick={() => navigate(-1)} className="self-start flex items-center gap-2 text-gray-400 hover:text-red-500 transition mb-10">
        <ArrowLeft size={20} /> Volver
      </button>

      <h1 className="text-4xl font-bold mb-16 text-center">Creadores de <span className="text-red-600">RUNtimer</span></h1>

      <div className="grid md:grid-cols-2 gap-8 w-full max-w-4xl">
        {creators.map((c, i) => (
          <div key={i} className="bg-zinc-900 border border-zinc-800 p-8 rounded-[32px] text-center shadow-2xl hover:border-red-600/50 transition">
            <img 
              src={c.img} 
              alt={c.name} 
              className="w-32 h-32 rounded-full mx-auto mb-6 object-cover border-4 border-zinc-800 select-none pointer-events-none"
              style={{ WebkitUserDrag: "none" }}
            />
            
            <h2 className="text-2xl font-bold">{c.name}</h2>
            <p className="text-red-500 font-medium mb-6">{c.role}</p>
            
            <div className="flex justify-center gap-4">
              <a href={c.linkedin} target="_blank" rel="noreferrer" className="p-3 bg-zinc-800 rounded-full hover:bg-red-600 transition"><Linkedin size={20}/></a>
              <a href={c.insta} target="_blank" rel="noreferrer" className="p-3 bg-zinc-800 rounded-full hover:bg-red-600 transition"><Instagram size={20}/></a>
              <a href={c.facebook} target="_blank" rel="noreferrer" className="p-3 bg-zinc-800 rounded-full hover:bg-red-600 transition"><Facebook size={20}/></a>
            </div>
          </div>
        ))}
      </div>

      <div className="mt-16 w-full max-w-4xl bg-gradient-to-r from-red-700 to-black p-8 rounded-[32px] flex flex-col md:flex-row items-center justify-between gap-6 shadow-xl">
        <div>
          <h3 className="text-2xl font-bold">¿Tienes dudas o sugerencias?</h3>
          <p className="text-gray-300">Contacta al equipo de desarrollo.</p>
        </div>
        <div className="flex gap-3">
            {creators.map((c, i) => (
                <a key={i} href={`mailto:${c.gmail}`} className="bg-white text-red-700 px-6 py-4 rounded-2xl font-bold hover:scale-105 transition text-sm">
                   Email {c.name.split(" ")[0]}
                </a>
            ))}
        </div>
      </div>
    </motion.div>
  );
}