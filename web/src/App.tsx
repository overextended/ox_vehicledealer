import { debugData } from './utils/debugData';
import VehicleBrowser from './layouts/browser';
import { useNuiEvent } from './hooks/useNuiEvent';
import { useState } from 'react';
import { useAppDispatch } from './state';
import { useExitListener } from './hooks/useExitListener';
import Vehicle from './layouts/vehicle';
import Management from './layouts/management';
import Dev from './layouts/dev';
import { isEnvBrowser } from './utils/misc';
import { vehicleClasses } from './state/models/filters';

export default function App() {
  const [categories, setCategories] = useState<string[]>(['']);
  const dispatch = useAppDispatch();

  useExitListener(dispatch.visibility.setBrowserVisible);

  useNuiEvent(
    'setVisible',
    (data: { categories: Record<string, true>; types: Record<string, true>; weapons?: boolean; visible: boolean }) => {
      const categories: string[] = [];
      for (const category in Object.keys(data.categories)) categories.push(vehicleClasses[category]);
      setCategories(categories);
      dispatch.filters.setCategories(data.categories);
      dispatch.filters.setTypes(data.types);
      dispatch.filters.setState({ key: 'weapons', value: data.weapons });
      dispatch.visibility.setBrowserVisible(data.visible);
    }
  );

  return (
    <>
      <VehicleBrowser categories={categories} />
      <Vehicle />
      <Management />
      {isEnvBrowser() && <Dev />}
    </>
  );
}
