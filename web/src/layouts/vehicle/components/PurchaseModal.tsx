import { Button, Group, Modal, Text } from "@mantine/core";
import { VehicleDataState } from "../../../state/models/vehicleData";
import { fetchNui } from "../../../utils/fetchNui";

interface Props {
  opened: boolean;
  setOpened: (opened: boolean) => void;
  vehicle: VehicleDataState;
  price: number;
}

const PurchaseModal: React.FC<Props> = ({ opened, setOpened, vehicle, price }) => {
  return (
    <Modal title="Purchase vehicle" opened={opened} onClose={() => setOpened(false)}>
      <Text>
        Confirm purchase of{" "}
        <Text component="span" weight={700} transform="uppercase">
          {`${vehicle.make} ${vehicle.name}`}{" "}
        </Text>
        for{" "}
        <Text component="span" weight={700}>
          ${price}
        </Text>
        ?
      </Text>

      <Group position="right" mt={10}>
        <Button color="red" variant="light" onClick={() => setOpened(false)}>
          Cancel
        </Button>
        <Button
          color="green"
          variant="light"
          onClick={() => {
            setOpened(false);
            fetchNui("purchaseVehicle", vehicle);
          }}
        >
          Confirm
        </Button>
      </Group>
    </Modal>
  );
};

export default PurchaseModal;
