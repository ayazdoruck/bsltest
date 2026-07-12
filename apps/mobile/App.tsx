import { StatusBar } from 'expo-status-bar';
import { StyleSheet, Text, View } from 'react-native';
import { DISCOVERY_UDP_PORT, TRANSFER_HTTP_PORT } from '@bslend/core';

export default function App() {
  return (
    <View style={styles.container}>
      <Text>Bslend (Faz 0 iskelet)</Text>
      <Text>
        @bslend/core yuklendi: UDP {DISCOVERY_UDP_PORT} / HTTP {TRANSFER_HTTP_PORT}
      </Text>
      <StatusBar style="auto" />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
    alignItems: 'center',
    justifyContent: 'center',
  },
});
