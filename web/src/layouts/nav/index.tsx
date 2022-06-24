import { Group, ActionIcon, Divider, Box, useMantineTheme, ScrollArea, Stack, Select, Modal } from "@mantine/core";
import { useNuiEvent } from "../../hooks/useNuiEvent";
import { Navbar } from "@mantine/core";
import { TbCar } from "react-icons/tb";
import VehicleList from "./components/VehicleList";
import TopNav from "./components/TopNav";
import { useAppDispatch, useAppSelector } from "../../state";
import { useState } from "react";

const Nav: React.FC<{ categories: string[]; style: React.CSSProperties }> = ({ categories, style }) => {
  const [active, setActive] = useState("");
  const dispatch = useAppDispatch();
  const vehicles = useAppSelector((state) => state.vehicles);

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
          <TopNav />
          <Select
            label="Vehicle category"
            icon={<TbCar fontSize={20} />}
            searchable
            clearable
            nothingFound="No such vehicle category"
            data={categories}
            width="100%"
            styles={{
              root: {
                width: "100%",
              },
            }}
          />
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
