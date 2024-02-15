import * as React from 'react';
import BaseLayout from './BaseLayout';
import Snackbar from 'react-native-snackbar';
import {
  TouchableOpacity,
  Text,
  StyleSheet,
  View,
  TextInput,
} from 'react-native';
import { Consentmanager } from 'cmp-sdk';
import { CmpConfig, type CmpEventCallbacks } from '../../src/CmpTypes';

export default function App() {
  const [consentStatus, setConsentStatus] = React.useState('');
  const [callbackLogs, setCallbackLogs] = React.useState('');
  const [cmpString, setCmpString] = React.useState('');
  React.useEffect(() => {
    const config: CmpConfig = new CmpConfig({
      isAutomaticATTrackingRequest: true,
      id: 'xxxx',
      domain: 'delivery.consentmanager.net',
      appName: 'test',
      language: 'en',
      isDebugMode: true,
    });
    Consentmanager.createInstanceByConfig(config);

    const customCallbacks: CmpEventCallbacks = {
      onOpen: () => {
        setCallbackLogs((prevLogs) => prevLogs + 'Custom Open Handler\n');
      },
      onClose: () => {
        setCallbackLogs((prevLogs) => prevLogs + 'Custom Close Handler\n');
      },
      onNotOpened: () => {
        setCallbackLogs((prevLogs) => prevLogs + 'Custom Not Open Handler\n');
      },
      onButtonClicked: (buttonType: String) => {
        setCallbackLogs(
          (prevLogs) => prevLogs + `Button clicked ${buttonType}`
        );
      },
      onError: (errorType: String, errorMessage: String) => {
        setCallbackLogs(
          (prevLogs) =>
            prevLogs + `Error occurred: ${errorType}:${errorMessage}`
        );
      },
    };

    Consentmanager.initialize();

    const removeListeners = Consentmanager.addEventListeners(customCallbacks);

    return () => {
      removeListeners();
    };
  }, []);

  const openConsentLayer = () => {
    Consentmanager.openConsentLayer();
  };

  const openConsentOnCheck = () => {
    Consentmanager.openConsentLayerOnCheck();
  };

  const getStatus = async () => {
    console.log('Get consent status');

    const fetchStatus = async (name: String, method: Function) => {
      const result = await method();
      return `${name}: ${JSON.stringify(result)}`;
    };

    const statusReport = await Promise.all([
      fetchStatus('last ATT Request', () =>
        Consentmanager.getLastATTRequestDate().catch((err) => {
          console.log(err);
        })
      ),
      fetchStatus('CmpString', Consentmanager.exportCmpString),
      fetchStatus('has Purpose 1', () => Consentmanager.hasPurpose('1')),
      fetchStatus('has Vendor 1', () => Consentmanager.hasVendor('1')),
      fetchStatus('has Consent', Consentmanager.hasConsent),
      fetchStatus('all Vendors', Consentmanager.getAllVendors),
      fetchStatus('all Purposes', Consentmanager.getAllPurposes),
      fetchStatus('get Enabled Vendors', Consentmanager.getEnabledVendors),
      fetchStatus('get Enabled Purposes', Consentmanager.getEnabledPurposes),
      fetchStatus('get Disabled Vendors', Consentmanager.getDisabledVendors),
      fetchStatus('get Disabled Purposes', Consentmanager.getDisabledPurposes),
      fetchStatus('get US Privacy String', Consentmanager.getUSPrivacyString),
      fetchStatus('get Google AC String', Consentmanager.getGoogleACString),
    ]);

    const statusString = statusReport.join('\n');
    console.log(statusString);
    setConsentStatus(statusString);
  };

  const resetConsent = () => {
    Consentmanager.reset();
    console.log('Reset consent data');
  };

  const hasVendorConsent = async () => {
    try {
      const hasConsent = await Consentmanager.hasVendor('1');
      console.log('has Vendor', hasConsent);
      Snackbar.show({
        text: `Has Vendor consent: ${hasConsent}`,
        duration: Snackbar.LENGTH_SHORT,
      });
    } catch (e) {
      Snackbar.show({
        text: 'Failed to get vendor consent',
        duration: Snackbar.LENGTH_SHORT,
      });
    }
  };

  const hasPurposeConsent = async () => {
    try {
      const hasConsent = await Consentmanager.hasPurpose('1');
      console.log('has purpose', hasConsent);
      Snackbar.show({
        text: `Has Purpose consent: ${hasConsent}`,
        duration: Snackbar.LENGTH_SHORT,
      });
    } catch (e) {
      Snackbar.show({
        text: 'Failed to get purpose consent',
        duration: Snackbar.LENGTH_SHORT,
      });
    }
  };

  const requestATTrackingPermission = () => {
    Consentmanager.requestATTPermission();
  };

  const importCmpString = () => {
    Consentmanager.importCmpString(cmpString)
      .then((result) => {
        // Assuming the promise resolves with an object { success: boolean, message: string }
        Snackbar.show({
          text: result.success
            ? 'Import successful'
            : `Import failed: ${result.message}`,
          duration: Snackbar.LENGTH_LONG,
        });
        // You might want to clear the input field after import
        setCmpString('');
      })
      .catch((error) => {
        // Handle any errors here
        Snackbar.show({
          text: `Import error: ${error.message}`,
          duration: Snackbar.LENGTH_LONG,
        });
      });
  };

  return (
    <BaseLayout>
      <View style={styles.inputContainer}>
        <TextInput
          style={styles.textInput}
          value={cmpString}
          onChangeText={setCmpString}
          placeholder="Enter CMP string"
        />
        <TouchableOpacity style={styles.importButton} onPress={importCmpString}>
          <Text style={styles.buttonText}>Import CMP String</Text>
        </TouchableOpacity>
      </View>
      <View style={styles.buttonGrid}>
        <View style={styles.buttonRow}>
          <TouchableOpacity style={styles.button} onPress={openConsentLayer}>
            <Text style={styles.buttonText}>Open Consent</Text>
          </TouchableOpacity>
          <TouchableOpacity style={styles.button} onPress={getStatus}>
            <Text style={styles.buttonText}>Get Status</Text>
          </TouchableOpacity>
          <TouchableOpacity style={styles.button} onPress={openConsentOnCheck}>
            <Text style={styles.buttonText}>Open Layer on check</Text>
          </TouchableOpacity>
        </View>
        <View style={styles.buttonRow}>
          <TouchableOpacity style={styles.button} onPress={resetConsent}>
            <Text style={styles.buttonText}>Reset</Text>
          </TouchableOpacity>
          <TouchableOpacity style={styles.button} onPress={hasVendorConsent}>
            <Text style={styles.buttonText}>Has Vendor</Text>
          </TouchableOpacity>
          <TouchableOpacity style={styles.button} onPress={hasPurposeConsent}>
            <Text style={styles.buttonText}>Has Purpose</Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={styles.button}
            onPress={requestATTrackingPermission}
          >
            <Text style={styles.buttonText}>Request ATTracking</Text>
          </TouchableOpacity>
        </View>
      </View>
      <TextInput
        style={[styles.largeTextInput]}
        multiline
        editable={false}
        value={consentStatus}
      />
      <TextInput
        style={styles.callbackLog}
        multiline
        editable={false}
        value={callbackLogs}
        placeholder="Callback Logs"
      />
    </BaseLayout>
  );
}

const styles = StyleSheet.create({
  inputContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginVertical: 10,
    paddingHorizontal: 10, // Adjust padding for alignment
  },
  textInput: {
    flex: 1,
    borderColor: 'gray',
    borderWidth: 1,
    padding: 10,
    borderRadius: 5,
    marginRight: 10,
  },
  largeTextInput: {
    flex: 1,
    borderColor: 'gray',
    borderWidth: 1,
    borderRadius: 5,
    height: '30%',
    textAlignVertical: 'top', // Align text to top
    width: '100%', // Take full width of the parent container
  },
  callbackLog: {
    flex: 1,
    borderColor: 'gray',
    borderWidth: 1,
    padding: 10,
    borderRadius: 5,
    marginTop: 10,
    maxHeight: 100,
    width: '100%', // Take full width of the parent container
  },
  importButton: {
    padding: 10,
    borderRadius: 5,
    backgroundColor: '#007bff',
    justifyContent: 'center', // Center content vertically
    minWidth: 120, // Minimum width for the button
  },
  buttonGrid: {
    width: '100%', // Take full width
  },
  buttonRow: {
    flexDirection: 'row',
    justifyContent: 'space-evenly', // Space buttons evenly
    marginVertical: 10,
  },
  button: {
    flex: 1, // Each button takes equal space
    backgroundColor: '#007bff',
    padding: 10,
    borderRadius: 5,
    marginHorizontal: 5,
  },
  buttonText: {
    color: 'white',
    textAlign: 'center',
  },
});
