import { motion } from "framer-motion";

import {
  Trophy,
  CalendarDays,
  MapPin,
  Users,
} from "lucide-react";

 

function Competitions() {

  const competitions = [

    {
      id: 1,
      name: "Velocity League",
      date: "18 Mayo 2026",
      location: "Bogotá",
      category: "Profesional",
      participants: 24,
      registered: true,
    },

    {
      id: 2,
      name: "Run Challenge",
      date: "25 Mayo 2026",
      location: "Medellín",
      category: "Avanzado",
      participants: 18,
      registered: false,
    },

    {
      id: 3,
      name: "SprintBot Cup",
      date: "02 Junio 2026",
      location: "Cali",
      category: "Profesional",
      participants: 32,
      registered: false,
    },

  ];

  return (

    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      transition={{ duration: 0.4 }}
      className="min-h-screen bg-black text-white p-6 md:p-10"
    >

      {/* HEADER */}
      <div className="mb-10">

        <h1 className="text-4xl font-bold mb-3">
          Competiciones
        </h1>

        <p className="text-gray-400 text-lg">
          Próximas competencias disponibles para participar.
        </p>

      </div>

      {/* EMPTY STATE */}
      {
        competitions.length === 0 ? (

          <div
            className="
              bg-zinc-900
              border
              border-zinc-800
              rounded-3xl
              p-10
              text-center
            "
          >

            <div
              className="
                w-24
                h-24
                rounded-full
                bg-zinc-800
                flex
                items-center
                justify-center
                mx-auto
                mb-6
              "
            >

              <Trophy size={40} className="text-gray-500" />

            </div>

            <h2 className="text-2xl font-bold mb-3">
              No hay competiciones actualmente
            </h2>

            <p className="text-gray-400">
              Las nuevas competencias aparecerán aquí.
            </p>

          </div>

        ) : (

          <div
            className="
              bg-zinc-900
              border
              border-zinc-800
              rounded-3xl
              p-6
            "
          >

            {/* TITLE */}
            <div className="mb-8">

              <h2 className="text-2xl font-bold mb-2">
                Próximas competiciones
              </h2>

              <p className="text-gray-400">
                Inscríbete y participa en nuevas carreras.
              </p>

            </div>

            {/* TABLE */}
            <div className="overflow-x-auto">

              <table className="w-full min-w-[900px]">

                <thead>

                  <tr className="border-b border-zinc-800 text-left text-gray-400">

                    <th className="pb-4">Competición</th>

                    <th className="pb-4">Fecha</th>

                    <th className="pb-4">Ubicación</th>

                    <th className="pb-4">Categoría</th>

                    <th className="pb-4">Participantes</th>

                    <th className="pb-4">Acción</th>

                  </tr>

                </thead>

                <tbody>

                  {
                    competitions.map((competition) => (

                      <tr
                        key={competition.id}
                        className="
                          border-b
                          border-zinc-800
                          hover:bg-zinc-800/40
                          transition
                        "
                      >

                        {/* NAME */}
                        <td className="py-6">

                          <div className="flex items-center gap-4">

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

                            <div>

                              <h2 className="font-semibold text-lg">
                                {competition.name}
                              </h2>

                              <p className="text-gray-400 text-sm">
                                Competencia oficial
                              </p>

                            </div>

                          </div>

                        </td>

                        {/* DATE */}
                        <td className="py-6">

                          <div className="flex items-center gap-2">

                            <CalendarDays
                              size={18}
                              className="text-gray-400"
                            />

                            <span>
                              {competition.date}
                            </span>

                          </div>

                        </td>

                        {/* LOCATION */}
                        <td className="py-6">

                          <div className="flex items-center gap-2">

                            <MapPin
                              size={18}
                              className="text-gray-400"
                            />

                            <span>
                              {competition.location}
                            </span>

                          </div>

                        </td>

                        {/* CATEGORY */}
                        <td className="py-6">

                          <span
                            className="
                              bg-zinc-800
                              px-4
                              py-2
                              rounded-xl
                              text-sm
                            "
                          >
                            {competition.category}
                          </span>

                        </td>

                        {/* PARTICIPANTS */}
                        <td className="py-6">

                          <div className="flex items-center gap-2">

                            <Users
                              size={18}
                              className="text-gray-400"
                            />

                            <span>
                              {competition.participants}
                            </span>

                          </div>

                        </td>

                        {/* ACTION */}
                        <td className="py-6">

                          {
                            competition.registered ? (

                              <button
                                className="
                                  bg-red-500/20
                                  hover:bg-red-500/30
                                  text-red-400
                                  px-5
                                  py-3
                                  rounded-2xl
                                  font-semibold
                                  transition
                                "
                              >
                                Cancelar inscripción
                              </button>

                            ) : (

                              <button
                                className="
                                  bg-red-500
                                  hover:bg-red-600
                                  px-5
                                  py-3
                                  rounded-2xl
                                  font-semibold
                                  transition
                                "
                              >
                                Inscribirse
                              </button>

                            )
                          }

                        </td>

                      </tr>

                    ))
                  }

                </tbody>

              </table>

            </div>

          </div>

        )
      }

    </motion.div>
  );
}

export default Competitions;