import { Select } from "@mantine/core";
import { useEffect } from "react";
import { TbCar } from "react-icons/tb";
import { useDebounce } from "../../../hooks/useDebounce";
import { useIsFirstRender } from "../../../hooks/useIsFirstRender";
import { useAppDispatch, useAppSelector } from "../../../state";
import Filters from "./Filters";

const TopNav: React.FC<{ categories: string[] }> = ({ categories }) => {
  const isFirst = useIsFirstRender();
  const filters = useAppSelector((state) => state.filters);
  const dispatch = useAppDispatch();
  const debouncedFilters = useDebounce(filters);

  useEffect(() => {
    if (isFirst) return;
    dispatch.filters.filterVehicles(filters);
  }, [debouncedFilters]);

  return (
    <>
      <Filters />
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
