import React from 'react';
import { Typography, TextField, IconButton, Box, Alert } from '@mui/material';
import LightbulbIcon from '@mui/icons-material/Lightbulb';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';

interface NetworkingChallengesCardProps {
  value: string;
  onChange: (val: string) => void;
  error?: string;
  completed?: boolean;
  showInspire: boolean;
  inspireText: string;
  onInspire: () => void;
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

const NetworkingChallengesCard: React.FC<NetworkingChallengesCardProps> = ({ value, onChange, error, completed, showInspire, inspireText, onInspire }) => {
  return (
    <AnimatedQuestionCard completed={!!completed} borderColor={completed ? '#D4A017' : '#A0AEC0'}>
      <Typography variant="subtitle1" fontWeight={600} mb={1} color="#2A4B7C">
        Networking sürecinde karşılaştığınız en büyük zorluk nedir?
      </Typography>
      <Box display="flex" alignItems="flex-start" mb={1}>
        <TextField
          fullWidth
          multiline
          minRows={2}
          maxRows={4}
          value={value}
          onChange={e => onChange(e.target.value)}
          inputProps={{ maxLength: 100 }}
          placeholder="Örneğin: Zaman eksikliği nedeniyle etkinliklere katılamamak."
          error={!!error}
          helperText={error || 'Networking zorluğunuzu kısaca açıklayın (en az 10 karakter).'}
          size="small"
          sx={{ background: '#F8FAFC', borderRadius: 2 }}
        />
        <IconButton onClick={onInspire} sx={{ ml: 1, mt: 0.5 }} aria-label="İlham önerisi göster">
          <LightbulbIcon sx={{ color: '#D4A017' }} />
        </IconButton>
      </Box>
      {showInspire && (
        <Alert severity="info" sx={{ mb: 1 }}>{inspireText}</Alert>
      )}
    </AnimatedQuestionCard>
  );
};

export default NetworkingChallengesCard; 