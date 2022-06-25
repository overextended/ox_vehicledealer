import { Models } from "@rematch/core";
import { filters } from "./filters";
import { vehicles } from "./vehicles";
import { isLoading } from "./isLoading";
import { visibility } from "./visibility";

export interface RootModel extends Models<RootModel> {
  filters: typeof filters;
  vehicles: typeof vehicles;
  isLoading: typeof isLoading;
  visibility: typeof visibility;
}

export const models: RootModel = { filters, vehicles, isLoading, visibility };
