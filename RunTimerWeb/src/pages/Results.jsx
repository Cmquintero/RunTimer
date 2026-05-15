import {
  Timer,
  Trophy,
  Activity,
  Medal,
  ArrowUpRight,
} from "lucide-react";

import { motion } from "framer-motion";

function Results() {
  const results = [
    {
      id: 1,
      competition: "Copa Nacional",
      date: "10 Mayo 2026",
      time: "2.19s",
      position: "1°",
      status: "Finalizado",
    },
    {
      id: 2,
      competition: "Velocity League",
      date: "08 Mayo 2026",
      time: "2.31s",
      position: "2°",
      status: "Finalizado",
    },
    {
      id: 3,
      competition: "Run Challenge",
      date: "03 Mayo 2026",
      time: "2.44s",
      position: "4°",
      status: "Finalizado",
    },
    {
      id: 4,
      competition: "SprintBot Cup",
      date: "28 Abril 2026",
      time: "2.27s",
      position: "1°",
      status: "Finalizado",
    },
  ];

  return (
    <motion.div
      
      initial={{ opacity: 0, y: 15 }} 
      animate={{ opacity: 1, y: 0 }}
      transition={{ 
        duration: 0.2, 
        ease: "easeOut" 
      }}
      className="min-h-screen bg-black text-white p-6 md:p-10"
    >
    
      <div className="mb-10">
        <h1 className="text-4xl font-bold mb-3">
          Mis Resultados
        </h1>
        <p className="text-gray-400 text-lg">
          Historial personal y rendimiento competitivo.
        </p>
      </div>

    
      <div
        className="
          grid
          grid-cols-1
          md:grid-cols-2
          xl:grid-cols-4
          gap-6
          mb-10
        "
      >
        
        <div
          className="
            bg-zinc-900
            border
            border-zinc-800
            rounded-3xl
            p-6
          "
        >
          <div className="flex justify-between items-center mb-5">
            <div
              className="
                w-14
                h-14
                rounded-2xl
                bg-red-500/20
                flex
                items-center
                justify-center
              "
            >
              <Timer className="text-red-500" />
            </div>
            <ArrowUpRight className="text-green-400" />
          </div>

          <h2 className="text-gray-400 mb-2">Mejor tiempo</h2>
          <p className="text-4xl font-bold">2.19s</p>
        </div>

       
        <div
          className="
            bg-zinc-900
            border
            border-zinc-800
            rounded-3xl
            p-6
          "
        >
          <div className="flex justify-between items-center mb-5">
            <div
              className="
                w-14
                h-14
                rounded-2xl
                bg-red-500/20
                flex
                items-center
                justify-center
              "
            >
              <Activity className="text-red-500" />
            </div>
            <ArrowUpRight className="text-green-400" />
          </div>

          <h2 className="text-gray-400 mb-2">Último tiempo</h2>
          <p className="text-4xl font-bold">2.31s</p>
        </div>

    
        <div
          className="
            bg-zinc-900
            border
            border-zinc-800
            rounded-3xl
            p-6
          "
        >
          <div className="flex justify-between items-center mb-5">
            <div
              className="
                w-14
                h-14
                rounded-2xl
                bg-red-500/20
                flex
                items-center
                justify-center
              "
            >
              <Trophy className="text-red-500" />
            </div>
            <ArrowUpRight className="text-green-400" />
          </div>

          <h2 className="text-gray-400 mb-2">Competencias</h2>
          <p className="text-4xl font-bold">14</p>
        </div>

    
        <div
          className="
            bg-zinc-900
            border
            border-zinc-800
            rounded-3xl
            p-6
          "
        >
          <div className="flex justify-between items-center mb-5">
            <div
              className="
                w-14
                h-14
                rounded-2xl
                bg-red-500/20
                flex
                items-center
                justify-center
              "
            >
              <Medal className="text-red-500" />
            </div>
            <ArrowUpRight className="text-green-400" />
          </div>

          <h2 className="text-gray-400 mb-2">Victorias</h2>
          <p className="text-4xl font-bold">8</p>
        </div>
      </div>

    
      <div
        className="
          bg-zinc-900
          border
          border-zinc-800
          rounded-3xl
          p-6
          mb-10
        "
      >
        <div className="flex items-center justify-between mb-6">
          <div>
            <h2 className="text-2xl font-bold mb-2">
              Última competencia
            </h2>
            <p className="text-gray-400">Velocity League 2026</p>
          </div>

          <div
            className="
              bg-green-500/20
              text-green-400
              px-4
              py-2
              rounded-xl
              text-sm
              font-semibold
            "
          >
            FINALIZADO
          </div>
        </div>

        <div
          className="
            grid
            grid-cols-1
            md:grid-cols-3
            gap-6
          "
        >
          <div
            className="
              bg-black
              border
              border-zinc-800
              rounded-2xl
              p-5
            "
          >
            <p className="text-gray-400 mb-2">Tiempo obtenido</p>
            <h2 className="text-3xl font-bold text-green-400">2.31s</h2>
          </div>

          <div
            className="
              bg-black
              border
              border-zinc-800
              rounded-2xl
              p-5
            "
          >
            <p className="text-gray-400 mb-2">Posición</p>
            <h2 className="text-3xl font-bold">#2</h2>
          </div>

          <div
            className="
              bg-black
              border
              border-zinc-800
              rounded-2xl
              p-5
            "
          >
            <p className="text-gray-400 mb-2">Categoría</p>
            <h2 className="text-3xl font-bold">Profesional</h2>
          </div>
        </div>
      </div>

    
      <div
        className="
          bg-zinc-900
          border
          border-zinc-800
          rounded-3xl
          p-6
        "
      >
        <div className="mb-6">
          <h2 className="text-2xl font-bold mb-2">
            Historial de competencias
          </h2>
          <p className="text-gray-400">
            Últimos resultados registrados.
          </p>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full min-w-[800px]">
            <thead>
              <tr className="border-b border-zinc-800 text-left text-gray-400">
                <th className="pb-4">Competencia</th>
                <th className="pb-4">Fecha</th>
                <th className="pb-4">Tiempo</th>
                <th className="pb-4">Posición</th>
                <th className="pb-4">Estado</th>
              </tr>
            </thead>

            <tbody>
              {results.map((result) => (
                <tr
                  key={result.id}
                  className="
                    border-b
                    border-zinc-800
                    hover:bg-zinc-800/40
                    transition
                  "
                >
                  <td className="py-5 font-semibold">
                    {result.competition}
                  </td>

                  <td className="py-5 text-gray-400">{result.date}</td>

                  <td className="py-5 font-bold text-green-400">
                    {result.time}
                  </td>

                  <td className="py-5">{result.position}</td>

                  <td className="py-5">
                    <span
                      className="
                        bg-green-500/20
                        text-green-400
                        px-4
                        py-2
                        rounded-xl
                        text-sm
                        font-semibold
                      "
                    >
                      {result.status}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </motion.div>
  );
}

export default Results;