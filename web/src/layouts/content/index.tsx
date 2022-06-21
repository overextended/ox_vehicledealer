import { SimpleGrid, ScrollArea, Center, Stack, Text } from "@mantine/core";
import VehicleCard from "../../components/VehicleCard";
import { useAppSelector } from "../../state";
import { TbSearch } from "react-icons/tb";

const Content: React.FC = () => {
  const vehicleState = useAppSelector((state) => state.vehicles);

  return (
    <>
      {vehicleState.length > 0 ? (
        <ScrollArea scrollbarSize={6} offsetScrollbars style={{ height: "100%" }}>
          <SimpleGrid cols={4} spacing={1}>
            {vehicleState.map((vehicle, index) => (
              <VehicleCard key={`vehicle-${index}`} vehicle={vehicle} />
            ))}
          </SimpleGrid>
        </ScrollArea>
      ) : (
        <Center sx={{ height: "100%" }}>
          <Stack align="center">
            <TbSearch fontSize={48} />
            <Text size="xl">No vehicles found</Text>
          </Stack>
        </Center>
      )}
    </>
  );
};

export default Content;
