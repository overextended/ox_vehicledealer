import { Stack, Text, Center, Loader } from '@mantine/core';
import { useState } from 'react';
import { TbSearch } from 'react-icons/tb';
import { useLocales } from '../../../providers/LocaleProvider';
import { useAppSelector } from '../../../state';
import VehiclePaper from './VehiclePaper';

const VehicleList: React.FC = () => {
  const vehicles = useAppSelector((state) => state.listVehicles);
  const isLoading = useAppSelector((state) => state.isLoading);
  const { locale } = useLocales();

  return (
    <>
      {isLoading ? (
        <Center style={{ position: 'absolute', top: '50%', left: '50%', transform: 'translate(-50%, -50%)' }}>
          <Loader />
        </Center>
      ) : (
        <>
          {Object.keys(vehicles).length > 0 ? (
            <Stack spacing="sm">
              {Object.entries(vehicles).map((vehicle, index) => (
                <VehiclePaper key={`vehicle-${index}`} vehicle={vehicle[1]} index={vehicle[0]} />
              ))}
            </Stack>
          ) : (
            <Center>
              <Stack align="center">
                <TbSearch fontSize={48} />
                <Text size="xl">{locale.ui.no_vehicles_found}</Text>
              </Stack>
            </Center>
          )}
        </>
      )}
    </>
  );
};

export default VehicleList;
