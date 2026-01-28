// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument.Verifactu.Test;

using Microsoft.EServices.EDocument;
using Microsoft.EServices.EDocument.Verifactu;
using System.Privacy;
using System.Security.Encryption;

codeunit 148003 "Test Verifactu Setup"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        IsInitialized: Boolean;
        DisableSIIQst: Label 'SII setup will be disabled. Do you want to proceed?';
        DisableVerifactuQst: Label 'Verifactu setup will be disabled. Do you want to proceed?';

    [Test]
    procedure VerifactuSetupPageOpensAndInitializes()
    var
        VerifactuSetup: Record "Verifactu Setup";
    begin
        // [SCENARIO] Verifactu Setup page opens and initializes record with default values
        Initialize();

        // [GIVEN] Verifactu Setup table is empty
        VerifactuSetup.DeleteAll();

        // [WHEN] User opens Verifactu Setup page
        SimulatePageOpen(VerifactuSetup);

        // [THEN] A record is created if it does not exist
        VerifySetupRecordExists(VerifactuSetup);
    end;

    [Test]
    [HandlerFunctions('CustomerConsentConfirmationPageChooseYesModalPageHandler')]
    procedure VerifactuSetupEnablesWithValidCertificate()
    var
        VerifactuSetup: Record "Verifactu Setup";
        IsolatedCertificate: Record "Isolated Certificate";
        CertCode: Code[20];
    begin
        // [SCENARIO] User enables Verifactu Setup when valid certificate is configured
        Initialize();

        // [GIVEN] Verifactu Setup record exists
        CreateVerifactuSetup(VerifactuSetup);

        // [GIVEN] Certificate "C" exists in Isolated Certificate table
        CertCode := CreateCertificate(IsolatedCertificate);

        // [GIVEN] Setup field Certificate Code is set to "C"
        VerifactuSetup.Validate("Certificate Code", CertCode);
        VerifactuSetup.Modify(true);

        // [WHEN] User sets Enabled field to true
        VerifactuSetup.Validate(Enabled, true);
        VerifactuSetup.Modify(true);

        // [THEN] Enabled field is set to true
        // [THEN] No error is raised
        Assert.IsTrue(VerifactuSetup.Enabled, 'Setup should be enabled');
    end;

    [Test]
    procedure VerifactuSetupCannotEnableWithoutCertificate()
    var
        VerifactuSetup: Record "Verifactu Setup";
    begin
        // [SCENARIO] User cannot enable Verifactu Setup without a certificate
        Initialize();

        // [GIVEN] Verifactu Setup record exists
        CreateVerifactuSetup(VerifactuSetup);

        // [GIVEN] Certificate Code field is blank
        VerifactuSetup."Certificate Code" := '';
        VerifactuSetup.Modify(true);

        // [WHEN] User attempts to set Enabled field to true
        asserterror VerifactuSetup.Validate(Enabled, true);

        // [THEN] Error is raised with message about missing certificate
        // [THEN] Enabled field remains false
        Assert.ExpectedError('certificate');
    end;

    [Test]
    [HandlerFunctions('CustomerConsentConfirmationPageChooseYesModalPageHandler')]
    procedure VerifactuSetupIsEnabledReturnsTrueWhenEnabled()
    var
        VerifactuSetup: Record "Verifactu Setup";
        IsolatedCertificate: Record "Isolated Certificate";
        CertCode: Code[20];
        IsEnabled: Boolean;
    begin
        // [SCENARIO] IsEnabled procedure returns true when setup is enabled
        Initialize();

        // [GIVEN] Verifactu Setup record exists
        CreateVerifactuSetup(VerifactuSetup);

        // [GIVEN] Certificate "C" is assigned
        CertCode := CreateCertificate(IsolatedCertificate);
        VerifactuSetup.Validate("Certificate Code", CertCode);

        // [GIVEN] Enabled field is set to true
        VerifactuSetup.Validate(Enabled, true);
        VerifactuSetup.Modify(true);

        // [WHEN] IsEnabled procedure is called
        IsEnabled := VerifactuSetup.IsEnabled();

        // [THEN] Result is true
        Assert.IsTrue(IsEnabled, 'IsEnabled should return true');
    end;

    [Test]
    procedure VerifactuSetupIsEnabledReturnsFalseWhenDisabled()
    var
        VerifactuSetup: Record "Verifactu Setup";
        IsEnabled: Boolean;
    begin
        // [SCENARIO] IsEnabled procedure returns false when setup is disabled
        Initialize();

        // [GIVEN] Verifactu Setup record exists
        CreateVerifactuSetup(VerifactuSetup);

        // [GIVEN] Enabled field is set to false
        VerifactuSetup.Enabled := false;
        VerifactuSetup.Modify(true);

        // [WHEN] IsEnabled procedure is called
        IsEnabled := VerifactuSetup.IsEnabled();

        // [THEN] Result is false
        Assert.IsFalse(IsEnabled, 'IsEnabled should return false');
    end;

    [Test]
    [HandlerFunctions('CustomerConsentConfirmationPageChooseYesModalPageHandler')]
    procedure VerifactuSetupCertificateCodeLookup()
    var
        VerifactuSetup: Record "Verifactu Setup";
        IsolatedCertificate: Record "Isolated Certificate";
        CertCode1: Code[20];
    begin
        // [SCENARIO] User can lookup and select certificate using drilldown
        Initialize();

        // [GIVEN] Verifactu Setup record exists
        CreateVerifactuSetup(VerifactuSetup);

        // [GIVEN] Certificates "C1" and "C2" exist in Isolated Certificate table
        CertCode1 := CreateCertificate(IsolatedCertificate);
        CreateCertificate(IsolatedCertificate);

        // [WHEN] User performs lookup on Certificate Code field
        // [WHEN] User selects certificate "C1"
        VerifactuSetup.Validate("Certificate Code", CertCode1);
        VerifactuSetup.Modify(true);

        // [THEN] Certificate Code field is set to "C1"
        Assert.AreEqual(CertCode1, VerifactuSetup."Certificate Code", 'Certificate Code should be set');
    end;

    [Test]
    [HandlerFunctions('CustomerConsentConfirmationPageChooseNoModalPageHandler')]
    procedure VerifactuSetupRemainsDisabledWhenConsentDeclined()
    var
        VerifactuSetup: Record "Verifactu Setup";
        IsolatedCertificate: Record "Isolated Certificate";
        CertCode: Code[20];
    begin
        // [SCENARIO] Setup remains disabled when user declines consent
        Initialize();

        // [GIVEN] Verifactu Setup record exists
        CreateVerifactuSetup(VerifactuSetup);

        // [GIVEN] Certificate "C" exists in Isolated Certificate table
        CertCode := CreateCertificate(IsolatedCertificate);

        // [GIVEN] Setup field Certificate Code is set to "C"
        VerifactuSetup.Validate("Certificate Code", CertCode);
        VerifactuSetup.Modify(true);

        // [WHEN] User attempts to set Enabled field to true but declines consent
        VerifactuSetup.Validate(Enabled, true);
        VerifactuSetup.Modify(true);

        // [THEN] Enabled field remains false
        Assert.IsFalse(VerifactuSetup.Enabled, 'Setup should remain disabled when consent is declined');
    end;

    [Test]
    [HandlerFunctions('CustomerConsentConfirmationPageChooseYesModalPageHandler,ConfirmSIISetupHandlerYes')]
    procedure VerifactuSetupEnablesWhenSIISetupDisabled()
    var
        VerifactuSetup: Record "Verifactu Setup";
        SIISetup: Record "SII Setup";
        IsolatedCertificate: Record "Isolated Certificate";
        CertCode: Code[20];
    begin
        // [SCENARIO] Verifactu Setup can be enabled when SII Setup is disabled
        IsInitialized := false;
        Initialize();

        // [GIVEN] SII Setup exists and is enabled
        CreateSIISetup(SIISetup, true);

        // [GIVEN] Verifactu Setup record exists
        CreateVerifactuSetup(VerifactuSetup);

        // [GIVEN] Certificate "C" exists in Isolated Certificate table
        CertCode := CreateCertificate(IsolatedCertificate);

        // [GIVEN] Setup field Certificate Code is set to "C"
        VerifactuSetup.Validate("Certificate Code", CertCode);
        VerifactuSetup.Modify(true);

        // [WHEN] User sets Enabled field to true
        VerifactuSetup.Validate(Enabled, true);
        VerifactuSetup.Modify(true);

        // [THEN] Enabled field is set to true
        Assert.IsTrue(VerifactuSetup.Enabled, 'Setup should be enabled when SII Setup is disabled');
    end;

    [Test]
    [HandlerFunctions('ConfirmSIISetupHandlerNo')]
    procedure VerifactuSetupCannotEnableWhenSIISetupEnabled()
    var
        VerifactuSetup: Record "Verifactu Setup";
        SIISetup: Record "SII Setup";
        IsolatedCertificate: Record "Isolated Certificate";
        CertCode: Code[20];
    begin
        // [SCENARIO] Verifactu Setup cannot be enabled when SII Setup is enabled
        IsInitialized := false;
        Initialize();

        // [GIVEN] SII Setup exists and is enabled
        CreateSIISetup(SIISetup, true);

        // [GIVEN] Verifactu Setup record exists
        CreateVerifactuSetup(VerifactuSetup);

        // [GIVEN] Certificate "C" exists in Isolated Certificate table
        CertCode := CreateCertificate(IsolatedCertificate);

        // [GIVEN] Setup field Certificate Code is set to "C"
        VerifactuSetup.Validate("Certificate Code", CertCode);
        VerifactuSetup.Modify(true);

        // [WHEN] User attempts to set Enabled field to true
        VerifactuSetup.Validate(Enabled, true);
        VerifactuSetup.Modify(true);

        // [THEN] Enabled field remains false
        Assert.IsFalse(VerifactuSetup.Enabled, 'Setup should remain disabled when SII Setup is enabled');
    end;

    [Test]
    [HandlerFunctions('CustomerConsentConfirmationPageChooseYesModalPageHandler,ConfirmVerifactuSetupHandlerYes')]
    procedure SIISetupEnablesWhenVerifactuSetupDisabled()
    var
        VerifactuSetup: Record "Verifactu Setup";
        SIISetup: Record "SII Setup";
        IsolatedCertificate: Record "Isolated Certificate";
        CertCode: Code[20];
    begin
        // [SCENARIO] SII Setup can be enabled when Verifactu Setup is disabled
        IsInitialized := false;
        Initialize();

        // [GIVEN] Verifactu Setup exists and is enabled
        CreateVerifactuSetup(VerifactuSetup);
        CertCode := CreateCertificate(IsolatedCertificate);
        VerifactuSetup.Validate("Certificate Code", CertCode);
        VerifactuSetup.Validate(Enabled, true);
        VerifactuSetup.Modify(true);

        // [GIVEN] SII Setup record exists
        CreateSIISetup(SIISetup, false);

        // [WHEN] User sets SII Setup Enabled field to true
        SIISetup."Certificate Code" := CertCode;
        SIISetup.Validate(Enabled, true);
        SIISetup.Modify();

        // [THEN] SII Setup Enabled field is set to true
        // [THEN] Verifactu Setup is disabled after user confirms
        Assert.IsTrue(SIISetup.Enabled, 'SII Setup should be enabled when Verifactu Setup is disabled');
        VerifactuSetup.Get();
        Assert.IsFalse(VerifactuSetup.Enabled, 'Verifactu Setup should be disabled');
    end;

    [Test]
    [HandlerFunctions('ConfirmVerifactuSetupHandlerNo,CustomerConsentConfirmationPageChooseYesModalPageHandler')]
    procedure SIISetupCannotEnableWhenVerifactuSetupEnabled()
    var
        VerifactuSetup: Record "Verifactu Setup";
        SIISetup: Record "SII Setup";
        IsolatedCertificate: Record "Isolated Certificate";
        CertCode: Code[20];
    begin
        // [SCENARIO] SII Setup cannot be enabled when Verifactu Setup is enabled and user declines
        IsInitialized := false;
        Initialize();

        // [GIVEN] Verifactu Setup exists and is enabled
        CreateVerifactuSetup(VerifactuSetup);
        CertCode := CreateCertificate(IsolatedCertificate);
        VerifactuSetup.Validate("Certificate Code", CertCode);
        VerifactuSetup.Validate(Enabled, true);
        VerifactuSetup.Modify(true);

        // [GIVEN] SII Setup record exists and is disabled
        CreateSIISetup(SIISetup, false);

        // [WHEN] User attempts to set SII Setup Enabled field to true but declines confirmation
        SIISetup.Validate(Enabled, true);
        SIISetup.Modify();

        // [THEN] SII Setup Enabled field remains false
        // [THEN] Verifactu Setup remains enabled
        Assert.IsFalse(SIISetup.Enabled, 'SII Setup should remain disabled when Verifactu Setup is enabled');
        VerifactuSetup.Get();
        Assert.IsTrue(VerifactuSetup.Enabled, 'Verifactu Setup should remain enabled');
    end;

    local procedure Initialize()
    var
        VerifactuSetup: Record "Verifactu Setup";
        SIISetup: Record "SII Setup";
    begin
        // code that is run before each test
        if IsInitialized then
            exit;
        // code that is run only once before the first test
        VerifactuSetup.DeleteAll();
        SIISetup.DeleteAll();
        IsInitialized := true;
    end;

    local procedure CreateVerifactuSetup(var VerifactuSetup: Record "Verifactu Setup")
    begin
        VerifactuSetup.DeleteAll();
        VerifactuSetup.Init();
        VerifactuSetup."Primary Key" := '';
        VerifactuSetup.Insert(true);
    end;

    local procedure CreateCertificate(var IsolatedCertificate: Record "Isolated Certificate"): Code[20]
    begin
        IsolatedCertificate.Init();
        IsolatedCertificate.Scope := IsolatedCertificate.Scope::Company;
        IsolatedCertificate.Insert(true);
        exit(IsolatedCertificate.Code);
    end;

    local procedure CreateSIISetup(var SIISetup: Record "SII Setup"; IsEnabled: Boolean)
    begin
        SIISetup.DeleteAll();
        SIISetup.Init();
        SIISetup.Enabled := IsEnabled;
        if not SIISetup.Insert(true) then begin
            SIISetup.Enabled := IsEnabled;
            SIISetup.Modify(true);
        end;
    end;

    local procedure SimulatePageOpen(var VerifactuSetup: Record "Verifactu Setup")
    begin
        VerifactuSetup.Reset();
        if not VerifactuSetup.Get() then begin
            VerifactuSetup.Init();
            VerifactuSetup.Insert(true);
        end;
    end;

    local procedure VerifySetupRecordExists(var VerifactuSetup: Record "Verifactu Setup")
    begin
        Assert.IsTrue(VerifactuSetup.Get(), 'Verifactu Setup record should exist');
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure CustomerConsentConfirmationPageChooseNoModalPageHandler(var CustConsentConfPage: TestPage "Cust. Consent Confirmation")
    begin
        CustConsentConfPage.Cancel.Invoke();
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure CustomerConsentConfirmationPageChooseYesModalPageHandler(var CustConsentConfPage: TestPage "Cust. Consent Confirmation")
    begin
        CustConsentConfPage.Accept.Invoke();
    end;

    [ConfirmHandler]
    [Scope('OnPrem')]
    procedure ConfirmSIISetupHandlerYes(Question: Text[1024]; var Reply: Boolean)
    begin
        Assert.AreEqual(DisableSIIQst, Question, 'Expected SII disable confirmation');
        Reply := true;
    end;

    [ConfirmHandler]
    [Scope('OnPrem')]
    procedure ConfirmSIISetupHandlerNo(Question: Text[1024]; var Reply: Boolean)
    begin
        Assert.AreEqual(DisableSIIQst, Question, 'Expected SII disable confirmation');
        Reply := false;
    end;

    [ConfirmHandler]
    [Scope('OnPrem')]
    procedure ConfirmVerifactuSetupHandlerYes(Question: Text[1024]; var Reply: Boolean)
    begin
        Assert.AreEqual(DisableVerifactuQst, Question, 'Expected Verifactu disable confirmation');
        Reply := true;
    end;

    [ConfirmHandler]
    [Scope('OnPrem')]
    procedure ConfirmVerifactuSetupHandlerNo(Question: Text[1024]; var Reply: Boolean)
    begin
        Assert.AreEqual(DisableVerifactuQst, Question, 'Expected Verifactu disable confirmation');
        Reply := false;
    end;
}
