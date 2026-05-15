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
} from "lucide-react";

function Profile() {

  const history = [

    {
      id: 1,
      competition: "Velocity League",
      date: "10 Mayo 2026",
      time: "2.19s",
      position: "1°",
    },

    {
      id: 2,
      competition: "Run Challenge",
      date: "04 Mayo 2026",
      time: "2.31s",
      position: "2°",
    },

    {
      id: 3,
      competition: "SprintBot Cup",
      date: "28 Abril 2026",
      time: "2.27s",
      position: "1°",
    },

  ];

  return (

    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      transition={{ duration: 0.4 }}
      className="min-h-screen bg-black text-white p-6 md:p-10"
    >

      <div
        className="
          bg-zinc-900
          border
          border-zinc-800
          rounded-3xl
          p-8
          mb-10
        "
      >

        <div
          className="
            flex
            flex-col
            lg:flex-row
            lg:items-center
            gap-8
          "
        >

          {/* AVATAR */}
          <div
            className="
              w-36
              h-36
              rounded-full
              bg-red-500
              flex
              items-center
              justify-center
              text-5xl
              font-bold
            "
          >
            C
          </div>

          <div className="flex-1">

            <div
              className="
                flex
                flex-col
                lg:flex-row
                lg:items-center
                lg:justify-between
                gap-6
              "
            >

              <div>

                <h1 className="text-4xl font-bold mb-3">
                  Carlos Quintero
                </h1>

                <div
                  className="
                    flex
                    flex-wrap
                    items-center
                    gap-4
                    text-gray-400
                  "
                >

                  <div className="flex items-center gap-2">

                    <ShieldCheck size={18} />

                    <span>
                      Profesional
                    </span>

                  </div>

                  <div className="flex items-center gap-2">

                    <MapPin size={18} />

                    <span>
                      Bogotá, Colombia
                    </span>

                  </div>

                  <div className="flex items-center gap-2">

                    <Calendar size={18} />

                    <span>
                      21 años
                    </span>

                  </div>

                </div>

              </div>

              <div
                className="
                  bg-green-500/20
                  text-green-400
                  px-5
                  py-3
                  rounded-2xl
                  font-semibold
                  w-fit
                "
              >
                Activo
              </div>

            </div>

          </div>

        </div>

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

            <TrendingUp className="text-green-400" />

          </div>

          <h2 className="text-gray-400 mb-2">
            Mejor tiempo
          </h2>

          <p className="text-4xl font-bold">
            2.19s
          </p>

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

          </div>

          <h2 className="text-gray-400 mb-2">
            Victorias
          </h2>

          <p className="text-4xl font-bold">
            8
          </p>

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

          </div>

          <h2 className="text-gray-400 mb-2">
            Competencias
          </h2>

          <p className="text-4xl font-bold">
            14
          </p>

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

          </div>

          <h2 className="text-gray-400 mb-2">
            Ranking
          </h2>

          <p className="text-4xl font-bold">
            #2
          </p>

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

        <h2 className="text-2xl font-bold mb-6">
          Logros
        </h2>

        <div className="flex flex-wrap gap-4">

          <div
            className="
              bg-red-500/20
              text-red-400
              px-5
              py-3
              rounded-2xl
              font-semibold
            "
          >
            🏆 Campeón Regional
          </div>

          <div
            className="
              bg-green-500/20
              text-green-400
              px-5
              py-3
              rounded-2xl
              font-semibold
            "
          >
            ⚡ Sub 2.20s
          </div>

          <div
            className="
              bg-yellow-500/20
              text-yellow-400
              px-5
              py-3
              rounded-2xl
              font-semibold
            "
          >
            🔥 5 victorias seguidas
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
            Historial reciente
          </h2>

          <p className="text-gray-400">
            Últimas competencias registradas.
          </p>

        </div>

        <div className="overflow-x-auto">

          <table className="w-full min-w-[800px]">

            <thead>

              <tr className="border-b border-zinc-800 text-left text-gray-400">

                <th className="pb-4">
                  Competencia
                </th>

                <th className="pb-4">
                  Fecha
                </th>

                <th className="pb-4">
                  Tiempo
                </th>

                <th className="pb-4">
                  Posición
                </th>

              </tr>

            </thead>

            <tbody>

              {
                history.map((item) => (

                  <tr
                    key={item.id}
                    className="
                      border-b
                      border-zinc-800
                      hover:bg-zinc-800/40
                      transition
                    "
                  >

                    <td className="py-5 font-semibold">
                      {item.competition}
                    </td>

                    <td className="py-5 text-gray-400">
                      {item.date}
                    </td>

                    <td className="py-5 font-bold text-green-400">
                      {item.time}
                    </td>

                    <td className="py-5">
                      {item.position}
                    </td>

                  </tr>

                ))
              }

            </tbody>

          </table>

        </div>

      </div>

    </motion.div>
  );
}

export default Profile;