import { AppShell, Center, Transition } from '@mantine/core';
import { Routes, Route } from 'react-router-dom';
import { useExitListener } from '../../hooks/useExitListener';
import { useNuiEvent } from '../../hooks/useNuiEvent';
import { useAppDispatch, useAppSelector } from '../../state';
import Nav from './components/nav';
import Stock from './views/stock';
import Gallery from './views/gallery';

const Management: React.FC = () => {
  const dispatch = useAppDispatch();
  const visible = useAppSelector((state) => state.visibility.management);

  useNuiEvent('setManagementVisible', (data) => dispatch.visibility.setManagementVisible(true));

  useExitListener(dispatch.visibility.setManagementVisible);

  return (
    <Center sx={{ height: '100%', position: 'absolute', width: '100%' }}>
      <Transition transition="slide-up" mounted={visible}>
        {(style) => (
          <AppShell
            style={style}
            padding={0}
            fixed={false}
            styles={(theme) => ({
              main: {
                backgroundColor: theme.colors.dark[8],
                width: 900,
                height: 600,
                borderTopRightRadius: theme.radius.sm,
                borderBottomRightRadius: theme.radius.sm,
              },
            })}
            navbar={<Nav />}
          >
            <Routes>
              <Route path="/" element={<Stock />} />
              <Route path="/gallery" element={<Gallery />} />
            </Routes>
          </AppShell>
        )}
      </Transition>
    </Center>
  );
};

export default Management;
