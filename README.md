# react-native-mapkit-search

This package is **in no way** associated with Expo. Its name reflects its utility in EAS (Expo modules).

Search for places (restaurants, bars, shops and so on) from React Native using Apple's MapKit, the same search Apple Maps uses. You pass in the search text, and it sends back a list of places with coordinates, address, category and distance from the user.

The component doesn't draw anything. You build your own search box and results list, and pair it with something like `react-native-maps` to show places on a map.

**iOS only** (iOS 17+).

## Installation

```sh
npm install expo-map-extension
```

Then rebuild your iOS app (`npx expo run:ios`, or `pod install` in `ios/` for a bare project).

### Location permission

Results are centred on the user's location, so your app needs a location permission message. Without it, iOS never asks, searches fall back to central London, and `distanceMeters` is never returned.

In `app.json`:

```json
{
  "expo": {
    "ios": {
      "infoPlist": {
        "NSLocationWhenInUseUsageDescription": "Used to find places near you."
      }
    }
  }
}
```

Or add `NSLocationWhenInUseUsageDescription` to `Info.plist` in a bare project.

## Usage

```tsx
import { useState } from 'react'
import { FlatList, Text, TextInput, View } from 'react-native'
import { ExpoMapExtensionView } from 'expo-map-extension'

export default function PlaceSearch() {
  const [searchText, setSearchText] = useState('')
  const [places, setPlaces] = useState([])

  return (
    <View style={{ flex: 1 }}>
      <TextInput
        placeholder="Search for bars, restaurants..."
        value={searchText}
        onChangeText={setSearchText}
      />

      <ExpoMapExtensionView
        searchText={searchText}
        onSubmit={(e) => setPlaces(e.nativeEvent.placesData)}
        onSelect={() => {}}
      />

      <FlatList
        data={places}
        keyExtractor={(place) => place.transientId}
        renderItem={({ item }) => (
          <Text>
            {item.title} · {item.address?.neighbourhood ?? item.subTitle}
          </Text>
        )}
      />
    </View>
  )
}
```

## How searching works

- A search runs 250ms after the user stops typing, so fast typing doesn't send a request per key.
- Only the latest search's results are sent back. Older, slower searches are dropped.
- Clearing the text, or a search with no matches, sends back an empty list.
- Results are within about 10km of the user, or central London if location isn't available.
- Category words like "bars" or "coffee" return places of that type, not places with that word in the name.
- If Apple rate-limits searches, the previous results are kept instead of being cleared.

## Props

| Prop | Type | Description |
|---|---|---|
| `searchText` | `string` | What to search for. Update it as the user types. |
| `onSubmit` | `(event) => void` | Called with the results each time a search finishes. Results are in `event.nativeEvent.placesData`. |
| `onSelect` | `(event) => void` | Called automatically when a search returns **exactly one** result, with that result in `event.nativeEvent.selectedItem` (an array of one). There's no way to select a place yourself; handle that in your own UI using `placesData`. |

## Result fields

Each place in `placesData` looks like this:

```json
{
  "id": "mapitem-abc123",
  "transientId": "6F9619FF-8B86-D011-B42D-00C04FC964FF",
  "mapItemId": "mapitem-abc123",
  "title": "The Soho Bar",
  "subTitle": "12 Greek Street, London, W1D 4DA",
  "category": "nightlife",
  "distanceMeters": 412.7,
  "url": "https://example.com",
  "phoneNumber": "+44 20 1234 5678",
  "address": {
    "streetNumber": "12",
    "street": "Greek Street",
    "neighbourhood": "Soho",
    "city": "London",
    "county": "Greater London",
    "state": "England",
    "postcode": "W1D 4DA",
    "country": "United Kingdom",
    "countryCode": "GB"
  },
  "placemark": {
    "name": "The Soho Bar",
    "coordinate": { "latitude": 51.5136, "longitude": -0.1318 },
    "region": "..."
  }
}
```

| Field | Notes |
|---|---|
| `id` | Stays the same for a place across searches, so it's safe to save. Uses Apple's place ID when there is one (iOS 18+), otherwise the name plus rounded coordinates. |
| `transientId` | New every search. Use it for React list keys, not for saving. |
| `mapItemId` | Apple's own place ID. Empty below iOS 18, or when Apple doesn't have one. |
| `title` | The place's name. |
| `subTitle` | One-line address: street, city, postcode. |
| `category` | Apple's place type, e.g. `restaurant`, `nightlife`, `cafe`, `brewery`, `bakery`. Missing if Apple doesn't have one. |
| `distanceMeters` | Straight-line distance from the user in metres. Missing until the user's location is known. |
| `url`, `phoneNumber` | Empty string if Apple doesn't have them. |
| `address` | Address parts. Any part Apple doesn't know is left out, so check each one. |
| `placemark.coordinate` | Latitude and longitude, e.g. for a map pin. |

Opening hours, ratings and photos aren't available; Apple's MapKit doesn't provide them.

## Upgrading from 1.0.x

- Results now come from `MKLocalSearch` instead of autocomplete, so they're more relevant.
- `id` is now stable across searches instead of a new random ID each time. Use `transientId` if you relied on it changing.
- New fields: `transientId`, `mapItemId`, `category`, `distanceMeters`, `address`.

## License

MIT
