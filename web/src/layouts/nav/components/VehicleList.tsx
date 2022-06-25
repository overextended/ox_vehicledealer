import { Stack, Text, Center } from "@mantine/core";
import { TbSearch } from "react-icons/tb";
import { useAppSelector } from "../../../state";
import VehiclePaper from "./VehiclePaper";

const VehicleList: React.FC = () => {
  const vehicles = useAppSelector((state) => state.vehicles);

  return (
    <>
      {vehicles.length > 0 ? (
        <Stack spacing="sm">
          {vehicles.map((vehicle, index) => (
            <VehiclePaper key={`vehicle-${index}`} vehicle={vehicle} index={index} />
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
