import { Context, createContext, useContext, useEffect, useState } from 'react';
import { useIsFirstRender } from '../hooks/useIsFirstRender';
import { useNuiEvent } from '../hooks/useNuiEvent';
import { debugData } from '../utils/debugData';
import { fetchNui } from '../utils/fetchNui';
import { isEnvBrowser } from '../utils/misc';

debugData([
  {
    action: 'setLocale',
    data: {
      ui: {
        vehicle_category: 'Vehicle category',
        no_vehilce_category: 'No such vehicle category',
        vehicles: 'Vehicles',
        no_vehicles_found: 'No vehicles found',
        filters: {
          advanced_filters: 'Advanced filters',
          max_price: 'Max price',
          seats: 'Seats',
          doors: 'Doors',
        },
        vehicle_info: {
          color_primary: 'Primary color',
          color_secondary: 'Secondary color',
          speed: 'Speed',
          acceleration: 'Acceleration',
          braking: 'Braking',
          handling: 'Handling',
          purchase: 'Purchase',
        },
        purchase_modal: {
          purchase_vehicle: 'Purchase vehicle',
          purchase_confirm: 'Confirm purchase of %s for %d?',
          confirm: 'Confirm',
          cancel: 'Cancel',
        },
      },
    },
  },
]);

interface Locale {
  ui: {
    vehicle_category: string;
    no_vehicle_category: string;
    vehicles: string;
    no_vehicles_found: string;
    filters: {
      advanced_filters: string;
      max_price: string;
      seats: string;
      doors: string;
    };
    vehicle_info: {
      color_primary: string;
      color_secondary: string;
      speed: string;
      acceleration: string;
      braking: string;
      handling: string;
      purchase: string;
    };
    purchase_modal: {
      purchase_vehicle: string;
      purchase_confirm: string;
      confirm: string;
      cancel: string;
    };
  };
}

interface LocaleContextValue {
  locale: Locale;
  setLocale: (locales: Locale) => void;
}

const LocaleCtx = createContext<LocaleContextValue | null>(null);

const LocaleProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const isFirst = useIsFirstRender();
  const [locale, setLocale] = useState<Locale>({
    ui: {
      vehicle_category: '',
      no_vehicle_category: '',
      vehicles: '',
      no_vehicles_found: '',
      filters: {
        advanced_filters: '',
        max_price: '',
        seats: '',
        doors: '',
      },
      vehicle_info: {
        color_primary: '',
        color_secondary: '',
        speed: '',
        acceleration: '',
        braking: '',
        handling: '',
        purchase: '',
      },
      purchase_modal: {
        purchase_vehicle: '',
        purchase_confirm: '',
        confirm: '',
        cancel: '',
      },
    },
  });

  useEffect(() => {
    if (!isFirst && !isEnvBrowser()) return;
    fetchNui('loadLocale');
  }, []);

  useNuiEvent('setLocale', async (data: Locale) => setLocale(data));

  return <LocaleCtx.Provider value={{ locale, setLocale }}>{children}</LocaleCtx.Provider>;
};

export default LocaleProvider;

export const useLocales = () => useContext<LocaleContextValue>(LocaleCtx as Context<LocaleContextValue>);
