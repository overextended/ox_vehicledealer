import { Card, Stack, Group, Center, Button, Text, Paper, Box } from '@mantine/core';
import { FaCarSide } from 'react-icons/fa';
import { TbDatabase, TbPlus, TbTag } from 'react-icons/tb';
import IconGroup from '../../../../../components/IconGroup';
import { GalleryVehicle } from '../index';

interface Props {
  vehicle: GalleryVehicle | null;
  index: number;
}

const GalleryCard: React.FC<Props> = ({ vehicle, index }) => {
  return (
    <Paper
      sx={(theme) => ({
        height: 180,
        '&:hover': { backgroundColor: !vehicle ? theme.colors.dark[6] : undefined },
      })}
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
            <IconGroup
              label={Intl.NumberFormat('en-us', {
                style: 'currency',
                currency: 'USD',
                maximumFractionDigits: 0,
              }).format(vehicle.price)}
              Icon={TbTag}
              textColor="teal"
            />
            <IconGroup label={vehicle.stock} Icon={TbDatabase} />
          </Group>
          <Button fullWidth uppercase color="red" variant="light">
            Remove vehicle
          </Button>
        </Stack>
      )}
    </Paper>
  );
};

export default GalleryCard;
