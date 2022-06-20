import {
  createStyles,
  Navbar,
  Group,
  Input,
  ActionIcon,
  Divider,
  Box,
  Collapse,
  useMantineTheme,
  ScrollArea,
} from "@mantine/core";
import { TbFilter } from "react-icons/tb";
import { useToggle } from "@mantine/hooks";
import Search from "./components/Search";
import Filters from "./components/Filters";

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

      "&:hover": {
        backgroundColor: theme.colors.dark[6],
        color: theme.white,
      },
    },
  };
});

const data = ["Compacts", "Sedans", "SUVs", "Coupes", "Muscle", "Sports", "Super", "Motorcycles"];

const Nav: React.FC = () => {
  const theme = useMantineTheme();
  const { classes } = useStyles();
  const [collapse, toggleCollapse] = useToggle(false, [false, true]);

  return (
    <Navbar
      height={theme.breakpoints.sm}
      width={{ sm: 200 }}
      p="md"
      sx={{ borderTopLeftRadius: 5, borderBottomLeftRadius: 5 }}
    >
      <Navbar.Section sx={{ fontWeight: 500, paddingBottom: 10 }}>
        <Group noWrap>
          <ActionIcon variant="outline" color="blue" size="lg" onClick={() => toggleCollapse()}>
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
        {data.map((vehicleClass, index) => (
          <Box key={`category-${index}`} className={classes.category}>
            {vehicleClass}
          </Box>
        ))}
      </Navbar.Section>
    </Navbar>
  );
};

export default Nav;
