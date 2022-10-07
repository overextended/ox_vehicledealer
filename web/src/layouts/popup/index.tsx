import { Box, createStyles, Stack, Text, Transition } from '@mantine/core';
import { useMemo, useState } from 'react';
import { VehicleData } from '../../state/models/vehicles';
import StatBar from '../vehicle/components/StatBar';
import { useLocales } from '../../providers/LocaleProvider';
import { useAppSelector } from '../../state';
import { useNuiEvent } from '../../hooks/useNuiEvent';
import { vehicleTypeToGroup } from '../../state/models/vehicles';
import { useAppDispatch } from '../../state';
import { formatNumber } from '../../utils/formatNumber';

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

const Popup: React.FC = () => {
  const { classes } = useStyles();
  const { locale } = useLocales();
  const dispatch = useAppDispatch();
  const [visible, setVisible] = useState(false);
  const topStats = useAppSelector((state) => state.topStats);
  const [vehicle, setVehicle] = useState<VehicleData>({
    name: '',
    acceleration: 0,
    braking: 0,
    class: 0,
    doors: 0,
    handling: 0,
    make: '',
    price: 0,
    seats: 0,
    speed: 0,
    type: 'automobile',
    weapons: false,
  });

  useNuiEvent('setStatsVisible', (data: [string, number] | false) => {
    if (!data) return setVisible(false);
    const vehicle = dispatch.vehicleData.getSingleVehicle(data[0]);
    vehicle.price = data[1];
    setVehicle(vehicle);
    setVisible(true);
  });

  const getVehicleStat = useMemo(
    () => (key: 'speed' | 'handling' | 'braking' | 'acceleration') => {
      return (vehicle[key] / topStats[vehicleTypeToGroup[vehicle.type]][key]) * 100;
    },
    [vehicle]
  );

  return (
    <Transition mounted={visible} transition="slide-left">
      {(style) => (
        <Box style={style} className={classes.wrapper}>
          <Box className={classes.box}>
            <Stack>
              <Text align="center" size={20} weight={700}>{`${vehicle.make} ${vehicle.name}`}</Text>
              <StatBar label={locale.ui.vehicle_info.speed} value={getVehicleStat('speed')} />
              <StatBar label={locale.ui.vehicle_info.acceleration} value={getVehicleStat('acceleration')} />
              <StatBar label={locale.ui.vehicle_info.braking} value={getVehicleStat('braking')} />
              <StatBar label={locale.ui.vehicle_info.handling} value={getVehicleStat('handling')} />
              <Text align="center" color="teal" size={20} weight={700}>
                {formatNumber(vehicle.price)}
              </Text>
            </Stack>
          </Box>
        </Box>
      )}
    </Transition>
  );
};

export default Popup;
