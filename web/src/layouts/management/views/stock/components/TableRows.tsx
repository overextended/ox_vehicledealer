import { Tooltip, Badge, ActionIcon } from '@mantine/core';
import { TbEdit, TbTrash } from 'react-icons/tb';
import { openConfirmModal, openModal } from '@mantine/modals';
import EditModal from './EditModal';
import { VehicleStock } from '../../../../../state/models/vehicleStock';
import { fetchNui } from '../../../../../utils/fetchNui';
import { formatNumber } from '../../../../../utils/formatNumber';
import { useLocales } from '../../../../../providers/LocaleProvider';

interface Props {
  vehicle: VehicleStock;
  model: string;
}

const TableRows: React.FC<Props> = ({ vehicle, model }) => {
  const { locale } = useLocales();

  return (
    <tr style={{ textAlign: 'center' }}>
      <td>{vehicle.make}</td>
      <td>{vehicle.name}</td>
      <td>{vehicle.price ? formatNumber(vehicle.price) : '-'}</td>
      <td>{formatNumber(vehicle.wholesale)}</td>
      <td>{vehicle.plate}</td>
      <td>
        {vehicle.gallery && (
          <Tooltip withArrow label="Vehicle is displayed in the gallery">
            <Badge>{locale.ui.management.gallery}</Badge>
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
              openModal({
                title: locale.ui.stock.edit,
                children: <EditModal currentPrice={vehicle.price} plate={vehicle.plate} />,
              })
            }
          >
            <TbEdit fontSize={20} />
          </ActionIcon>
        </Tooltip>
      </td>
      <td>
        <Tooltip label={locale.ui.stock.sell} withArrow position="top" offset={10}>
          <ActionIcon
            color="red"
            variant="light"
            onClick={() =>
              openConfirmModal({
                title: locale.ui.stock.vehicle_sell,
                size: 'sm',
                children: locale.ui.stock.vehicle_sell_text
                  .replace('%s', `${vehicle.make} ${vehicle.name}`)
                  .replace('%s', vehicle.plate)
                  .replace('%d', formatNumber(vehicle.wholesale)),
                labels: { confirm: locale.ui.confirm, cancel: locale.ui.cancel },
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
