import { Divider, ScrollArea, Stack, Loader, Center } from "@mantine/core";
import { Navbar } from "@mantine/core";
import VehicleList from "./components/VehicleList";
import TopNav from "./components/TopNav";
import { useAppSelector } from "../../state";

const Nav: React.FC<{ categories: string[]; style: React.CSSProperties }> = ({ categories, style }) => {
  const isLoading = useAppSelector((state) => state.isLoading);

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
        {!isLoading ? (
          <VehicleList />
        ) : (
          <Center sx={{ position: "absolute", top: "50%", left: "50%", transform: "translate(-50%, -50%)" }}>
            <Loader />
          </Center>
        )}
      </Navbar.Section>
    </Navbar>
  );
};

export default Nav;
