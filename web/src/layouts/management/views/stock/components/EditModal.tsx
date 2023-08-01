import { useState } from 'react';
import { NumberInput, Stack, Button } from '@mantine/core';
import { TbTag } from 'react-icons/tb';
import { closeAllModals } from '@mantine/modals';
import { useAppDispatch } from '../../../../../state';
import { fetchNui } from '../../../../../utils/fetchNui';
import { useLocales } from '../../../../../providers/LocaleProvider';

const EditModal: React.FC<{ currentPrice: number; id: number }> = ({ currentPrice, id }) => {
  const dispatch = useAppDispatch();
  const [price, setPrice] = useState<number | undefined>();
  const { locale } = useLocales();

  return (
    <Stack>
      <NumberInput
        icon={<TbTag size={20} />}
        hideControls
        defaultValue={currentPrice}
        label={locale.ui.management.vehicle_price}
        value={price}
        onChange={(val) => setPrice(val)}
      />
      <Button
        fullWidth
        variant="light"
        uppercase
        onClick={() => {
          closeAllModals();
          if (price === undefined) return;
          fetchNui('changeVehicleStockPrice', { id, price });
          dispatch.vehicleStock.setVehiclePrice({ id, price });
        }}
      >
        {locale.ui.confirm}
      </Button>
    </Stack>
  );
};

export default EditModal;
