import { createModel } from "@rematch/core";
import { RootModel } from ".";

interface VisibilityState {
  browser: boolean;
  vehicle: boolean;
  management: boolean;
}

export const visibility = createModel<RootModel>()({
  state: {
    browser: false,
    vehicle: false,
    management: false,
  } as VisibilityState,
  reducers: {
    setBrowserVisible(state, payload: boolean) {
      return {
        ...state,
        browser: payload,
      };
    },
    setVehicleVisible(state, payload: boolean) {
      return {
        ...state,
        vehicle: payload,
      };
    },
    setManagementVisible(state, payload: boolean) {
      return {
        ...state,
        management: payload,
      };
    },
  },
});
