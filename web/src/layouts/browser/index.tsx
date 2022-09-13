import { Divider, ScrollArea, Stack, Transition } from '@mantine/core';
import { Navbar } from '@mantine/core';
import VehicleList from './components/VehicleList';
import TopNav from './components/TopNav';
import { useAppSelector } from '../../state';
import { useLocales } from '../../providers/LocaleProvider';

const VehicleBrowser: React.FC<{ categories: string[] }> = ({ categories }) => {
  const browserVisibility = useAppSelector((state) => state.visibility.browser);
  const { locale } = useLocales();

  return (
    <Transition mounted={browserVisibility} transition="slide-right">
      {(style) => (
        <Navbar
          height="100%"
          width={{ base: 300 }}
          fixed
          style={style}
          sx={(theme) => ({
            backgroundColor: theme.colors.dark[7],
          })}
        >
          <Navbar.Section>
            <Stack align="center" p={10} sx={{ width: '100%' }}>
              <TopNav categories={categories} />
              <Divider sx={{ width: '100%' }} label={locale.ui.vehicles} my="xs" labelPosition="center" />
            </Stack>
          </Navbar.Section>

          <Navbar.Section grow component={ScrollArea} p={10} offsetScrollbars scrollbarSize={6}>
            <VehicleList />
          </Navbar.Section>
        </Navbar>
      )}
    </Transition>
  );
};

export default VehicleBrowser;
