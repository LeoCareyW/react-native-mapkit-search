import * as React from 'react';

import { ExpoMapExtensionViewProps } from './ExpoMapExtension.types';

export default function ExpoMapExtensionView(props: ExpoMapExtensionViewProps) {
  return (
    <div>
      <span>{props.name}</span>
    </div>
  );
}
