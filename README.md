# Expo Map Extension

**Expo Map Extension** is a React Native package that allows iOS apps to connect to Apple's MapKit API for location search and autofill. It integrates with `react-native-maps` and provides search functionality, returning place data and coordinates to your app.

## Features

- Search for places using Apple's API when running on iPhones.
- Autofill search results displayed in a sheet view.
- Select a place from the search results to pass back to the React Native app.
- Receive place details, including coordinates, to populate your app's map.

## Installation

```sh
npm install expo-map-extension
```

or

```sh
yarn add expo-map-extension
```

## Usage

```jsx
import { useState } from 'react'
import { View, TextInput, Button, Text } from 'react-native'
import ExpoMapExtension from 'expo-map-extension'

const MyComponent = () => {
  const [searchText, setSearchText] = useState('')
  const [placesData, setPlacesData] = useState([])
  const [selectedItem, setSelectedItem] = useState(null)

  return (
    <View style={{ flex: 1 }}>
      <TextInput
        placeholder="Search here"
        value={searchText}
        onChangeText={setSearchText}
        style={{ borderColor: 'black', borderWidth: 1, borderRadius: 4 }}
      />
        <ExpoMapExtension.ExpoMapExtensionView
          style={{ flex: 1, height: 1000, width: '100%' }}
          searchText={searchText}
          onSubmit={(event) => setPlacesData(event.nativeEvent.placesData)}
          onSelect={(event) => setSelectedItem(event.nativeEvent.selectedItem)}
        />
    </View>
  )
}

export default MyComponent
```

## Props

| Prop          | Type     | Description |
|--------------|---------|-------------|
| `searchText` | String  | The search query input from React Native. |
| `onSubmit`   | Function | Callback that receives the list of search results. |
| `onSelect`   | Function | Callback that receives the selected place's details. |

## Example Flow

1. The user types a query into the search bar.
2. The sheet view updates with autofilled search results.
3. The user selects a place from the list.
4. The selected place data, including coordinates, is passed back to the React Native app.

## License

MIT



