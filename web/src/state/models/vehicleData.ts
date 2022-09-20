import { createModel } from '@rematch/core';
import { RootModel } from '.';
import { store } from '..';
import { fetchNui } from '../../utils/fetchNui';
import { VehicleData } from './vehicles';

interface SelectedVehicle extends VehicleData {
  model: string;
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
  } as SelectedVehicle,

  reducers: {
    setState(state, payload: SelectedVehicle) {
      return (state = payload);
    },
  },
  effects: (dispatch) => ({
    getVehicleData(payload: string) {
      try {
        const vehicle = { ...store.getState().vehicles[payload], model: payload };
        fetchNui('clickVehicle', vehicle);
        dispatch.vehicleData.setState(vehicle);
      } catch {
        const vehicleData: SelectedVehicle = {
          acceleration: 73.5,
          braking: 40.0,
          speed: 57.3,
          handling: 20.3,
          make: 'Dinka',
          name: 'Blista',
          model: 'blista',
          type: 'automobile',
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
