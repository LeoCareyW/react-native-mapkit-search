import * as ExpoMapExtension from 'expo-map-extension'
import { useState } from 'react'
import { Alert, Button, StyleSheet, Text, TextInput, View } from 'react-native'

export default function App() {
  const [data, setData] = useState<Record<string, any>[]>()
  const [isDisplay, setIsDispay] = useState(false)
  const [searchText, setSearchText] = useState('')
  const [selectedItem, setSelectedItem] = useState([])

  console.log('>>>>>>>>>>>>>', data)

  // const transformSearchText = (searchText) => {
  //   return searchText.searchText
  // }

  console.log('searchText:', searchText)
  console.log('selected item:', selectedItem[0].placemark)

  return (
    <View style={styles.container}>
      <Text style={{ marginTop: 20 }}>Hello There</Text>
      <TextInput
        placeholder="Search here"
        value={searchText}
        onChangeText={(text) => setSearchText(text)}
        style={{ borderColor: 'black', borderWidth: 1 }}
      />
      <Button onPress={() => setIsDispay(!isDisplay)} title="Toggle map" />
      {isDisplay && (
        <ExpoMapExtension.ExpoMapExtensionView
          style={{ flex: 1, height: 1000, width: '100%' }}
          searchText={searchText.toString()}
          onSubmit={(event) => {
            setData(event.nativeEvent.placesData)
          }}
          onSelect={(event) => {
            setSelectedItem(event.nativeEvent.selectedItem)
          }}
        />
      )}
    </View>
  )
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
    alignItems: 'center',
    justifyContent: 'center',
    height: '100%',
    width: '100%',
    flexDirection: 'column',
  },
})
