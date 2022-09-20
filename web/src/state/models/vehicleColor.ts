import { createModel } from '@rematch/core';
import { RootModel } from './index';

export const vehicleColor = createModel<RootModel>()({
  state: {
    primary: '',
    secondary: '',
  },
  reducers: {
    setPrimaryColor(state, payload: string) {
      return { ...state, primary: payload };
    },
    setSecondaryColor(state, payload: string) {
      return { ...state, secondary: payload };
    },
    setColors(state, payload: [string, string]) {
      return { ...state, primary: payload[0], secondary: payload[1] };
    },
  },
});
