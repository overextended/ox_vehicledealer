import { Button, Group, Modal, Text } from '@mantine/core';
import { useLocales } from '../../../providers/LocaleProvider';
import { fetchNui } from '../../../utils/fetchNui';
import { useAppDispatch } from '../../../state';
import { VehicleData } from '../../../state/models/vehicles';

interface Props {
  opened: boolean;
  setOpened: (opened: boolean) => void;
  vehicle: VehicleData;
  price: number;
}

const PurchaseModal: React.FC<Props> = ({ opened, setOpened, vehicle, price }) => {
  const { locale } = useLocales();
  const dispatch = useAppDispatch();

  return (
    <Modal title="Purchase vehicle" opened={opened} onClose={() => setOpened(false)}>
      <Text>
        {locale.ui.purchase_modal.purchase_confirm
          .replace('%s', `${vehicle.make} ${vehicle.name}`)
          .replace(
            '%d',
            Intl.NumberFormat('en-us', { style: 'currency', currency: 'USD', maximumFractionDigits: 0 }).format(
              vehicle.price
            )
          )}
      </Text>

      <Group position="right" mt={10}>
        <Button uppercase variant="default" onClick={() => setOpened(false)}>
          {locale.ui.purchase_modal.cancel}
        </Button>
        <Button
          uppercase
          color="green"
          variant="light"
          onClick={() => {
            setOpened(false);
            dispatch.visibility.setBrowserVisible(false);
            dispatch.visibility.setVehicleVisible(false);
            fetchNui('purchaseVehicle', vehicle);
          }}
        >
          {locale.ui.purchase_modal.confirm}
        </Button>
      </Group>
    </Modal>
  );
};

export default PurchaseModal;
