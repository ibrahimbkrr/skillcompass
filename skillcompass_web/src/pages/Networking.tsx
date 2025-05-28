import React, { useState } from 'react';
import { Box, Paper, Typography, AppBar, Toolbar, IconButton, Stepper, Step, StepLabel, Snackbar, Button, LinearProgress, Container, Alert, CircularProgress } from '@mui/material';
import LightModeIcon from '@mui/icons-material/LightMode';
import DarkModeIcon from '@mui/icons-material/DarkMode';
import LogoutIcon from '@mui/icons-material/Logout';
import { useThemeMode } from '../contexts/ThemeContext';
import { useAuth } from '../contexts/AuthContext';
import { useNavigate } from 'react-router-dom';
import MentorshipNeedCard from './Networking/MentorshipNeedCard';
import CurrentConnectionsCard from './Networking/CurrentConnectionsCard';
import NetworkingGoalCard from './Networking/NetworkingGoalCard';
import NetworkingChallengesCard from './Networking/NetworkingChallengesCard';
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

const GOAL_INSPIRE = [
  'Bir açık kaynak projesinde 5 geliştiriciyle bağlantı kurmak.',
  'Bir bilişim konferansında 10 yeni bağlantı kurmak.',
  'LinkedIn üzerinden 20 yeni profesyonel bağlantı eklemek.',
  'Bir topluluk etkinliğinde liderlik yapmak.',
];
const CHALLENGES_INSPIRE = [
  'Zaman eksikliği nedeniyle etkinliklere katılamamak.',
  'Çekingenlik ve yeni insanlarla iletişimde zorluk.',
  'Dil bariyeri veya teknik terimlerde yetersizlik.',
  'Profesyonel platformları etkin kullanamamak.',
];

const Networking: React.FC = () => {
  const { mode, toggleTheme } = useThemeMode();
  const { logout, user } = useAuth();
  const navigate = useNavigate();

  // State for each card
  const [mentorshipNeed, setMentorshipNeed] = useState('');
  const [connections, setConnections] = useState<string[]>([]);
  const [goal, setGoal] = useState('');
  const [challenges, setChallenges] = useState('');

  // Validation
  const [errorMentorship, setErrorMentorship] = useState<string | undefined>();
  const [errorConnections, setErrorConnections] = useState<string | undefined>();
  const [errorGoal, setErrorGoal] = useState<string | undefined>();
  const [errorChallenges, setErrorChallenges] = useState<string | undefined>();

  // Snackbar
  const [snackbarOpen, setSnackbarOpen] = useState(false);
  const [saving, setSaving] = useState(false);

  // Inspiration state
  const [showGoalInspire, setShowGoalInspire] = useState(false);
  const [goalInspireText, setGoalInspireText] = useState('');
  const [showChallengesInspire, setShowChallengesInspire] = useState(false);
  const [challengesInspireText, setChallengesInspireText] = useState('');

  // Progress calculation
  const completedCount = [
    mentorshipNeed.trim().length > 0,
    connections.length > 0,
    goal.trim().length >= 10,
    challenges.trim().length >= 10,
  ].filter(Boolean).length;
  const progressValue = completedCount / TOTAL_STEPS;
  const isFormValid = mentorshipNeed.trim() && connections.length > 0 && goal.trim().length >= 10 && challenges.trim().length >= 10;

  // Save handler
  const handleSave = async () => {
    if (!user) {
      setErrorMentorship('Kullanıcı oturumu bulunamadı. Lütfen tekrar giriş yapın.');
      return;
    }
    let valid = true;
    setErrorMentorship(undefined);
    setErrorConnections(undefined);
    setErrorGoal(undefined);
    setErrorChallenges(undefined);
    if (!mentorshipNeed.trim()) {
      setErrorMentorship('Bu alan zorunludur.');
      valid = false;
    }
    if (connections.length === 0) {
      setErrorConnections('En az bir bağlantı seçmelisiniz.');
      valid = false;
    }
    if (goal.trim().length < 10) {
      setErrorGoal('En az 10 karakter giriniz.');
      valid = false;
    }
    if (challenges.trim().length < 10) {
      setErrorChallenges('En az 10 karakter giriniz.');
      valid = false;
    }
    if (!valid) return;
    setSaving(true);
    setSnackbarOpen(true);
    setTimeout(() => {
      setSnackbarOpen(false);
      setSaving(false);
      navigate('/brand');
    }, 2000);
    try {
      await setDoc(doc(db, 'users', user!.uid, 'profile_data', 'networking'), {
        mentorshipNeed: mentorshipNeed.trim(),
        connections,
        goal: goal.trim(),
        challenges: challenges.trim(),
      });
    } catch (error) {
      console.error('Hata:', error);
    }
  };

  // Inspiration handlers
  const handleGoalInspire = () => {
    setGoalInspireText(GOAL_INSPIRE[Math.floor(Math.random() * GOAL_INSPIRE.length)]);
    setShowGoalInspire(true);
    setTimeout(() => setShowGoalInspire(false), 4000);
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
            Networking
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
          Networking
        </Typography>
      </Box>
      {/* Sayfa ilerleme Stepper'ı */}
      <Box sx={{ maxWidth: 600, mx: 'auto', mb: 3, px: 2 }}>
        <Stepper activeStep={5} alternativeLabel>
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
            Mentorluk ihtiyaçlarınızı, mevcut bağlantılarınızı ve networking hedeflerinizi paylaşın.
          </Typography>
          <Typography variant="subtitle1" color="primary" sx={{ fontStyle: 'italic', fontWeight: 600, fontSize: { xs: 15, sm: 17 }, textAlign: 'center' }}>
            Doğru bağlantılarla kariyerinizi bir üst seviyeye taşıyın!
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
          <MentorshipNeedCard
            value={mentorshipNeed}
            onChange={setMentorshipNeed}
            error={errorMentorship}
            completed={!!mentorshipNeed.trim()}
          />
          <CurrentConnectionsCard
            values={connections}
            onChange={setConnections}
            error={errorConnections}
            completed={connections.length > 0}
          />
          <NetworkingGoalCard
            value={goal}
            onChange={setGoal}
            error={errorGoal}
            completed={goal.trim().length >= 10}
            showInspire={showGoalInspire}
            inspireText={goalInspireText}
            onInspire={handleGoalInspire}
          />
          <NetworkingChallengesCard
            value={challenges}
            onChange={setChallenges}
            error={errorChallenges}
            completed={challenges.trim().length >= 10}
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
            Networking hedeflerinizi paylaşarak profesyonel yolculuğunuzu güçlendirin.
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
          Kaydedildi, Kişisel Marka sayfasına yönlendiriliyor...
        </Alert>
      </Snackbar>
    </Box>
  );
};

export default Networking; 