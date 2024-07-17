// BaseLayout.tsx
import { SafeAreaView, StyleSheet, View } from 'react-native';

const BaseLayout = ({ children }: any) => {
  return (
    <SafeAreaView style={styles.safeArea}>
      <View style={styles.container}>{children}</View>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: '#f0f0f0', // You can choose a color that fits your app theme
  },
  container: {
    flex: 1,
    paddingHorizontal: 16,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#ffffff', // Background color for the inner container
    // You can add more styling as needed
  },
});

export default BaseLayout;
