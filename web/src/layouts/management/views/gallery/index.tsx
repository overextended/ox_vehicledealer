import { ScrollArea, SimpleGrid } from '@mantine/core';
import { useState } from 'react';
import GalleryCard from './components/GalleryCard';

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
    <ScrollArea offsetScrollbars scrollbarSize={6} style={{ height: 584 }}>
      <SimpleGrid p="md" cols={3}>
        {gallerySlots.map((vehicle, index) => (
          <GalleryCard vehicle={vehicle} index={index} />
        ))}
      </SimpleGrid>
    </ScrollArea>
  );
};

export default Gallery;
