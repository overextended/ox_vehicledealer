import { StrictMode } from "react";
import ReactDOM from "react-dom/client";
import { theme } from "./theme";
import { MantineProvider } from "@mantine/core";
import { VisibilityProvider } from "./providers/VisibilityProvider";
import App from "./App";
import "./index.css";
import { isEnvBrowser } from "./utils/misc";

if (isEnvBrowser()) {
  const root = document.getElementById("root");

  // https://i.imgur.com/iPTAdYV.png - Night time img
  root!.style.backgroundImage = 'url("https://i.imgur.com/3pzRj9n.png")';
  root!.style.backgroundSize = "cover";
  root!.style.backgroundRepeat = "no-repeat";
  root!.style.backgroundPosition = "center";
}

ReactDOM.createRoot(document.getElementById("root")!).render(
  <StrictMode>
    <MantineProvider theme={theme} withGlobalStyles withNormalizeCSS>
      <VisibilityProvider>
        <App />
      </VisibilityProvider>
    </MantineProvider>
  </StrictMode>
);
