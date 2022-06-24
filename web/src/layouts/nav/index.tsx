import { Group, ActionIcon, Divider, Box, useMantineTheme, ScrollArea, Stack, Select, Modal } from "@mantine/core";
import { useNuiEvent } from "../../hooks/useNuiEvent";
import { Navbar } from "@mantine/core";
import { TbCar, TbFilter } from "react-icons/tb";
import Search from "./components/Search";
import VehiclePaper from "./components/VehiclePaper";
import Filters from "./components/Filters";
import { useAppDispatch, useAppSelector } from "../../state";
import { useState } from "react";

const vehicleData = [
  { make: "Dinka", name: "Blista", price: 3000, seats: 4, doors: 4, weapons: false },
  { make: "Vapid", name: "Domintaor", price: 15000, seats: 6, doors: 3, weapons: true },
  { make: "Ocelot", name: "Jugular", price: 185000, seats: 4, doors: 4, weapons: false },
  { make: "Pfister", name: "Neon", price: 7500000, seats: 4, doors: 4, weapons: false },
  { make: "Karin", name: "Kuruma", price: 9000, seats: 4, doors: 4, weapons: false },
  { make: "Dinka", name: "Blista", price: 3000, seats: 4, doors: 4, weapons: false },
  { make: "Vapid", name: "Domintaor", price: 15000, seats: 6, doors: 3, weapons: true },
  { make: "Ocelot", name: "Jugular", price: 185000, seats: 4, doors: 4, weapons: false },
  { make: "Pfister", name: "Neon", price: 7500000, seats: 4, doors: 4, weapons: false },
  { make: "Karin", name: "Kuruma", price: 9000, seats: 4, doors: 4, weapons: false },
  { make: "Dinka", name: "Blista", price: 3000, seats: 4, doors: 4, weapons: false },
  { make: "Vapid", name: "Domintaor", price: 15000, seats: 6, doors: 3, weapons: true },
  { make: "Ocelot", name: "Jugular", price: 185000, seats: 4, doors: 4, weapons: false },
  { make: "Pfister", name: "Neon", price: 7500000, seats: 4, doors: 4, weapons: false },
  { make: "Karin", name: "Kuruma", price: 9000, seats: 4, doors: 4, weapons: false },
];

const Nav: React.FC<{ categories: string[]; style: React.CSSProperties }> = ({ categories, style }) => {
  const [open, setOpen] = useState(false);
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
          <Group noWrap sx={{ width: "100%" }} position="apart" grow>
            <ActionIcon variant="outline" color="blue" size="lg" onClick={() => setOpen(true)}>
              <TbFilter fontSize={20} />
            </ActionIcon>
            <Search />
          </Group>
          <Modal opened={open} onClose={() => setOpen(false)} size="xs" title="Advanced filters" closeOnEscape={false}>
            <Filters />
          </Modal>
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
        <Stack spacing="sm">
          {vehicleData.map((vehicle, index) => (
            <VehiclePaper key={`vehicle-${index}`} vehicle={vehicle} />
          ))}
        </Stack>
      </Navbar.Section>
    </Navbar>
  );
};

export default Nav;
