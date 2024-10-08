import { requireNativeViewManager } from 'expo-modules-core';
import * as React from 'react';

import { ExpoMapExtensionViewProps } from './ExpoMapExtension.types';

const NativeView: React.ComponentType<ExpoMapExtensionViewProps> =
  requireNativeViewManager('ExpoMapExtension');

export default function ExpoMapExtensionView(props: ExpoMapExtensionViewProps) {
  return <NativeView {...props} />;
}
