import { Tooltip, Badge, ActionIcon } from '@mantine/core';
import { TbEdit } from 'react-icons/tb';
import { openModal } from '@mantine/modals';
import EditModal from './EditModal';
import { VehicleStock } from '../../../../../state/models/vehicleStock';

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
      <td>{vehicle.plate}</td>
      <td>
        {vehicle.gallery && (
          <Tooltip withArrow label="Vehicle is displayed in the gallery">
            <Badge>Gallery</Badge>
          </Tooltip>
        )}
      </td>
      <td>
        <Tooltip label="Edit" withArrow position="top" offset={10}>
          <ActionIcon
            color="blue"
            variant="light"
            onClick={() =>
              openModal({ title: 'Edit', children: <EditModal currentPrice={vehicle.price} plate={vehicle.plate} /> })
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
