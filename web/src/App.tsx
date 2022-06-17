import { Box, AppShell, SimpleGrid, Group, Text, Card, Button } from "@mantine/core";
import { debugData } from "./utils/debugData";
import Nav from "./components/navbar";

debugData([
  {
    action: "setVisible",
    data: true,
  },
]);

const data = [
  { label: "Dinka Blista", price: 3000, seats: 4 },
  { label: "Domintaor", price: 3000, seats: 4 },
  { label: "Jugular", price: 3000, seats: 4 },
  { label: "Neon", price: 3000, seats: 4 },
  { label: "Duck", price: 3000, seats: 4 },
];

export default function App() {
  return (
    <>
      <Box
        sx={{
          width: "100%",
          height: "100%",
          display: "flex",
          justifyContent: "center",
          alignItems: "center",
        }}
      >
        <Box>
          <AppShell
            padding="sm"
            sx={(theme) => ({
              backgroundColor: theme.colors.dark[8],
              width: theme.breakpoints.lg,
              height: theme.breakpoints.sm,
            })}
            navbar={<Nav />}
          >
            <SimpleGrid cols={4} spacing={1}>
              {data.map((vehicle) => (
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
              ))}
            </SimpleGrid>
          </AppShell>
        </Box>
      </Box>
    </>
  );
}
