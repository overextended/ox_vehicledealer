import { createModel } from '@rematch/core';
import { RootModel } from './index';
import { fetchNui } from '../../utils/fetchNui';
import { store } from '../index';

export interface VehicleStock {
  make: string;
  name: string;
  price: number;
  model: string;
  wholesale: number;
  plate: string;
  id: number;
  gallery: boolean;
}

export const vehicleStock = createModel<RootModel>()({
  state: [] as VehicleStock[],
  reducers: {
    setVehicleStock(state, payload: VehicleStock[]) {
      return (state = payload);
    },
    setVehiclePrice(state, payload: { id: number; price: number }) {
      return state.map((vehicle) => {
        if (vehicle.id === payload.id) return { ...vehicle, price: payload.price };
        else return vehicle;
      });
    },
    setVehicleInGallery(state, payload: { plate: string; gallery: boolean; price?: number }) {
      return state.map((vehicle) => {
        if (vehicle.plate === payload.plate) {
          if (payload.price) return { ...vehicle, gallery: payload.gallery, price: payload.price };
          else return { ...vehicle, gallery: payload.gallery };
        } else return vehicle;
      });
    },
  },
  effects: (dispatch) => ({
    // Converts data sent from Lua to match data types in UI
    convertToStock(payload: { model: string; plate: string; price: number; gallery: boolean; id: number }[]) {
      const vehicleStock: VehicleStock[] = [];
      for (const vehicle of payload) {
        const vehicleData = store.getState().vehicles[vehicle.model];
        const stockVehicle: VehicleStock = {
          wholesale: vehicleData.price,
          make: vehicleData.make,
          name: vehicleData.name,
          price: vehicle.price,
          id: vehicle.id,
          plate: vehicle.plate,
          model: vehicle.model,
          gallery: vehicle.gallery,
        };
        vehicleStock.push(stockVehicle);
      }
      return vehicleStock;
    },
  }),
});
