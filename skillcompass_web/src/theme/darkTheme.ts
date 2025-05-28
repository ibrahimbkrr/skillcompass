import { ThemeOptions } from '@mui/material/styles';

const darkTheme: ThemeOptions = {
  palette: {
    mode: 'dark',
    primary: {
      main: '#90caf9',
    },
    secondary: {
      main: '#ffb300',
    },
    background: {
      default: '#121212',
      paper: '#23272f',
    },
  },
  shape: {
    borderRadius: 12,
  },
  typography: {
    fontFamily: 'Nunito, Arial, sans-serif',
    fontWeightBold: 700,
  },
};

export default darkTheme; 