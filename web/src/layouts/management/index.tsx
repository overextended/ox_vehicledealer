import { AppShell, Center } from "@mantine/core";
import Nav from "./components/nav";

const Management: React.FC = () => {
  return (
    <Center sx={{ height: "100%" }}>
      <AppShell
        styles={(theme) => ({
          main: {
            backgroundColor: theme.colors.dark[8],
            width: 900,
            height: 600,
            borderTopRightRadius: theme.radius.sm,
            borderBottomRightRadius: theme.radius.sm,
          },
        })}
        navbar={<Nav />}
      >
        Important stuff goes here
      </AppShell>
    </Center>
  );
};

export default Management;
