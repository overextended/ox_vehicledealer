import { createModel } from '@rematch/core';
import { RootModel } from './index';

export const vehicleColor = createModel<RootModel>()({
  state: {
    primary: '',
    secondary: '',
  },
  reducers: {
    setColors(state, payload: [string, string]) {
      return { ...state, primary: payload[0], secondary: payload[1] };
    },
  },
});
