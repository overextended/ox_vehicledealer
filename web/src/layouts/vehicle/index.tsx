import { Box, Button, createStyles, Stack, Title, Transition } from '@mantine/core';
import { useExitListener } from '../../hooks/useExitListener';
import { useAppDispatch, useAppSelector } from '../../state';
import StatBar from './components/StatBar';
import Color from './components/Color';
import PurchaseModal from './components/PurchaseModal';
import { useMemo, useState } from 'react';
import { useLocales } from '../../providers/LocaleProvider';
import { vehicleTypeToGroup } from '../../state/models/vehicles';

const useStyles = createStyles((theme) => ({
  wrapper: {
    display: 'flex',
    flexDirection: 'column',
    justifyContent: 'center',
    alignItems: 'flex-end',
    height: '100%',
    width: '100%',
  },

  box: {
    height: 'fit-content',
    width: 300,
    backgroundColor: theme.colors.dark[7],
    padding: 10,
    borderTopLeftRadius: theme.radius.sm,
    borderBottomLeftRadius: theme.radius.sm,
  },
}));

const Vehicle: React.FC = () => {
  const { classes } = useStyles();
  const { locale } = useLocales();
  const dispatch = useAppDispatch();
  const topStats = useAppSelector((state) => state.topStats);
  const vehicleVisibility = useAppSelector((state) => state.visibility.vehicle);
  const vehicleData = useAppSelector((state) => state.vehicleData);
  const [opened, setOpened] = useState(false);

  useExitListener(dispatch.visibility.setVehicleVisible);

  const getVehicleStat = useMemo(
    () => (key: 'speed' | 'handling' | 'braking' | 'acceleration') => {
      return (vehicleData[key] / topStats[vehicleTypeToGroup[vehicleData.type]][key]) * 100;
    },
    [vehicleData]
  );

  return (
    <Transition mounted={vehicleVisibility} transition="slide-left">
      {(style) => (
        <Box style={style} className={classes.wrapper}>
          <Box className={classes.box}>
            <Stack align="center">
              <Title order={4}>{`${vehicleData.make} ${vehicleData.name}`}</Title>
              <Color />
              <StatBar label={locale.ui.vehicle_info.speed} value={getVehicleStat('speed')} />
              <StatBar label={locale.ui.vehicle_info.acceleration} value={getVehicleStat('acceleration')} />
              <StatBar label={locale.ui.vehicle_info.braking} value={getVehicleStat('braking')} />
              <StatBar label={locale.ui.vehicle_info.handling} value={getVehicleStat('handling')} />
              <Button fullWidth uppercase onClick={() => setOpened(true)}>
                {locale.ui.vehicle_info.purchase}
              </Button>
            </Stack>
          </Box>
          <PurchaseModal opened={opened} setOpened={setOpened} price={vehicleData.price} vehicle={vehicleData} />
        </Box>
      )}
    </Transition>
  );
};

export default Vehicle;
