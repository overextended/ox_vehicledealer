import { Box, createStyles, Transition, Title, Stack, Group, ActionIcon, Button } from "@mantine/core";
import { TbRotate, TbRotateClockwise } from "react-icons/tb";
import { useExitListener } from "../../hooks/useExitListener";
import { useAppDispatch, useAppSelector } from "../../state";
import StatBar from "./components/StatBar";
import Color from "./components/Color";

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

  useExitListener(dispatch.visibility.setVehicleVisible);

  return (
    <Transition mounted={vehicleVisibility} transition="slide-left">
      {(style) => (
        <Box style={style} className={classes.wrapper}>
          <Box className={classes.box}>
            <Stack align="center">
              <Title order={4}>{`${vehicleData.make} ${vehicleData.name}`}</Title>
              <Color />
              <StatBar label="Speed" value={vehicleData.speed} />
              <StatBar label="Acceleration" value={vehicleData.acceleration} />
              <StatBar label="Braking" value={vehicleData.braking} />
              <StatBar label="Handling" value={vehicleData.handling} />
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
