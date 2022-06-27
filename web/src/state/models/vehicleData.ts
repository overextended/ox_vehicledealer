import { createModel } from "@rematch/core";
import { RootModel } from ".";
import { fetchNui } from "../../utils/fetchNui";
import { VehicleState } from "./vehicles";

export interface VehicleDataState extends VehicleState {
  acceleration: number;
  braking: number;
  speed: number;
  handling: number;
}

export const vehicleData = createModel<RootModel>()({
  state: {
    acceleration: 0,
    braking: 0,
    speed: 0,
    handling: 0,
    name: "",
    make: "",
    price: 0,
  } as VehicleDataState,
  reducers: {
    setState(state, payload: VehicleDataState) {
      return (state = payload);
    },
  },
  effects: (dispatch) => ({
    async getVehicleData(payload: number) {
      try {
        const vehicleData = await fetchNui("clickVehicle", payload);
        dispatch.vehicleData.setState(vehicleData);
      } catch {
        const vehicleData: VehicleDataState = {
          acceleration: 73.5,
          braking: 40.0,
          speed: 57.3,
          handling: 20.3,
          make: "Dinka",
          name: "Blista",
          price: 9500,
          seats: 4,
          doors: 4,
          weapons: false,
        };
        dispatch.vehicleData.setState(vehicleData);
      }
    },
  }),
});
