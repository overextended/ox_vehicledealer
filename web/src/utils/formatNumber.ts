export const formatNumber = (number: number) =>
  Intl.NumberFormat('en-us', { style: 'currency', currency: 'USD', maximumFractionDigits: 0 }).format(number);
