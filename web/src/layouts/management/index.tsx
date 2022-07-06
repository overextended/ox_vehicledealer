import { AppShell, Center } from "@mantine/core";
import { Routes, Route } from "react-router-dom";
import Nav from "./components/nav";
import Home from "./views";
import PurchaseVehicles from "./views/purchase";
import Stock from "./views/stock";

const Management: React.FC = () => {
  return (
    <Center sx={{ height: "100%" }}>
      <AppShell
        padding={0}
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
          <Route path="/stock" element={<Stock />} />
          <Route path="/gallery" element={<div>Gallery</div>} />
          <Route path="/employees" element={<>Employees</>} />
        </Routes>
      </AppShell>
    </Center>
  );
};

export default Management;
