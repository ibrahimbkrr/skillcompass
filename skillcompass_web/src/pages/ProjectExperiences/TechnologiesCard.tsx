import React, { useState } from 'react';
import { Typography, Chip, Box, TextField, Button, Stack } from '@mui/material';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';

const TECH_OPTIONS = [
  'Flutter/Dart',
  'Python',
  'JavaScript/React',
  'Java',
  'SQL/NoSQL',
  'Diğer'
];

interface TechnologiesCardProps {
  values: string[];
  onChange: (vals: string[]) => void;
  error?: string;
  completed?: boolean;
}

const AnimatedQuestionCard: React.FC<{ completed: boolean; children: React.ReactNode; borderColor: string }> = ({ completed, children, borderColor }) => (
  <Box sx={{ position: 'relative', mb: 2 }}>
    <Box
      sx={{
        p: 3,
        borderRadius: 2,
        border: `2px solid ${borderColor}`,
        boxShadow: completed ? 6 : 1,
        background: '#fff',
        transition: 'border-color 0.3s, box-shadow 0.3s',
      }}
    >
      {children}
      {completed && (
        <Box sx={{ position: 'absolute', top: 12, right: 12, bgcolor: '#fff', borderRadius: '50%', boxShadow: 2, p: 0.5 }}>
          <CheckCircleIcon sx={{ color: '#D4A017' }} fontSize="small" />
        </Box>
      )}
    </Box>
  </Box>
);

const TechnologiesCard: React.FC<TechnologiesCardProps> = ({ values, onChange, error, completed }) => {
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
    <AnimatedQuestionCard completed={!!completed} borderColor={completed ? '#D4A017' : '#A0AEC0'}>
      <Box display="flex" alignItems="center" mb={1}>
        <Typography variant="subtitle1" fontWeight={600} color="#2A4B7C" flex={1}>
          Projelerinizde hangi teknolojileri veya araçları kullandınız?
        </Typography>
        <Typography variant="body2" color="#D4A017" fontWeight={600}>
          {values.length}/3
        </Typography>
      </Box>
      <Stack direction="row" spacing={1} flexWrap="wrap" mb={1}>
        {TECH_OPTIONS.map(option => (
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
            placeholder="Kendi teknolojinizi yazın"
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
        Projelerinizde kullandığınız teknolojileri seçin.
      </Typography>
      {error && <Typography color="error" variant="body2">{error}</Typography>}
    </AnimatedQuestionCard>
  );
};

export default TechnologiesCard; 