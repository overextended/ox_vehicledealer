import { Stack } from "@mantine/core";
import VehiclePaper from "./VehiclePaper";

const vehicleData = [
  { make: "Dinka", name: "Blista", price: 3000, seats: 4, doors: 4, weapons: false },
  { make: "Vapid", name: "Domintaor", price: 15000, seats: 6, doors: 3, weapons: true },
  { make: "Ocelot", name: "Jugular", price: 185000, seats: 4, doors: 4, weapons: false },
  { make: "Pfister", name: "Neon", price: 7500000, seats: 4, doors: 4, weapons: false },
  { make: "Karin", name: "Kuruma", price: 9000, seats: 4, doors: 4, weapons: false },
  { make: "Dinka", name: "Blista", price: 3000, seats: 4, doors: 4, weapons: false },
  { make: "Vapid", name: "Domintaor", price: 15000, seats: 6, doors: 3, weapons: true },
  { make: "Ocelot", name: "Jugular", price: 185000, seats: 4, doors: 4, weapons: false },
  { make: "Pfister", name: "Neon", price: 7500000, seats: 4, doors: 4, weapons: false },
  { make: "Karin", name: "Kuruma", price: 9000, seats: 4, doors: 4, weapons: false },
  { make: "Dinka", name: "Blista", price: 3000, seats: 4, doors: 4, weapons: false },
  { make: "Vapid", name: "Domintaor", price: 15000, seats: 6, doors: 3, weapons: true },
  { make: "Ocelot", name: "Jugular", price: 185000, seats: 4, doors: 4, weapons: false },
  { make: "Pfister", name: "Neon", price: 7500000, seats: 4, doors: 4, weapons: false },
  { make: "Karin", name: "Kuruma", price: 9000, seats: 4, doors: 4, weapons: false },
];

const VehicleList: React.FC = () => {
  return (
    <Stack spacing="sm">
      {vehicleData.map((vehicle, index) => (
        <VehiclePaper key={`vehicle-${index}`} vehicle={vehicle} />
      ))}
    </Stack>
  );
};

export default VehicleList;
