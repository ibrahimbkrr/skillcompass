import React, { useEffect, useState } from 'react';
import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';
import Grid from '@mui/material/Grid';
import Paper from '@mui/material/Paper';
import IconButton from '@mui/material/IconButton';
import AppBar from '@mui/material/AppBar';
import Toolbar from '@mui/material/Toolbar';
import Avatar from '@mui/material/Avatar';
import LogoutIcon from '@mui/icons-material/Logout';
import LightModeIcon from '@mui/icons-material/LightMode';
import DarkModeIcon from '@mui/icons-material/DarkMode';
import PersonIcon from '@mui/icons-material/Person';
import CodeIcon from '@mui/icons-material/Code';
import SchoolIcon from '@mui/icons-material/School';
import WorkIcon from '@mui/icons-material/Work';
import RocketLaunchIcon from '@mui/icons-material/RocketLaunch';
import ConnectWithoutContactIcon from '@mui/icons-material/ConnectWithoutContact';
import PersonPinIcon from '@mui/icons-material/PersonPin';
import BarChartIcon from '@mui/icons-material/BarChart';
import { useAuth } from '../contexts/AuthContext';
import { useThemeMode } from '../contexts/ThemeContext';
import { db } from '../services/firebase';
import { doc, getDoc } from 'firebase/firestore';
import { useNavigate } from 'react-router-dom';

const profileSections = [
  { title: 'Kimlik Durumu', icon: <PersonIcon fontSize="large" />, color: '#1976d2', route: '/identity' },
  { title: 'Teknik Profil', icon: <CodeIcon fontSize="large" />, color: '#388e3c', route: '/technical' },
  { title: 'Öğrenme Stili', icon: <SchoolIcon fontSize="large" />, color: '#f57c00', route: '/learning' },
  { title: 'Kariyer Vizyonu', icon: <WorkIcon fontSize="large" />, color: '#7b1fa2', route: '/career' },
  { title: 'Proje Deneyimleri', icon: <RocketLaunchIcon fontSize="large" />, color: '#ffb300', route: '/projects' },
  { title: 'Networking', icon: <ConnectWithoutContactIcon fontSize="large" />, color: '#3949ab', route: '/networking' },
  { title: 'Kişisel Marka', icon: <PersonPinIcon fontSize="large" />, color: '#512da8', route: '/brand' },
  { title: 'Analiz Et', icon: <BarChartIcon fontSize="large" />, color: '#d32f2f', route: '/analysis' },
];

const Dashboard: React.FC<{ onToggleTheme?: () => void }> = ({ onToggleTheme }) => {
  const { user, logout } = useAuth();
  const { mode } = useThemeMode();
  const [fullName, setFullName] = useState<string | null>(null);
  const navigate = useNavigate();

  useEffect(() => {
    const fetchName = async () => {
      if (user?.uid) {
        const userDoc = await getDoc(doc(db, 'users', user.uid));
        if (userDoc.exists()) {
          const data = userDoc.data();
          setFullName(`${data.firstName || ''} ${data.lastName || ''}`.trim());
        }
      }
    };
    fetchName();
  }, [user]);

  return (
    <Box sx={{ minHeight: '100vh', background: 'linear-gradient(135deg, #B2FEFA 0%, #0ED2F7 100%)' }}>
      <AppBar position="static" color="transparent" elevation={0} sx={{ background: 'transparent' }}>
        <Toolbar>
          <Typography variant="h6" sx={{ flexGrow: 1, fontWeight: 700, color: '#222' }}>
            SkillCompass
          </Typography>
          <IconButton color="inherit" onClick={onToggleTheme}>
            {mode === 'dark' ? <LightModeIcon /> : <DarkModeIcon />}
          </IconButton>
          <IconButton color="inherit" onClick={logout} sx={{ ml: 1 }}>
            <LogoutIcon />
          </IconButton>
        </Toolbar>
      </AppBar>
      <Box sx={{ maxWidth: 1100, mx: 'auto', py: 6, px: 2 }}>
        <Paper elevation={4} sx={{ p: 4, borderRadius: 4, mb: 4, background: 'rgba(255,255,255,0.95)' }}>
          <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
            <Avatar sx={{ bgcolor: 'primary.main', width: 56, height: 56, mr: 2 }}>
              {fullName ? fullName[0]?.toUpperCase() : (user?.email?.[0]?.toUpperCase() || '?')}
            </Avatar>
            <Box>
              <Typography variant="h5" fontWeight={700} color="primary.main">
                Hoş Geldiniz!
              </Typography>
              <Typography variant="subtitle1" color="text.secondary">
                {fullName || user?.email}
              </Typography>
            </Box>
          </Box>
          <Typography variant="body1" color="text.secondary">
            Yeteneklerinizi keşfetmeye ve geliştirmeye devam edin!
          </Typography>
        </Paper>
        <Grid container spacing={3}>
          {profileSections.map((section) => (
            <Grid item xs={12} sm={6} md={3} key={section.title}>
              <Paper
                elevation={3}
                sx={{
                  p: 3,
                  borderRadius: 3,
                  display: 'flex',
                  flexDirection: 'column',
                  alignItems: 'center',
                  cursor: 'pointer',
                  background: section.color,
                  color: '#fff',
                  transition: 'transform 0.15s',
                  '&:hover': { transform: 'scale(1.05)', boxShadow: 6 },
                }}
                onClick={() => navigate(section.route)}
              >
                {section.icon}
                <Typography variant="subtitle1" fontWeight={600} sx={{ mt: 2, textAlign: 'center' }}>
                  {section.title}
                </Typography>
              </Paper>
            </Grid>
          ))}
        </Grid>
      </Box>
    </Box>
  );
};

export default Dashboard; 