import { createModel } from "@rematch/core";
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
    setState(state, payload: VehicleState[]) {
      return (state = payload);
    },
  },
  effects: (dispatch) => ({
    // payload: filters?
    async fetchVehiclesByFilter(payload: VehicleState) {
      dispatch.isLoading.setState(true);
      const vehicles = await fetchNui("fetchVehicles", payload);
      dispatch.vehicles.setState(vehicles);
      dispatch.isLoading.setState(false);
    },
    async fetchVehiclesByCategory(payload: string) {
      dispatch.isLoading.setState(true);
      try {
        const vehicles = await fetchNui("fetchCategory", payload);
        dispatch.vehicles.setState(vehicles);
        dispatch.isLoading.setState(false);
      } catch (e) {
        const vehicles = [
          {
            make: "Dinka",
            name: "Blista",
            price: 9500,
            seats: 4,
            doors: 4,
            weapons: false,
          },
        ];
        dispatch.vehicles.setState(vehicles);
        dispatch.isLoading.setState(false);
      }
    },
  }),
});
