import React, { useState } from 'react';
import { Box, Paper, Typography, AppBar, Toolbar, IconButton, Stepper, Step, StepLabel, Snackbar, Button, LinearProgress, Container, Alert, CircularProgress } from '@mui/material';
import LightModeIcon from '@mui/icons-material/LightMode';
import DarkModeIcon from '@mui/icons-material/DarkMode';
import LogoutIcon from '@mui/icons-material/Logout';
import FlagIcon from '@mui/icons-material/Flag';
import { useThemeMode } from '../contexts/ThemeContext';
import { useAuth } from '../contexts/AuthContext';
import { useNavigate } from 'react-router-dom';
import ShortTermGoalCard from './CareerVision/ShortTermGoalCard';
import LongTermGoalCard from './CareerVision/LongTermGoalCard';
import PrioritiesCard from './CareerVision/PrioritiesCard';
import ProgressSliderCard from './CareerVision/ProgressSliderCard';
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
const SHORT_TERM_INSPIRE = [
  'Veri analizi projelerinde lider bir analist.',
  'Bir açık kaynak projesine katkıda bulunan geliştirici.',
  'UI/UX tasarımıyla bir ürünün kullanıcı deneyimini iyileştiren tasarımcı.',
  'Flutter ile 2 mobil uygulama yayınlamış bir geliştirici.'
];
const LONG_TERM_INSPIRE = [
  'Yapay zeka projelerinde küresel çapta tanınan bir mühendis.',
  'Kendi mobil uygulamasını milyonlarca kullanıcıya ulaştıran bir girişimci.',
  'Siber güvenlikte bir ekibi yöneten uzman.',
  "Bir teknoloji startup'ında teknik lider."
];

const CareerVision: React.FC = () => {
  const { mode, toggleTheme } = useThemeMode();
  const { logout, user } = useAuth();
  const navigate = useNavigate();

  // State for each card
  const [shortTerm, setShortTerm] = useState('');
  const [longTerm, setLongTerm] = useState('');
  const [priorities, setPriorities] = useState<string[]>([]);
  const [progress, setProgress] = useState(50);

  // Validation
  const [errorShort, setErrorShort] = useState<string | undefined>();
  const [errorLong, setErrorLong] = useState<string | undefined>();
  const [errorPriorities, setErrorPriorities] = useState<string | undefined>();

  // Snackbar
  const [snackbarOpen, setSnackbarOpen] = useState(false);
  const [saving, setSaving] = useState(false);

  // Inspiration state
  const [showShortInspire, setShowShortInspire] = useState(false);
  const [shortInspireText, setShortInspireText] = useState('');
  const [showLongInspire, setShowLongInspire] = useState(false);
  const [longInspireText, setLongInspireText] = useState('');

  // Progress calculation
  const completedCount = [
    shortTerm.trim().length > 0,
    longTerm.trim().length > 0,
    priorities.length > 0,
    true // progress slider always counts as completed
  ].filter(Boolean).length;
  const progressValue = completedCount / TOTAL_STEPS;
  const isFormValid = shortTerm.trim() && longTerm.trim() && priorities.length > 0;

  // Save handler
  const handleSave = async () => {
    if (!user) {
      setErrorShort('Kullanıcı oturumu bulunamadı. Lütfen tekrar giriş yapın.');
      return;
    }
    let valid = true;
    setErrorShort(undefined);
    setErrorLong(undefined);
    setErrorPriorities(undefined);
    if (!shortTerm.trim()) {
      setErrorShort('Bu alan zorunludur.');
      valid = false;
    }
    if (!longTerm.trim()) {
      setErrorLong('Bu alan zorunludur.');
      valid = false;
    }
    if (priorities.length === 0) {
      setErrorPriorities('En az bir öncelik seçmelisiniz.');
      valid = false;
    }
    if (!valid) return;
    setSaving(true);
    setSnackbarOpen(true);
    setTimeout(() => {
      setSnackbarOpen(false);
      setSaving(false);
      navigate('/projects');
    }, 2000);
    try {
      await setDoc(doc(db, 'users', user!.uid, 'profile_data', 'career-vision'), {
        shortTerm: shortTerm.trim(),
        longTerm: longTerm.trim(),
        priorities,
        progress,
        showShortInspire,
        shortInspireText,
        showLongInspire,
        longInspireText,
      });
    } catch (error) {
      console.error('Error saving career vision data:', error);
    }
  };

  // Inspiration handlers
  const handleShortInspire = () => {
    setShortInspireText(SHORT_TERM_INSPIRE[Math.floor(Math.random() * SHORT_TERM_INSPIRE.length)]);
    setShowShortInspire(true);
    setTimeout(() => setShowShortInspire(false), 4000);
  };
  const handleLongInspire = () => {
    setLongInspireText(LONG_TERM_INSPIRE[Math.floor(Math.random() * LONG_TERM_INSPIRE.length)]);
    setShowLongInspire(true);
    setTimeout(() => setShowLongInspire(false), 4000);
  };

  return (
    <Box minHeight="100vh" sx={{ background: BG_GRADIENT }}>
      <AppBar position="static" color="transparent" elevation={0} sx={{ background: 'transparent' }}>
        <Toolbar>
          <Typography variant="h6" sx={{ flexGrow: 1, fontWeight: 700, color: mode === 'dark' ? '#fff' : MAIN_BLUE }}>
            Kariyer Vizyonu
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
          Kariyer Vizyonu
        </Typography>
      </Box>
      {/* Sayfa ilerleme Stepper'ı */}
      <Box sx={{ maxWidth: 600, mx: 'auto', mb: 3, px: 2 }}>
        <Stepper activeStep={3} alternativeLabel>
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
            Kısa ve uzun vadeli hedeflerinizi, motivasyonunuzu ve vizyonunuzu paylaşın.
          </Typography>
          <Typography variant="subtitle1" color="primary" sx={{ fontStyle: 'italic', fontWeight: 600, fontSize: { xs: 15, sm: 17 }, textAlign: 'center' }}>
            Hedeflerinizi netleştir, yol haritanı oluştur!
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
          <ShortTermGoalCard
            value={shortTerm}
            onChange={setShortTerm}
            error={errorShort}
            completed={!!shortTerm.trim()}
            showInspire={showShortInspire}
            inspireText={shortInspireText}
            onInspire={handleShortInspire}
          />
          <LongTermGoalCard
            value={longTerm}
            onChange={setLongTerm}
            error={errorLong}
            completed={!!longTerm.trim()}
            showInspire={showLongInspire}
            inspireText={longInspireText}
            onInspire={handleLongInspire}
          />
          <PrioritiesCard
            values={priorities}
            onChange={setPriorities}
            error={errorPriorities}
            completed={priorities.length > 0}
          />
          <ProgressSliderCard
            value={progress}
            onChange={setProgress}
            completed={true}
          />
          <Button
            fullWidth
            variant="contained"
            size="large"
            sx={{ mt: 2, background: priorities.length > 0 ? ACCENT_CORAL : '#A0AEC0', color: '#fff', fontWeight: 700, borderRadius: 2, boxShadow: 'none' }}
            onClick={handleSave}
            disabled={!isFormValid || saving}
          >
            {saving ? <CircularProgress size={24} color="inherit" /> : 'Kaydet ve İlerle'}
          </Button>
          <Typography variant="body2" color="#6B7280" align="center" mt={1}>
            Hedeflerinizi netleştirerek kariyer planınızı güçlendirin.
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
          Kaydedildi, Proje Deneyimleri sayfasına yönlendiriliyor...
        </Alert>
      </Snackbar>
    </Box>
  );
};

export default CareerVision; 