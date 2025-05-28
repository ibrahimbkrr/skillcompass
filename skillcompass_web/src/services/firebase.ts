import { initializeApp } from "firebase/app";
import { getAuth } from "firebase/auth";
import { getFirestore } from "firebase/firestore";
import { getAnalytics } from "firebase/analytics";

const firebaseConfig = {
  apiKey: "AIzaSyCMhxlJ_0ncIMfWenEeSSv70fFF72GoW7s",
  authDomain: "skillcompass-project.firebaseapp.com",
  projectId: "skillcompass-project",
  storageBucket: "skillcompass-project.firebasestorage.app",
  messagingSenderId: "758428088032",
  appId: "1:758428088032:web:c43266f04bfeb71a074285",
  measurementId: "G-9X0W0DFV5Y"
};

const app = initializeApp(firebaseConfig);

export const auth = getAuth(app);
export const db = getFirestore(app);
export const analytics = getAnalytics(app);