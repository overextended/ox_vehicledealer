import { createModel } from "@rematch/core";
import { RootModel } from ".";
import { fetchNui } from "../../utils/fetchNui";
import { FilterState } from "./filters";

export interface VehicleState {
  [key: string]: {
    make: string;
    name: string;
    price: number;
    seats: number;
    doors: number;
    class: number;
    weapons: boolean;
  };
}

export const vehicles = createModel<RootModel>()({
  state: {} as VehicleState,
  reducers: {
    setState(state, payload: VehicleState) {
      return (state = payload);
    },
  },
  effects: (dispatch) => ({
    async fetchVehicles(payload: FilterState) {
      dispatch.isLoading.setState(true);
      try {
        const vehicles = await fetchNui("fetchVehicles", payload);
        dispatch.vehicles.setState(vehicles);
      } catch {
        const vehicles = {
          dinka: {
            make: "Dinka",
            name: "Blista",
            price: 9500,
            seats: 4,
            doors: 4,
            class: 0,
            weapons: false,
          },
        } as VehicleState;
        dispatch.vehicles.setState(vehicles);
      }
      dispatch.isLoading.setState(false);
    },
  }),
});
