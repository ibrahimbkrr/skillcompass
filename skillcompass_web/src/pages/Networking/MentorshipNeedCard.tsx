import React, { useState } from 'react';
import { Typography, Chip, Box, TextField, Button, Stack } from '@mui/material';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';

const MENTORSHIP_OPTIONS = [
  'Kariyer Planlama',
  'Teknik Bilgi',
  'İletişim Becerileri',
  'Liderlik',
  'Diğer'
];

interface MentorshipNeedCardProps {
  value: string;
  onChange: (val: string) => void;
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

const MentorshipNeedCard: React.FC<MentorshipNeedCardProps> = ({ value, onChange, error, completed }) => {
  const [showCustom, setShowCustom] = useState(false);
  const [customValue, setCustomValue] = useState('');

  const handleChipClick = (option: string) => {
    if (option === 'Diğer') {
      setShowCustom(true);
      return;
    }
    if (value === option) {
      onChange('');
    } else {
      onChange(option);
    }
  };

  const handleAddCustom = () => {
    if (customValue.trim()) {
      onChange(customValue.trim());
      setCustomValue('');
      setShowCustom(false);
    }
  };

  const handleDelete = () => {
    onChange('');
  };

  return (
    <AnimatedQuestionCard completed={!!completed} borderColor={completed ? '#D4A017' : '#A0AEC0'}>
      <Typography variant="subtitle1" fontWeight={600} color="#2A4B7C" mb={1}>
        Hangi konuda mentorluk almak istersiniz?
      </Typography>
      <Stack direction="row" spacing={1} flexWrap="wrap" mb={1}>
        {MENTORSHIP_OPTIONS.map(option => (
          <Chip
            key={option}
            label={option}
            color={value === option ? 'warning' : 'default'}
            variant={value === option ? 'filled' : 'outlined'}
            onClick={() => handleChipClick(option)}
            sx={{ mb: 1, fontWeight: 500, fontSize: 15, background: value === option ? '#D4A017' : '#fff', color: value === option ? '#fff' : '#2A4B7C', borderRadius: 2 }}
            icon={option === 'Diğer' ? <span style={{ fontWeight: 'bold', color: '#D4A017' }}>+</span> : undefined}
            disabled={!!value && value !== option}
          />
        ))}
      </Stack>
      {showCustom && (
        <Box display="flex" alignItems="center" mb={1}>
          <TextField
            value={customValue}
            onChange={e => setCustomValue(e.target.value)}
            placeholder="Kendi mentorluk ihtiyacınızı yazın"
            inputProps={{ maxLength: 30 }}
            size="small"
            sx={{ mr: 1, flex: 1, background: '#F8FAFC', borderRadius: 2 }}
          />
          <Button
            variant="contained"
            color="warning"
            onClick={handleAddCustom}
            disabled={!customValue.trim()}
            sx={{ borderRadius: 2, fontWeight: 600 }}
          >
            Ekle
          </Button>
        </Box>
      )}
      {value && (
        <Chip
          label={value}
          onDelete={handleDelete}
          color="warning"
          sx={{ background: '#D4A017', color: '#fff', fontWeight: 600, borderRadius: 2, mb: 1, maxWidth: 200 }}
        />
      )}
      <Typography variant="body2" color="#6B7280">
        Mentorluk almak istediğiniz alanı seçin veya yazın.
      </Typography>
      {error && <Typography color="error" variant="body2">{error}</Typography>}
    </AnimatedQuestionCard>
  );
};

export default MentorshipNeedCard; 