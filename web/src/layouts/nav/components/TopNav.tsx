import { Group, ActionIcon, Modal, Select } from "@mantine/core";
import { useEffect, useState } from "react";
import { TbCar, TbFilter } from "react-icons/tb";
import { useAppDispatch, useAppSelector } from "../../../state";
import Filters from "./Filters";
import Search from "./Search";

const TopNav: React.FC<{ categories: string[] }> = ({ categories }) => {
  const [open, setOpen] = useState(false);
  const filters = useAppSelector((state) => state.filters);
  const dispatch = useAppDispatch();

  useEffect(() => {
    dispatch.vehicles.fetchVehicles(filters);
  }, [filters.category]);

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
      <Select
        label="Vehicle category"
        icon={<TbCar fontSize={20} />}
        searchable
        clearable
        nothingFound="No such vehicle category"
        onChange={(value) => dispatch.filters.setState({ key: "category", value })}
        value={filters.category}
        data={categories}
        width="100%"
        styles={{
          root: {
            width: "100%",
          },
        }}
      />
    </>
  );
};

export default TopNav;
