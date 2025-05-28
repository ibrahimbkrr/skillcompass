import React, { ReactElement } from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import Login from './pages/Login';
import Register from './pages/Register';
import Dashboard from './pages/Dashboard';
import IdentityStatus from './pages/IdentityStatus';
import TechnicalProfile from './pages/TechnicalProfile';
import LearningStyle from './pages/LearningStyle';
import CareerVision from './pages/CareerVision';
import ProjectExperiences from './pages/ProjectExperiences';
import Networking from './pages/Networking';
import PersonalBrand from './pages/PersonalBrand';
import Analysis from './pages/Analysis';
import { AuthProvider, useAuth } from './contexts/AuthContext';
import { ThemeProvider, useThemeMode } from './contexts/ThemeContext';

function PrivateRoute({ children }: { children: ReactElement }) {
  const { user, loading } = useAuth();
  if (loading) return <div>Yükleniyor...</div>;
  return user ? children : <Navigate to="/login" replace />;
}

function AppRoutes() {
  const { toggleTheme } = useThemeMode();
  return (
    <Router>
      <Routes>
        <Route path="/login" element={<Login />} />
        <Route path="/register" element={<Register />} />
        <Route path="/dashboard" element={<PrivateRoute><Dashboard onToggleTheme={toggleTheme} /></PrivateRoute>} />
        <Route path="/identity" element={<PrivateRoute><IdentityStatus /></PrivateRoute>} />
        <Route path="/technical" element={<PrivateRoute><TechnicalProfile /></PrivateRoute>} />
        <Route path="/learning" element={<PrivateRoute><LearningStyle /></PrivateRoute>} />
        <Route path="/career" element={<PrivateRoute><CareerVision /></PrivateRoute>} />
        <Route path="/projects" element={<PrivateRoute><ProjectExperiences /></PrivateRoute>} />
        <Route path="/networking" element={<PrivateRoute><Networking /></PrivateRoute>} />
        <Route path="/brand" element={<PrivateRoute><PersonalBrand /></PrivateRoute>} />
        <Route path="/analysis" element={<PrivateRoute><Analysis /></PrivateRoute>} />
        <Route path="*" element={<Navigate to="/login" replace />} />
      </Routes>
    </Router>
  );
}

function App() {
  return (
    <ThemeProvider>
      <AuthProvider>
        <AppRoutes />
      </AuthProvider>
    </ThemeProvider>
  );
}

export default App;
