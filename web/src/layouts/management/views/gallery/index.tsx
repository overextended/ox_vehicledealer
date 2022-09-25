import { ScrollArea, SimpleGrid, Paper, Box, Center, Text, Stack, Group, Button } from '@mantine/core';
import { useState } from 'react';
import GalleryCard from './components/GalleryCard';
import IconGroup from '../../../../components/IconGroup';
import { TbDatabase, TbPlus, TbTag } from 'react-icons/tb';
import { VehicleStock } from '../../../../state/models/vehicleStock';

export interface GalleryVehicle {
  make: string;
  name: string;
  price: number;
  stock: number;
  wholesale: number;
  gallery: boolean;
  model: string;
}

const Gallery: React.FC = () => {
  const [gallerySlots, setGallerySlots] = useState<Array<null | GalleryVehicle>>([
    null,
    { make: 'Dinka', name: 'Blista', stock: 3, price: 13000, wholesale: 9500, model: 'blista', gallery: true },
    null,
    { make: 'Vapid', name: 'Dominator', price: 29000, wholesale: 15000, stock: 1, gallery: false, model: 'dominator' },
    null,
  ]);

  return (
    <Box p={16}>
      <ScrollArea offsetScrollbars scrollbarSize={6} style={{ height: 584 }}>
        <SimpleGrid cols={3}>
          {gallerySlots.map((vehicle, index) => (
            <GalleryCard vehicle={vehicle} index={index} />
          ))}
        </SimpleGrid>
      </ScrollArea>
    </Box>
  );
};

export default Gallery;
