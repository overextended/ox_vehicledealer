import { Input } from "@mantine/core";
import { TbSearch } from "react-icons/tb";
import { useAppDispatch, useAppSelector } from "../../../state";

const Search: React.FC = () => {
  const filterState = useAppSelector((state) => state.filters);
  const dispatch = useAppDispatch();

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
