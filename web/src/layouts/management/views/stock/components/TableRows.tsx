import { Tooltip, Badge, ActionIcon } from "@mantine/core";
import { TbEdit } from "react-icons/tb";

interface VehicleStock {
  make: string;
  name: string;
  price: number;
  stock: number;
  gallery: boolean;
}

interface Props {
  vehicle: VehicleStock;
}

const TableRows: React.FC<Props> = ({ vehicle }) => {
  return (
    <tr style={{ textAlign: "center" }}>
      <td>{vehicle.make}</td>
      <td>{vehicle.name}</td>
      <td>${vehicle.price}</td>
      <td>{vehicle.stock}</td>
      <td>
        {vehicle.gallery && (
          <Tooltip withArrow label="Vehicle is displayed in the gallery">
            <Badge>Gallery</Badge>
          </Tooltip>
        )}
      </td>
      <td>
        <Tooltip label="Edit" withArrow position="right" gutter={10}>
          <ActionIcon color="blue" variant="light">
            <TbEdit fontSize={20} />
          </ActionIcon>
        </Tooltip>
      </td>
    </tr>
  );
};

export default TableRows;
