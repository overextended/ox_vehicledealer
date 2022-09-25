import { ScrollArea, SimpleGrid, Paper, Box, Center, Text, Stack, Group, Button } from '@mantine/core';
import { useState } from 'react';
import GalleryCard from './components/GalleryCard';
import IconGroup from '../../../../components/IconGroup';
import { TbDatabase, TbPlus, TbTag } from 'react-icons/tb';

const Gallery: React.FC = () => {
  const [gallerySlots, setGallerySlots] = useState<
    Array<null | { make: string; name: string; stock: number; salePrice: number }>
  >([
    null,
    { make: 'Dinka', name: 'Blista', stock: 3, salePrice: 9500 },
    null,
    { make: 'Vapid', name: 'Dominator', stock: 1, salePrice: 150000 },
    null,
  ]);

  return (
    <Box p={16}>
      <ScrollArea offsetScrollbars scrollbarSize={6} style={{ height: 584 }}>
        <SimpleGrid cols={3}>
          {gallerySlots.map((vehicle, index) => (
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
                      }).format(vehicle.salePrice)}
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
          ))}
        </SimpleGrid>
      </ScrollArea>
    </Box>
  );
};

export default Gallery;
