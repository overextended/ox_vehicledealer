import { Divider, ScrollArea, Stack, Loader, Center, Transition } from "@mantine/core";
import { Navbar } from "@mantine/core";
import VehicleList from "./components/VehicleList";
import TopNav from "./components/TopNav";
import { useAppSelector } from "../../state";

const Nav: React.FC<{ categories: string[] }> = ({ categories }) => {
  const browserVisibility = useAppSelector((state) => state.visibility.browser);

  return (
    <Transition mounted={browserVisibility} transition="slide-right">
      {(style) => (
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
      )}
    </Transition>
  );
};

export default Nav;
