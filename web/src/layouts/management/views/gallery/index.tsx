import { ScrollArea, SimpleGrid, Paper, Box, Center, Text, Stack, Group, Button } from '@mantine/core';
import { useEffect, useState } from 'react';
import GalleryCard from './components/GalleryCard';
import IconGroup from '../../../../components/IconGroup';
import { TbDatabase, TbPlus, TbTag } from 'react-icons/tb';
import { VehicleStock } from '../../../../state/models/vehicleStock';
import { isEnvBrowser } from '../../../../utils/misc';
import { fetchNui } from '../../../../utils/fetchNui';
import { useAppSelector } from '../../../../state';

export interface GalleryVehicle {
  make: string;
  name: string;
  price: number;
  stock: number;
  wholesale: number;
  model: string;
}

const Gallery: React.FC = () => {
  const [gallerySlots, setGallerySlots] = useState<Array<null | GalleryVehicle>>([]);
  const vehicleStock = useAppSelector((state) => state.vehicleStock);

  useEffect(() => {
    if (isEnvBrowser())
      return setGallerySlots([
        null,
        { make: 'Dinka', name: 'Blista', stock: 3, price: 13000, wholesale: 9500, model: 'blista' },
        null,
        {
          make: 'Vapid',
          name: 'Dominator',
          price: 29000,
          wholesale: 15000,
          stock: 1,
          model: 'dominator',
        },
        null,
      ]);

    const fetchGallery = async () => {
      const fetchedGallery = (await fetchNui('fetchGallery')) as Array<string | null>;
      const galleryArray: Array<null | GalleryVehicle> = [];
      for (const vehicle of fetchedGallery) {
        galleryArray.push(vehicle ? { ...vehicleStock[vehicle], model: vehicle } : null);
      }
      setGallerySlots(galleryArray);
    };

    fetchGallery().catch();
  }, []);

  return (
    <Box p={16}>
      <ScrollArea offsetScrollbars scrollbarSize={6} style={{ height: 584 }}>
        <SimpleGrid cols={3}>
          {gallerySlots.map((vehicle, index) => (
            <GalleryCard vehicle={vehicle} index={index} setGallerySlots={setGallerySlots} key={`${index}`} />
          ))}
        </SimpleGrid>
      </ScrollArea>
    </Box>
  );
};

export default Gallery;
