import { createModel } from '@rematch/core';
import { RootModel } from '.';
import { store } from '..';

export interface FilterState {
  search: string;
  price: number | undefined;
  seats: number;
  doors: number;
  category: string | null;
  types: string[];
  weapons?: boolean;
}

type PayloadKey = 'search' | 'category' | 'price' | 'seats' | 'doors' | 'types' | 'weapons';
type PayloadValue = string | string[] | number | boolean | undefined | null;

export const vehicleClasses = [
  'Compacts',
  'Sedans',
  'SUVs',
  'Coupes',
  'Muscle',
  'Sports Classics',
  'Sports',
  'Super',
  'Motorcycles',
  'Off-road',
  'Industrial',
  'Utility',
  'Vans',
  'Cycles',
  'Boats',
  'Helicopters',
  'Planes',
  'Service',
  'Emergency',
  'Military',
  'Commercial',
  'Trains',
  'Open Wheel',
];

export const filters = createModel<RootModel>()({
  state: {
    search: '',
    price: undefined,
    seats: 0,
    doors: 0,
    category: null,
    types: [],
    weapons: undefined,
  } as FilterState,
  reducers: {
    setState(state, payload: { key: PayloadKey; value: PayloadValue }) {
      return {
        ...state,
        [payload.key]: payload.value,
      };
    },
    setTypes(state, payload: Record<string, true>) {
      return { ...state, types: Object.keys(payload) };
    },
  },
  effects: (dispatch) => ({
    filterVehicles(payload: FilterState) {
      const vehiclesArray = Object.entries(store.getState().vehicles);
      const filteredVehicles = vehiclesArray.filter((value) => {
        const vehicle = value[1];

        // Doesn't send back the whole vehicles object when there's no filters applied
        if (payload.doors === 0 && payload.seats === 0 && !payload.price && !payload.category && payload.search === '')
          return false;
        if (payload.doors !== 0 && vehicle.doors !== payload.doors) return false;
        if (payload.seats !== 0 && vehicle.seats !== payload.seats) return false;
        if (payload.price && vehicle.price > payload.price) return false;
        if (payload.category && vehicleClasses[vehicle.class] !== payload.category) return false;
        if (!payload.types.includes(vehicle.type)) return false;
        if ((payload.weapons === false && vehicle.weapons) || (payload.weapons && !vehicle.weapons)) return false;

        const regEx = new RegExp(payload.search, 'gi');
        const vehicleModel = `${vehicle.make} ${vehicle.name}`;
        if (payload.search !== '' && !vehicleModel.match(regEx)) return false;

        return true;
      });

      dispatch.listVehicles.setVehicles(Object.fromEntries(filteredVehicles));
    },
  }),
});
