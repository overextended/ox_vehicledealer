import { Paper, Group, Stack, Text, Title, Box } from "@mantine/core";
import React from "react";
import IconGroup from "../../../components/IconGroup";
import { TbReceipt2 } from "react-icons/tb";
import { GiCarDoor, GiHeavyBullets } from "react-icons/gi";
import { MdAirlineSeatReclineNormal } from "react-icons/md";
import { fetchNui } from "../../../utils/fetchNui";
import { useAppDispatch } from "../../../state";

const VehiclePaper: React.FC<{
  vehicle: { make: string; name: string; price: number; seats: number; doors: number; weapons: boolean };
  index: number;
  vehicleIndex: number | null;
  setVehicleIndex: React.Dispatch<React.SetStateAction<number | null>>;
}> = ({ vehicle, index, vehicleIndex, setVehicleIndex }) => {
  const dispatch = useAppDispatch();

  return (
    <>
      <Paper
        onClick={() => {
          fetchNui("clickVehicle", index);
          setVehicleIndex(index);
          dispatch.visibility.setVehicleVisible(true);
        }}
        shadow="xs"
        p="md"
        withBorder
        sx={(theme) => ({
          width: "100%",
          backgroundColor: vehicleIndex == index ? theme.colors[theme.primaryColor][8] : theme.colors.dark[6],
          color: vehicleIndex === index ? theme.white : undefined,
          "&:hover": { backgroundColor: vehicleIndex !== index ? theme.colors.dark[5] : undefined, cursor: "pointer" },
        })}
      >
        <Stack sx={{ width: "100%" }}>
          <Group position="apart" noWrap>
            <Title order={4}>{`${vehicle.make} ${vehicle.name}`}</Title>
            {vehicle.weapons && <GiHeavyBullets fontSize={20} />}
          </Group>
          <Group position="apart">
            <IconGroup label={vehicle.price} Icon={TbReceipt2} />
            <Group>
              <IconGroup label={vehicle.seats} Icon={MdAirlineSeatReclineNormal} />
              <IconGroup label={vehicle.doors} Icon={GiCarDoor} />
            </Group>
          </Group>
        </Stack>
      </Paper>
    </>
  );
};

export default VehiclePaper;
