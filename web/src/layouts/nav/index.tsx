import { Divider, ScrollArea, Stack, Loader, Center } from "@mantine/core";
import { Navbar } from "@mantine/core";
import VehicleList from "./components/VehicleList";
import TopNav from "./components/TopNav";

const Nav: React.FC<{ categories: string[]; style: React.CSSProperties }> = ({ categories, style }) => {
  return (
    <Navbar
      height="100%"
      width={{ base: 300 }}
      fixed
      style={style}
      sx={(theme) => ({
        backgroundColor: theme.colors.dark[7],
      })}
    >
      <Navbar.Section>
        <Stack align="center" p={10} sx={{ width: "100%" }}>
          <TopNav categories={categories} />
          <Divider sx={{ width: "100%" }} label="Vehicles" my="xs" labelPosition="center" />
        </Stack>
      </Navbar.Section>

      <Navbar.Section grow component={ScrollArea} p={10} offsetScrollbars scrollbarSize={6}>
        <VehicleList />
      </Navbar.Section>
    </Navbar>
  );
};

export default Nav;
