import { StrictMode } from 'react';
import ReactDOM from 'react-dom/client';
import { theme } from './theme';
import { MantineProvider } from '@mantine/core';
import App from './App';
import './index.css';
import { isEnvBrowser } from './utils/misc';
import { Provider } from 'react-redux';
import { store } from './state';
import LocaleProvider from './providers/LocaleProvider';
import { HashRouter } from 'react-router-dom';
import { fetchNui } from './utils/fetchNui';

if (isEnvBrowser()) {
  const root = document.getElementById('root');

  // https://i.imgur.com/iPTAdYV.png - Night time img
  root!.style.backgroundImage = 'url("https://i.imgur.com/3pzRj9n.png")';
  root!.style.backgroundSize = 'cover';
  root!.style.backgroundRepeat = 'no-repeat';
  root!.style.backgroundPosition = 'center';
}

ReactDOM.createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <HashRouter>
      <MantineProvider theme={theme} withGlobalStyles withNormalizeCSS>
        <Provider store={store}>
          <LocaleProvider>
            <App />
          </LocaleProvider>
        </Provider>
      </MantineProvider>
    </HashRouter>
  </StrictMode>
);
