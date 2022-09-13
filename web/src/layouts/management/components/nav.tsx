import { Navbar, Center, Stack } from '@mantine/core';
import { RiGalleryLine } from 'react-icons/ri';
import { TbCar, TbDatabase, TbUsers, TbHome2 } from 'react-icons/tb';
import NavIcon from './NavIcon';

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
              <NavIcon tooltip="Purchase vehicles" Icon={TbCar} to="/purchase_vehicles" />
              <NavIcon tooltip="Stock" Icon={TbDatabase} to="/stock" />
              <NavIcon tooltip="Gallery" Icon={RiGalleryLine} to="/gallery" />
              <NavIcon tooltip="Employees" Icon={TbUsers} to="/employees" />
            </Stack>
          </Center>
        </Navbar.Section>

        <Navbar.Section>
          <Center>
            <NavIcon tooltip="Home" Icon={TbHome2} to="/" />
          </Center>
        </Navbar.Section>
      </Navbar>
    </>
  );
};

export default Nav;
