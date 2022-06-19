import { Box, AppShell } from "@mantine/core";
import { debugData } from "./utils/debugData";
import Nav from "./layouts/nav";
import Content from "./layouts/content";

debugData([
  {
    action: "setVisible",
    data: true,
  },
]);

export default function App() {
  return (
    <>
      <Box
        sx={{
          width: "100%",
          height: "100%",
          display: "flex",
          justifyContent: "center",
          alignItems: "center",
        }}
      >
        <Box>
          <AppShell
            padding="sm"
            sx={(theme) => ({
              borderRadius: 5,
              backgroundColor: theme.colors.dark[8],
              width: theme.breakpoints.lg,
              height: theme.breakpoints.sm,
            })}
            styles={(theme) => ({
              main: {
                height: theme.breakpoints.sm,
                overflow: "hidden",
              },
            })}
            navbar={<Nav />}
          >
            <Content />
          </AppShell>
        </Box>
      </Box>
    </>
  );
}
