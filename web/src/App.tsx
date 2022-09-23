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
import Popup from './layouts/popup';
import vehicle from './layouts/vehicle';

export default function App() {
  const [categories, setCategories] = useState<string[]>(['']);
  const dispatch = useAppDispatch();

  useExitListener(dispatch.visibility.setBrowserVisible);

  useNuiEvent(
    'setVisible',
    (data: { categories: number[]; types: Record<string, true>; weapons?: boolean; visible: boolean }) => {
      const categories: string[] = [];
      for (let i = 0; i < data.categories.length; i++) categories.push(vehicleClasses[data.categories[i]]);
      setCategories(categories);
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
      <Popup />
      {isEnvBrowser() && <Dev />}
    </>
  );
}
