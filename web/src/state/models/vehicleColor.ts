import { createModel } from '@rematch/core';
import { RootModel } from './index';

export const vehicleColor = createModel<RootModel>()({
  state: '',
  reducers: {
    setVehicleColor(state, payload: string) {
      return (state = payload);
    },
  },
});
