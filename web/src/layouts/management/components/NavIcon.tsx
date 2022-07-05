import { Tooltip, ActionIcon } from "@mantine/core";
import { IconBaseProps } from "react-icons";
import { Link } from "react-router-dom";

interface Props {
  tooltip: string;
  to: string;
  Icon: React.ComponentType<IconBaseProps>;
  iconSize?: number;
}

const NavIcon: React.FC<Props> = ({ tooltip, to, Icon, iconSize }) => {
  return (
    <>
      <Tooltip label={tooltip} withArrow position="right">
        <ActionIcon
          component={Link}
          to={to}
          variant="transparent"
          size="xl"
          sx={(theme) => ({
            width: 50,
            height: 50,
            transition: "300ms",
            ":hover": { color: theme.colors.blue[5] },
          })}
        >
          <Icon fontSize={iconSize || 24} />
        </ActionIcon>
      </Tooltip>
    </>
  );
};

export default NavIcon;
