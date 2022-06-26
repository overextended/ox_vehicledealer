import { Box, createStyles, Transition } from "@mantine/core";
import { useAppSelector } from "../../state";

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
    height: 400,
    width: 300,
    backgroundColor: theme.colors.dark[7],
  },
}));

const Vehicle: React.FC = () => {
  const { classes } = useStyles();
  const vehicleVisibility = useAppSelector((state) => state.visibility.vehicle);

  return (
    <Transition mounted={vehicleVisibility} transition="slide-left">
      {(style) => (
        <Box style={style} className={classes.wrapper}>
          <Box className={classes.box}>Hello there</Box>
        </Box>
      )}
    </Transition>
  );
};

export default Vehicle;
