import { Box, Card, Group, Button, Text, Stack, Title } from "@mantine/core";
import { TbReceipt2 } from "react-icons/tb";
import { MdAirlineSeatReclineNormal } from "react-icons/md";
import { GiCarDoor, GiHeavyBullets } from "react-icons/gi";

interface VehicleProps {
  make: string;
  name: string;
  price: number;
  seats: number;
  doors: number;
  weapons: boolean;
}

const VehicleCard: React.FC<{ vehicle: VehicleProps }> = ({ vehicle }) => {
  return (
    <>
      <Box sx={{ padding: 5 }}>
        <Card shadow="sm">
          <Card.Section p={10}>
            <Title
              // Truncates names that are too long to avoid making the container taller
              sx={{ overflow: "hidden", whiteSpace: "nowrap", textOverflow: "ellipsis" }}
              align="center"
              order={4}
            >{`${vehicle.make} ${vehicle.name}`}</Title>
          </Card.Section>
          <Card.Section p={10}>
            <Group position="center" spacing="xl">
              <Stack spacing="sm">
                <Group spacing={5}>
                  <TbReceipt2 fontSize={20} />
                  <Text>{vehicle.price}</Text>
                </Group>
                <Group spacing={5}>
                  <MdAirlineSeatReclineNormal fontSize={20} />
                  <Text>{vehicle.seats}</Text>
                </Group>
              </Stack>
              <Stack spacing="sm">
                <Group spacing={5}>
                  <GiCarDoor fontSize={20} />
                  <Text>{vehicle.doors}</Text>
                </Group>
                <Group spacing={5}>
                  <GiHeavyBullets fontSize={20} />
                  <Text>{vehicle.weapons ? "Yes" : "No"}</Text>
                </Group>
              </Stack>
            </Group>
          </Card.Section>
          <Card.Section p={10}>
            <Group spacing="xs" position="center">
              <Button>Purchase</Button>
              <Button color="orange">Preview</Button>
            </Group>
          </Card.Section>
        </Card>
      </Box>
    </>
  );
};

export default VehicleCard;
