import { Models } from '@rematch/core';
import { filters } from './filters';
import { isLoading } from './isLoading';
import { visibility } from './visibility';
import { vehicleData } from './vehicleData';
import { listVehicles, vehicles } from './vehicles';
import { vehicleColor } from './vehicleColor';
import { topStats } from './topStats';
import { vehicleStock } from './vehicleStock';

export interface RootModel extends Models<RootModel> {
  filters: typeof filters;
  topStats: typeof topStats;
  vehicles: typeof vehicles;
  isLoading: typeof isLoading;
  visibility: typeof visibility;
  vehicleData: typeof vehicleData;
  listVehicles: typeof listVehicles;
  vehicleColor: typeof vehicleColor;
  vehicleStock: typeof vehicleStock;
}

export const models: RootModel = {
  filters,
  vehicles,
  topStats,
  isLoading,
  visibility,
  vehicleData,
  vehicleColor,
  listVehicles,
  vehicleStock,
};
