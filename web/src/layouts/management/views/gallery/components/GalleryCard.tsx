import { Stack, Group, Center, Button, Text, Paper, Box } from '@mantine/core';
import { TbDatabase, TbPlus, TbTag } from 'react-icons/tb';
import IconGroup from '../../../../../components/IconGroup';
import { openModal } from '@mantine/modals';
import GalleryModal from './GalleryModal';
import { fetchNui } from '../../../../../utils/fetchNui';
import { useAppDispatch } from '../../../../../state';
import { VehicleStock } from '../../../../../state/models/vehicleStock';
import { formatNumber } from '../../../../../utils/formatNumber';
import { useLocales } from '../../../../../providers/LocaleProvider';

interface Props {
  vehicle: VehicleStock | null;
  index: number;
  setGallerySlots: React.Dispatch<React.SetStateAction<(VehicleStock | null)[]>>;
}

const GalleryCard: React.FC<Props> = ({ vehicle, index, setGallerySlots }) => {
  const dispatch = useAppDispatch();
  const { locale } = useLocales();

  return (
    <Paper
      sx={(theme) => ({
        height: 180,
        '&:hover': { backgroundColor: !vehicle ? theme.colors.dark[6] : undefined },
      })}
      onClick={() => {
        if (vehicle) return;
        openModal({
          title: locale.ui.management_gallery.add_vehicle,
          children: <GalleryModal index={index} setGallerySlots={setGallerySlots} />,
        });
      }}
      p="md"
    >
      {!vehicle ? (
        <Center sx={{ height: '100%' }}>
          <TbPlus size={32} />
        </Center>
      ) : (
        <Stack justify="space-between" sx={{ height: '100%' }}>
          <Box>
            <Text>{vehicle.make}</Text>
            <Text>{vehicle.name}</Text>
          </Box>
          <Group position="apart">
            <IconGroup label={formatNumber(vehicle.price)} Icon={TbTag} textColor="teal" />
            <Text>{vehicle.plate}</Text>
          </Group>
          <Button
            fullWidth
            uppercase
            color="red"
            variant="light"
            onClick={() => {
              setGallerySlots((prevState) => {
                return prevState.map((item, indx) => {
                  if (indx === index) return null;
                  else return item;
                });
              });
              fetchNui('galleryRemoveVehicle', { vehicle: vehicle.id, slot: index + 1 });
              dispatch.vehicleStock.setVehicleInGallery({ plate: vehicle.plate, gallery: false });
            }}
          >
            {locale.ui.management_gallery.remove_vehicle}
          </Button>
        </Stack>
      )}
    </Paper>
  );
};

export default GalleryCard;
