import { createModel } from '@rematch/core';
import { RootModel } from '.';
import { store } from '..';
import { fetchNui } from '../../utils/fetchNui';

export interface VehicleDataState {
  acceleration: number;
  braking: number;
  speed: number;
  handling: number;
  make: string;
  name: string;
  price: number;
  seats: number;
  doors: number;
  class: number;
  weapons: boolean;
}

export const vehicleData = createModel<RootModel>()({
  state: {
    acceleration: 0,
    braking: 0,
    speed: 0,
    handling: 0,
    name: '',
    make: '',
    price: 0,
    seats: 0,
    doors: 0,
    class: 0,
    weapons: false,
  } as VehicleDataState,
  reducers: {
    setState(state, payload: VehicleDataState) {
      return (state = payload);
    },
  },
  effects: (dispatch) => ({
    async getVehicleData(payload: string) {
      try {
        const vehicle = store.getState().vehicleList[payload];
        const vehicleData = await fetchNui('clickVehicle', vehicle);
        dispatch.vehicleData.setState(vehicleData);
      } catch {
        const vehicleData: VehicleDataState = {
          acceleration: 73.5,
          braking: 40.0,
          speed: 57.3,
          handling: 20.3,
          make: 'Dinka',
          name: 'Blista',
          price: 9500,
          seats: 4,
          doors: 4,
          weapons: false,
          class: 0,
        };
        dispatch.vehicleData.setState(vehicleData);
      }
    },
  }),
});
