import { createModel, Model, RematchDispatch } from "@rematch/core";
import { RootModel } from ".";
import { fetchNui } from "../../utils/fetchNui";

export interface VehicleState {
  make: string;
  name: string;
  price: number;
  seats: number;
  doors: number;
  weapons: boolean;
}

export const vehicles = createModel<RootModel>()({
  state: [] as VehicleState[],
  reducers: {
    setState(state, payload: number) {
      return {
        ...state,
        payload,
      };
    },
  },
  effects: (dispatch) => ({
    async fetchVehicles(payload: VehicleState) {
      const vehicles = await fetchNui("fetchVehicles", payload);
      dispatch.vehicles.setState(vehicles);
    },
  }),
});
