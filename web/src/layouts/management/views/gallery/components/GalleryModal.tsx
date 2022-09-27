import { Select, Stack, Button } from '@mantine/core';
import { TbCar } from 'react-icons/tb';
import { useAppDispatch, useAppSelector } from '../../../../../state';
import { closeAllModals } from '@mantine/modals';
import { useState } from 'react';
import { fetchNui } from '../../../../../utils/fetchNui';
import { VehicleStock } from '../../../../../state/models/vehicleStock';

interface Props {
  setGallerySlots: React.Dispatch<React.SetStateAction<(VehicleStock | null)[]>>;
  index: number;
}

const GalleryModal: React.FC<Props> = ({ setGallerySlots, index }) => {
  const dispatch = useAppDispatch();
  const vehicleStock = useAppSelector((state) => state.vehicleStock);
  const vehicles = vehicleStock.map((vehicle) => {
    return { label: `${vehicle.make} ${vehicle.name} - ${vehicle.plate}`, value: vehicle.plate };
  });
  const [selectedVehicle, setSelectedVehicle] = useState<string | null>(null);

  return (
    <Stack>
      <Select
        data={vehicles}
        icon={<TbCar size={20} />}
        searchable
        clearable
        nothingFound="No such vehicle in stock"
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
              if (indx === index) return vehicleStock.find((veh) => veh.plate === selectedVehicle)!;
              else return item;
            });
          });
          fetchNui('galleryAddVehicle', { vehicle: selectedVehicle, slot: index + 1 });
          dispatch.vehicleStock.setVehicleInGallery({ plate: selectedVehicle, gallery: true });
        }}
      >
        Confirm
      </Button>
    </Stack>
  );
};

export default GalleryModal;
