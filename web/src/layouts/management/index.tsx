import { AppShell, Center } from "@mantine/core";
import { Routes, Route } from "react-router-dom";
import Nav from "./components/nav";
import Home from "./views";
import PurchaseVehicles from "./views/purchase";

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
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/purchase_vehicles" element={<PurchaseVehicles />} />
          <Route path="/stock" element={<>Stock</>} />
          <Route path="/gallery" element={<>Gallery</>} />
          <Route path="/employees" element={<>Employees</>} />
        </Routes>
      </AppShell>
    </Center>
  );
};

export default Management;
