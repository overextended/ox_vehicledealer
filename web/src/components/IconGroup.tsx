import { Group, Text } from "@mantine/core";
import { IconBaseProps, IconType } from "react-icons";

interface Props {
  label: string | number;
  Icon: React.ComponentType<IconBaseProps>;
}

const IconGroup: React.FC<Props> = ({ label, Icon }) => {
  return (
    <>
      <Group spacing={5} position="left">
        <Icon fontSize={20} />
        <Text>{label}</Text>
      </Group>
    </>
  );
};

export default IconGroup;
