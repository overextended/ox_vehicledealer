import { Transition } from "@mantine/core";
import { debugData } from "./utils/debugData";
import Nav from "./layouts/nav";
import { useNuiEvent } from "./hooks/useNuiEvent";
import { useState } from "react";
import { useAppDispatch, useAppSelector } from "./state";
import { useExitListener } from "./hooks/useExitListener";

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
  const browserVisibility = useAppSelector((state) => state.visibility.browser);
  const [categories, setCategories] = useState<string[]>([""]);
  const dispatch = useAppDispatch();

  useExitListener(dispatch.visibility.setBrowserVisible);

  useNuiEvent("setVisible", (data) => {
    setCategories(data.categories);
    dispatch.visibility.setBrowserVisible(data.visible);
  });

  return (
    <Transition mounted={browserVisibility} transition="slide-right">
      {(style) => <Nav style={style} categories={categories} />}
    </Transition>
  );
}
