import { motion } from "framer-motion";

import {
  User,
  Moon,
  Bell,
  Shield,
  LogOut,
  Info,
  ChevronRight,
} from "lucide-react";

function Settings() {

  return (

    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      transition={{ duration: 0.4 }}
      className="min-h-screen bg-black text-white p-6 md:p-10"
    >

      <div className="mb-10">

        <h1 className="text-4xl font-bold mb-3">
          Configuración
        </h1>

        <p className="text-gray-400 text-lg">
          Personaliza tu experiencia dentro de RunTimer.
        </p>

      </div>

      <div
        className="
          bg-zinc-900
          border
          border-zinc-800
          rounded-3xl
          p-6
          mb-8
        "
      >

        <div className="flex items-center gap-4 mb-8">

          <div
            className="
              w-20
              h-20
              rounded-full
              bg-red-500
            "
          ></div>

          <div>

            <h2 className="text-2xl font-bold">
              Carlos Quintero
            </h2>

            <p className="text-gray-400">
              carlos@email.com
            </p>

          </div>

        </div>

        <button
          className="
            bg-red-500
            hover:bg-red-600
            transition
            px-6
            py-3
            rounded-2xl
            font-semibold
          "
        >
          Editar perfil
        </button>

      </div>


      <div className="space-y-5">

        <div
          className="
            bg-zinc-900
            border
            border-zinc-800
            rounded-3xl
            p-6
          "
        >

          <div className="flex items-center justify-between">

            <div className="flex items-center gap-4">

              <div
                className="
                  w-14
                  h-14
                  rounded-2xl
                  bg-zinc-800
                  flex
                  items-center
                  justify-center
                "
              >

                <Moon className="text-red-500" />

              </div>

              <div>

                <h2 className="font-semibold text-lg">
                  Apariencia
                </h2>

                <p className="text-gray-400 text-sm">
                  Tema oscuro activado
                </p>

              </div>

            </div>

            <ChevronRight className="text-gray-500" />

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

          <div className="flex items-center justify-between">

            <div className="flex items-center gap-4">

              <div
                className="
                  w-14
                  h-14
                  rounded-2xl
                  bg-zinc-800
                  flex
                  items-center
                  justify-center
                "
              >

                <Bell className="text-red-500" />

              </div>

              <div>

                <h2 className="font-semibold text-lg">
                  Notificaciones
                </h2>

                <p className="text-gray-400 text-sm">
                  Alertas y actualizaciones
                </p>

              </div>

            </div>

            <ChevronRight className="text-gray-500" />

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

          <div className="flex items-center justify-between">

            <div className="flex items-center gap-4">

              <div
                className="
                  w-14
                  h-14
                  rounded-2xl
                  bg-zinc-800
                  flex
                  items-center
                  justify-center
                "
              >

                <Shield className="text-red-500" />

              </div>

              <div>

                <h2 className="font-semibold text-lg">
                  Seguridad
                </h2>

                <p className="text-gray-400 text-sm">
                  Contraseña y acceso
                </p>

              </div>

            </div>

            <ChevronRight className="text-gray-500" />

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

          <div className="flex items-center justify-between">

            <div className="flex items-center gap-4">

              <div
                className="
                  w-14
                  h-14
                  rounded-2xl
                  bg-zinc-800
                  flex
                  items-center
                  justify-center
                "
              >

                <User className="text-red-500" />

              </div>

              <div>

                <h2 className="font-semibold text-lg">
                  Cuenta
                </h2>

                <p className="text-gray-400 text-sm">
                  Información personal
                </p>

              </div>

            </div>

            <ChevronRight className="text-gray-500" />

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

          <div className="flex items-center justify-between">

            <div className="flex items-center gap-4">

              <div
                className="
                  w-14
                  h-14
                  rounded-2xl
                  bg-zinc-800
                  flex
                  items-center
                  justify-center
                "
              >

                <Info className="text-red-500" />

              </div>

              <div>

                <h2 className="font-semibold text-lg">
                  Información
                </h2>

                <p className="text-gray-400 text-sm">
                  RunTimer v3.0
                </p>

              </div>

            </div>

            <ChevronRight className="text-gray-500" />

          </div>

        </div>
        <button
          className="
            w-full
            bg-red-500/20
            hover:bg-red-500/30
            transition
            border
            border-red-500/20
            rounded-3xl
            p-6
            flex
            items-center
            justify-center
            gap-4
            text-red-400
            font-semibold
            text-lg
          "
        >

          <LogOut />

          Cerrar sesión

        </button>

      </div>

    </motion.div>
  );
}

export default Settings;