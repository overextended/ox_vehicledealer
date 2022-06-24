import { Group, ActionIcon, Modal } from "@mantine/core";
import { useState } from "react";
import { TbFilter } from "react-icons/tb";
import Filters from "./Filters";
import Search from "./Search";

const TopNav: React.FC = () => {
  const [open, setOpen] = useState(false);

  return (
    <>
      <Group noWrap sx={{ width: "100%" }} position="apart" grow>
        <ActionIcon variant="outline" color="blue" size="lg" onClick={() => setOpen(true)}>
          <TbFilter fontSize={20} />
        </ActionIcon>
        <Search />
      </Group>
      <Modal opened={open} onClose={() => setOpen(false)} size="xs" title="Advanced filters" closeOnEscape={false}>
        <Filters />
      </Modal>
    </>
  );
};

export default TopNav;
