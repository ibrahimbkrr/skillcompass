import React, { useState } from 'react';
import { Box, Paper, Typography, AppBar, Toolbar, IconButton, Stepper, Step, StepLabel, Snackbar, Button, Stack, Chip, TextField, Select, MenuItem, FormControl, InputLabel, Slider, Alert } from '@mui/material';
import LightModeIcon from '@mui/icons-material/LightMode';
import DarkModeIcon from '@mui/icons-material/DarkMode';
import LogoutIcon from '@mui/icons-material/Logout';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';
import EngineeringIcon from '@mui/icons-material/Engineering';
import ExpandMoreIcon from '@mui/icons-material/ExpandMore';
import AutoAwesomeIcon from '@mui/icons-material/AutoAwesome';
import { useThemeMode } from '../contexts/ThemeContext';
import { useAuth } from '../contexts/AuthContext';
import { useNavigate } from 'react-router-dom';
import Collapse from '@mui/material/Collapse';
import CircularProgress from '@mui/material/CircularProgress';
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
      <EngineeringIcon color="primary" sx={{ mr: 1 }} />
      <Box sx={{ bgcolor: 'primary.main', color: '#fff', px: 1.5, py: 0.5, borderRadius: 1, fontWeight: 700, fontSize: 14 }}>{completed}/{total}</Box>
    </Box>
  </Box>
);

// Seçenekler
const PRIMARY_FIELD_OPTIONS = [
  'Frontend Geliştirme',
  'Backend Geliştirme',
  'Fullstack Geliştirme',
  'Mobil Uygulama Geliştirme',
  'Oyun Geliştirme',
  'Veri Bilimi / Analitiği',
  'Bulut Teknolojileri',
  'DevOps / SRE',
  'Siber Güvenlik',
  'UI/UX Tasarım',
  'Yapay Zeka / Makine Öğrenmesi',
  'Gömülü Sistemler / IoT',
  'Diğer',
];

// Teknik beceri kategorileri ve seçenekleri
const SKILL_CATEGORIES = [
  {
    label: 'Programlama Dilleri',
    skills: ['Python', 'JavaScript', 'Dart', 'Java', 'C++', 'Go', 'Rust', 'Diğer'],
  },
  {
    label: 'Frameworkler ve Kütüphaneler',
    skills: ['Flutter', 'React', 'Django', 'TensorFlow', 'Node.js', 'Diğer'],
  },
  {
    label: 'Veritabanları ve Araçlar',
    skills: ['Firebase', 'MongoDB', 'SQL', 'PostgreSQL', 'Docker', 'Kubernetes', 'Diğer'],
  },
  {
    label: 'Tasarım ve Prototipleme',
    skills: ['Figma', 'Adobe XD', 'Sketch', 'Diğer'],
  },
  {
    label: 'Diğer Yetkinlikler',
    skills: ['API geliştirme', 'CI/CD', 'Bulut Bilişim (AWS, Azure)', 'Siber Güvenlik', 'Diğer'],
  },
];

const LEARNING_APPROACHES = [
  'Uygulamalı Projeler (Kod yazarak, proje geliştirerek öğrenirim)',
  'Video Eğitimler (Udemy, YouTube gibi platformlarla öğrenirim)',
  'Dokümantasyon ve Makaleler (Resmi dokümanlar, bloglar okurum)',
  'Mentorluk ve Ekip Çalışması (Deneyimli kişilerden öğrenirim)',
  'Online Topluluklar (Stack Overflow, Discord gibi platformlarda öğrenirim)',
  'Yapılandırılmış Kurslar (Coursera, edX gibi sertifikalı programlar)',
];

const HIGHLIGHT_EXAMPLES = [
  'Python ile veri analizi.',
  'React ile dinamik web arayüzleri.',
  'AWS ile bulut altyapısı kurma.',
  'Flutter ile mobil uygulama geliştirme.',
];

const minHighlightLength = 10;
const maxSkillCount = 10;

const TechnicalProfile: React.FC = () => {
  const { mode, toggleTheme } = useThemeMode();
  const { logout, user } = useAuth();
  const navigate = useNavigate();

  // State
  const [expandedCategories, setExpandedCategories] = useState<string[]>([]);
  const [selectedSkills, setSelectedSkills] = useState<string[]>([]);
  const [customSkill, setCustomSkill] = useState('');
  const [showCustomSkillInput, setShowCustomSkillInput] = useState(false);
  const [highlightSkill, setHighlightSkill] = useState('');
  const [showInspire, setShowInspire] = useState(false);
  const [inspireText, setInspireText] = useState('');
  const [selectedLearningApproach, setSelectedLearningApproach] = useState('');
  const [confidence, setConfidence] = useState(50);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [openSnackbar, setOpenSnackbar] = useState(false);

  // Kategori aç/kapa
  const handleCategoryToggle = (label: string) => {
    setExpandedCategories((prev) =>
      prev.includes(label) ? prev.filter((l) => l !== label) : [...prev, label]
    );
  };

  // Beceri seçimi
  const handleSkillToggle = (skill: string) => {
    if (selectedSkills.includes(skill)) {
      setSelectedSkills(selectedSkills.filter((s) => s !== skill));
    } else if (selectedSkills.length < maxSkillCount) {
      setSelectedSkills([...selectedSkills, skill]);
    }
  };

  // İlham örneği göster
  const handleInspire = () => {
    setInspireText(HIGHLIGHT_EXAMPLES[Math.floor(Math.random() * HIGHLIGHT_EXAMPLES.length)]);
    setShowInspire(true);
    setTimeout(() => setShowInspire(false), 4000);
  };

  // Validasyonlar
  const skillsDone = selectedSkills.length > 0;
  const highlightDone = highlightSkill.trim().length >= minHighlightLength;
  const learningDone = selectedLearningApproach !== '';
  const confidenceDone = true;
  const completedCount = [skillsDone, highlightDone, learningDone, confidenceDone].filter(Boolean).length;
  const totalSteps = 4;
  const progress = completedCount / totalSteps;
  const isFormValid = skillsDone && highlightDone && learningDone;

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
      await setDoc(doc(db, 'users', user!.uid, 'profile_data', 'technical-profile'), {
        skills: selectedSkills,
        highlight: highlightSkill.trim(),
        learningApproach: selectedLearningApproach,
        confidence,
      });
      setOpenSnackbar(true);
      setTimeout(() => {
        setOpenSnackbar(false);
        navigate('/learning');
      }, 2000);
    } catch (e) {
      setError('Kaydetme sırasında hata oluştu.');
    } finally {
      setSaving(false);
    }
  };

  // Teknik özgüven açıklaması
  const confidenceText =
    confidence <= 25
      ? 'Henüz yolun başındayım, temel becerilere ihtiyacım var.'
      : confidence <= 50
      ? 'Bazı becerilerim var, ama daha çok pratik yapmalıyım.'
      : confidence <= 75
      ? 'Kendime güveniyorum, ama daha fazla uzmanlaşabilirim.'
      : 'Becerilerimde çok iyiyim, ileri düzey projelere hazırım.';

  return (
    <Box sx={{ minHeight: '100vh', background: mode === 'dark' ? 'linear-gradient(135deg, #23272f 0%, #121212 100%)' : 'linear-gradient(135deg, #B2FEFA 0%, #0ED2F7 100%)' }}>
      <AppBar position="static" color="transparent" elevation={0} sx={{ background: 'transparent' }}>
        <Toolbar>
          <Typography variant="h6" sx={{ flexGrow: 1, fontWeight: 700, color: mode === 'dark' ? '#fff' : '#222' }}>
            Teknik Profil
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
          Teknik Profil
        </Typography>
      </Box>
      {/* Sayfa ilerleme Stepper'ı */}
      <Box sx={{ maxWidth: 600, mx: 'auto', mb: 3, px: 2 }}>
        <Stepper activeStep={1} alternativeLabel>
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
            Teknik becerilerinizi, öne çıkan yeteneklerinizi ve öğrenme yaklaşımınızı paylaşın.
          </Typography>
          <Typography variant="subtitle1" color="primary" sx={{ fontStyle: 'italic', fontWeight: 600, fontSize: { xs: 15, sm: 17 }, textAlign: 'center' }}>
            Güçlü yönlerinizi ve deneyimlerinizi vurgulayın!
          </Typography>
        </Paper>
      </Box>
      <Box sx={{ maxWidth: 600, mx: 'auto', py: { xs: 2, sm: 6 }, px: 2 }}>
        {/* Kart içi ilerleme barı */}
        <CardProgressBar completed={completedCount} total={totalSteps} progress={progress} />
        {/* 1. Kart: Teknik Beceriler */}
        <AnimatedQuestionCard completed={skillsDone} borderColor={skillsDone ? '#1976d2' : '#bdbdbd'}>
          <Typography variant="subtitle1" fontWeight={600} mb={1}>Teknik Becerileriniz (en fazla 10)</Typography>
          <Typography variant="body2" color="text.secondary" mb={1}>Sahip olduğunuz teknik becerileri kategorilere göre seçin.</Typography>
          <Typography variant="caption" color="text.secondary" mb={1}>
            {selectedSkills.length < maxSkillCount
              ? `En fazla 10 seçim yapabilirsiniz (${maxSkillCount - selectedSkills.length} hakkınız kaldı)`
              : 'Maksimum seçim yapıldı'}
          </Typography>
          {SKILL_CATEGORIES.map((cat) => (
            <Box key={cat.label} sx={{ mb: 1 }}>
              <Button
                variant="text"
                endIcon={<ExpandMoreIcon sx={{ transform: expandedCategories.includes(cat.label) ? 'rotate(180deg)' : 'none', transition: '0.2s' }} />}
                onClick={() => handleCategoryToggle(cat.label)}
                sx={{ fontWeight: 700, color: 'primary.main', textTransform: 'none', pl: 0 }}
              >
                {cat.label}
              </Button>
              <Collapse in={expandedCategories.includes(cat.label)}>
                <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 1, mb: 1, mt: 1 }}>
                  {cat.skills.map((skill) => (
                    skill === 'Diğer' ? (
                      <>
                        <Chip
                          key={skill}
                          label="Diğer"
                          color={showCustomSkillInput ? 'primary' : 'default'}
                          onClick={() => setShowCustomSkillInput((prev) => !prev)}
                          sx={{ fontWeight: 600 }}
                        />
                        {showCustomSkillInput && (
                          <TextField
                            size="small"
                            label="Diğer (lütfen belirtin)"
                            value={customSkill}
                            onChange={(e) => setCustomSkill(e.target.value)}
                            sx={{ ml: 1, width: 180 }}
                            onBlur={() => {
                              if (customSkill.trim() && !selectedSkills.includes(customSkill.trim()) && selectedSkills.length < maxSkillCount) {
                                setSelectedSkills([...selectedSkills, customSkill.trim()]);
                                setCustomSkill('');
                              }
                            }}
                          />
                        )}
                      </>
                    ) : (
                      <Chip
                        key={skill}
                        label={skill}
                        color={selectedSkills.includes(skill) ? 'primary' : 'default'}
                        onClick={() => handleSkillToggle(skill)}
                        sx={{ fontWeight: 600 }}
                      />
                    )
                  ))}
                </Box>
              </Collapse>
            </Box>
          ))}
          {/* Seçili beceriler gösterimi */}
          {selectedSkills.length > 0 && (
            <Box sx={{ mt: 1, display: 'flex', flexWrap: 'wrap', gap: 1 }}>
              {selectedSkills.map((skill) => (
                <Chip key={skill} label={skill} color="primary" onDelete={() => handleSkillToggle(skill)} />
              ))}
            </Box>
          )}
        </AnimatedQuestionCard>
        {/* 2. Kart: En Çok Öne Çıkan Beceriniz */}
        <AnimatedQuestionCard completed={highlightDone} borderColor={highlightDone ? '#1976d2' : '#bdbdbd'}>
          <Typography variant="subtitle1" fontWeight={600} mb={1}>En Çok Öne Çıkan Beceriniz</Typography>
          <Typography variant="body2" color="text.secondary" mb={1}>Kendinizi en iyi ifade eden, öne çıkan teknik becerinizi yazın.</Typography>
          <Stack direction="row" alignItems="center" spacing={1} mb={1}>
            <TextField
              fullWidth
              label="Öne çıkan beceriniz"
              value={highlightSkill}
              onChange={(e) => setHighlightSkill(e.target.value)}
              inputProps={{ maxLength: 100 }}
              helperText={
                highlightSkill.length < minHighlightLength
                  ? `En az ${minHighlightLength} karakter (${minHighlightLength - highlightSkill.length} karakter kaldı)`
                  : `${highlightSkill.length}/100 karakter`
              }
              error={highlightSkill.length < minHighlightLength}
            />
            <IconButton onClick={handleInspire} color="primary" size="large">
              <AutoAwesomeIcon />
            </IconButton>
          </Stack>
          {showInspire && (
            <Alert severity="info" sx={{ mb: 2 }}>{inspireText}</Alert>
          )}
        </AnimatedQuestionCard>
        {/* 3. Kart: Öğrenme Yaklaşımınız */}
        <AnimatedQuestionCard completed={learningDone} borderColor={learningDone ? '#1976d2' : '#bdbdbd'}>
          <Typography variant="subtitle1" fontWeight={600} mb={1}>Öğrenme Yaklaşımınız</Typography>
          <Typography variant="body2" color="text.secondary" mb={1}>Yeni becerileri nasıl öğrendiğinizi seçin.</Typography>
          <FormControl fullWidth sx={{ mb: 2 }} error={selectedLearningApproach === ''}>
            <InputLabel>Seçiniz</InputLabel>
            <Select
              value={selectedLearningApproach}
              label="Öğrenme Yaklaşımınız"
              onChange={(e) => setSelectedLearningApproach(e.target.value)}
            >
              <MenuItem value=""><em>Seçiniz</em></MenuItem>
              {LEARNING_APPROACHES.map((option) => (
                <MenuItem key={option} value={option}>{option}</MenuItem>
              ))}
            </Select>
          </FormControl>
        </AnimatedQuestionCard>
        {/* 4. Kart: Teknik Özgüven */}
        <AnimatedQuestionCard completed={confidenceDone} borderColor={confidenceDone ? '#1976d2' : '#bdbdbd'}>
          <Typography variant="subtitle1" fontWeight={600} mb={1}>Teknik Özgüveniniz</Typography>
          <Typography variant="body2" color="text.secondary" mb={1}>Kendinizi teknik olarak ne kadar özgüvenli hissediyorsunuz?</Typography>
          <Box px={1}>
            <Slider
              value={confidence}
              min={0}
              max={100}
              step={1}
              onChange={(_, val) => setConfidence(val as number)}
              valueLabelDisplay="auto"
              sx={{ color: 'primary.main' }}
            />
            <Typography variant="body2" color="text.secondary" mb={2}>{confidenceText}</Typography>
          </Box>
        </AnimatedQuestionCard>
        {/* Hata ve başarı mesajları */}
        {error && <Alert severity="error" sx={{ mb: 2 }}>{error}</Alert>}
        <Snackbar
          open={openSnackbar}
          autoHideDuration={2000}
          onClose={() => {
            setOpenSnackbar(false);
            navigate('/learning');
          }}
          anchorOrigin={{ vertical: 'top', horizontal: 'center' }}
        >
          <Alert severity="success" sx={{ width: '100%' }}>
            Kaydedildi, Öğrenme Stili adımına geçiliyor...
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

export default TechnicalProfile; 