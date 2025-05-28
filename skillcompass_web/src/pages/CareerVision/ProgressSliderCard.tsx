import React from 'react';
import { Card, CardContent, Typography, Slider, Box } from '@mui/material';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';

interface ProgressSliderCardProps {
  value: number;
  onChange: (val: number) => void;
  completed?: boolean;
}

const getProgressText = (progress: number) => {
  if (progress <= 25) return 'Yolun başındayım, rehber bir plana ihtiyacım var.';
  if (progress <= 50) return 'Bazı adımlar attım, ama daha yolum var.';
  if (progress <= 75) return 'Hedeflerime yaklaşıyorum, stratejik önerilere açığım.';
  return 'Hedeflerime çok yakınım, son adımları planlıyorum.';
};

const ProgressSliderCard: React.FC<ProgressSliderCardProps> = ({ value, onChange, completed }) => {
  return (
    <Card elevation={completed ? 6 : 2} sx={{ borderRadius: 3, border: completed ? '2px solid #D4A017' : '1px solid #A0AEC0', mb: 3, position: 'relative' }}>
      <CardContent>
        <Box display="flex" alignItems="center" mb={1}>
          <Typography variant="h6" fontWeight={600} color="#2A4B7C" flex={1}>
            Hedeflerinize ulaşmaya ne kadar yakınsınız?
          </Typography>
          {completed && <CheckCircleIcon sx={{ color: '#D4A017', ml: 1 }} />}
        </Box>
        <Slider
          value={value}
          min={0}
          max={100}
          step={1}
          onChange={(_, val) => onChange(typeof val === 'number' ? val : value)}
          valueLabelDisplay="auto"
          sx={{ color: '#2A4B7C', mb: 1 }}
        />
        <Typography variant="body2" color="#4A4A4A" mb={1}>
          {getProgressText(value)}
        </Typography>
        <Typography variant="body2" color="#6B7280">
          Mevcut durumunuzu dürüstçe değerlendirin. Bu, size en uygun adımları önermemizi sağlayacak.
        </Typography>
      </CardContent>
    </Card>
  );
};

export default ProgressSliderCard; 