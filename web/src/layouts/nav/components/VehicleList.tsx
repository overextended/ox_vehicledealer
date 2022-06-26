import { Stack, Text, Center, Loader } from "@mantine/core";
import { useState } from "react";
import { TbSearch } from "react-icons/tb";
import { useAppSelector } from "../../../state";
import VehiclePaper from "./VehiclePaper";

const VehicleList: React.FC = () => {
  const vehicles = useAppSelector((state) => state.vehicles);
  const isLoading = useAppSelector((state) => state.isLoading);
  const [vehicleIndex, setVehicleIndex] = useState<number | null>(null);

  return (
    <>
      {isLoading ? (
        <Center style={{ position: "absolute", top: "50%", left: "50%", transform: "translate(-50%, -50%)" }}>
          <Loader />
        </Center>
      ) : (
        <>
          {vehicles.length > 0 ? (
            <Stack spacing="sm">
              {vehicles.map((vehicle, index) => (
                <VehiclePaper
                  key={`vehicle-${index}`}
                  vehicle={vehicle}
                  index={index}
                  vehicleIndex={vehicleIndex}
                  setVehicleIndex={setVehicleIndex}
                />
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
      )}
    </>
  );
};

export default VehicleList;
