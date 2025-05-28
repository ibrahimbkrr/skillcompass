import React, { useEffect, useState } from 'react';
import { Box, Paper, Typography, TextField, Button, Chip, Slider, MenuItem, Select, InputLabel, FormControl, CircularProgress, Alert, Stack, IconButton, AppBar, Toolbar, Avatar, Stepper, Step, StepLabel } from '@mui/material';
import AutoAwesomeIcon from '@mui/icons-material/AutoAwesome';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';
import LightModeIcon from '@mui/icons-material/LightMode';
import DarkModeIcon from '@mui/icons-material/DarkMode';
import LogoutIcon from '@mui/icons-material/Logout';
import CheckCircleOutlineIcon from '@mui/icons-material/CheckCircleOutline';
import ExploreIcon from '@mui/icons-material/Explore';
import { db } from '../services/firebase';
import { doc, getDoc, setDoc } from 'firebase/firestore';
import { useAuth } from '../contexts/AuthContext';
import { useThemeMode } from '../contexts/ThemeContext';
import { useNavigate } from 'react-router-dom';
import Snackbar from '@mui/material/Snackbar';

const MOTIVATION_OPTIONS = [
  'Yenilik ve Teknoloji',
  'Problem Çözme',
  'Kullanıcı Etkisi',
  'Liderlik ve Etki',
  'Öğrenme ve Gelişim',
  'Finansal Başarı',
  'Toplumsal Katkı',
  'Diğer',
];
const IMPACT_OPTIONS = [
  'Ürün Geliştirme',
  'Veri ve Analitik',
  'Güvenlik ve Altyapı',
  'Tasarım ve Deneyim',
  'Strateji ve Yönetim',
  'Eğitim ve Mentorluk',
  'İnovasyon ve Araştırma',
];
const INSPIRE_EXAMPLES = [
  'Veri hikayeleriyle dünyayı anlamlandıran bir analist.',
  'Siber tehditlere karşı dijital kaleler inşa eden bir güvenlik uzmanı.',
  'Yapay zekayla geleceği şekillendiren bir mühendis.',
  'Kullanıcı odaklı mobil uygulamalar geliştiren bir Flutter tutkunu.',
  'Topluma fayda sağlayan projeler üreten bir geliştirici.',
];

const minStoryLength = 10;

const PROFILE_STEPS = [
  'Kimlik',
  'Teknik',
  'Öğrenme',
  'Vizyon',
  'Projeler',
  'Networking',
  'Marka',
];

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
      <ExploreIcon color="primary" sx={{ mr: 1 }} />
      <Box sx={{ bgcolor: 'primary.main', color: '#fff', px: 1.5, py: 0.5, borderRadius: 1, fontWeight: 700, fontSize: 14 }}>{completed}/{total}</Box>
    </Box>
  </Box>
);

const IdentityStatus: React.FC = () => {
  const { user, logout } = useAuth();
  const { mode, toggleTheme } = useThemeMode();
  const navigate = useNavigate();
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [success, setSuccess] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [openSnackbar, setOpenSnackbar] = useState(false);

  // Form state
  const [story, setStory] = useState('');
  const [showInspire, setShowInspire] = useState(false);
  const [inspireText, setInspireText] = useState('');
  const [motivations, setMotivations] = useState<string[]>([]);
  const [customMotivation, setCustomMotivation] = useState('');
  const [showCustomMotivation, setShowCustomMotivation] = useState(false);
  const [impact, setImpact] = useState<string>('');
  const [clarity, setClarity] = useState<number>(50);
  const [fullName, setFullName] = useState<string | null>(null);

  // Firestore'dan veri çek
  useEffect(() => {
    const fetchData = async () => {
      if (!user) return;
      setLoading(true);
      try {
        const ref = doc(db, 'identity_status', user.uid);
        const snap = await getDoc(ref);
        if (snap.exists()) {
          const data = snap.data();
          setStory(data.story || '');
          setMotivations(data.motivations || []);
          setCustomMotivation(data.custom_motivation || '');
          setShowCustomMotivation(!!data.custom_motivation);
          setImpact(data.impact || '');
          setClarity(data.clarity ?? 50);
        }
      } catch (e) {
        setError('Profil verisi yüklenemedi.');
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, [user]);

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

  // İlham örneği göster
  const handleInspire = () => {
    setInspireText(INSPIRE_EXAMPLES[Math.floor(Math.random() * INSPIRE_EXAMPLES.length)]);
    setShowInspire(true);
    setTimeout(() => setShowInspire(false), 4000);
  };

  // Motivasyon seçimi
  const handleMotivationToggle = (motivation: string) => {
    if (motivation === 'Diğer') {
      setShowCustomMotivation((prev) => !prev);
      if (showCustomMotivation) setCustomMotivation('');
      return;
    }
    setMotivations((prev) =>
      prev.includes(motivation)
        ? prev.filter((m) => m !== motivation)
        : prev.length < 3
        ? [...prev, motivation]
        : prev
    );
  };

  // Validasyon
  const isFormValid =
    story.trim().length >= minStoryLength &&
    (motivations.length > 0 || (showCustomMotivation && customMotivation.trim().length > 0)) &&
    impact !== '';

  // Kaydet
  const handleSave = async () => {
    if (!user) return;
    if (!isFormValid) {
      setError('Lütfen tüm zorunlu alanları doldurun.');
      return;
    }
    setSaving(true);
    setError(null);
    try {
      await setDoc(doc(db, 'users', user.uid, 'profile_data', 'identity-status'), {
        story: story.trim(),
        motivations,
        custom_motivation: showCustomMotivation ? customMotivation.trim() : '',
        impact,
        clarity,
      });
      setOpenSnackbar(true);
      setTimeout(() => {
        setOpenSnackbar(false);
        navigate('/technical');
      }, 2000);
    } catch (e) {
      setError('Kaydetme sırasında hata oluştu.');
    } finally {
      setSaving(false);
    }
  };

  // Netlik açıklaması
  const clarityText =
    clarity <= 25
      ? 'Henüz keşif aşamasındayım, rehberliğe ihtiyacım var.'
      : clarity <= 50
      ? 'Bazı fikirlerim var ama netleştirmem lazım.'
      : clarity <= 75
      ? 'Oldukça netim, ama yönlendirme faydalı olur.'
      : 'Tamamen netim, hedeflerime ulaşmak için plan istiyorum.';

  // Tamamlanma durumu
  const storyDone = story.trim().length >= minStoryLength;
  const motivationDone = motivations.length > 0 || (showCustomMotivation && customMotivation.trim().length > 0);
  const impactDone = impact !== '';
  const clarityDone = true; // Slider her zaman tamam
  const completedCount = [storyDone, motivationDone, impactDone, clarityDone].filter(Boolean).length;
  const totalSteps = 4;
  const progress = completedCount / totalSteps;

  if (loading) return <Box p={4} textAlign="center"><CircularProgress /></Box>;

  return (
    <Box sx={{ minHeight: '100vh', background: mode === 'dark' ? 'linear-gradient(135deg, #23272f 0%, #121212 100%)' : 'linear-gradient(135deg, #B2FEFA 0%, #0ED2F7 100%)' }}>
      <AppBar position="static" color="transparent" elevation={0} sx={{ background: 'transparent' }}>
        <Toolbar>
          <Typography variant="h6" sx={{ flexGrow: 1, fontWeight: 700, color: mode === 'dark' ? '#fff' : '#222' }}>
            Kimlik Durumu
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
          Kimlik Durumu
        </Typography>
      </Box>
      {/* Sayfa ilerleme Stepper'ı */}
      <Box sx={{ maxWidth: 600, mx: 'auto', mb: 3, px: 2 }}>
        <Stepper activeStep={0} alternativeLabel>
          {PROFILE_STEPS.map((label) => (
            <Step key={label}>
              <StepLabel>{label}</StepLabel>
            </Step>
          ))}
        </Stepper>
      </Box>
      {/* Açıklama ve alt başlık */}
      <Box sx={{ maxWidth: 600, mx: 'auto', mb: 3, px: 2 }}>
        <Paper elevation={4} sx={{ p: { xs: 2, sm: 3 }, borderRadius: 3, background: mode === 'dark' ? 'rgba(35,39,47,0.93)' : 'rgba(255,255,255,0.93)', boxShadow: '0 4px 24px rgba(0,0,0,0.07)' }}>
          <Typography variant="body1" color="text.secondary" sx={{ fontSize: { xs: 16, sm: 18 }, mb: 1, fontWeight: 500, textAlign: 'center' }}>
            Bilişim dünyasındaki yerinizi tarif edin. Kendinizi nasıl görüyorsunuz, neyi temsil ediyorsunuz? Bu, kariyer yolculuğunuzun başlangıç noktası.
          </Typography>
          <Typography variant="subtitle1" color="primary" sx={{ fontStyle: 'italic', fontWeight: 600, fontSize: { xs: 15, sm: 17 }, textAlign: 'center' }}>
            Hikayenizi anlatın, yolculuğunuzu birlikte şekillendirelim!
          </Typography>
        </Paper>
      </Box>
      <Box sx={{ maxWidth: 600, mx: 'auto', py: { xs: 2, sm: 6 }, px: 2 }}>
        <Paper elevation={6} sx={{ p: { xs: 2, sm: 4 }, borderRadius: 4, mt: 4, background: mode === 'dark' ? 'rgba(35,39,47,0.98)' : 'rgba(255,255,255,0.98)' }}>
          {/* Kart içi ilerleme barı */}
          <CardProgressBar completed={completedCount} total={totalSteps} progress={progress} />
          {/* Soru 1: Hikaye */}
          <AnimatedQuestionCard completed={storyDone} borderColor={storyDone ? '#1976d2' : '#bdbdbd'}>
            <Typography variant="subtitle1" fontWeight={600} mb={1}>Hikayeniz</Typography>
            <Typography variant="body2" color="text.secondary" mb={1}>Kendinizi bir cümleyle anlatın. Unvanınızdan ziyade tutkunuzu ve vizyonunuzu düşünün.</Typography>
            <Stack direction="row" alignItems="center" spacing={1} mb={1}>
              <TextField
                fullWidth
                label="Kendinizi bir cümleyle anlatın"
                value={story}
                onChange={(e) => setStory(e.target.value)}
                inputProps={{ maxLength: 100 }}
                helperText={
                  story.length < minStoryLength
                    ? `En az ${minStoryLength} karakter (${minStoryLength - story.length} karakter kaldı)`
                    : `${story.length}/100 karakter`
                }
                error={story.length < minStoryLength}
                multiline
                minRows={2}
                maxRows={2}
              />
              <IconButton onClick={handleInspire} color="primary" size="large">
                <AutoAwesomeIcon />
              </IconButton>
            </Stack>
            {showInspire && (
              <Alert severity="info" sx={{ mb: 2 }}>{inspireText}</Alert>
            )}
          </AnimatedQuestionCard>
          {/* Soru 2: Motivasyonlar */}
          <AnimatedQuestionCard completed={motivationDone} borderColor={motivationDone ? '#1976d2' : '#bdbdbd'}>
            <Typography variant="subtitle1" fontWeight={600} mb={1}>Motivasyonlarınız (en fazla 3)</Typography>
            <Typography variant="body2" color="text.secondary" mb={1}>Sizi harekete geçiren ana motivasyonları seçin.</Typography>
            <Typography variant="caption" color="text.secondary" mb={1}>
              {motivations.length < 3
                ? `En fazla 3 seçim yapabilirsiniz (${3 - motivations.length} hakkınız kaldı)`
                : 'Maksimum seçim yapıldı'}
            </Typography>
            <Box mb={2}>
              {MOTIVATION_OPTIONS.map((option) => (
                <Chip
                  key={option}
                  label={option}
                  color={motivations.includes(option) || (option === 'Diğer' && showCustomMotivation) ? 'primary' : 'default'}
                  onClick={() => handleMotivationToggle(option)}
                  sx={{ mr: 1, mb: 1, fontWeight: 600, fontSize: 15, px: 2, py: 1, borderRadius: 2, boxShadow: motivations.includes(option) ? 3 : 0 }}
                  variant={option === 'Diğer' && showCustomMotivation ? 'filled' : 'outlined'}
                />
              ))}
            </Box>
            {showCustomMotivation && (
              <TextField
                fullWidth
                label="Diğer (lütfen belirtin)"
                value={customMotivation}
                onChange={(e) => setCustomMotivation(e.target.value)}
                sx={{ mb: 2 }}
                error={showCustomMotivation && customMotivation.trim().length === 0}
                helperText={showCustomMotivation && customMotivation.trim().length === 0 ? 'Bu alan zorunlu.' : ''}
              />
            )}
          </AnimatedQuestionCard>
          {/* Soru 3: En Büyük Etki Alanı */}
          <AnimatedQuestionCard completed={impactDone} borderColor={impactDone ? '#1976d2' : '#bdbdbd'}>
            <Typography variant="subtitle1" fontWeight={600} mb={1}>En Büyük Etki Alanınız</Typography>
            <Typography variant="body2" color="text.secondary" mb={1}>Kariyerinizde en çok etki yaratmak istediğiniz alanı seçin.</Typography>
            <FormControl fullWidth sx={{ mb: 2 }} error={impact === ''}>
              <InputLabel>Seçiniz</InputLabel>
              <Select
                value={impact}
                label="En Büyük Etki Alanınız"
                onChange={(e) => setImpact(e.target.value)}
              >
                <MenuItem value=""><em>Seçiniz</em></MenuItem>
                {IMPACT_OPTIONS.map((option) => (
                  <MenuItem key={option} value={option}>{option}</MenuItem>
                ))}
              </Select>
            </FormControl>
          </AnimatedQuestionCard>
          {/* Soru 4: Netlik */}
          <AnimatedQuestionCard completed={clarityDone} borderColor={clarityDone ? '#1976d2' : '#bdbdbd'}>
            <Typography variant="subtitle1" fontWeight={600} mb={1}>Kariyer Kimliği Netliğiniz</Typography>
            <Typography variant="body2" color="text.secondary" mb={1}>Kariyer hedeflerinizin ne kadar net olduğunu belirtin.</Typography>
            <Box px={1}>
              <Slider
                value={clarity}
                min={0}
                max={100}
                step={1}
                onChange={(_, val) => setClarity(val as number)}
                valueLabelDisplay="auto"
                sx={{ color: 'primary.main' }}
              />
              <Typography variant="body2" color="text.secondary" mb={2}>{clarityText}</Typography>
            </Box>
          </AnimatedQuestionCard>
          {/* Hata ve başarı mesajları */}
          {error && <Alert severity="error" sx={{ mb: 2 }}>{error}</Alert>}
          <Snackbar
            open={openSnackbar}
            autoHideDuration={2000}
            onClose={() => {
              setOpenSnackbar(false);
              navigate('/technical');
            }}
            anchorOrigin={{ vertical: 'top', horizontal: 'center' }}
          >
            <Alert severity="success" sx={{ width: '100%' }}>
              Kaydedildi, Teknik Profil adımına geçiliyor...
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
        </Paper>
      </Box>
    </Box>
  );
};

export default IdentityStatus; 