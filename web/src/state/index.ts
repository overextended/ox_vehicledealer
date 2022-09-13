import { init, RematchDispatch, RematchRootState } from '@rematch/core';
import { TypedUseSelectorHook, useDispatch, useSelector } from 'react-redux';
import { models, RootModel } from './models';

export const store = init({ models });

export type Store = typeof store;
export type Dispatch = RematchDispatch<RootModel>;
export type RootState = RematchRootState<RootModel>;

export const useAppDispatch = () => useDispatch<Dispatch>();
export const useAppSelector: TypedUseSelectorHook<RootState> = useSelector;
