import { useState } from 'react';
import { NumberInput, Stack, Button } from '@mantine/core';
import { TbTag } from 'react-icons/tb';
import { closeAllModals } from '@mantine/modals';
import { useAppDispatch } from '../../../../../state';
import { fetchNui } from '../../../../../utils/fetchNui';

const EditModal: React.FC<{ currentPrice: number; model: string }> = ({ currentPrice, model }) => {
  const dispatch = useAppDispatch();
  const [price, setPrice] = useState<number | undefined>();

  return (
    <Stack>
      <NumberInput
        icon={<TbTag size={20} />}
        hideControls
        defaultValue={currentPrice}
        label="Vehicle price"
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
          fetchNui('changeVehicleStockPrice', { model, price });
          dispatch.vehicleStock.setVehiclePrice({ model, price });
        }}
      >
        Confirm
      </Button>
    </Stack>
  );
};

export default EditModal;
