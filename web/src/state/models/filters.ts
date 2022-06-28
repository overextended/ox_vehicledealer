import { createModel } from "@rematch/core";
import { RootModel } from ".";

export interface FilterState {
  search: string;
  price: number | undefined;
  seats: number;
  doors: number;
  category: string | null;
}

type PayloadKey = "search" | "category" | "price" | "seats" | "doors";
type PayloadValue = string | number | undefined | null;

export const filters = createModel<RootModel>()({
  state: {
    search: "",
    price: undefined,
    seats: 1,
    doors: 1,
    category: null,
  } as FilterState,
  reducers: {
    setState(state, payload: { key: PayloadKey; value: PayloadValue }) {
      return {
        ...state,
        [payload.key]: payload.value,
      };
    },
  },
});
