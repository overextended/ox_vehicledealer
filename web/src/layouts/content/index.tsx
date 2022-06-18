import { SimpleGrid } from "@mantine/core";
import VehicleCard from "../../components/VehicleCard";

const data = [
  { label: "Dinka Blista", price: 3000, seats: 4 },
  { label: "Domintaor", price: 3000, seats: 4 },
  { label: "Jugular", price: 3000, seats: 4 },
  { label: "Neon", price: 3000, seats: 4 },
  { label: "Duck", price: 3000, seats: 4 },
];

const Content: React.FC = () => {
  return (
    <>
      <SimpleGrid cols={4} spacing={1}>
        {data.map((vehicle) => (
          <VehicleCard vehicle={vehicle} />
        ))}
      </SimpleGrid>
    </>
  );
};

export default Content;
