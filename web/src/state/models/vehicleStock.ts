import { createModel } from '@rematch/core';
import { RootModel } from './index';
import { fetchNui } from '../../utils/fetchNui';

export interface VehicleStock {
  [key: string]: {
    make: string;
    name: string;
    price: number;
    stock: number;
    wholesale: number;
    gallery: boolean;
  };
}

export const vehicleStock = createModel<RootModel>()({
  state: {} as VehicleStock,
  reducers: {
    setVehicleStock(state, payload: VehicleStock) {
      return (state = payload);
    },
    setVehiclePrice(state, payload: { model: string; price: number }) {
      return {
        ...state,
        [payload.model]: {
          ...state[payload.model],
          price: payload.price,
        },
      };
    },
  },
  effects: (dispatch) => ({
    async fetchVehicleStock() {
      try {
        const vehicleStock = await fetchNui('getVehicleStock');
        dispatch.vehicleStock.setVehicleStock(vehicleStock);
      } catch {
        dispatch.vehicleStock.setVehicleStock({
          ['blista']: {
            make: 'Dinka',
            name: 'Blista',
            price: 13000,
            stock: 3,
            wholesale: 9500,
            gallery: true,
          },
          ['dominator']: {
            make: 'Vapid',
            name: 'Dominator',
            price: 29000,
            wholesale: 15000,
            stock: 1,
            gallery: false,
          },
        });
      }
    },
  }),
});
