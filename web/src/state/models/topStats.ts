import { isEnvBrowser } from '../../utils/misc';
import { createModel } from '@rematch/core';
import { RootModel } from './index';

export type TopStatsKey = 'air' | 'land' | 'sea';

interface VehicleTopStats {
  acceleration: number;
  handling: number;
  braking: number;
  speed: number;
}

const stats: Record<TopStatsKey, VehicleTopStats> = await (async () => {
  if (!isEnvBrowser()) {
    const resp = await fetch(`nui://ox_core/shared/files/topVehicleStats.json`, {
      method: 'post',
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
    });

    return await resp.json();
  } else {
    return {
      air: {
        acceleration: 21.07000160217285,
        handling: 21.07000160217285,
        braking: 20.57999992370605,
        speed: 109.7642593383789,
      },
      land: {
        acceleration: 0.75999999046325,
        handling: 1.13999998569488,
        braking: 3.0,
        speed: 53.86687088012695,
      },
      sea: {
        acceleration: 18.0,
        handling: 18.38000106811523,
        braking: 0.40000000596046,
        speed: 46.66666793823242,
      },
    };
  }
})();

export const topStats = createModel<RootModel>()({
  state: stats,
});
