import { createModel } from "@rematch/core";
import { RootModel } from ".";

interface FilterState {
  search: string;
  price: number | undefined;
  seats: number;
  doors: number;
}

type PayloadKey = "search" | "price" | "seats" | "doors";

export const filters = createModel<RootModel>()({
  state: {
    search: "",
    price: undefined,
    seats: 1,
    doors: 1,
  } as FilterState,
  reducers: {
    setState(state, payload: { key: PayloadKey; value: string | number | undefined }) {
      return {
        ...state,
        [payload.key]: payload.value,
      };
    },
  },
});
