import { createModel } from "@rematch/core";
import { RootModel } from ".";
import { isEnvBrowser } from "../../utils/misc";

interface Vehicles {
  [key: string]: {
    bodytype: string;
    class: number;
    doors: number;
    make: string;
    name: string;
    price: number;
    seats: number;
    type: string;
    weapons: boolean;
  };
}

const vehicles: Vehicles = await (async () => {
  if (!isEnvBrowser()) {
    const resp = await fetch(`nui://ox_core/files/vehicles.json`, {
      method: "post",
      headers: {
        "Content-Type": "application/json; charset=UTF-8",
      },
    });

    return await resp.json();
  } else {
    return {
      dinka: {
        bodytype: "automobile",
        class: 0,
        doors: 4,
        make: "Dinka",
        name: "Blista",
        price: 9500,
        seats: 4,
        type: "",
        weapons: false,
      },
      dominator: {
        bodytype: "automobile",
        class: 1,
        doors: 2,
        make: "Vapid",
        name: "Dominator",
        price: 13500,
        seats: 2,
        type: "",
        weapons: false,
      },
    };
  }
})();

export const vehicleList = createModel<RootModel>()({
  state: vehicles,
});
