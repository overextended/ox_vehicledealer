import { Table, ScrollArea } from '@mantine/core';
import TableHeadings from './components/TableHeadings';
import TableRows from './components/TableRows';

const vehicles: {
  [key: string]: {
    make: string;
    name: string;
    price: number;
    stock: number;
    gallery: boolean;
  };
} = {
  blista: {
    make: 'Dinka',
    name: 'Blista',
    price: 9500,
    gallery: true,
    stock: 3,
  },
  dominator: {
    make: 'Vapid',
    name: 'Dominator',
    price: 135000,
    gallery: false,
    stock: 1,
  },
};

const Stock: React.FC = () => {
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
