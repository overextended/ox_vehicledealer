import { Tooltip, Badge, ActionIcon } from '@mantine/core';
import { TbEdit } from 'react-icons/tb';
import { openModal } from '@mantine/modals';
import EditModal from './EditModal';

interface VehicleStock {
  make: string;
  name: string;
  price: number;
  stock: number;
  gallery: boolean;
  wholesale: number;
}

interface Props {
  vehicle: VehicleStock;
  model: string;
}

const TableRows: React.FC<Props> = ({ vehicle, model }) => {
  return (
    <tr style={{ textAlign: 'center' }}>
      <td>{vehicle.make}</td>
      <td>{vehicle.name}</td>
      <td>
        {Intl.NumberFormat('en-us', { style: 'currency', currency: 'USD', maximumFractionDigits: 0 }).format(
          vehicle.price
        )}
      </td>
      <td>
        {Intl.NumberFormat('en-us', { style: 'currency', currency: 'USD', maximumFractionDigits: 0 }).format(
          vehicle.wholesale
        )}
      </td>
      <td>{vehicle.stock}</td>
      <td>
        {vehicle.gallery && (
          <Tooltip withArrow label="Vehicle is displayed in the gallery">
            <Badge>Gallery</Badge>
          </Tooltip>
        )}
      </td>
      <td>
        <Tooltip label="Edit" withArrow position="right" offset={10}>
          <ActionIcon
            color="blue"
            variant="light"
            onClick={() =>
              openModal({ title: 'Edit', children: <EditModal currentPrice={vehicle.price} model={model} /> })
            }
          >
            <TbEdit fontSize={20} />
          </ActionIcon>
        </Tooltip>
      </td>
    </tr>
  );
};

export default TableRows;
