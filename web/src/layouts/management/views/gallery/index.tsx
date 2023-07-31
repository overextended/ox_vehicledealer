import { ScrollArea, SimpleGrid, Paper, Box, Center, Text, Stack, Group, Button } from '@mantine/core';
import { useEffect, useState } from 'react';
import GalleryCard from './components/GalleryCard';
import IconGroup from '../../../../components/IconGroup';
import { TbDatabase, TbPlus, TbTag } from 'react-icons/tb';
import { VehicleStock } from '../../../../state/models/vehicleStock';
import { isEnvBrowser } from '../../../../utils/misc';
import { fetchNui } from '../../../../utils/fetchNui';
import { useAppSelector } from '../../../../state';

const Gallery: React.FC = () => {
  const [gallerySlots, setGallerySlots] = useState<Array<null | VehicleStock>>([]);
  const vehicleStock = useAppSelector((state) => state.vehicleStock);

  useEffect(() => {
    if (isEnvBrowser()) return setGallerySlots([null, vehicleStock[0], null, vehicleStock[1], null]);

    const fetchGallery = async () => {
      const fetchedGallery = (await fetchNui('fetchGallery')) as Array<number | null>;
      const galleryArray: Array<null | VehicleStock> = [];
      for (const id of fetchedGallery) {
        galleryArray.push(id ? vehicleStock.find((veh) => veh.id === id)! : null);
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
