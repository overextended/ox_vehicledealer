import { Stack, Slider, Text } from "@mantine/core";

interface Props {
  label: string;
  min?: number;
  max?: number;
  step?: number;
}

const FilterSlider: React.FC<Props> = (props) => {
  return (
    <>
      <Stack spacing="xs">
        <Text>{props.label}</Text>
        <Slider min={props.min} max={props.max} step={props.step} />
      </Stack>
    </>
  );
};

export default FilterSlider;
