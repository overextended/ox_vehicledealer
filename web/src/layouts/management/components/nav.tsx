import { Navbar, Center, Stack } from '@mantine/core';
import { RiGalleryLine } from 'react-icons/ri';
import { TbDatabase, TbUsers, TbLogout } from 'react-icons/tb';
import NavIcon from './NavIcon';
import { useAppDispatch } from '../../../state';
import { fetchNui } from '../../../utils/fetchNui';

const Nav: React.FC = () => {
  const dispatch = useAppDispatch();

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
            <Stack spacing={0}>
              <NavIcon tooltip="Stock" Icon={TbDatabase} to="/" />
              <NavIcon tooltip="Gallery" Icon={RiGalleryLine} to="/gallery" />
              <NavIcon tooltip="Employees" Icon={TbUsers} to="/employees" />
            </Stack>
          </Center>
        </Navbar.Section>

        <Navbar.Section>
          <Center>
            <NavIcon
              tooltip="Exit"
              Icon={TbLogout}
              to=""
              color="red.4"
              handleClick={() => {
                dispatch.visibility.setManagementVisible(false);
                fetchNui('exit');
              }}
            />
          </Center>
        </Navbar.Section>
      </Navbar>
    </>
  );
};

export default Nav;
