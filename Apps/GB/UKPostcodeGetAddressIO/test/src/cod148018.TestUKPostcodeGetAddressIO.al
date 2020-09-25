// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 148018 "Test UK Postcode GetAddress.io"
{
    // version Test,W1,All

    Subtype = Test;

    var
        Assert: Codeunit 130000;
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        PostcodeServiceManager: Codeunit 9090;
        LibraryLowerPermissions: Codeunit 132217;

    [Test]
    procedure TestGetAddressIOListFromPostcode()
    begin
        Initialize();
        LibraryLowerPermissions.SetO365Basic();
        GeneralTestGetAddressIO('CM129UR', '', 21);
    end;

    [Test]
    procedure TestGetAddressIOListFromPostcodeAndDeliveryPoint()
    begin
        Initialize();
        LibraryLowerPermissions.SetO365Basic();
        GeneralTestGetAddressIO('CM129UR', '21', 1);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure TestGetAddressIOListFromPostcodeNotExists()
    begin
        Initialize();
        LibraryLowerPermissions.SetO365Basic();
        LibraryVariableStorage.Enqueue('No addresses could be found for this postcode.');
        GeneralTestGetAddressIO('CM120UY', '', 0);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure TestGetAddressIOListFromInvalidPostcode()
    begin
        Initialize();
        LibraryLowerPermissions.SetO365Basic();
        LibraryVariableStorage.Enqueue('The postcode is not valid.');
        GeneralTestGetAddressIO('INVALID', '', 0);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure TestGetAddressIOListFromPostcodeServiceNotAvailable()
    begin
        Initialize();
        LibraryLowerPermissions.SetO365Basic();
        LibraryVariableStorage.Enqueue('The getAddress.io service is not available right now. Try again later.');
        GeneralTestGetAddressIO('NOTAVAILABLE', '', 0);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure TestGetAddressIOListFromPostcodeAuthProblem()
    begin
        Initialize();
        LibraryLowerPermissions.SetO365Basic();
        LibraryVariableStorage.Enqueue('Your access to the getAddress.io service has expired. Please renew your API key.');
        GeneralTestGetAddressIO('AUTH', '', 0);
    end;

    [Test]
    procedure TestGetAddressIOSpecificAddress()
    var
        TempAutocompleteAddress: Record 9090 temporary;
    begin
        // [GIVEN]
        // - Create GetAddress.io setup
        // - Simulate which record user selected
        Initialize();
        LibraryLowerPermissions.SetO365Basic();
        LibraryVariableStorage.Enqueue(1);

        // [WHEN]
        SimulateGetAddresIOSpecificAddressSelection(TempAutocompleteAddress);

        // [THEN]
        Assert.AreEqual('Microsoft Ltd', TempAutocompleteAddress.Address, 'Retrieved selected value is incorrect.');
        Assert.AreEqual('Microsoft Campus', TempAutocompleteAddress."Address 2", 'Retrieved selected value is incorrect.');
    end;

    [Test]
    [HandlerFunctions('ConfigPageHandler,MessageHandler')]
    procedure TestOpenConfigPageBlankAPIShow()
    var
        Successful: Boolean;
    begin
        // [GIVEN]
        LibraryLowerPermissions.SetO365BusFull();
        Initialize();

        LibraryVariableStorage.Enqueue('You must provide an API key.');

        // [WHEN] request to open a page, error is also thrown because of an empty API key, ignore it
        PostcodeServiceManager.ShowConfigurationPage('GetAddress.io', Successful);

        // [THEN] a page is open, otherwise we have an unused handler
    end;

    [Test]
    procedure TestIsConfiguredNoAPIKey()
    var
        Successful: Boolean;
    begin
        // [GIVEN]
        LibraryLowerPermissions.SetO365BusFull();
        Initialize();

        // [WHEN] request to open a page is made
        PostcodeServiceManager.IsServiceConfigured('GetAddress.io', Successful);

        // [THEN] API key is not set to result should be false
        Assert.IsFalse(Successful, 'API key is not set so service should not respond as configured');
    end;

    [Test]
    procedure TestIsConfiguredWithAPIKey()
    var
        PostcodeGetAddressIoConfig: Record 9092;
        Successful: Boolean;
    begin
        // [GIVEN]
        LibraryLowerPermissions.SetO365BusFull();
        Initialize();
        PostcodeGetAddressIoConfig.FINDFIRST();
        PostcodeGetAddressIoConfig.APIKey := CREATEGUID();
        PostcodeGetAddressIoConfig.MODIFY();

        // [WHEN] request to open a page is made
        PostcodeServiceManager.IsServiceConfigured('GetAddress.io', Successful);

        // [THEN] API key is not set to result should be false
        Assert.IsTrue(Successful, 'Service should be active, as endpoint url and api key are set');

        // Cleanup
        CLEAR(PostcodeGetAddressIoConfig.APIKey);
        PostcodeGetAddressIoConfig.MODIFY();
    end;

    [Test]
    procedure TestConfigPageEmptyAPIKey()
    var
        GetAddressioConfig: TestPage 9142;
    begin
        // [GIVEN] we have an empty API Key
        LibraryLowerPermissions.SetO365BusFull();
        Initialize();

        // [WHEN] we leave it empty
        GetAddressioConfig.OPENEDIT();
        ASSERTERROR GetAddressioConfig."API Key".VALUE('');

        // [THEN] an error is raised.
        Assert.ExpectedError('You must provide an API key.');
    end;

    [Test]
    procedure TestConfigPageInputedAPIKey()
    var
        PostcodeGetAddressIoConfig: Record 9092;
        GetAddressioConfig: TestPage 9142;
    begin
        // [GIVEN] we have an empty API Key
        LibraryLowerPermissions.SetO365BusFull();
        Initialize();
        // [WHEN] we assign a value to it
        GetAddressioConfig.OPENEDIT();
        GetAddressioConfig."API Key".VALUE('VALUE');

        // [THEN] GUID should not be null for encrypted API Key in table
        PostcodeGetAddressIoConfig.FINDFIRST();
        Assert.IsFalse(ISNULLGUID(PostcodeGetAddressIoConfig.APIKey), 'Encrypted API Key was stored incorectly');
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure TestConfigPageTermsAndConditionsNotice()
    var
        GetAddressioConfig: TestPage 9142;
    begin
        // [GIVEN] Empty configuration
        LibraryLowerPermissions.SetO365BusFull();

        // Expected message
        Initialize();
        LibraryVariableStorage.Enqueue(
          'You are accessing a third-party website and service. You should review the third-party''s terms and privacy policy.');

        // [WHEN] Open and close the dialog box
        GetAddressioConfig.OPENEDIT();
        GetAddressioConfig."API Key".VALUE('KEY'); // Doesn't matter what
        GetAddressioConfig.TermsAndConditions.ACTIVATE(); // Make sure the field exists
        GetAddressioConfig.OK().INVOKE();

        // [THEN] Message dialog should appear.
    end;

    local procedure Initialize()
    var
        PostcodeGetAddressIoConfig: Record 9092;
        PostcodeServiceConfig: Record 9091;
    begin
        CLEAR(LibraryVariableStorage);
        CLEAR(PostcodeServiceManager);

        PostcodeServiceConfig.DELETEALL();
        PostcodeGetAddressIoConfig.DELETEALL();
        COMMIT();

        // Create GetAddress.io Config and Postcode config
        IF PostcodeGetAddressIoConfig.ISEMPTY() THEN BEGIN
            PostcodeServiceConfig.INIT();
            PostcodeServiceConfig.INSERT();
            PostcodeServiceConfig.SaveServiceKey('GetAddress.io');

            PostcodeGetAddressIoConfig.INIT();
            PostcodeGetAddressIoConfig.EndpointURL := 'https://localhost:8080/UKPostcode/getaddressio/';
            PostcodeGetAddressIoConfig.INSERT();
            COMMIT();
        END;

        // Active service in Postcode Service Manager
    end;

    local procedure GeneralTestGetAddressIO(Postcode: Text[20]; DeliveryPoint: Text[30]; ExpectedResultCount: Integer)
    var
        TempAutocompleteAddress: Record 9090 temporary;
        TempAddressListNameValueBuffer: Record 823 temporary;
    begin
        // [GIVEN] create fill data into "query" entity
        TempAutocompleteAddress.Address := DeliveryPoint;
        TempAutocompleteAddress.Postcode := Postcode;

        // [WHEN]
        PostcodeServiceManager.GetAddressList(TempAutocompleteAddress, TempAddressListNameValueBuffer);

        // [THEN] number of records retrieved should be 21
        Assert.RecordCount(TempAddressListNameValueBuffer, ExpectedResultCount);
    end;

    local procedure SimulateGetAddresIOSpecificAddressSelection(var TempAutocompleteAddress: Record 9090 temporary)
    var
        TempAddressNameValueBuffer: Record 823 temporary;
        TempEnteredAutocompleteAddress: Record 9090 temporary;
    begin
        TempAddressNameValueBuffer.ID := 1;
        TempAddressNameValueBuffer.Value := 'Microsoft Ltd, Microsoft Campus, , , , Reading, Berkshire';
        TempAddressNameValueBuffer.Name := TempAddressNameValueBuffer.Value;
        TempEnteredAutocompleteAddress.Postcode := 'RG61WG';

        PostcodeServiceManager.GetAddress(TempAddressNameValueBuffer, TempEnteredAutocompleteAddress, TempAutocompleteAddress);
    end;

    [ModalPageHandler]
    procedure ConfigPageHandler(var GetAddressioConfig: TestPage 9142)
    begin
        GetAddressioConfig.OK().INVOKE();
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
        Assert.AreEqual(LibraryVariableStorage.DequeueText(), Message, 'Incorrect error was shown.');
    end;
}
