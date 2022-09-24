import { Table, ScrollArea } from '@mantine/core';
import TableHeadings from './components/TableHeadings';
import TableRows from './components/TableRows';
import { useAppDispatch, useAppSelector } from '../../../../state';
import { useEffect } from 'react';

const Stock: React.FC = () => {
  const vehicles = useAppSelector((state) => state.vehicleStock);
  const dispatch = useAppDispatch();

  useEffect(() => {
    dispatch.vehicleStock.fetchVehicleStock();
  }, []);

  return (
    <ScrollArea style={{ height: 584 }} offsetScrollbars scrollbarSize={6}>
      <Table verticalSpacing="sm">
        <TableHeadings />
        <tbody>
          {Object.values(vehicles).map((vehicle, index) => (
            <TableRows vehicle={vehicle} key={`${vehicle.name}-${index}`} />
          ))}
        </tbody>
      </Table>
    </ScrollArea>
  );
};

export default Stock;
