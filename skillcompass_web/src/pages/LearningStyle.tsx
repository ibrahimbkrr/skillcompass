import React, { useState } from 'react';
import { Box, Paper, Typography, AppBar, Toolbar, IconButton, Stepper, Step, StepLabel, Snackbar, Button, Stack, Chip, TextField, Alert, Collapse, CircularProgress } from '@mui/material';
import LightModeIcon from '@mui/icons-material/LightMode';
import DarkModeIcon from '@mui/icons-material/DarkMode';
import LogoutIcon from '@mui/icons-material/Logout';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';
import MenuBookIcon from '@mui/icons-material/MenuBook';
import AutoAwesomeIcon from '@mui/icons-material/AutoAwesome';
import LightbulbIcon from '@mui/icons-material/Lightbulb';
import { useThemeMode } from '../contexts/ThemeContext';
import { useAuth } from '../contexts/AuthContext';
import { useNavigate } from 'react-router-dom';
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

const PREFERENCE_OPTIONS = [
  'Videolar ve Eğitim Platformları',
  'Kitaplar ve Makaleler',
  'Uygulamalı Projeler',
  'Mentor veya Eğitim Grupları',
  'Diğer',
];
const RESOURCE_OPTIONS = [
  'Online Eğitim Platformları (Udemy, Coursera)',
  'YouTube Videoları',
  'Açık Kaynak Belgeler (GitHub, Stack Overflow)',
  'Kütüphane ve Akademik Kaynaklar',
  'Diğer',
];
const MOTIVATION_EXAMPLES = [
  'Kariyerimde ilerlemek için yeni beceriler kazanmak.',
  'Gerçek projelerde uygulama yaparak öğrenmek.',
  'Teknolojide güncel kalmak ve yenilikleri takip etmek.',
  'Bir topluluğa katkı sağlamak ve paylaşmak.',
];
const BARRIER_EXAMPLES = [
  'Zaman yönetimi',
  'Kaynaklara erişim zorluğu',
  'Motivasyon eksikliği',
  'Dikkat dağınıklığı',
];
const minMotivationLength = 10;
const minBarrierLength = 10;
const maxResourceCount = 3;

// AnimatedQuestionCard bileşeni
const AnimatedQuestionCard: React.FC<{
  completed: boolean;
  children: React.ReactNode;
  borderColor: string;
}> = ({ completed, children, borderColor }) => (
  <Box sx={{ position: 'relative', mb: 2 }}>
    <Paper
      elevation={completed ? 6 : 2}
      sx={{
        p: 3,
        borderRadius: 2,
        border: `2px solid ${borderColor}`,
        boxShadow: completed ? 6 : 1,
        transition: 'border-color 0.3s, box-shadow 0.3s',
        background: '#fff',
      }}
    >
      {children}
    </Paper>
    {completed && (
      <Box sx={{ position: 'absolute', top: 12, right: 12, bgcolor: '#fff', borderRadius: '50%', boxShadow: 2, p: 0.5 }}>
        <CheckCircleIcon color="success" fontSize="small" />
      </Box>
    )}
  </Box>
);

// Kart içi ilerleme barı
const CardProgressBar: React.FC<{ completed: number; total: number; progress: number }> = ({ completed, total, progress }) => (
  <Box sx={{ mb: 3 }}>
    <Box sx={{ display: 'flex', alignItems: 'center', mb: 1 }}>
      <Box sx={{ flex: 1, mr: 2, position: 'relative' }}>
        <Box sx={{ height: 7, bgcolor: 'grey.300', borderRadius: 2 }} />
        <Box sx={{
          position: 'absolute',
          left: 0,
          top: 0,
          height: 7,
          width: `${progress * 100}%`,
          bgcolor: 'primary.main',
          borderRadius: 2,
          transition: 'width 0.4s',
        }} />
      </Box>
      <MenuBookIcon color="primary" sx={{ mr: 1 }} />
      <Box sx={{ bgcolor: 'primary.main', color: '#fff', px: 1.5, py: 0.5, borderRadius: 1, fontWeight: 700, fontSize: 14 }}>{completed}/{total}</Box>
    </Box>
  </Box>
);

const LearningStyle: React.FC = () => {
  const { mode, toggleTheme } = useThemeMode();
  const { logout, user } = useAuth();
  const navigate = useNavigate();

  // State
  const [selectedPreference, setSelectedPreference] = useState('');
  const [showCustomPreferenceInput, setShowCustomPreferenceInput] = useState(false);
  const [customPreference, setCustomPreference] = useState('');
  const [customPreferenceList, setCustomPreferenceList] = useState<string[]>([]);
  const [selectedResources, setSelectedResources] = useState<string[]>([]);
  const [showCustomResourceInput, setShowCustomResourceInput] = useState(false);
  const [customResource, setCustomResource] = useState('');
  const [motivation, setMotivation] = useState('');
  const [showMotivationInspire, setShowMotivationInspire] = useState(false);
  const [motivationInspireText, setMotivationInspireText] = useState('');
  const [barrier, setBarrier] = useState('');
  const [showBarrierInspire, setShowBarrierInspire] = useState(false);
  const [barrierInspireText, setBarrierInspireText] = useState('');
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [openSnackbar, setOpenSnackbar] = useState(false);

  // Öğrenme tercihi seçimi
  const handlePreferenceSelect = (option: string) => {
    if (option === 'Diğer') {
      setShowCustomPreferenceInput(true);
    } else {
      setSelectedPreference(option);
      setShowCustomPreferenceInput(false);
    }
  };
  const handleAddCustomPreference = () => {
    if (customPreference.trim() && !customPreferenceList.includes(customPreference.trim())) {
      setCustomPreferenceList([...customPreferenceList, customPreference.trim()]);
      setCustomPreference('');
      setShowCustomPreferenceInput(false);
    }
  };
  const handleDeleteCustomPreference = (pref: string) => {
    setCustomPreferenceList(customPreferenceList.filter((p) => p !== pref));
  };

  // Kaynak seçimi
  const handleResourceToggle = (resource: string) => {
    if (selectedResources.includes(resource)) {
      setSelectedResources(selectedResources.filter((r) => r !== resource));
    } else if (selectedResources.length < maxResourceCount) {
      setSelectedResources([...selectedResources, resource]);
    }
  };
  const handleAddCustomResource = () => {
    if (customResource.trim() && !selectedResources.includes(customResource.trim()) && selectedResources.length < maxResourceCount) {
      setSelectedResources([...selectedResources, customResource.trim()]);
      setCustomResource('');
      setShowCustomResourceInput(false);
    }
  };

  // İlham örnekleri
  const handleMotivationInspire = () => {
    setMotivationInspireText(MOTIVATION_EXAMPLES[Math.floor(Math.random() * MOTIVATION_EXAMPLES.length)]);
    setShowMotivationInspire(true);
    setTimeout(() => setShowMotivationInspire(false), 4000);
  };
  const handleBarrierInspire = () => {
    setBarrierInspireText(BARRIER_EXAMPLES[Math.floor(Math.random() * BARRIER_EXAMPLES.length)]);
    setShowBarrierInspire(true);
    setTimeout(() => setShowBarrierInspire(false), 4000);
  };

  // Validasyonlar
  const preferenceDone = selectedPreference !== '' || customPreferenceList.length > 0;
  const resourcesDone = selectedResources.length > 0;
  const motivationDone = motivation.trim().length >= minMotivationLength;
  const barrierDone = barrier.trim().length >= minBarrierLength;
  const completedCount = [preferenceDone, resourcesDone, motivationDone, barrierDone].filter(Boolean).length;
  const totalSteps = 4;
  const progress = completedCount / totalSteps;
  const isFormValid = preferenceDone && resourcesDone && motivationDone && barrierDone;

  // Kaydet
  const handleSave = async () => {
    if (!user) {
      setError('Kullanıcı oturumu bulunamadı. Lütfen tekrar giriş yapın.');
      return;
    }
    if (!isFormValid) {
      setError('Lütfen tüm zorunlu alanları doldurun.');
      return;
    }
    setSaving(true);
    setError(null);
    try {
      await setDoc(doc(db, 'users', user!.uid, 'profile_data', 'learning-style'), {
        preference: selectedPreference,
        customPreferences: customPreferenceList,
        resources: selectedResources,
        motivation: motivation.trim(),
        barrier: barrier.trim(),
      });
      setOpenSnackbar(true);
      setTimeout(() => {
        setOpenSnackbar(false);
        navigate('/career');
      }, 2000);
    } catch (e) {
      setError('Kaydetme sırasında hata oluştu.');
    } finally {
      setSaving(false);
    }
  };

  return (
    <Box sx={{ minHeight: '100vh', background: mode === 'dark' ? 'linear-gradient(135deg, #23272f 0%, #121212 100%)' : 'linear-gradient(135deg, #B2FEFA 0%, #0ED2F7 100%)' }}>
      <AppBar position="static" color="transparent" elevation={0} sx={{ background: 'transparent' }}>
        <Toolbar>
          <Typography variant="h6" sx={{ flexGrow: 1, fontWeight: 700, color: mode === 'dark' ? '#fff' : '#222' }}>
            Öğrenme Stili
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
          Öğrenme Stili
        </Typography>
      </Box>
      {/* Sayfa ilerleme Stepper'ı */}
      <Box sx={{ maxWidth: 600, mx: 'auto', mb: 3, px: 2 }}>
        <Stepper activeStep={2} alternativeLabel>
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
            Nasıl öğrendiğinizi ve düşündüğünüzü paylaşın. Kişisel gelişiminize ışık tutacak ipuçları verin.
          </Typography>
          <Typography variant="subtitle1" color="primary" sx={{ fontStyle: 'italic', fontWeight: 600, fontSize: { xs: 15, sm: 17 }, textAlign: 'center' }}>
            Öğrenme alışkanlıklarınızı keşfedin!
          </Typography>
        </Paper>
      </Box>
      <Box sx={{ maxWidth: 600, mx: 'auto', py: { xs: 2, sm: 6 }, px: 2 }}>
        {/* Kart içi ilerleme barı */}
        <CardProgressBar completed={completedCount} total={totalSteps} progress={progress} />
        {/* 1. Kart: Öğrenme Tercihi */}
        <AnimatedQuestionCard completed={preferenceDone} borderColor={preferenceDone ? '#1976d2' : '#bdbdbd'}>
          <Typography variant="subtitle1" fontWeight={600} mb={1}>Öğrenme Tercihiniz</Typography>
          <Typography variant="body2" color="text.secondary" mb={1}>Bilişim konularını öğrenirken en çok hangi yöntemi tercih edersiniz?</Typography>
          <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 1, mb: 1 }}>
            {PREFERENCE_OPTIONS.map((option) => (
              <Chip
                key={option}
                label={option}
                color={selectedPreference === option ? 'primary' : 'default'}
                onClick={() => handlePreferenceSelect(option)}
                sx={{ fontWeight: 600 }}
              />
            ))}
            {customPreferenceList.map((pref) => (
              <Chip
                key={pref}
                label={pref}
                color="primary"
                onDelete={() => handleDeleteCustomPreference(pref)}
                sx={{ fontWeight: 600 }}
              />
            ))}
          </Box>
          {showCustomPreferenceInput && (
            <Stack direction="row" spacing={1} alignItems="center" sx={{ mt: 1 }}>
              <TextField
                size="small"
                label="Diğer (lütfen belirtin)"
                value={customPreference}
                onChange={(e) => setCustomPreference(e.target.value)}
                sx={{ width: 180 }}
              />
              <Button variant="contained" color="primary" onClick={handleAddCustomPreference} disabled={!customPreference.trim()}>
                Ekle
              </Button>
            </Stack>
          )}
        </AnimatedQuestionCard>
        {/* 2. Kart: Kullandığınız Kaynaklar */}
        <AnimatedQuestionCard completed={resourcesDone} borderColor={resourcesDone ? '#1976d2' : '#bdbdbd'}>
          <Typography variant="subtitle1" fontWeight={600} mb={1}>Kullandığınız Kaynaklar (en fazla 3)</Typography>
          <Typography variant="body2" color="text.secondary" mb={1}>Öğrenme sürecinizde sık kullandığınız kaynakları seçin.</Typography>
          <Typography variant="caption" color="text.secondary" mb={1}>
            {selectedResources.length < maxResourceCount
              ? `En fazla 3 seçim yapabilirsiniz (${maxResourceCount - selectedResources.length} hakkınız kaldı)`
              : 'Maksimum seçim yapıldı'}
          </Typography>
          <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 1, mb: 1 }}>
            {RESOURCE_OPTIONS.map((option) => (
              <Chip
                key={option}
                label={option}
                color={selectedResources.includes(option) ? 'primary' : 'default'}
                onClick={() => {
                  if (option === 'Diğer') setShowCustomResourceInput((prev) => !prev);
                  else handleResourceToggle(option);
                }}
                sx={{ fontWeight: 600 }}
              />
            ))}
            {selectedResources.filter((r) => !RESOURCE_OPTIONS.includes(r)).map((custom) => (
              <Chip
                key={custom}
                label={custom}
                color="primary"
                onDelete={() => setSelectedResources(selectedResources.filter((r) => r !== custom))}
                sx={{ fontWeight: 600 }}
              />
            ))}
          </Box>
          {showCustomResourceInput && (
            <Stack direction="row" spacing={1} alignItems="center" sx={{ mt: 1 }}>
              <TextField
                size="small"
                label="Diğer (lütfen belirtin)"
                value={customResource}
                onChange={(e) => setCustomResource(e.target.value)}
                sx={{ width: 180 }}
              />
              <Button variant="contained" color="primary" onClick={handleAddCustomResource} disabled={!customResource.trim() || selectedResources.length >= maxResourceCount}>
                Ekle
              </Button>
            </Stack>
          )}
        </AnimatedQuestionCard>
        {/* 3. Kart: Motivasyon */}
        <AnimatedQuestionCard completed={motivationDone} borderColor={motivationDone ? '#1976d2' : '#bdbdbd'}>
          <Typography variant="subtitle1" fontWeight={600} mb={1}>Motivasyonunuz</Typography>
          <Typography variant="body2" color="text.secondary" mb={1}>Bilişim öğrenirken sizi en çok ne motive eder?</Typography>
          <Stack direction="row" alignItems="center" spacing={1} mb={1}>
            <TextField
              fullWidth
              label="Motivasyonunuz"
              value={motivation}
              onChange={(e) => setMotivation(e.target.value)}
              inputProps={{ maxLength: 100 }}
              helperText={
                motivation.length < minMotivationLength
                  ? `En az ${minMotivationLength} karakter (${minMotivationLength - motivation.length} karakter kaldı)`
                  : `${motivation.length}/100 karakter`
              }
              error={motivation.length < minMotivationLength}
            />
            <IconButton onClick={handleMotivationInspire} color="primary" size="large">
              <AutoAwesomeIcon />
            </IconButton>
          </Stack>
          {showMotivationInspire && (
            <Alert severity="info" sx={{ mb: 2 }}>{motivationInspireText}</Alert>
          )}
        </AnimatedQuestionCard>
        {/* 4. Kart: En Büyük Engel */}
        <AnimatedQuestionCard completed={barrierDone} borderColor={barrierDone ? '#1976d2' : '#bdbdbd'}>
          <Typography variant="subtitle1" fontWeight={600} mb={1}>En Büyük Engel</Typography>
          <Typography variant="body2" color="text.secondary" mb={1}>Öğrenme sürecinizde en büyük engeliniz nedir?</Typography>
          <Stack direction="row" alignItems="center" spacing={1} mb={1}>
            <TextField
              fullWidth
              label="En büyük engeliniz"
              value={barrier}
              onChange={(e) => setBarrier(e.target.value)}
              inputProps={{ maxLength: 100 }}
              helperText={
                barrier.length < minBarrierLength
                  ? `En az ${minBarrierLength} karakter (${minBarrierLength - barrier.length} karakter kaldı)`
                  : `${barrier.length}/100 karakter`
              }
              error={barrier.length < minBarrierLength}
            />
            <IconButton onClick={handleBarrierInspire} color="primary" size="large">
              <LightbulbIcon />
            </IconButton>
          </Stack>
          {showBarrierInspire && (
            <Alert severity="info" sx={{ mb: 2 }}>{barrierInspireText}</Alert>
          )}
        </AnimatedQuestionCard>
        {/* Hata ve başarı mesajları */}
        {error && <Alert severity="error" sx={{ mb: 2 }}>{error}</Alert>}
        <Snackbar
          open={openSnackbar}
          autoHideDuration={2000}
          onClose={() => {
            setOpenSnackbar(false);
            navigate('/career');
          }}
          anchorOrigin={{ vertical: 'top', horizontal: 'center' }}
        >
          <Alert severity="success" sx={{ width: '100%' }}>
            Kaydedildi, Kariyer Vizyonu adımına geçiliyor...
          </Alert>
        </Snackbar>
        {/* Kaydet butonu */}
        <Button
          variant="contained"
          color="primary"
          fullWidth
          size="large"
          sx={{ mt: 2, fontWeight: 700, fontSize: '1.1rem' }}
          onClick={handleSave}
          disabled={!isFormValid || saving}
        >
          {saving ? <CircularProgress size={24} color="inherit" /> : 'Kaydet ve İlerle'}
        </Button>
      </Box>
    </Box>
  );
};

export default LearningStyle; 