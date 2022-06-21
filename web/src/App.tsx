import { Box, AppShell, Transition } from "@mantine/core";
import { debugData } from "./utils/debugData";
import Nav from "./layouts/nav";
import Content from "./layouts/content";
import { useVisibility } from "./providers/VisibilityProvider";

debugData([
  {
    action: "setVisible",
    data: true,
  },
]);

export default function App() {
  const visibility = useVisibility();

  return (
    <>
      <Box
        sx={{
          width: "100%",
          height: "100%",
          display: "flex",
          justifyContent: "center",
          alignItems: "center",
          flexDirection: "column",
        }}
      >
        <Box>
          <Transition mounted={visibility.visible} transition="slide-up">
            {(style) => (
              <AppShell
                style={style}
                padding="sm"
                sx={(theme) => ({
                  borderRadius: theme.radius.sm,
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
            )}
          </Transition>
        </Box>
      </Box>
    </>
  );
}
