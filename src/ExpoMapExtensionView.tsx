import { requireNativeViewManager } from 'expo-modules-core'
import * as React from 'react'
import { ViewProps } from 'react-native'

export type ChangeEventPayload = {
  value: string
}

interface SearchCompletions {
  id: string
  title: string
  subTitle: string
  url?: string | null
  phoneNumber?: string
  placemark?: any
}

interface SubmitEvent {
  nativeEvent: {
    placesData: SearchCompletions[]
  }
}

interface SelectEvent {
  nativeEvent: {
    selectedItem: SearchCompletions[]
  }
}

export interface ExpoMapExtensionViewProps extends ViewProps {
  searchText: string
  onSubmit(event: SubmitEvent): void
  onSelect(event: SelectEvent): void
}

const NativeView: React.ComponentType<ExpoMapExtensionViewProps> =
  requireNativeViewManager('ExpoMapExtension')

export default function ExpoMapExtensionView(props: ExpoMapExtensionViewProps) {
  return <NativeView {...props} />
}
