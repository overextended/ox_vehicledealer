import { Box, Stack, Slider, Text } from "@mantine/core";
import FilterSlider from "../../../components/FilterSlider";

const Filters: React.FC = () => {
  return (
    <>
      <Box mt={15} sx={{ fontWeight: 400 }}>
        <Stack>
          <FilterSlider label="Price" max={7900000} />
          <FilterSlider label="Seats" min={1} max={16} />
          <FilterSlider label="Doors" max={8} min={1} />
        </Stack>
      </Box>
    </>
  );
};

export default Filters;
