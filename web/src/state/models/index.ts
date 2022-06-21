import { Models } from "@rematch/core";
import { filters } from "./filters";
import { vehicles } from "./vehicles";

export interface RootModel extends Models<RootModel> {
  filters: typeof filters;
  vehicles: typeof vehicles;
}

export const models: RootModel = { filters, vehicles };
