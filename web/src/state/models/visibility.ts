import { createModel } from "@rematch/core";
import { RootModel } from ".";

interface VisibilityState {
  browser: boolean;
}

export const visibility = createModel<RootModel>()({
  state: {
    browser: false,
  } as VisibilityState,
  reducers: {
    setBrowserVisible(state, payload: boolean) {
      return {
        ...state,
        browser: payload,
      };
    },
  },
});
