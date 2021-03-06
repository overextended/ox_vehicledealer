import { createModel } from "@rematch/core";
import { VehicleState } from "./vehicles";
import { RootModel } from ".";
import { isEnvBrowser } from "../../utils/misc";
import { store } from "..";

export interface FilterState {
  search: string;
  price: number | undefined;
  seats: number;
  doors: number;
  category: string | null;
  categories: string[];
}

type PayloadKey = "search" | "category" | "price" | "seats" | "doors" | "categories";
type PayloadValue = string | string[] | number | undefined | null;

const vehicleClasses = [
  "Compacts",
  "Sedans",
  "SUVs",
  "Coupes",
  "Muscle",
  "Sports Classics",
  "Sports",
  "Super",
  "Motorcycles",
  "Off-road",
  "Industrial",
  "Utility",
  "Vans",
  "Cycles",
  "Boats",
  "Helicopters",
  "Planes",
  "Service",
  "Emergency",
  "Military",
  "Commercial",
  "Trains",
];

export const filters = createModel<RootModel>()({
  state: {
    search: "",
    price: undefined,
    seats: 0,
    doors: 0,
    category: null,
    categories: [],
  } as FilterState,
  reducers: {
    setState(state, payload: { key: PayloadKey; value: PayloadValue }) {
      return {
        ...state,
        [payload.key]: payload.value,
      };
    },
  },
  effects: (dispatch) => ({
    filterVehicles(payload: FilterState) {
      const vehiclesArray = Object.entries(store.getState().vehicleList);
      const filteredVehicles = vehiclesArray.filter((value) => {
        const vehicle = value[1];

        // Doesn't send back the whole vehicles object when there's no filters applied
        if (payload.doors === 0 && payload.seats === 0 && !payload.price && !payload.category && payload.search === "")
          return false;
        if (payload.doors !== 0 && vehicle.doors !== payload.doors) return false;
        if (payload.seats !== 0 && vehicle.seats !== payload.seats) return false;
        if (payload.price && vehicle.price > payload.price) return false;
        if (payload.category && vehicleClasses[vehicle.class] !== payload.category) return false;
        if (payload.categories[vehicle.class] === null) return false; // doesn't allow filtering through not allowed classes

        const regEx = new RegExp(payload.search, "gi");
        const vehicleModel = `${vehicle.make} ${vehicle.name}`;
        if (payload.search !== "" && !vehicleModel.match(regEx)) return false;

        return true;
      });

      dispatch.vehicles.setState(Object.fromEntries(filteredVehicles));
    },
  }),
});
