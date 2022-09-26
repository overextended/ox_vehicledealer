import { Select, Stack, Button } from '@mantine/core';
import { TbCar } from 'react-icons/tb';
import { useAppSelector } from '../../../../../state';
import { GalleryVehicle } from '../index';
import { closeAllModals } from '@mantine/modals';
import { useState } from 'react';

interface Props {
  setGallerySlots: React.Dispatch<React.SetStateAction<(GalleryVehicle | null)[]>>;
  index: number;
}

const GalleryModal: React.FC<Props> = ({ setGallerySlots, index }) => {
  const vehicleStock = useAppSelector((state) => state.vehicleStock);
  const vehicles = Object.entries(vehicleStock).map((vehicle) => {
    const vehicleModel = vehicle[0];
    const vehicleData = vehicle[1];
    return { label: `${vehicleData.make} ${vehicleData.name}`, value: vehicleModel };
  });
  const [selectedVehicle, setSelectedVehicle] = useState<string | null>(null);

  return (
    <Stack>
      <Select
        data={vehicles}
        icon={<TbCar size={20} />}
        searchable
        clearable
        value={selectedVehicle}
        onChange={(value) => setSelectedVehicle(value)}
      />
      <Button
        uppercase
        fullWidth
        variant="light"
        onClick={() => {
          closeAllModals();
          if (!selectedVehicle) return;
          setGallerySlots((prevState) => {
            return prevState.map((item, indx) => {
              if (indx === index) return { ...vehicleStock[selectedVehicle], model: selectedVehicle };
              else return item;
            });
          });
        }}
      >
        Confirm
      </Button>
    </Stack>
  );
};

export default GalleryModal;
