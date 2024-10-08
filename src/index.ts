import { NativeModulesProxy, EventEmitter, Subscription } from 'expo-modules-core';

// Import the native module. On web, it will be resolved to ExpoMapExtension.web.ts
// and on native platforms to ExpoMapExtension.ts
import ExpoMapExtensionModule from './ExpoMapExtensionModule';
import ExpoMapExtensionView from './ExpoMapExtensionView';
import { ChangeEventPayload, ExpoMapExtensionViewProps } from './ExpoMapExtension.types';

// Get the native constant value.
export const PI = ExpoMapExtensionModule.PI;

export function hello(): string {
  return ExpoMapExtensionModule.hello();
}

export async function setValueAsync(value: string) {
  return await ExpoMapExtensionModule.setValueAsync(value);
}

const emitter = new EventEmitter(ExpoMapExtensionModule ?? NativeModulesProxy.ExpoMapExtension);

export function addChangeListener(listener: (event: ChangeEventPayload) => void): Subscription {
  return emitter.addListener<ChangeEventPayload>('onChange', listener);
}

export { ExpoMapExtensionView, ExpoMapExtensionViewProps, ChangeEventPayload };
