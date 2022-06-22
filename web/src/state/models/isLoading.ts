import { createModel } from "@rematch/core";
import { RootModel } from ".";

export const isLoading = createModel<RootModel>()({
  state: false as boolean,
  reducers: {
    setState(state, payload: boolean) {
      return (state = payload);
    },
  },
});
