import * as React from "react";

import { ExpoMapExtensionViewProps } from "./ExpoMapExtensionView";

export default function ExpoMapExtensionView(props: ExpoMapExtensionViewProps) {
  return (
    <div>
      <span>{props.searchText}</span>
    </div>
  );
}
