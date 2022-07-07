import { Card, Stack, Group, Center, Button, Text } from "@mantine/core";
import { FaCarSide } from "react-icons/fa";
import { TbDatabase, TbPlus, TbTag } from "react-icons/tb";
import IconGroup from "../../../../../components/IconGroup";

interface Props {
  vehicle: {
    make: string;
    name: string;
    stock: number;
    salePrice: number;
  } | null;
  index: number;
}

const GalleryCard: React.FC<Props> = ({ vehicle, index }) => {
  return (
    <Card sx={{ width: 280, height: 200 }} shadow="sm">
      <Stack justify="space-between" sx={{ height: "100%" }}>
        <Group position="apart">
          <Text>Gallery Slot</Text>
          <Text>{index + 1}</Text>
        </Group>

        {vehicle ? (
          <Group position="apart">
            <Stack>
              <IconGroup label={vehicle.salePrice} Icon={TbTag} />
              <IconGroup label={vehicle.stock} Icon={TbDatabase} />
            </Stack>
            <IconGroup label={`${vehicle.make} ${vehicle.name}`} Icon={FaCarSide} style={{ alignSelf: "flex-start" }} />
          </Group>
        ) : (
          <Center>
            <TbPlus fontSize={42} />
          </Center>
        )}

        <Center>
          <Button fullWidth variant="light" color={vehicle ? "red" : undefined}>
            {vehicle ? "Remove vehicle" : "Select vehicle"}
          </Button>
        </Center>
      </Stack>
    </Card>
  );
};

export default GalleryCard;
