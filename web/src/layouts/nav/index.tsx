import {
  createStyles,
  Navbar,
  Group,
  ActionIcon,
  Divider,
  Box,
  Collapse,
  useMantineTheme,
  ScrollArea,
} from "@mantine/core";
import { useNuiEvent } from "../../hooks/useNuiEvent";
import { TbFilter } from "react-icons/tb";
import { useToggle } from "@mantine/hooks";
import Search from "./components/Search";
import Filters from "./components/Filters";
import { useAppDispatch } from "../../state";
import { useState } from "react";

const useStyles = createStyles((theme) => {
  return {
    category: {
      ...theme.fn.focusStyles(),
      display: "flex",
      alignItems: "center",
      textDecoration: "none",
      fontSize: theme.fontSizes.md,
      color: theme.colors.dark[1],
      padding: `${theme.spacing.xs}px ${theme.spacing.sm}px`,
      borderRadius: theme.radius.sm,
      fontWeight: 500,
    },
  };
});

const data = ["Compacts", "Sedans", "SUVs", "Coupes", "Muscle", "Sports", "Super", "Motorcycles"];

const Nav: React.FC<{ categories: string[] }> = ({ categories }) => {
  const theme = useMantineTheme();
  const { classes } = useStyles();
  const [collapse, toggleCollapse] = useToggle(false, [false, true]);
  const [active, setActive] = useState("");
  const dispatch = useAppDispatch();

  useNuiEvent("setVisible", (data) => {
    console.log(data);
  });

  return (
    <Navbar
      height={theme.breakpoints.sm}
      width={{ sm: 200 }}
      p="md"
      sx={(theme) => ({
        borderTopLeftRadius: theme.radius.sm,
        borderBottomLeftRadius: theme.radius.sm,
        "@media (max-height: 768px)": {
          height: theme.breakpoints.xs,
        },
      })}
    >
      <Navbar.Section sx={{ fontWeight: 500, paddingBottom: 10 }}>
        <Group noWrap>
          <ActionIcon
            variant="outline"
            color="blue"
            size="lg"
            onClick={() => {
              toggleCollapse();
              setActive("");
            }}
          >
            <TbFilter fontSize={20} />
          </ActionIcon>
          <Search />
        </Group>
        <Collapse in={collapse}>
          <Filters opened={collapse} />
        </Collapse>
        <Divider mt={15} />
      </Navbar.Section>

      <Navbar.Section grow mt={5} component={ScrollArea}>
        {categories.map((vehicleCategory, index) => (
          <Box
            key={`category-${index}`}
            className={classes.category}
            sx={(theme) => ({
              backgroundColor:
                active === vehicleCategory
                  ? theme.fn.rgba(theme.colors[theme.primaryColor][9], 0.25)
                  : theme.colors.dark[7],
              color: active === vehicleCategory ? theme.colors[theme.primaryColor][4] : undefined,

              "&:hover": {
                backgroundColor: active !== vehicleCategory ? theme.colors.dark[6] : undefined,
                color: active !== vehicleCategory ? theme.white : undefined,
                cursor: "pointer",
              },
            })}
            onClick={() => {
              setActive(vehicleCategory);
              dispatch.vehicles.fetchVehiclesByCategory(vehicleCategory);
            }}
          >
            {vehicleCategory}
          </Box>
        ))}
      </Navbar.Section>
    </Navbar>
  );
};

export default Nav;
