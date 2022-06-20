import { Models } from "@rematch/core";
import { filters } from "./filters";

export interface RootModel extends Models<RootModel> {
  filters: typeof filters;
}

export const models: RootModel = { filters };
