// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Foundation.Address.IdealPostcodes.Test;

using Microsoft.Foundation.Address;
using Microsoft.Foundation.Address.IdealPostcodes;
using System.TestLibraries.Utilities;

codeunit 148119 "Test Negative Outcomes"
{
    // version Test,W1,All

    Subtype = Test;
    TestType = IntegrationTest;

    var
        Assert: Codeunit "Assert";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        PostcodeServiceManager: Codeunit "Postcode Service Manager";
        LibraryLowerPermissions: Codeunit "Library - Lower Permissions";
        MyServiceKeyTok: Label 'IDEAL_POSTCODE_POSTCODE_SERVICE', Locked = true;

    [Test]
    [HandlerFunctions('ConfigPageHandler')]
    procedure TestOpenConfigPageBlankAPIShow()
    var
        Successful: Boolean;
    begin
        // [GIVEN]
        LibraryLowerPermissions.SetO365BusFull();
        Initialize();

        LibraryVariableStorage.Enqueue('You must specify an API Key.');
        LibraryVariableStorage.Enqueue('You must specify an API Key.');

        // [WHEN] request to open a page, error is also thrown because of an empty API key, ignore it
        PostcodeServiceManager.ShowConfigurationPage('IDEAL_POSTCODE_POSTCODE_SERVICE', Successful);

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
        PostcodeServiceManager.IsServiceConfigured('IDEAL_POSTCODE_POSTCODE_SERVICE', Successful);

        // [THEN] API key is not set to result should be false
        Assert.IsFalse(Successful, 'API key is not set so service should not respond as configured');
    end;

    [Test]
    procedure TestIsConfiguredWithAPIKey()
    var
        IPCConfig: Record "IPC Config";
        Successful: Boolean;
        ApiKeyGuid: Guid;
    begin
        // [GIVEN]
        LibraryLowerPermissions.SetO365BusFull();
        Initialize();
        IPCConfig.FINDFIRST();
        IPCConfig.Enabled := true;
        ApiKeyGuid := CreateGuid();
        IPCConfig.SaveAPIKeyAsSecret(ApiKeyGuid, SecretStrSubstNo('apikey'));
        IPCConfig."API Key" := ApiKeyGuid;
        IPCConfig.MODIFY();

        // [WHEN] request to open a page is made
        PostcodeServiceManager.IsServiceConfigured('IDEAL_POSTCODE_POSTCODE_SERVICE', Successful);

        // [THEN] API key is not set to result should be false
        Assert.IsTrue(Successful, 'Service should be active, as endpoint url and api key are set');

        // Cleanup
        CLEAR(IPCConfig."API Key");
        IPCConfig.MODIFY();
    end;

    [Test]
    procedure TestConfigPageInputedAPIKey()
    var
        IPCConfig: Record "IPC Config";
        IPCConfigPage: TestPage "IPC Config";
    begin
        // [GIVEN] we have an empty API Key
        LibraryLowerPermissions.SetO365BusFull();
        Initialize();
        // [WHEN] we assign a value to it
        IPCConfigPage.OPENEDIT();
        IPCConfigPage."API Key".VALUE('VALUE');

        // [THEN] GUID should not be null for encrypted API Key in table
        IPCConfig.FINDFIRST();
        Assert.IsFalse(ISNULLGUID(IPCConfig."API Key"), 'Encrypted API Key was stored incorectly');
    end;

    [Test]
    procedure TestConfigPageTermsAndConditionsNotice()
    var
        IPCConfig: TestPage "IPC Config";
    begin
        // [GIVEN] Empty configuration
        LibraryLowerPermissions.SetO365BusFull();

        // Expected message
        Initialize();
        LibraryVariableStorage.Enqueue(
          'You are accessing a third-party website and service. You should review the third-party''s terms and privacy policy.');

        // [WHEN] Open and close the dialog box
        IPCConfig.OPENEDIT();
        IPCConfig."API Key".VALUE('KEY'); // Doesn't matter what
        IPCConfig.TermsAndConditions.ACTIVATE(); // Make sure the field exists
        IPCConfig.OK().INVOKE();

        // [THEN] Message dialog should appear.
    end;

    local procedure Initialize()
    var
        IPCConfig: Record "IPC Config";
        PostcodeServiceConfig: Record "Postcode Service Config";
    begin
        Clear(LibraryVariableStorage);
        Clear(PostcodeServiceManager);

        PostcodeServiceConfig.DeleteAll();
        IPCConfig.DeleteAll();
        Commit();

        // Create IdealPostcodes Config and Postcode config
        if IPCConfig.IsEmpty() then begin
            PostcodeServiceConfig.Init();
            PostcodeServiceConfig.Insert();
            PostcodeServiceConfig.SaveServiceKey(MyServiceKeyTok);

            IPCConfig.Init();
            IPCConfig.Insert();
            Commit();
        end;

        // Active service in Postcode Service Manager
    end;

    [ModalPageHandler]
    procedure ConfigPageHandler(var IPCConfig: TestPage "IPC Config")
    begin
        IPCConfig.OK().Invoke()
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
        Assert.AreEqual(LibraryVariableStorage.DequeueText(), Message, 'Incorrect error was shown.');
    end;
}
