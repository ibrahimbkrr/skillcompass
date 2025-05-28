import React, { useEffect, useState } from 'react';
import { useAuth } from '../contexts/AuthContext';
import {
  Box, Card, CardContent, Typography, Grid, CircularProgress, Snackbar, Alert, AppBar, Toolbar, IconButton, Avatar, Button, Chip, Accordion, AccordionSummary, AccordionDetails, Fade
} from '@mui/material';
import LightModeIcon from '@mui/icons-material/LightMode';
import DarkModeIcon from '@mui/icons-material/DarkMode';
import LogoutIcon from '@mui/icons-material/Logout';
import RefreshIcon from '@mui/icons-material/Refresh';
import EmojiEventsIcon from '@mui/icons-material/EmojiEvents';
import BoltIcon from '@mui/icons-material/Bolt';
import TrendingUpIcon from '@mui/icons-material/TrendingUp';
import TipsAndUpdatesIcon from '@mui/icons-material/TipsAndUpdates';
import InfoIcon from '@mui/icons-material/Info';
import ExpandMoreIcon from '@mui/icons-material/ExpandMore';
import { useThemeMode } from '../contexts/ThemeContext';
import EngineeringIcon from '@mui/icons-material/Engineering';
import MenuBookIcon from '@mui/icons-material/MenuBook';
import FlagIcon from '@mui/icons-material/Flag';
import RocketLaunchIcon from '@mui/icons-material/RocketLaunch';
import PeopleIcon from '@mui/icons-material/People';
import StarIcon from '@mui/icons-material/Star';

const CATEGORY_META: Record<string, { icon: React.ReactNode; color: string; badge: string }> = {
  'Kimlik': { icon: <Avatar sx={{ bgcolor: '#1976d2' }}>K</Avatar>, color: '#1976d2', badge: 'Kimlik' },
  'Teknik Profil': { icon: <EngineeringIcon sx={{ color: '#1976d2' }} />, color: '#1976d2', badge: 'Teknik' },
  'Öğrenme Stili': { icon: <MenuBookIcon sx={{ color: '#00bcd4' }} />, color: '#00bcd4', badge: 'Öğrenme' },
  'Kariyer Vizyonu': { icon: <FlagIcon sx={{ color: '#ff9800' }} />, color: '#ff9800', badge: 'Vizyon' },
  'Proje Deneyimleri': { icon: <RocketLaunchIcon sx={{ color: '#43a047' }} />, color: '#43a047', badge: 'Proje' },
  'Networking': { icon: <PeopleIcon sx={{ color: '#8e24aa' }} />, color: '#8e24aa', badge: 'Networking' },
  'Kişisel Marka': { icon: <StarIcon sx={{ color: '#fbc02d' }} />, color: '#fbc02d', badge: 'Marka' },
};

const Analysis: React.FC = () => {
  const { user, logout } = useAuth();
  const { mode, toggleTheme } = useThemeMode();
  const [analysis, setAnalysis] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [openSnackbar, setOpenSnackbar] = useState(false);
  const [fadeIn, setFadeIn] = useState(false);

  const fetchAnalysis = async () => {
    if (!user) return;
    setLoading(true);
    setError(null);
    setFadeIn(false);
    try {
      const token = await user.getIdToken();
      const res = await fetch(`${process.env.REACT_APP_API_URL || 'http://localhost:8000'}/analysis/${user.uid}/analyze`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
        },
      });
      const data = await res.json();
      if (data.status !== 'success') {
        setError(data.message || 'Analiz alınamadı.');
        setAnalysis(null);
      } else {
        setAnalysis(data.data);
        setTimeout(() => setFadeIn(true), 200); // animasyon için gecikme
      }
    } catch (e) {
      setError('Analiz alınırken bir hata oluştu.');
      setAnalysis(null);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchAnalysis();
    // eslint-disable-next-line
  }, [user]);

  const getCategoryMeta = (key: string) => CATEGORY_META[key.toLowerCase()] || { icon: <InfoIcon />, color: '#1976d2', badge: key };

  if (loading) return <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', minHeight: '60vh' }}><CircularProgress size={48} /></Box>;

  // Kullanıcı adı ve avatar
  const displayName = user?.displayName || user?.email?.split('@')[0] || 'Kullanıcı';
  const avatarLetter = displayName[0]?.toUpperCase() || '?';

  return (
    <Box sx={{ minHeight: '100vh', background: mode === 'dark' ? 'linear-gradient(135deg, #23272f 0%, #121212 100%)' : 'linear-gradient(135deg, #B2FEFA 0%, #0ED2F7 100%)' }}>
      <AppBar position="static" color="transparent" elevation={0} sx={{ background: 'transparent' }}>
        <Toolbar>
          <Typography variant="h6" sx={{ flexGrow: 1, fontWeight: 700, color: mode === 'dark' ? '#fff' : '#222' }}>
            Kapsamlı Profil Analizi
          </Typography>
          <IconButton color="inherit" onClick={toggleTheme}>
            {mode === 'dark' ? <LightModeIcon /> : <DarkModeIcon />}
          </IconButton>
          <IconButton color="inherit" onClick={logout} sx={{ ml: 1 }}>
            <LogoutIcon />
          </IconButton>
        </Toolbar>
      </AppBar>
      <Box sx={{ maxWidth: 950, mx: 'auto', mt: 4, mb: 2, px: 2 }}>
        {/* Özet Kartı */}
        <Fade in={fadeIn} timeout={800}>
          <Card elevation={6} sx={{ borderRadius: 4, mb: 4, p: 3, background: '#fff', display: 'flex', alignItems: 'center', boxShadow: 8 }}>
            <Avatar sx={{ bgcolor: '#1976d2', width: 72, height: 72, fontSize: 36, mr: 3 }}>{avatarLetter}</Avatar>
            <Box>
              <Typography variant="h4" fontWeight={900} color="primary.main" gutterBottom>
                {displayName}
              </Typography>
              <Typography variant="h6" color="text.secondary" gutterBottom>
                Kapsamlı Analiz Raporu
              </Typography>
              <Chip label="Kariyer Yolculuğu Başladı!" color="success" sx={{ fontWeight: 700, fontSize: 16, px: 2, py: 1, mb: 1 }} />
              <Typography variant="body1" color="text.secondary" sx={{ mt: 1 }}>
                Tüm adımlarınız ve cevaplarınız profesyonelce analiz edildi. Güçlü yönleriniz, gelişim alanlarınız ve önerileriniz aşağıda kategorilere ayrılmış şekilde sunulmuştur.
              </Typography>
            </Box>
            <Box flex={1} />
            <Button variant="outlined" color="primary" startIcon={<RefreshIcon />} sx={{ ml: 2, fontWeight: 700 }} onClick={fetchAnalysis}>
              Analizi Yenile
            </Button>
          </Card>
        </Fade>
        {/* Kategori Kartları */}
        {error && <Alert severity="error" sx={{ mb: 2 }}>{error}</Alert>}
        {analysis && (
          <Fade in={fadeIn} timeout={1000}>
            <Grid container spacing={4}>
              {Array.isArray(analysis?.kategoriler) && analysis.kategoriler.length > 0 ? (
                analysis.kategoriler.map((cat: any, idx: number) => {
                  const meta = CATEGORY_META[cat.ad] || { icon: <InfoIcon />, color: '#1976d2', badge: cat.ad };
                  return (
                    <Grid item xs={12} md={6} key={idx}>
                      <Card elevation={6} sx={{ borderRadius: 4, boxShadow: '0 4px 24px rgba(0,0,0,0.09)', borderLeft: `8px solid ${meta.color}` }}>
                        <CardContent>
                          <Box display="flex" alignItems="center" mb={1}>
                            {meta.icon}
                            <Typography variant="h6" fontWeight={800} color={meta.color} ml={2}>{cat.ad}</Typography>
                            <Chip label={meta.badge} sx={{ ml: 2, bgcolor: meta.color, color: '#fff', fontWeight: 700 }} />
                          </Box>
                          <Typography variant="subtitle1" color="text.secondary" fontWeight={600} mb={1}>{cat.aciklama}</Typography>
                          <Box mb={1}>
                            <Typography variant="subtitle2" color={meta.color} fontWeight={700}>Güçlü Yönler</Typography>
                            <ul style={{ margin: 0, paddingLeft: 20 }}>
                              {cat.guclu_yonler?.map((item: string, i: number) => <li key={i}>{item}</li>)}
                            </ul>
                          </Box>
                          <Box mb={1}>
                            <Typography variant="subtitle2" color={meta.color} fontWeight={700}>Gelişim Alanları</Typography>
                            <ul style={{ margin: 0, paddingLeft: 20 }}>
                              {cat.gelisim_alanlari?.map((item: string, i: number) => <li key={i}>{item}</li>)}
                            </ul>
                          </Box>
                          <Box mb={1}>
                            <Typography variant="subtitle2" color={meta.color} fontWeight={700}>Öneriler</Typography>
                            <ul style={{ margin: 0, paddingLeft: 20 }}>
                              {cat.oneriler?.map((item: string, i: number) => <li key={i}>{item}</li>)}
                            </ul>
                          </Box>
                          <Box mb={1}>
                            <Typography variant="subtitle2" color={meta.color} fontWeight={700}>Motivasyon</Typography>
                            <Typography variant="body2">{cat.motivasyon}</Typography>
                          </Box>
                          <Box mb={1}>
                            <Typography variant="subtitle2" color={meta.color} fontWeight={700}>Örnek</Typography>
                            <Typography variant="body2">{cat.ornek}</Typography>
                          </Box>
                          <Box mb={1}>
                            <Typography variant="subtitle2" color={meta.color} fontWeight={700}>Kaynaklar</Typography>
                            <ul style={{ margin: 0, paddingLeft: 20 }}>
                              {cat.kaynaklar?.map((item: string, i: number) => <li key={i}>{item}</li>)}
                            </ul>
                          </Box>
                        </CardContent>
                      </Card>
                    </Grid>
                  );
                })
              ) : (
                <Grid item xs={12}><Typography color="text.secondary">Kategori verisi bulunamadı.</Typography></Grid>
              )}
            </Grid>
          </Fade>
        )}
      </Box>
      <Snackbar open={!!error && openSnackbar} autoHideDuration={4000} onClose={() => setOpenSnackbar(false)} anchorOrigin={{ vertical: 'top', horizontal: 'center' }}>
        <Alert severity="error" sx={{ width: '100%' }}>{error}</Alert>
      </Snackbar>
    </Box>
  );
};

export default Analysis; 