import { motion } from "framer-motion";
import {
  Activity,
  Bell,
  LayoutDashboard,
  Settings,
  Timer,
  Trophy,
  Users,
  Wifi,
} from "lucide-react";
import { useState } from "react";
import { useNavigate } from "react-router-dom";

function Dashboard() {
  const navigate = useNavigate();
  const [isAnimating, setAnimating] = useState(false);

  const handleCompetitions = () => {
    setAnimating(true);
    setTimeout(() => {
      navigate("/Competitions");
    }, 250);
  };

  const handleRegister = () => {
    setAnimating(true);
    setTimeout(() => {
      navigate("/Register");
    }, 250);
  };

  const handleResults = () => {
    setAnimating(true);
    setTimeout(() => {
      navigate("/Results");
    }, 250);
  };

  const handleSettings = () => {
    setAnimating(true);
    setTimeout(() => {
      navigate("/Settings");
    }, 250);
  };
  const handleProfile = () => {
    setAnimating(true);
    setTimeout(() => {
      navigate("/Profile");
    }, 250);
  };
  const handleparticipanteProfile =() =>{
    setAnimating(true);
    setTimeout(() => {
      navigate("/participanteProfile");
    }, 250);
  }
  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: isAnimating ? 0 : 1 }}
      transition={{ duration: 0.2 }}
      className="min-h-screen bg-black text-white flex"
    >
      <aside
        className="
          w-72
          bg-zinc-950
          border-r
          border-zinc-900
          p-6
          hidden
          md:flex
          flex-col
        "
      >
        <div className="flex items-center gap-4 mb-12">
          <div
            className="
              w-14
              h-14
              rounded-2xl
              bg-red-500
              flex
              items-center
              justify-center
              font-bold
              text-xl
            "
          >
            R
          </div>

          <div>
            <h1 className="text-2xl font-bold">RunTimer</h1>
            <p className="text-gray-400 text-sm">Sistema de carreras</p>
          </div>
        </div>
        <nav className="flex flex-col gap-3">
          <button
            className="
      flex
      items-center
      gap-4
      bg-red-500
      px-5
      py-4
      rounded-2xl
      font-semibold
    "
          >
            <LayoutDashboard size={22} />
            Dashboard
          </button>

          <button
            onClick={handleCompetitions}
            className="
      flex
      items-center
      gap-4
      px-5
      py-4
      rounded-2xl
      bg-zinc-900
      hover:bg-zinc-800
      transition
    "
          >
            <Trophy size={22} />
            Competencias
          </button>

          <button
            onClick={handleResults}
            className="
      flex
      items-center
      gap-4
      px-5
      py-4
      rounded-2xl
      bg-zinc-900
      hover:bg-zinc-800
      transition
    "
          >
            <Activity size={22} />
            Resultados
          </button>

          <button
            onClick={handleProfile}
            className="
      flex
      items-center
      gap-4
      px-5
      py-4
      rounded-2xl
      bg-zinc-900
      hover:bg-zinc-800
      transition
    "
          >
            <Users size={22} />
            Perfil
          </button>

          <button
            onClick={handleSettings}
            className="
      flex
      items-center
      gap-4
      px-5
      py-4
      rounded-2xl
      bg-zinc-900
      hover:bg-zinc-800
      transition
    "
          >
            <Settings size={22} />
            Configuración
          </button>
        </nav>

        <div
          className="
            mt-auto
            bg-zinc-900
            border
            border-zinc-800
            rounded-3xl
            p-5
          "
        >
          <div className="flex items-center gap-3 mb-3">
            <Wifi className="text-green-400" />
            <span className="font-semibold">ESP32 conectado</span>
          </div>

          <p className="text-gray-400 text-sm">
            Sistema funcionando en tiempo real.
          </p>
        </div>
      </aside>

      <main className="flex-1 p-6 md:p-10 overflow-hidden">
        <div
          className="
            flex
            flex-col
            md:flex-row
            md:items-center
            md:justify-between
            gap-6
            mb-10
          "
        >
          <div>
            <h1 className="text-4xl font-bold mb-2">Dashboard</h1>
            <p className="text-gray-400">
              Monitoreo en tiempo real de las carreras.
            </p>
          </div>

          <div className="flex items-center gap-4">
            <button
              className="
                w-14
                h-14
                rounded-2xl
                bg-zinc-900
                border
                border-zinc-800
                flex
                items-center
                justify-center
              "
            >
              <Bell />
            </button>

            <div
              className="
                bg-zinc-900
                border
                border-zinc-800
                rounded-2xl
                px-5
                py-3
                flex
                items-center
                gap-4
              "
            >
              <div
                className="
                  w-12
                  h-12
                  rounded-full
                  bg-red-500
                "
              ></div>

              <div>
                <h2 className="font-semibold">Carlos Quintero</h2>
                <p className="text-gray-400 text-sm">Administrador</p>
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

              <Activity className="text-green-400" />
            </div>

            <h2 className="text-gray-400 mb-2">Mejor tiempo</h2>

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

              <Activity className="text-green-400" />
            </div>

            <h2 className="text-gray-400 mb-2">Competencias activas</h2>

            <p className="text-4xl font-bold">3</p>
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
                <Users className="text-red-500" />
              </div>

              <Activity className="text-green-400" />
            </div>

            <h2 className="text-gray-400 mb-2">Participantes</h2>

            <p className="text-4xl font-bold">48</p>
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
                <Wifi className="text-red-500" />
              </div>

              <Activity className="text-green-400" />
            </div>

            <h2 className="text-gray-400 mb-2">Sensores activos</h2>

            <p className="text-4xl font-bold">2</p>
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
          <div className="flex items-center justify-between mb-6">
            <div>
              <h2 className="text-2xl font-bold mb-1">Carrera en vivo</h2>

              <p className="text-gray-400">
                Datos actualizados en tiempo real.
              </p>
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
              LIVE
            </div>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full min-w-[900px]">
              <thead>
                <tr className="text-left text-gray-400 border-b border-zinc-800">
                  <th className="pb-4">Robot</th>

                  <th className="pb-4">Primer tiempo</th>

                  <th className="pb-4">Segundo tiempo</th>

                  <th className="pb-4">Último tiempo</th>

                  <th className="pb-4">Promedio</th>

                  <th className="pb-4">Estado</th>
                </tr>
              </thead>

              <tbody>
                <tr 
                onClick={handleparticipanteProfile}
                className="border-b border-zinc-800 hover:bg-zinc-800/40 transition">
                  <td className="py-5">
                    <div className="flex items-center gap-4">
                      <div
                        className="
                          w-12
                          h-12
                          rounded-2xl
                          bg-red-500/20
                          flex
                          items-center
                          justify-center
                          font-bold
                          text-red-500
                        "
                      >
                        VX
                      </div>

                      <div>
                        <h2 className="font-semibold">Velocity X</h2>

                        <p className="text-sm text-gray-400">Competidor #01</p>
                      </div>
                    </div>
                  </td>

                  <td className="py-5 font-semibold">2.31s</td>

                  <td className="py-5 font-semibold">2.28s</td>

                  <td className="py-5 font-bold text-green-400">2.19s</td>

                  <td className="py-5">
                    <span
                      className="
                        bg-zinc-800
                        px-4
                        py-2
                        rounded-xl
                        text-sm
                      "
                    >
                      2.26s
                    </span>
                  </td>

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
                      Finalizado
                    </span>
                  </td>
                </tr>

                <tr 
                onClick={handleparticipanteProfile}
                className="hover:bg-zinc-800/40 transition">
                  <td className="py-5">
                    <div className="flex items-center gap-4">
                      <div
                        className="
                          w-12
                          h-12
                          rounded-2xl
                          bg-yellow-500/20
                          flex
                          items-center
                          justify-center
                          font-bold
                          text-yellow-400
                        "
                      >
                        TB
                      </div>

                      <div>
                        <h2 className="font-semibold">Titan Bot</h2>

                        <p className="text-sm text-gray-400">Competidor #02</p>
                      </div>
                    </div>
                  </td>

                  <td className="py-5 font-semibold">2.52s</td>

                  <td className="py-5 font-semibold">2.47s</td>

                  <td className="py-5 font-bold text-yellow-400">
                    Corriendo...
                  </td>

                  <td className="py-5">
                    <span
                      className="
                        bg-zinc-800
                        px-4
                        py-2
                        rounded-xl
                        text-sm
                      "
                    >
                      --
                    </span>
                  </td>

                  <td className="py-5">
                    <span
                      className="
                        bg-yellow-500/20
                        text-yellow-400
                        px-4
                        py-2
                        rounded-xl
                        text-sm
                        font-semibold
                      "
                    >
                      En progreso
                    </span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </main>
    </motion.div>
  );
}

export default Dashboard;
