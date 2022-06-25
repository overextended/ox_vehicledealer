import { Input } from "@mantine/core";
import { useEffect } from "react";
import { TbSearch } from "react-icons/tb";
import { useDebounce } from "../../../hooks/useDebounce";
import { useAppDispatch, useAppSelector } from "../../../state";

const Search: React.FC = () => {
  const filterState = useAppSelector((state) => state.filters);
  const dispatch = useAppDispatch();
  const debounceSearch = useDebounce(filterState.search);

  useEffect(() => {
    dispatch.vehicles.fetchVehicles(filterState);
  }, [debounceSearch]);

  return (
    <>
      <Input
        icon={<TbSearch />}
        value={filterState.search}
        onChange={(e: React.ChangeEvent<HTMLInputElement>) =>
          dispatch.filters.setState({ key: "search", value: e.target.value })
        }
      />
    </>
  );
};

export default Search;
