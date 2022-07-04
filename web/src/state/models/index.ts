import { Models } from "@rematch/core";
import { filters } from "./filters";
import { vehicles } from "./vehicles";
import { isLoading } from "./isLoading";
import { visibility } from "./visibility";
import { vehicleData } from "./vehicleData";
import { vehicleList } from "./vehicleList";

export interface RootModel extends Models<RootModel> {
  filters: typeof filters;
  vehicles: typeof vehicles;
  isLoading: typeof isLoading;
  visibility: typeof visibility;
  vehicleData: typeof vehicleData;
  vehicleList: typeof vehicleList;
}

export const models: RootModel = { filters, vehicles, isLoading, visibility, vehicleData, vehicleList };
