# react-native-mapkit-search

This package is **not** associated with expo. It's name reflects its utility in EAS (expo modules). 

A React Native package that integrates with Apple's MapKit API to provide location search with autofill suggestions. Designed to work seamlessly with `react-native-maps`, this package enables location-based searches on iOS devices.

## Features

- **Search with autofill**: Users can enter a query, and the package returns a list of matching places.
- **Select a place**: Clicking on a search result passes the selected location back to the React Native app.
- **Coordinates provided**: Useful for displaying locations on a map or performing other location-based actions.
- **Seamless integration with `react-native-maps`**: Use this package to fetch locations and display them using `react-native-maps`.


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



