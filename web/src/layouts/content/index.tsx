import { SimpleGrid, ScrollArea } from "@mantine/core";
import VehicleCard from "../../components/VehicleCard";

const data = [
  { make: "Dinka", name: "Blista", price: 3000, seats: 4, doors: 4, weapons: false },
  { make: "Vapid", name: "Domintaor", price: 15000, seats: 6, doors: 3, weapons: true },
  { make: "Ocelot", name: "Jugular", price: 185000, seats: 4, doors: 4, weapons: false },
  { make: "Pfister", name: "Neon", price: 7500000, seats: 4, doors: 4, weapons: false },
  { make: "Karin", name: "Kuruma", price: 9000, seats: 4, doors: 4, weapons: false },
];

const Content: React.FC = () => {
  return (
    <ScrollArea scrollbarSize={6} offsetScrollbars style={{ height: "100%" }}>
      <SimpleGrid cols={4} spacing={1}>
        {data.map((vehicle, index) => (
          <VehicleCard key={`vehicle-${index}`} vehicle={vehicle} />
        ))}
      </SimpleGrid>
    </ScrollArea>
  );
};

export default Content;
