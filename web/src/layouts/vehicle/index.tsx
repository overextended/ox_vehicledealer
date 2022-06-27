import {
  Box,
  createStyles,
  Transition,
  Title,
  Stack,
  Text,
  Progress,
  Group,
  ActionIcon,
  Button,
  ColorInput,
} from "@mantine/core";
import { useState } from "react";
import { TbRotate, TbRotateClockwise } from "react-icons/tb";
import { useExitListener } from "../../hooks/useExitListener";
import { useAppDispatch, useAppSelector } from "../../state";

const useStyles = createStyles((theme) => ({
  wrapper: {
    display: "flex",
    flexDirection: "column",
    justifyContent: "center",
    alignItems: "flex-end",
    height: "100%",
    width: "100%",
  },

  box: {
    height: "fit-content",
    width: 300,
    backgroundColor: theme.colors.dark[7],
    padding: 10,
    borderTopLeftRadius: theme.radius.sm,
    borderBottomLeftRadius: theme.radius.sm,
  },
}));

const Vehicle: React.FC = () => {
  const { classes } = useStyles();
  const dispatch = useAppDispatch();
  const vehicleVisibility = useAppSelector((state) => state.visibility.vehicle);
  const vehicleData = useAppSelector((state) => state.vehicleData);
  const [color, setColor] = useState("");

  useExitListener(dispatch.visibility.setVehicleVisible);

  return (
    <Transition mounted={vehicleVisibility} transition="slide-left">
      {(style) => (
        <Box style={style} className={classes.wrapper}>
          <Box className={classes.box}>
            <Stack align="center">
              <Title order={4}>{`${vehicleData.make} ${vehicleData.name}`}</Title>
              <ColorInput
                label="Vehicle color"
                value={color}
                onChange={(value) => setColor(value)}
                sx={{ width: "100%" }}
              />
              <Stack sx={{ width: "100%" }} spacing={1}>
                <Text>Speed</Text>
                <Progress value={vehicleData.speed} />
              </Stack>
              <Stack sx={{ width: "100%" }} spacing={1}>
                <Text>Acceleration</Text>
                <Progress value={vehicleData.acceleration} />
              </Stack>
              <Stack sx={{ width: "100%" }} spacing={1}>
                <Text>Braking</Text>
                <Progress value={vehicleData.braking} />
              </Stack>
              <Stack sx={{ width: "100%" }} spacing={1}>
                <Text>Handling</Text>
                <Progress value={vehicleData.handling} />
              </Stack>
              <Group>
                <ActionIcon variant="outline" color="blue" size="lg">
                  <TbRotate fontSize={20} />
                </ActionIcon>
                <Button>Purchase</Button>
                <ActionIcon variant="outline" color="blue" size="lg">
                  <TbRotateClockwise fontSize={20} />
                </ActionIcon>
              </Group>
            </Stack>
          </Box>
        </Box>
      )}
    </Transition>
  );
};

export default Vehicle;
