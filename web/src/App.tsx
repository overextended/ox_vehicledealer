import { debugData } from './utils/debugData';
import VehicleBrowser from './layouts/browser';
import { useNuiEvent } from './hooks/useNuiEvent';
import { useState } from 'react';
import { useAppDispatch } from './state';
import { useExitListener } from './hooks/useExitListener';
import Vehicle from './layouts/vehicle';
import Management from './layouts/management';

debugData([
  {
    action: 'setVisible',
    data: {
      categories: ['Compacts', 'Sedans', 'Motorcycles', 'Sports'],
      visible: true,
    },
  },
]);

export default function App() {
  const [categories, setCategories] = useState<string[]>(['']);
  const dispatch = useAppDispatch();

  useExitListener(dispatch.visibility.setBrowserVisible);

  useNuiEvent('setVisible', (data: { categories: string[]; visible: boolean }) => {
    const categories = data.categories.filter((category) => category !== null);
    setCategories(categories);
    dispatch.filters.setState({ key: 'categories', value: data.categories });
    dispatch.visibility.setBrowserVisible(data.visible);
  });

  return (
    <>
      <VehicleBrowser categories={categories} />
      <Vehicle />
      <Management />
    </>
  );
}
