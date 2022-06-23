import { Box, AppShell, Transition } from "@mantine/core";
import { debugData } from "./utils/debugData";
import Nav from "./layouts/nav";
import Content from "./layouts/content";
import { useVisibility } from "./providers/VisibilityProvider";
import { useNuiEvent } from "./hooks/useNuiEvent";
import { useState } from "react";

debugData([
  {
    action: "setVisible",
    data: true,
  },
]);

export default function App() {
  const visibility = useVisibility();
  const [categories, setCategories] = useState<string[]>([""]);

  useNuiEvent("setVisible", (data) => setCategories(data.categories));

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

                  "@media (max-width: 1280px)": {
                    width: theme.breakpoints.sm,
                  },

                  "@media (max-height: 768px)": {
                    height: theme.breakpoints.xs,
                  },
                })}
                styles={(theme) => ({
                  main: {
                    height: theme.breakpoints.sm,
                    overflow: "hidden",
                    "@media (max-height: 768px)": {
                      height: theme.breakpoints.xs,
                    },
                  },
                })}
                navbar={<Nav categories={categories} />}
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
