import { Select, Stack, Button, NumberInput } from '@mantine/core';
import { TbCar, TbTag } from 'react-icons/tb';
import { useAppDispatch, useAppSelector } from '../../../../../state';
import { closeAllModals } from '@mantine/modals';
import { useMemo, useRef, useState } from 'react';
import { fetchNui } from '../../../../../utils/fetchNui';
import { VehicleStock } from '../../../../../state/models/vehicleStock';
import { useLocales } from '../../../../../providers/LocaleProvider';

interface Props {
  setGallerySlots: React.Dispatch<React.SetStateAction<(VehicleStock | null)[]>>;
  index: number;
}

const GalleryModal: React.FC<Props> = ({ setGallerySlots, index }) => {
  const dispatch = useAppDispatch();
  const { locale } = useLocales();
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
        label={locale.ui.management_gallery.modal.vehicle_select}
        description={locale.ui.management_gallery.modal.vehicle_select_description}
        nothingFound={locale.ui.management_gallery.modal.vehicle_nothing_found}
        value={selectedVehicle}
        onChange={(value) => setSelectedVehicle(value)}
      />
      <NumberInput
        label={locale.ui.management.vehicle_price}
        ref={ref}
        description={locale.ui.management_gallery.modal.vehicle_price_description}
        hideControls
        icon={<TbTag size={20} />}
      />
      <Button
        uppercase
        fullWidth
        variant="light"
        onClick={() => {
          if (!selectedVehicle) return;
          const vehicle = vehicleStock.find((veh) => veh.plate === selectedVehicle)!;
          const price = ref.current?.value || vehicle.wholesale;
          closeAllModals();
          dispatch.vehicleStock.setVehicleInGallery({
            plate: selectedVehicle,
            gallery: true,
            price: parseInt(price as string),
          });
          // @ts-ignore
          setGallerySlots((prevState) => {
            return prevState.map((item, indx) => {
              if (indx === index) return { ...vehicleStock.find((veh) => veh.plate === selectedVehicle)!, price };
              else return item;
            });
          });
          fetchNui('galleryAddVehicle', { vehicle: selectedVehicle, slot: index + 1, price });
        }}
      >
        {locale.ui.confirm}
      </Button>
    </Stack>
  );
};

export default GalleryModal;
