import { Tooltip, ActionIcon } from "@mantine/core";
import { IconBaseProps } from "react-icons";
import { Link, useLocation } from "react-router-dom";
import React from "react";

interface Props {
  tooltip: string;
  to: string;
  Icon: React.ComponentType<IconBaseProps>;
  iconSize?: number;
}

const NavIcon: React.FC<Props> = ({ tooltip, to, Icon, iconSize }) => {
  const location = useLocation();

  return (
    <>
      <Tooltip label={tooltip} withArrow position="right">
        <ActionIcon
          component={Link}
          to={to}
          variant={location.pathname === to ? "light" : "transparent"}
          size="xl"
          color="blue"
          sx={(theme) => ({
            width: 50,
            height: 50,
            transition: "300ms",
            ":hover": { color: theme.colors.blue[3] },
          })}
        >
          <Icon fontSize={iconSize || 24} />
        </ActionIcon>
      </Tooltip>
    </>
  );
};

export default NavIcon;
