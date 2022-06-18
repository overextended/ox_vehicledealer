import { Box, Card, Group, Button, Text } from "@mantine/core";

interface VehicleProps {
  label: string;
  price: number;
  seats: number;
}

const VehicleCard: React.FC<{ vehicle: VehicleProps }> = ({ vehicle }) => {
  return (
    <>
      <Box sx={{ padding: 5 }}>
        <Card shadow="sm">
          <Card.Section p={10}>{vehicle.label}</Card.Section>
          <Card.Section p={10}>
            <Text>Price: {vehicle.price}</Text>
            <Text>Seats: {vehicle.seats}</Text>
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
