import { motion } from "framer-motion";
import { useNavigate } from "react-router-dom";
import BonillaImg from "../assets/img/Bonilla.jpeg";
import MarioImg from "../assets/img/Mario.jpeg";

import {
  ArrowLeft,
  GraduationCap,
  Award,
  Briefcase,
  MapPin,
} from "lucide-react";

import {
  FaLinkedinIn,
  FaInstagram,
  FaFacebookF,
} from "react-icons/fa";

export default function ContactoCreadores() {
  const navigate = useNavigate();

  const creators = [
    {
      name: "Brayan Enrique Bonilla Carmona",
      role: "Ingeniería en Sistemas",
      description:
        "Desarrollador apasionado por la tecnología, diseño de software e innovación digital. Enfocado en crear soluciones modernas y eficientes, Contacto al correo bebonillc@ufpso.edu.co",
      insta: "https://instagram.com/bonilla18b",
      facebook: "https://www.facebook.com/share/1B7d1eTAka/?mibextid=wwXIfr",
      linkedin: "https://linkedin.com/in/brayan-bonilla",
      img: BonillaImg,
      location: "Ocaña, Norte de Santander",
      skills: [
        "Ingeniería de Sistemas",
        "Desarrollo En flutter",
        "Diseño de Software",
        "Desarrollo de circuitos"
      ],
    },
    {
      name: "Carlos Mario Quintero",
      role: "Ingeniería en Sistemas",
      description:
        "Apasionado por el desarrollo Full Stack, bases de datos, Firebase, arquitectura de software y tecnologías modernas enfocadas en productos reales,Contacto en cmquinterot@ufpso.edu.co",
      insta: "https://instagram.com/cm_quintero",
      facebook:
        "https://www.facebook.com/carlosmario.quinterotrigos",
      linkedin:
        "https://www.linkedin.com/in/carlos-mario-quintero-trigos-b9a21b271/",
      img: MarioImg,
      location: "Ocaña, Norte de Santander",
      skills: [
        "Full Stack Developer",
        "React + Firebase",
        "Bases de Datos",
        "Desarrollo Web",
      ],
    },
  ];

  return (
    <div className="min-h-screen bg-black text-white overflow-hidden relative">
      {/* Fondo Glow */}
      <div className="absolute top-[-120px] left-[-100px] w-[500px] h-[500px] bg-red-600/20 blur-[140px] rounded-full" />

      <div className="absolute bottom-[-120px] right-[-100px] w-[450px] h-[450px] bg-red-500/10 blur-[120px] rounded-full" />

      <div className="relative z-10 max-w-7xl mx-auto px-6 py-10">
        {/* Botón volver */}
        <button
          onClick={() => navigate(-1)}
          className="flex items-center gap-2 text-zinc-400 hover:text-red-500 transition duration-300 mb-12"
        >
          <ArrowLeft size={18} />
          Volver al Dashboard
        </button>

        {/* Hero */}
        <motion.div
          initial={{ opacity: 0, y: 35 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6 }}
          className="text-center mb-20"
        >
          <p className="uppercase tracking-[0.35em] text-red-500 mb-4 text-sm">
            Equipo de Desarrollo
          </p>

          <h1 className="text-5xl md:text-7xl font-black mb-6 leading-tight">
            Creadores de{" "}
            <span className="text-red-600">
              RUNtimer
            </span>
          </h1>

          <p className="text-zinc-400 text-lg max-w-3xl mx-auto leading-relaxed">
            Conoce a los desarrolladores detrás de
            RUNtimer. Tecnología, innovación y pasión
            por el desarrollo de software.
          </p>
        </motion.div>

        {/* Cards */}
        <div className="grid lg:grid-cols-2 gap-10">
          {creators.map((creator, index) => (
            <motion.div
              key={index}
              initial={{ opacity: 0, y: 60 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{
                delay: index * 0.2,
              }}
              whileHover={{
                y: -10,
                scale: 1.01,
              }}
              className="bg-gradient-to-br from-zinc-950 to-zinc-900 border border-zinc-800 rounded-[35px] overflow-hidden p-8 shadow-[0_0_40px_rgba(239,68,68,0.08)] backdrop-blur-xl"
            >
              {/* Perfil */}
              <div className="flex flex-col md:flex-row gap-8 items-center md:items-start">
                <img
                  src={creator.img}
                  alt={creator.name}
                  className="w-48 h-48 md:w-56 md:h-56 rounded-full object-cover object-top border-4 border-red-600 shadow-2xl bg-zinc-900"
                />

                <div className="flex-1 text-center md:text-left">
                  <h2 className="text-3xl font-bold mb-2">
                    {creator.name}
                  </h2>

                  <div className="flex items-center justify-center md:justify-start gap-2 text-red-500 mb-4">
                    <GraduationCap size={18} />
                    <span>{creator.role}</span>
                  </div>

                  <p className="text-zinc-400 leading-relaxed">
                    {creator.description}
                  </p>
                </div>
              </div>

              {/* Skills */}
              <div className="mt-8">
                <h3 className="flex items-center gap-2 text-lg font-semibold mb-4">
                  <Award size={18} />
                  Formación y habilidades
                </h3>

                <div className="flex flex-wrap gap-3">
                  {creator.skills.map(
                    (skill, i) => (
                      <span
                        key={i}
                        className="px-4 py-2 rounded-full border border-red-500/30 bg-red-500/10 text-red-400 text-sm"
                      >
                        {skill}
                      </span>
                    )
                  )}
                </div>
              </div>

              {/* Información */}
              <div className="grid md:grid-cols-2 gap-4 mt-8">
                <div className="bg-zinc-900/80 border border-zinc-800 rounded-3xl p-5">
                  <Briefcase className="text-red-500 mb-3" />

                  <h4 className="font-semibold mb-2">
                    Experiencia
                  </h4>

                  <p className="text-zinc-400 text-sm leading-relaxed">
                    Desarrollo web, software,
                    proyectos académicos y
                    tecnologías modernas.
                  </p>
                </div>

                <div className="bg-zinc-900/80 border border-zinc-800 rounded-3xl p-5">
                  <MapPin className="text-red-500 mb-3" />

                  <h4 className="font-semibold mb-2">
                    Ubicación
                  </h4>

                  <p className="text-zinc-400 text-sm leading-relaxed">
                    {creator.location},
                    Colombia
                  </p>
                </div>
              </div>

              {/* Redes */}
              <div className="border-t border-zinc-800 mt-10 pt-6 flex justify-center gap-5">
                <a
                  href={creator.linkedin}
                  target="_blank"
                  rel="noreferrer"
                  className="w-14 h-14 rounded-2xl bg-zinc-900 hover:bg-[#0A66C2] transition-all duration-300 flex items-center justify-center hover:scale-110"
                >
                  <FaLinkedinIn size={22} />
                </a>

                <a
                  href={creator.insta}
                  target="_blank"
                  rel="noreferrer"
                  className="w-14 h-14 rounded-2xl bg-zinc-900 hover:bg-pink-600 transition-all duration-300 flex items-center justify-center hover:scale-110"
                >
                  <FaInstagram size={22} />
                </a>

                <a
                  href={creator.facebook}
                  target="_blank"
                  rel="noreferrer"
                  className="w-14 h-14 rounded-2xl bg-zinc-900 hover:bg-blue-700 transition-all duration-300 flex items-center justify-center hover:scale-110"
                >
                  <FaFacebookF size={22} />
                </a>
              </div>
            </motion.div>
          ))}
        </div>

        {/* Footer */}
        <div className="mt-24 border-t border-zinc-900 pt-12 text-center">
          <h3 className="text-2xl font-bold mb-3">
            RUNtimer Development Team
          </h3>

          <p className="text-zinc-500 max-w-2xl mx-auto leading-relaxed">
            Construyendo tecnología enfocada en
            cronometraje deportivo, gestión de
            competencias y experiencias modernas
            para atletas.
          </p>
        </div>
      </div>
    </div>
  );
}