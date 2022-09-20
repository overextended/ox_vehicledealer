import { Group, Text } from '@mantine/core';
import { IconBaseProps } from 'react-icons';

interface Props {
  label: string | number;
  Icon: React.ComponentType<IconBaseProps>;
  style?: React.CSSProperties;
}

const IconGroup: React.FC<Props> = ({ label, Icon, style }) => {
  return (
    <>
      <Group spacing={5} position="left" style={style}>
        <Icon fontSize={20} />
        <Text sx={{ lineHeight: '20px' }}>{label}</Text>
      </Group>
    </>
  );
};

export default IconGroup;
