# react-native-mapkit-search

A React Native package that integrates with Apple's MapKit API to provide location search with autofill suggestions. Designed to work seamlessly with `react-native-maps`, this package enables location-based searches on iOS devices.

## Features

- **Search with autofill**: Users can enter a query, and the package returns a list of matching places.
- **Select a place**: Clicking on a search result passes the selected location back to the React Native app.
- **Coordinates provided**: Useful for displaying locations on a map or performing other location-based actions.
- **Seamless integration with `react-native-maps`**: Use this package to fetch locations and display them using `react-native-maps`.

## Installation

npm install react-native-mapkit-search

csharp
Copy
Edit

or with Yarn:

yarn add react-native-mapkit-search

## Usage

import React, { useState } from 'react' import { View, TextInput, Button } from 'react-native' import ExpoMapExtension from 'react-native-mapkit-search'

const MapSearchExample = () => { const [searchText, setSearchText] = useState('') const [data, setData] = useState([]) const [selectedItem, setSelectedItem] = useState(null) const [isDisplay, setIsDisplay] = useState(true)

return ( <View style={{ flex: 1 }}> <TextInput placeholder="Search here" value={searchText} onChangeText={(text) => setSearchText(text)} style={{ borderColor: 'black', borderWidth: 1 }} /> <Button onPress={() => setIsDisplay(!isDisplay)} title="Toggle map" /> {isDisplay && ( <ExpoMapExtension.ExpoMapExtensionView style={{ flex: 1, height: 1000, width: '100%' }} searchText={searchText} onSubmit={(event) => { setData(event.nativeEvent.placesData) }} onSelect={(event) => { setSelectedItem(event.nativeEvent.selectedItem) }} /> )} </View> ) }

export default MapSearchExample

## How It Works

1. The user enters a search query in the React Native app.
2. The package fetches search suggestions from Apple's MapKit API.
3. A sheet view displays search results.
4. When a user selects a place, its details (including coordinates) are sent back to the React Native app.
5. The app can then use this data to show an enlarged map view, navigate, or perform any location-based functionality.

## Requirements

- **iOS only**: This package relies on Apple’s MapKit API.
- **React Native Maps**: Optional, but recommended for displaying locations.

## Contributing

Feel free to open issues or submit pull requests.

## License

MIT






