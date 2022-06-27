import { createModel } from "@rematch/core";
import { RootModel } from ".";
import { fetchNui } from "../../utils/fetchNui";

interface VehicleDataState {
  acceleration: number;
  braking: number;
  speed: number;
  handling: number;
  name: string;
  make: string;
  price: number;
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
      console.log("nice");
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
        };
        dispatch.vehicleData.setState(vehicleData);
      }
    },
  }),
});
