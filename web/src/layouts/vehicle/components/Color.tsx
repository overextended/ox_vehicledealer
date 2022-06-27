import { ColorInput } from "@mantine/core";
import { useEffect, useState } from "react";
import { useDebounce } from "../../../hooks/useDebounce";
import { useIsFirstRender } from "../../../hooks/useIsFirstRender";
import { fetchNui } from "../../../utils/fetchNui";
import { isEnvBrowser } from "../../../utils/misc";

const Color: React.FC = () => {
  const isFirst = useIsFirstRender();
  const [color, setColor] = useState("");
  const debouncedColor = useDebounce(color);

  useEffect(() => {
    if (isFirst) return;
    if (!isEnvBrowser()) fetchNui("changeColor", debouncedColor);
  }, [debouncedColor]);

  return (
    <>
      <ColorInput label="Vehicle color" value={color} onChange={(value) => setColor(value)} sx={{ width: "100%" }} />
    </>
  );
};

export default Color;
