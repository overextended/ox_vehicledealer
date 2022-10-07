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
        confirm: 'Confirm',
        cancel: 'Cancel',
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
        },
        management: {
          stock: 'Stock',
          gallery: 'Gallery',
          exit: 'Exit',
          vehicle_price: 'Vehicle price',
        },
        management_gallery: {
          add_vehicle: 'Add gallery vehicle',
          remove_vehicle: 'Remove vehicle',
          modal: {
            vehicle_select: 'Vehicle',
            vehicle_select_description: 'Select a vehicle from the stock to display',
            vehicle_nothing_found: 'No such vehicle in stock',
            vehicle_price_description: 'If not set defaults to wholesale price',
          },
        },
        stock: {
          vehicle_make: 'Make',
          vehicle_name: 'Name',
          vehicle_price: 'Price',
          vehicle_wholesale: 'Wholesale',
          vehicle_plate: 'Plate',
          vehicle_in_gallery: 'Vehicle is displayed in the gallery',
          edit: 'Edit',
          sell: 'Sell',
          vehicle_sell: 'Sell vehicle',
          vehicle_sell_text: 'Are you sure you want to sell %s (%s) for %d',
        },
      },
    },
  },
]);

interface Locale {
  ui: {
    confirm: string;
    cancel: string;
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
    };
    management: {
      stock: string;
      gallery: string;
      exit: string;
      vehicle_price: string;
    };
    management_gallery: {
      add_vehicle: string;
      remove_vehicle: string;
      modal: {
        vehicle_select: string;
        vehicle_select_description: string;
        vehicle_nothing_found: string;
        vehicle_price_description: string;
      };
    };
    stock: {
      vehicle_make: string;
      vehicle_name: string;
      vehicle_price: string;
      vehicle_wholesale: string;
      vehicle_plate: string;
      vehicle_in_gallery: string;
      edit: string;
      sell: string;
      vehicle_sell: string;
      vehicle_sell_text: string;
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
      confirm: '',
      cancel: '',
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
      },
      management: {
        stock: '',
        gallery: '',
        exit: '',
        vehicle_price: '',
      },
      management_gallery: {
        add_vehicle: '',
        remove_vehicle: '',
        modal: {
          vehicle_select: '',
          vehicle_select_description: '',
          vehicle_nothing_found: '',
          vehicle_price_description: '',
        },
      },
      stock: {
        vehicle_make: '',
        vehicle_name: '',
        vehicle_price: '',
        vehicle_wholesale: '',
        vehicle_plate: '',
        vehicle_in_gallery: '',
        edit: '',
        sell: '',
        vehicle_sell: '',
        vehicle_sell_text: '',
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
