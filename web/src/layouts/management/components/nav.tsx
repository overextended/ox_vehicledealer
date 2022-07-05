import { Navbar, Center, Stack } from "@mantine/core";
import { RiGalleryLine } from "react-icons/ri";
import { TbCar, TbDatabase, TbUsers } from "react-icons/tb";
import NavIcon from "./NavIcon";

const Nav: React.FC = () => {
  return (
    <>
      <Navbar
        width={{ base: 80 }}
        height={600}
        p="md"
        sx={(theme) => ({ borderTopLeftRadius: theme.radius.sm, borderBottomLeftRadius: theme.radius.sm })}
      >
        <Navbar.Section grow>
          <Center>
            <Stack spacing={5}>
              <NavIcon tooltip="Purchase vehicles" Icon={TbCar} />
              <NavIcon tooltip="Stock" Icon={TbDatabase} />
              <NavIcon tooltip="Gallery" Icon={RiGalleryLine} />
              <NavIcon tooltip="Employees" Icon={TbUsers} />
            </Stack>
          </Center>
        </Navbar.Section>
      </Navbar>
    </>
  );
};

export default Nav;
