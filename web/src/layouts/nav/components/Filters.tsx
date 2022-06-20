import { Box, Stack, NumberInput } from "@mantine/core";
import FilterSlider from "../../../components/FilterSlider";
import { TbReceipt2 } from "react-icons/tb";
import { useAppDispatch, useAppSelector } from "../../../state";

const Filters: React.FC = () => {
  const dispatch = useAppDispatch();
  const filterState = useAppSelector((state) => state.filters);

  return (
    <>
      <Box mt={15} sx={{ fontWeight: 400 }}>
        <Stack>
          <NumberInput
            label="Max price"
            hideControls
            value={filterState.price}
            onChange={(value) => dispatch.filters.setState({ key: "price", value })}
            icon={<TbReceipt2 fontSize={20} />}
          />
          <FilterSlider
            label="Seats"
            min={1}
            max={16}
            value={filterState.seats}
            onChange={(value) => dispatch.filters.setState({ key: "seats", value })}
          />
          <FilterSlider
            label="Doors"
            max={8}
            min={1}
            value={filterState.doors}
            onChange={(value) => dispatch.filters.setState({ key: "doors", value })}
          />
        </Stack>
      </Box>
    </>
  );
};

export default Filters;
