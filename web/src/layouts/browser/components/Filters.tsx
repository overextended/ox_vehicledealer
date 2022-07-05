import { Box, Stack, NumberInput, ActionIcon, Group, Modal } from "@mantine/core";
import FilterSlider from "../../../components/FilterSlider";
import { TbFilter, TbReceipt2 } from "react-icons/tb";
import { useAppDispatch, useAppSelector } from "../../../state";
import Search from "./Search";
import { useState } from "react";
import { useLocales } from "../../../providers/LocaleProvider";

const Filters: React.FC = () => {
  const { locale } = useLocales();
  const dispatch = useAppDispatch();
  const filterState = useAppSelector((state) => state.filters);
  const [open, setOpen] = useState(false);

  return (
    <>
      <Group noWrap sx={{ width: "100%" }} position="apart" grow>
        <ActionIcon variant="outline" color="blue" size="lg" onClick={() => setOpen(true)}>
          <TbFilter fontSize={20} />
        </ActionIcon>
        <Search />
      </Group>
      <Modal
        opened={open}
        onClose={() => setOpen(false)}
        size="xs"
        title={locale.ui.filters.advanced_filters}
        closeOnEscape={false}
      >
        <Box mb={15}>
          <Stack>
            <NumberInput
              label={locale.ui.filters.max_price}
              hideControls
              value={filterState.price}
              onChange={(value) => dispatch.filters.setState({ key: "price", value })}
              icon={<TbReceipt2 fontSize={20} />}
            />
            <FilterSlider
              label={locale.ui.filters.seats}
              min={0}
              max={16}
              value={filterState.seats}
              onChange={(value) => dispatch.filters.setState({ key: "seats", value })}
            />
            <FilterSlider
              label={locale.ui.filters.doors}
              max={8}
              min={0}
              value={filterState.doors}
              onChange={(value) => dispatch.filters.setState({ key: "doors", value })}
            />
          </Stack>
        </Box>
      </Modal>
    </>
  );
};

export default Filters;
