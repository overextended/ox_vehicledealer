import { Box, ScrollArea, Transition, Group, ActionIcon, Stack, Select, Divider, Paper, Text } from "@mantine/core";
import { debugData } from "./utils/debugData";
import Nav from "./layouts/nav";
import { useVisibility } from "./providers/VisibilityProvider";
import { useNuiEvent } from "./hooks/useNuiEvent";
import { useState } from "react";
import { TbFilter, TbCar, TbReceipt2 } from "react-icons/tb";
import Search from "./layouts/nav/components/Search";

debugData([
  {
    action: "setVisible",
    data: {
      categories: ["Compacts", "Sedans", "Motorcycles", "Sports"],
      visible: true,
    },
  },
]);

export default function App() {
  const visibility = useVisibility();
  const [categories, setCategories] = useState<string[]>([""]);

  useNuiEvent("setVisible", (data) => setCategories(data.categories));

  return (
    <Transition mounted={visibility.visible} transition="slide-right">
      {(style) => <Nav style={style} categories={categories} />}
    </Transition>
  );
}
