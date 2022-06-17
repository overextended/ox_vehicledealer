import { StrictMode } from "react";
import ReactDOM from "react-dom/client";
import { theme } from "./theme";
import { MantineProvider } from "@mantine/core";
import { VisibilityProvider } from "./providers/VisibilityProvider";
import App from "./App";
import "./index.css";

ReactDOM.createRoot(document.getElementById("root")!).render(
  <StrictMode>
    <MantineProvider theme={theme} withGlobalStyles withNormalizeCSS>
      <VisibilityProvider>
        <App />
      </VisibilityProvider>
    </MantineProvider>
  </StrictMode>
);
