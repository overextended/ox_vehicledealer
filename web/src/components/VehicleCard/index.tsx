import { Box, Card, Group, Button, Grid, Stack, Title, SimpleGrid } from "@mantine/core";
import { TbReceipt2 } from "react-icons/tb";
import { MdAirlineSeatReclineNormal } from "react-icons/md";
import { GiCarDoor, GiHeavyBullets } from "react-icons/gi";
import IconGroup from "./IconGroup";

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
          <Card.Section p={10} sx={{ display: "flex", justifyContent: "center", alignItems: "center" }}>
            <Group position="center" spacing="xl">
              <Stack spacing="sm">
                <IconGroup label={vehicle.price} Icon={TbReceipt2} />
                <IconGroup label={vehicle.seats} Icon={MdAirlineSeatReclineNormal} />
              </Stack>
              <Stack spacing="sm">
                <IconGroup label={vehicle.doors} Icon={GiCarDoor} />
                <IconGroup label={vehicle.weapons ? "Yes" : "No"} Icon={GiHeavyBullets} />
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
