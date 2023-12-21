import * as React from 'react';

import { SafeAreaView, Button, StyleSheet, View } from 'react-native';
import { Consentmanager } from 'cmp-sdk';
import type { CmpEventCallbacks } from '../../src/CmpTypes';

export default function App() {
  React.useEffect(() => {
    Consentmanager.createInstance(
      'ac6777c3b1d55',
      'delivery.consentmanager.net',
      'test',
      'en'
    )
    const customCallbacks: CmpEventCallbacks = {
      onOpen: () => {
        console.log('Custom Open Handler');
      },
      onClose: () => {
        console.log('Custom Close Handler');
      },
    };

    const removeListeners = Consentmanager.addEventListeners(customCallbacks);

    return () => {
      removeListeners();
    };
  }, []);

  const openConsentLayer = () => {
    Consentmanager.openConsentlayer();
  };

  const getStatus = async () => {
    console.log('Get consent status');
    console.log('has Purpose 1', await Consentmanager.hasPurpose('1'));
    console.log('has Vendor 1', await Consentmanager.hasVendor('1'));
    // Getter
    console.log('has Consent', await Consentmanager.hasConsent());
    console.log('all Vendors', await Consentmanager.getAllVendors());
    console.log('all Purposes', await Consentmanager.getAllPurposes());
    console.log(
      'get Enabled Vendors',
      await Consentmanager.getEnabledVendors()
    );
    console.log(
      'get Enabled Purposes',
      await Consentmanager.getEnabledPurposes()
    );
    console.log(
      'get Disabled Vendors',
      await Consentmanager.getDisabledVendors()
    );
    console.log(
      'get Disabled Purposes',
      await Consentmanager.getDisabledPurposes()
    );
    console.log(
      'get US Privacy String',
      await Consentmanager.getUSPrivacyString()
    );
    console.log(
      'get Google AC String',
      await Consentmanager.getGoogleACString()
    );
  };

  const resetConsent = () => {
    Consentmanager.reset();
    console.log('Reset consent data');
  };

  const hasVendorConsent = async () => {
    return await Consentmanager.hasVendor('1');
  };
  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.buttonContainer}>
        <Button title="Open Consent" onPress={openConsentLayer} />
      </View>
      <View style={styles.buttonContainer}>
        <Button title="Get Status" onPress={getStatus} />
      </View>
      <View style={styles.buttonContainer}>
        <Button title="Reset" onPress={resetConsent} />
      </View>
      <View style={styles.buttonContainer}>
        <Button title="Has Vendor" onPress={hasVendorConsent} />
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
  },
  buttonContainer: {
    marginVertical: 10,
  },
});
