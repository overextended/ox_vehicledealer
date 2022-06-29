import { Button, Group, Modal, Text } from "@mantine/core";
import { useLocales } from "../../../providers/LocaleProvider";
import { VehicleDataState } from "../../../state/models/vehicleData";
import { fetchNui } from "../../../utils/fetchNui";

interface Props {
  opened: boolean;
  setOpened: (opened: boolean) => void;
  vehicle: VehicleDataState;
  price: number;
}

const PurchaseModal: React.FC<Props> = ({ opened, setOpened, vehicle, price }) => {
  const { locale } = useLocales();

  return (
    <Modal title="Purchase vehicle" opened={opened} onClose={() => setOpened(false)}>
      {/* <Text>
        Confirm purchase of{" "}
        <Text component="span" weight={700} transform="uppercase">
          {`${vehicle.make} ${vehicle.name}`}{" "}
        </Text>
        for{" "}
        <Text component="span" weight={700}>
          ${price}
        </Text>
        ?
      </Text> */}
      <Text>
        {locale.ui.purchase_modal.purchase_confirm
          .replace("%s", `${vehicle.make} ${vehicle.name}`)
          .replace("%d", price.toString())}
      </Text>

      <Group position="right" mt={10}>
        <Button color="red" variant="light" onClick={() => setOpened(false)}>
          {locale.ui.purchase_modal.cancel}
        </Button>
        <Button
          color="green"
          variant="light"
          onClick={() => {
            setOpened(false);
            fetchNui("purchaseVehicle", vehicle);
          }}
        >
          {locale.ui.purchase_modal.confirm}
        </Button>
      </Group>
    </Modal>
  );
};

export default PurchaseModal;
