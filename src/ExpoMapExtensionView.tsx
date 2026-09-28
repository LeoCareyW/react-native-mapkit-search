import { requireNativeViewManager } from 'expo-modules-core'
import * as React from 'react'
import { ViewProps } from 'react-native'

export type ChangeEventPayload = {
  value: string
}

interface SearchCompletions {
  /** Stable across searches — safe to persist. */
  id: string
  /** Fresh each search; for list keys only, never storage. */
  transientId?: string
  /** Apple's place id. Empty string below iOS 18, or when Apple has none. */
  mapItemId?: string
  title: string
  subTitle: string
  url?: string | null
  phoneNumber?: string
  /** e.g. "restaurant", "nightlife", "cafe". Absent when Apple has no category. */
  category?: string
  /** Straight-line metres from the user. Absent until the user's location is known. */
  distanceMeters?: number
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
