import React, { useState } from 'react';
import { Card, CardContent, Typography, Chip, Box, TextField, Button, Stack } from '@mui/material';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';

const PRIORITY_OPTIONS = [
  'Beceri Geliştirme',
  'Networking',
  'Proje Deneyimi',
  'Liderlik ve Yönetim',
  'Girişimcilik',
  'Sertifikasyon ve Eğitim',
  'İş-Yaşam Dengesi',
  'Diğer'
];

interface PrioritiesCardProps {
  values: string[];
  onChange: (vals: string[]) => void;
  error?: string;
  completed?: boolean;
}

const PrioritiesCard: React.FC<PrioritiesCardProps> = ({ values, onChange, error, completed }) => {
  const [showCustom, setShowCustom] = useState(false);
  const [customValue, setCustomValue] = useState('');

  const handleChipClick = (option: string) => {
    if (option === 'Diğer') {
      setShowCustom(true);
      return;
    }
    if (values.includes(option)) {
      onChange(values.filter(v => v !== option));
    } else if (values.length < 3) {
      onChange([...values, option]);
    }
  };

  const handleAddCustom = () => {
    if (customValue.trim() && values.length < 3) {
      onChange([...values, customValue.trim()]);
      setCustomValue('');
      setShowCustom(false);
    }
  };

  const handleDelete = (val: string) => {
    onChange(values.filter(v => v !== val));
  };

  return (
    <Card elevation={completed ? 6 : 2} sx={{ borderRadius: 3, border: completed ? '2px solid #D4A017' : '1px solid #A0AEC0', mb: 3, position: 'relative' }}>
      <CardContent>
        <Box display="flex" alignItems="center" mb={1}>
          <Typography variant="h6" fontWeight={600} color="#2A4B7C" flex={1}>
            Hedeflerinize ulaşmak için neler ön planda?
          </Typography>
          <Typography variant="body2" color="#D4A017" fontWeight={600}>
            {values.length}/3
          </Typography>
          {completed && <CheckCircleIcon sx={{ color: '#D4A017', ml: 1 }} />}
        </Box>
        <Stack direction="row" spacing={1} flexWrap="wrap" mb={1}>
          {PRIORITY_OPTIONS.map(option => (
            <Chip
              key={option}
              label={option}
              color={values.includes(option) ? 'warning' : 'default'}
              variant={values.includes(option) ? 'filled' : 'outlined'}
              onClick={() => handleChipClick(option)}
              sx={{ mb: 1, fontWeight: 500, fontSize: 15, background: values.includes(option) ? '#D4A017' : '#fff', color: values.includes(option) ? '#fff' : '#2A4B7C', borderRadius: 2 }}
              icon={option === 'Diğer' ? <span style={{ fontWeight: 'bold', color: '#D4A017' }}>+</span> : undefined}
              disabled={values.length >= 3 && !values.includes(option)}
            />
          ))}
        </Stack>
        {showCustom && (
          <Box display="flex" alignItems="center" mb={1}>
            <TextField
              value={customValue}
              onChange={e => setCustomValue(e.target.value)}
              placeholder="Kendi önceliğinizi yazın"
              inputProps={{ maxLength: 30 }}
              size="small"
              sx={{ mr: 1, flex: 1, background: '#F8FAFC', borderRadius: 2 }}
            />
            <Button
              variant="contained"
              color="warning"
              onClick={handleAddCustom}
              disabled={!customValue.trim() || values.length >= 3}
              sx={{ borderRadius: 2, fontWeight: 600 }}
            >
              Ekle
            </Button>
          </Box>
        )}
        <Stack direction="row" spacing={1} flexWrap="wrap" mb={1}>
          {values.map(val => (
            <Chip
              key={val}
              label={val}
              onDelete={() => handleDelete(val)}
              color="warning"
              sx={{ background: '#D4A017', color: '#fff', fontWeight: 600, borderRadius: 2, mb: 1, maxWidth: 200 }}
            />
          ))}
        </Stack>
        <Typography variant="body2" color="#6B7280">
          Hedeflerinize ulaşmak için en önemli 3 alanı seçin. Size özel bir yol haritası çizeceğiz.
        </Typography>
        {error && <Typography color="error" variant="body2">{error}</Typography>}
      </CardContent>
    </Card>
  );
};

export default PrioritiesCard; 