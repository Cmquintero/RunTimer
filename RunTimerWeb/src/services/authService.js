import {
  createUserWithEmailAndPassword,
  signInWithEmailAndPassword,
  signInWithPopup,
  signOut,
} from "firebase/auth";

import {
  doc,
  setDoc,
  collection,    // <-- Agregado para las carreras
  addDoc,        // <-- Agregado para las carreras
  serverTimestamp,
} from "firebase/firestore";

import {
  auth,
  db,
  googleProvider,
} from "../firebase/firebase";

// EXPORTS DIRECTOS
export { auth, db, googleProvider };

// ==========================================
// SERVICIOS DE AUTENTICACIÓN
// ==========================================

export const registerUser = async (
  email,
  password,
  nombre
) => {
  const response =
    await createUserWithEmailAndPassword(
      auth,
      email,
      password
    );

  const user = response.user;

  await setDoc(
    doc(db, "users", user.uid),
    {
      uid: user.uid,
      email: user.email,
      nombre,
      role: "user",
      fcmToken: "",
      photoUrl: user.photoURL || "",
      creadoEn: serverTimestamp(),
    }
  );

  return user;
};

export const loginUser = async (
  email,
  password
) => {
  const response =
    await signInWithEmailAndPassword(
      auth,
      email,
      password
    );

  return response.user;
};

export const loginWithGoogle =
  async () => {
    const response =
      await signInWithPopup(
        auth,
        googleProvider
      );

    const user = response.user;

    await setDoc(
      doc(db, "users", user.uid),
      {
        uid: user.uid,
        email: user.email,
        nombre:
          user.displayName ||
          "Usuario",
        role: "user",
        fcmToken: "",
        photoUrl:
          user.photoURL || "",
        creadoEn:
          serverTimestamp(),
      },
      { merge: true }
    );

    return user;
  };

export const logoutUser =
  async () => {
    await signOut(auth);
  };


// ==========================================
// SERVICIOS DE CARRERAS (HISTORIAL)
// ==========================================

/**
 * Guarda el resultado de una carrera en la colección "resultados" vinculada al usuario
 * @param {number|string} time - Tiempo final registrado (ej: 14.25)
 * @param {number|string} position - Puesto final (ej: 1 o "2")
 * @param {string} competition - Nombre de la carrera o pista
 */
export const saveRaceResult = async (time, position, competition) => {
  const user = auth.currentUser;
  
  if (!user) {
    throw new Error("No hay un usuario autenticado para registrar la carrera.");
  }

  try {
    const resultadosRef = collection(db, "resultados");
    
    const nuevoResultado = {
      userId: user.uid,
      competition: competition || "Carrera Rápida",
      time: parseFloat(time), // Guardar como número para que Profile calcule el 'bestTime'
      position: `${position}°`, // Estandariza el formato con el símbolo de grado
      date: serverTimestamp() // Sella la fecha exacta del servidor de Firebase
    };

    const docRef = await addDoc(resultadosRef, nuevoResultado);
    return docRef.id;
  } catch (error) {
    console.error("Error al guardar el resultado de carrera:", error);
    throw error;
  }
};