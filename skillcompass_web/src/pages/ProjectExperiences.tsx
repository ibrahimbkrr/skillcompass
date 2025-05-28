import React, { useState } from 'react';
import { Box, Paper, Typography, AppBar, Toolbar, IconButton, Stepper, Step, StepLabel, Snackbar, Button, LinearProgress, Container, Alert, CircularProgress } from '@mui/material';
import LightModeIcon from '@mui/icons-material/LightMode';
import DarkModeIcon from '@mui/icons-material/DarkMode';
import LogoutIcon from '@mui/icons-material/Logout';
import RocketLaunchIcon from '@mui/icons-material/RocketLaunch';
import { useThemeMode } from '../contexts/ThemeContext';
import { useAuth } from '../contexts/AuthContext';
import { useNavigate } from 'react-router-dom';
import PastProjectsCard from './ProjectExperiences/PastProjectsCard';
import TechnologiesCard from './ProjectExperiences/TechnologiesCard';
import FutureGoalCard from './ProjectExperiences/FutureGoalCard';
import ChallengesCard from './ProjectExperiences/ChallengesCard';
import { doc, setDoc } from 'firebase/firestore';
import { db } from '../services/firebase';

const PROFILE_STEPS = [
  'Kimlik',
  'Teknik',
  'Öğrenme',
  'Vizyon',
  'Projeler',
  'Networking',
  'Marka',
];

const MAIN_BLUE = '#2A4B7C';
const ACCENT_CORAL = '#FF6B6B';
const GOLD = '#D4A017';
const BG_GRADIENT = 'linear-gradient(180deg, #F8FAFC 0%, #E6EAF0 100%)';
const TOTAL_STEPS = 4;

const PAST_INSPIRE = [
  'Bir makine öğrenimi modelini Python ile geliştirdim.',
  'Bir mobil uygulama yayınladım.',
  'Bir web platformunda React ile çalıştım.',
  'Açık kaynak bir projeye katkı sağladım.',
];
const FUTURE_INSPIRE = [
  'Bir mobil oyun geliştirmek ve yayınlamak.',
  'Bir web projesi başlatmak.',
  'Bir IoT cihazı için yazılım geliştirmek.',
  'Veri analizi projesi tamamlamak.',
];
const CHALLENGES_INSPIRE = [
  'Zaman yönetimi.',
  'Kaynak eksikliği.',
  'Teknik karmaşıklık.',
  'Ekip çalışması.',
];

const ProjectExperiences: React.FC = () => {
  const { mode, toggleTheme } = useThemeMode();
  const { logout, user } = useAuth();
  const navigate = useNavigate();

  // State for each card
  const [pastProjects, setPastProjects] = useState('');
  const [technologies, setTechnologies] = useState<string[]>([]);
  const [futureGoal, setFutureGoal] = useState('');
  const [challenges, setChallenges] = useState('');

  // Validation
  const [errorPast, setErrorPast] = useState<string | undefined>();
  const [errorTech, setErrorTech] = useState<string | undefined>();
  const [errorFuture, setErrorFuture] = useState<string | undefined>();
  const [errorChallenges, setErrorChallenges] = useState<string | undefined>();

  // Snackbar
  const [snackbarOpen, setSnackbarOpen] = useState(false);
  const [saving, setSaving] = useState(false);

  // Inspiration state
  const [showPastInspire, setShowPastInspire] = useState(false);
  const [pastInspireText, setPastInspireText] = useState('');
  const [showFutureInspire, setShowFutureInspire] = useState(false);
  const [futureInspireText, setFutureInspireText] = useState('');
  const [showChallengesInspire, setShowChallengesInspire] = useState(false);
  const [challengesInspireText, setChallengesInspireText] = useState('');

  // Progress calculation
  const completedCount = [
    pastProjects.trim().length > 0,
    technologies.length > 0,
    futureGoal.trim().length > 0,
    challenges.trim().length > 0,
  ].filter(Boolean).length;
  const progressValue = completedCount / TOTAL_STEPS;
  const isFormValid = pastProjects.trim() && technologies.length > 0 && futureGoal.trim() && challenges.trim();

  // Save handler
  const handleSave = async () => {
    if (!user) {
      setErrorPast('Kullanıcı oturumu bulunamadı. Lütfen tekrar giriş yapın.');
      return;
    }
    let valid = true;
    setErrorPast(undefined);
    setErrorTech(undefined);
    setErrorFuture(undefined);
    setErrorChallenges(undefined);
    if (!pastProjects.trim()) {
      setErrorPast('Bu alan zorunludur.');
      valid = false;
    }
    if (technologies.length === 0) {
      setErrorTech('En az bir teknoloji seçmelisiniz.');
      valid = false;
    }
    if (!futureGoal.trim()) {
      setErrorFuture('Bu alan zorunludur.');
      valid = false;
    }
    if (!challenges.trim()) {
      setErrorChallenges('Bu alan zorunludur.');
      valid = false;
    }
    if (!valid) return;
    setSaving(true);
    setSnackbarOpen(true);
    setTimeout(() => {
      setSnackbarOpen(false);
      setSaving(false);
      navigate('/networking');
    }, 2000);
    try {
      await setDoc(doc(db, 'users', user!.uid, 'profile_data', 'project-experience'), {
        pastProjects: pastProjects.trim(),
        technologies,
        futureGoal: futureGoal.trim(),
        challenges: challenges.trim(),
      });
    } catch (error) {
      console.error('Error saving project experience:', error);
    }
  };

  // Inspiration handlers
  const handlePastInspire = () => {
    setPastInspireText(PAST_INSPIRE[Math.floor(Math.random() * PAST_INSPIRE.length)]);
    setShowPastInspire(true);
    setTimeout(() => setShowPastInspire(false), 4000);
  };
  const handleFutureInspire = () => {
    setFutureInspireText(FUTURE_INSPIRE[Math.floor(Math.random() * FUTURE_INSPIRE.length)]);
    setShowFutureInspire(true);
    setTimeout(() => setShowFutureInspire(false), 4000);
  };
  const handleChallengesInspire = () => {
    setChallengesInspireText(CHALLENGES_INSPIRE[Math.floor(Math.random() * CHALLENGES_INSPIRE.length)]);
    setShowChallengesInspire(true);
    setTimeout(() => setShowChallengesInspire(false), 4000);
  };

  return (
    <Box minHeight="100vh" sx={{ background: BG_GRADIENT }}>
      <AppBar position="static" color="transparent" elevation={0} sx={{ background: 'transparent' }}>
        <Toolbar>
          <Typography variant="h6" sx={{ flexGrow: 1, fontWeight: 700, color: mode === 'dark' ? '#fff' : MAIN_BLUE }}>
            Proje Deneyimleri
          </Typography>
          <IconButton color="inherit" onClick={toggleTheme}>
            {mode === 'dark' ? <LightModeIcon /> : <DarkModeIcon />}
          </IconButton>
          <IconButton color="inherit" onClick={logout} sx={{ ml: 1 }}>
            <LogoutIcon />
          </IconButton>
        </Toolbar>
      </AppBar>
      {/* Sayfa başlığı */}
      <Box sx={{ maxWidth: 600, mx: 'auto', mt: 4, mb: 2, px: 2 }}>
        <Typography variant="h4" fontWeight={800} color="primary.main" gutterBottom sx={{ letterSpacing: 0.5, textAlign: 'center' }}>
          Proje Deneyimleri
        </Typography>
      </Box>
      {/* Sayfa ilerleme Stepper'ı */}
      <Box sx={{ maxWidth: 600, mx: 'auto', mb: 3, px: 2 }}>
        <Stepper activeStep={4} alternativeLabel>
          {PROFILE_STEPS.map((label) => (
            <Step key={label}>
              <StepLabel>{label}</StepLabel>
            </Step>
          ))}
        </Stepper>
      </Box>
      {/* Açıklama ve alt başlık kartı */}
      <Box sx={{ maxWidth: 600, mx: 'auto', mb: 3, px: 2 }}>
        <Paper elevation={4} sx={{ p: { xs: 2, sm: 3 }, borderRadius: 3, background: mode === 'dark' ? 'rgba(35,39,47,0.93)' : 'rgba(255,255,255,0.93)', boxShadow: '0 4px 24px rgba(0,0,0,0.07)' }}>
          <Typography variant="body1" color="text.secondary" sx={{ fontSize: { xs: 16, sm: 18 }, mb: 1, fontWeight: 500, textAlign: 'center' }}>
            Geçmiş projelerinizi, kullandığınız teknolojileri ve karşılaştığınız zorlukları paylaşın.
          </Typography>
          <Typography variant="subtitle1" color="primary" sx={{ fontStyle: 'italic', fontWeight: 600, fontSize: { xs: 15, sm: 17 }, textAlign: 'center' }}>
            Deneyimlerinizi paylaşarak teknik yolculuğunuzu güçlendirin!
          </Typography>
        </Paper>
      </Box>
      <Container maxWidth="sm" sx={{ pb: 6 }}>
        <Paper elevation={0} sx={{ p: 2, mb: 2, background: 'transparent' }}>
          <Box mb={2}>
            <LinearProgress
              variant="determinate"
              value={progressValue * 100}
              sx={{ height: 8, borderRadius: 4, background: '#E6EAF0', '& .MuiLinearProgress-bar': { background: MAIN_BLUE } }}
            />
            <Box display="flex" justifyContent="space-between" alignItems="center" mt={0.5}>
              <Typography variant="caption" color={MAIN_BLUE} fontWeight={600}>
                {completedCount}/{TOTAL_STEPS} Adım
              </Typography>
              <Typography variant="caption" color={ACCENT_CORAL} fontWeight={600}>
                % {Math.round(progressValue * 100)} tamamlandı
              </Typography>
            </Box>
          </Box>
          <PastProjectsCard
            value={pastProjects}
            onChange={setPastProjects}
            error={errorPast}
            completed={!!pastProjects.trim()}
            showInspire={showPastInspire}
            inspireText={pastInspireText}
            onInspire={handlePastInspire}
          />
          <TechnologiesCard
            values={technologies}
            onChange={setTechnologies}
            error={errorTech}
            completed={technologies.length > 0}
          />
          <FutureGoalCard
            value={futureGoal}
            onChange={setFutureGoal}
            error={errorFuture}
            completed={!!futureGoal.trim()}
            showInspire={showFutureInspire}
            inspireText={futureInspireText}
            onInspire={handleFutureInspire}
          />
          <ChallengesCard
            value={challenges}
            onChange={setChallenges}
            error={errorChallenges}
            completed={!!challenges.trim()}
            showInspire={showChallengesInspire}
            inspireText={challengesInspireText}
            onInspire={handleChallengesInspire}
          />
          <Button
            fullWidth
            variant="contained"
            size="large"
            sx={{ mt: 2, background: isFormValid ? ACCENT_CORAL : '#A0AEC0', color: '#fff', fontWeight: 700, borderRadius: 2, boxShadow: 'none' }}
            onClick={handleSave}
            disabled={!isFormValid || saving}
          >
            {saving ? <CircularProgress size={24} color="inherit" /> : 'Kaydet ve İlerle'}
          </Button>
          <Typography variant="body2" color="#6B7280" align="center" mt={1}>
            Deneyimlerinizi paylaşarak teknik yolculuğunuzu güçlendirin.
          </Typography>
        </Paper>
      </Container>
      <Snackbar
        open={snackbarOpen}
        autoHideDuration={2000}
        onClose={() => setSnackbarOpen(false)}
        anchorOrigin={{ vertical: 'top', horizontal: 'center' }}
      >
        <Alert severity="success" sx={{ width: '100%' }}>
          Kaydedildi, Networking sayfasına yönlendiriliyor...
        </Alert>
      </Snackbar>
    </Box>
  );
};

export default ProjectExperiences; 