import { useLocales } from '../../../../../providers/LocaleProvider';

const TableHeadings: React.FC = () => {
  const { locale } = useLocales();

  return (
    <thead>
      <tr>
        <th style={{ textAlign: 'center' }}>{locale.ui.stock.vehicle_make}</th>
        <th style={{ textAlign: 'center' }}>{locale.ui.stock.vehicle_name}</th>
        <th style={{ textAlign: 'center' }}>{locale.ui.stock.vehicle_price}</th>
        <th style={{ textAlign: 'center' }}>{locale.ui.stock.vehicle_wholesale}</th>
        <th style={{ textAlign: 'center' }}>{locale.ui.stock.vehicle_plate}</th>
        <th></th>
        <th></th>
        <th></th>
      </tr>
    </thead>
  );
};

export default TableHeadings;
