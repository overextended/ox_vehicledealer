import { Tooltip, Badge, ActionIcon } from '@mantine/core';
import { TbEdit, TbTrash } from 'react-icons/tb';
import { openConfirmModal, openModal } from '@mantine/modals';
import EditModal from './EditModal';
import { VehicleStock } from '../../../../../state/models/vehicleStock';
import { fetchNui } from '../../../../../utils/fetchNui';

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
            disabled={!vehicle.gallery}
            onClick={() =>
              openModal({ title: 'Edit', children: <EditModal currentPrice={vehicle.price} plate={vehicle.plate} /> })
            }
          >
            <TbEdit fontSize={20} />
          </ActionIcon>
        </Tooltip>
      </td>
      <td>
        <Tooltip label="Sell" withArrow position="top" offset={10}>
          <ActionIcon
            color="red"
            variant="light"
            onClick={() =>
              openConfirmModal({
                title: 'Sell vehicle',
                size: 'sm',
                children: `Are you sure you want to sell ${vehicle.make} ${vehicle.name} (${
                  vehicle.plate
                }) for ${Intl.NumberFormat('en-us', {
                  style: 'currency',
                  currency: 'USD',
                  maximumFractionDigits: 0,
                }).format(vehicle.price)}?`,
                labels: { confirm: 'Confirm', cancel: 'Cancel' },
                confirmProps: { color: 'red', uppercase: true },
                cancelProps: { uppercase: true },
                onConfirm: () => fetchNui('sellVehicle', vehicle.plate),
              })
            }
          >
            <TbTrash fontSize={20} />
          </ActionIcon>
        </Tooltip>
      </td>
    </tr>
  );
};

export default TableRows;
