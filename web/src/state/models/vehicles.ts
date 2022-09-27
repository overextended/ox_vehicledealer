import { createModel } from '@rematch/core';
import { RootModel } from '.';
import { isEnvBrowser } from '../../utils/misc';
import { TopStatsKey } from './topStats';

export type VehicleType =
  | 'automobile'
  | 'heli'
  | 'bike'
  | 'plane'
  | 'trailer'
  | 'submarine'
  | 'quadbike'
  | 'blimp'
  | 'bicycle'
  | 'boat'
  | 'train';

export interface VehicleData {
  class: number;
  doors: number;
  make: string;
  name: string;
  price: number;
  seats: number;
  type: VehicleType;
  weapons?: boolean;
  acceleration: number;
  handling: number;
  braking: number;
  speed: number;
}

interface Vehicles {
  [key: string]: VehicleData;
}

export const vehicleTypeToGroup: Record<VehicleType, TopStatsKey> = {
  automobile: 'land',
  bicycle: 'land',
  bike: 'land',
  quadbike: 'land',
  train: 'land',
  trailer: 'land',
  plane: 'air',
  heli: 'air',
  blimp: 'air',
  boat: 'sea',
  submarine: 'sea',
};

const gameVehicles: Vehicles = await (async () => {
  if (!isEnvBrowser()) {
    const resp = await fetch(`nui://ox_core/shared/files/vehicles.json`, {
      method: 'post',
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
    });

    return await resp.json();
  } else {
    return {
      blista: {
        class: 0,
        doors: 4,
        make: 'Dinka',
        name: 'Blista',
        price: 9500,
        seats: 4,
        type: 'automobile',
        acceleration: 0.23000000417232,
        handling: 0.61000001430511,
        braking: 0.60000002384185,
        speed: 41.91736602783203,
      },
      dominator: {
        class: 4,
        doors: 4,
        make: 'Vapid',
        name: 'Dominator',
        price: 15000,
        seats: 2,
        type: 'automobile',
        acceleration: 0.28999999165534,
        handling: 0.6700000166893,
        braking: 0.80000001192092,
        speed: 48.33333587646484,
      },
    } as Vehicles;
  }
})();

export const listVehicles = createModel<RootModel>()({
  state: {} as Vehicles,
  reducers: {
    setVehicles(state, payload: Vehicles) {
      return (state = payload);
    },
  },
});

export const vehicles = createModel<RootModel>()({
  state: gameVehicles,
});
