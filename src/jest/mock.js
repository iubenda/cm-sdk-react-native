const mock = {
    Consentmanager: {
        createInstance: jest.fn(),
        createInstanceByConfig: jest.fn(),
        addEventListeners: jest.fn(),
        hasVendor: jest.fn(),
        hasPurpose: jest.fn(),
        reset: jest.fn(),
        exportCmpString: jest.fn(),
        hasConsent: jest.fn(),
        getAllVendors: jest.fn(),
        getAllPurposes: jest.fn(),
        getEnabledVendors: jest.fn(),
        getEnabledPurposes: jest.fn(),
        getDisabledVendors: jest.fn(),
        getDisabledPurposes: jest.fn(),
        getUSPrivacyString: jest.fn(),
        getGoogleACString: jest.fn(),
  },
}

module.exports = mock