import { createStyles, Navbar, Group, Input, ActionIcon, Divider, Box } from "@mantine/core";
import { TbCar, TbMotorbike, TbFilter, TbSearch } from "react-icons/tb";

const useStyles = createStyles((theme) => {
  return {
    category: {
      ...theme.fn.focusStyles(),
      display: "flex",
      alignItems: "center",
      textDecoration: "none",
      fontSize: theme.fontSizes.sm,
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
  const { classes } = useStyles();

  return (
    <Navbar height={700} width={{ sm: 200 }} p="md">
      <Navbar.Section sx={{ fontWeight: 500, paddingBottom: 10 }}>
        <Group noWrap>
          <ActionIcon variant="outline" color="blue" size="lg">
            <TbFilter fontSize={24} />
          </ActionIcon>
          <Input icon={<TbSearch />} />
        </Group>
        <Divider mt={15} />
      </Navbar.Section>

      <Navbar.Section grow mt={5}>
        {data.map((vehicleClass) => (
          <Box className={classes.category}>{vehicleClass}</Box>
        ))}
      </Navbar.Section>
    </Navbar>
  );
};

export default Nav;
