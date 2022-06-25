import { Stack, Text, Center } from "@mantine/core";
import { TbSearch } from "react-icons/tb";
import { useAppSelector } from "../../../state";
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
  const vehicles = useAppSelector((state) => state.vehicles);

  return (
    <>
      {vehicles.length > 0 ? (
        <Stack spacing="sm">
          {vehicles.map((vehicle, index) => (
            <VehiclePaper key={`vehicle-${index}`} vehicle={vehicle} />
          ))}
        </Stack>
      ) : (
        <Center>
          <Stack align="center">
            <TbSearch fontSize={48} />
            <Text size="xl">No vehicles found</Text>
          </Stack>
        </Center>
      )}
    </>
  );
};

export default VehicleList;
