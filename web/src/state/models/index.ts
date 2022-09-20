import { Models } from '@rematch/core';
import { filters } from './filters';
import { isLoading } from './isLoading';
import { visibility } from './visibility';
import { vehicleData } from './vehicleData';
import { listVehicles, vehicles } from './vehicles';
import { vehicleColor } from './vehicleColor';

export interface RootModel extends Models<RootModel> {
  filters: typeof filters;
  vehicles: typeof vehicles;
  isLoading: typeof isLoading;
  visibility: typeof visibility;
  vehicleData: typeof vehicleData;
  vehicleColor: typeof vehicleColor;
  listVehicles: typeof listVehicles;
}

export const models: RootModel = {
  filters,
  vehicles,
  isLoading,
  visibility,
  vehicleData,
  vehicleColor,
  listVehicles,
};
