import { Select, Stack, Button, NumberInput } from '@mantine/core';
import { TbCar, TbTag } from 'react-icons/tb';
import { useAppDispatch, useAppSelector } from '../../../../../state';
import { closeAllModals } from '@mantine/modals';
import { useMemo, useRef, useState } from 'react';
import { fetchNui } from '../../../../../utils/fetchNui';
import { VehicleStock } from '../../../../../state/models/vehicleStock';

interface Props {
  setGallerySlots: React.Dispatch<React.SetStateAction<(VehicleStock | null)[]>>;
  index: number;
}

const GalleryModal: React.FC<Props> = ({ setGallerySlots, index }) => {
  const dispatch = useAppDispatch();
  const ref = useRef<HTMLInputElement | null>(null);
  const [vehicles, setVehicles] = useState<{ label: string; value: string }[]>([]);
  const vehicleStock = useAppSelector((state) => state.vehicleStock);
  const [selectedVehicle, setSelectedVehicle] = useState<string | null>(null);

  useMemo(() => {
    setVehicles(
      vehicleStock
        .filter((vehicle) => !vehicle.gallery)
        .map((vehicle) => {
          return { label: `${vehicle.make} ${vehicle.name} - ${vehicle.plate}`, value: vehicle.plate };
        })
    );
  }, [vehicleStock]);

  return (
    <Stack>
      <Select
        data={vehicles}
        icon={<TbCar size={20} />}
        searchable
        clearable
        label="Vehicle"
        description="Select a vehicle from the stock to display"
        nothingFound="No such vehicle in stock"
        value={selectedVehicle}
        onChange={(value) => setSelectedVehicle(value)}
      />
      <NumberInput
        label="Vehicle price"
        ref={ref}
        description="Set the price of the vehicle"
        hideControls
        icon={<TbTag size={20} />}
      />
      <Button
        uppercase
        fullWidth
        variant="light"
        onClick={() => {
          if (!ref.current?.value || !selectedVehicle) return;
          closeAllModals();
          dispatch.vehicleStock.setVehicleInGallery({
            plate: selectedVehicle,
            gallery: true,
            price: parseInt(ref.current.value),
          });
          // @ts-ignore
          setGallerySlots((prevState) => {
            return prevState.map((item, indx) => {
              if (indx === index)
                return { ...vehicleStock.find((veh) => veh.plate === selectedVehicle)!, price: ref.current!.value };
              else return item;
            });
          });
          fetchNui('galleryAddVehicle', { vehicle: selectedVehicle, slot: index + 1, price: ref.current.value });
        }}
      >
        Confirm
      </Button>
    </Stack>
  );
};

export default GalleryModal;
