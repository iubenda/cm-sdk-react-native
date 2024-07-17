# CMP SDK for React Native

CMP SDK is a React Native library that facilitates the management of user consent for data processing and storage. It is designed to help developers comply with various data protection regulations.

## Installation

```sh
npm install cmp-sdk
```

## Getting Started

### Linking (React Native 0.59 and below)

If you are using React Native 0.59 or below, you need to link the native modules manually:

```bash
react-native link cmp-sdk
```

## Usage

Import the `Consentmanager` from the `cmp-sdk` package in your code:

```jsx
import { Consentmanager } from 'cmp-sdk';
```

### Initializing the SDK

You can initialize the CMP SDK using either the direct configuration or a config object:

- **Direct Initialization:**
  ```jsx
  Consentmanager.createInstance('yourID', 'yourDomain', 'yourAppName', 'yourLanguage');
  ```

- **Initialization using Config Object:**
  ```jsx
  Consentmanager.createInstanceByConfig(yourConfigObject);
  ```

### Managing Consent Layer

To manage the consent layer:

- **Open Consent Layer:**
  ```jsx
  Consentmanager.openConsentlayer();
  ```

### Event Handling

Add event listeners to handle various consent-related events:

```jsx
const removeListeners = Consentmanager.addEventListeners({
  onOpen: () => console.log('Consent layer opened'),
  onClose: () => console.log('Consent layer closed'),
  // Add other event handlers as needed
});
```

Remember to remove the event listeners when they are no longer needed:

```jsx
removeListeners();
```

### Consent Queries

You can check for vendor and purpose consents:

- **Check Vendor Consent:**
  ```jsx
  Consentmanager.hasVendor('vendorID').then((hasConsent) => {
    console.log('Has vendor consent: ', hasConsent);
  });
  ```

- **Check Purpose Consent:**
  ```jsx
  Consentmanager.hasPurpose('purposeID').then((hasConsent) => {
    console.log('Has purpose consent: ', hasConsent);
  });
  ```

### Resetting Consent

To reset the current consent settings:

```jsx
Consentmanager.reset();
```

### Exporting Consent String

Export the current consent string:

```jsx
Consentmanager.exportCmpString().then((cmpString) => {
  console.log('CMP String: ', cmpString);
});
```

## Additional Methods

The CMP SDK provides various methods to retrieve or manage consent data, such as:

- `getAllVendors()`
- `getAllPurposes()`
- `getEnabledVendors()`
- `getEnabledPurposes()`
- `getDisabledVendors()`
- `getDisabledPurposes()`
- `getUSPrivacyString()`
- `getGoogleACString()`

Refer to the SDK documentation for detailed information on these methods.

---

Remember to replace placeholders like 'yourID', 'yourDomain', etc., with actual values relevant to the users of your SDK. You can also expand each section with more detailed examples if needed.

## Jest mocks
When running jest, you can pass our mock
```js
jest.mock('cmp-sdk', () =>
  require('cmp-sdk/jest/mock'),
);
```

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)

---
