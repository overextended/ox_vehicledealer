import { createModel } from "@rematch/core";
import { RootModel } from ".";

interface FilterState {
  price: number | undefined;
  seats: number;
  doors: number;
}

type PayloadKey = "price" | "seats" | "doors";

export const filters = createModel<RootModel>()({
  state: {
    price: undefined,
    seats: 1,
    doors: 1,
  } as FilterState,
  reducers: {
    setState(state, payload: { key: PayloadKey; value: number | undefined }) {
      return {
        ...state,
        [payload.key]: payload.value,
      };
    },
  },
});
