// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

codeunit 148024 "Mock Key Vault Client IRIS" implements "IRS 1099 IRIS Configuration"
{
    SingleInstance = true;

    var
        TCCValue: Text;
        SoftwareIdValue: Text;
        ConsentAppURLValue: Text;
        ContactNameValue: Text;
        ContactEmailValue: Text;
        ContactPhoneValue: Text;
        TestModeValue: Boolean;

    #region Interface Methods
    procedure GetTCC(): Text
    begin
        exit(TCCValue);
    end;

    procedure GetSoftwareId(): Text
    begin
        exit(SoftwareIdValue);
    end;

    procedure GetConsentAppURL(): Text
    begin
        exit(ConsentAppURLValue);
    end;

    procedure GetContactInfo(var ContactName: Text; var ContactEmail: Text; var ContactPhone: Text)
    begin
        ContactName := ContactNameValue;
        ContactEmail := ContactEmailValue;
        ContactPhone := ContactPhoneValue;
    end;

    procedure TestMode(): Boolean
    begin
        exit(TestModeValue);
    end;
    #endregion Interface Methods

    #region Setup Methods
    procedure SetTCC(NewTCC: Text)
    begin
        TCCValue := NewTCC;
    end;

    procedure SetSoftwareId(NewSoftwareId: Text)
    begin
        SoftwareIdValue := NewSoftwareId;
    end;

    procedure SetConsentAppURL(NewConsentAppURL: Text)
    begin
        ConsentAppURLValue := NewConsentAppURL;
    end;

    procedure SetContactInfo(NewContactName: Text; NewContactEmail: Text; NewContactPhone: Text)
    begin
        ContactNameValue := NewContactName;
        ContactEmailValue := NewContactEmail;
        ContactPhoneValue := NewContactPhone;
    end;

    procedure SetTestMode(NewTestMode: Boolean)
    begin
        TestModeValue := NewTestMode;
    end;

    procedure SetDefaultValues()
    begin
        TCCValue := 'TEST-TCC';
        SoftwareIdValue := 'TEST-SOFTWARE-ID';
        ConsentAppURLValue := 'https://test.consent.app/url';
        ContactNameValue := 'Test Contact';
        ContactEmailValue := 'test@example.com';
        ContactPhoneValue := '1234567890';
        TestModeValue := true;
    end;

    procedure ResetValues()
    begin
        Clear(TCCValue);
        Clear(SoftwareIdValue);
        Clear(ConsentAppURLValue);
        Clear(ContactNameValue);
        Clear(ContactEmailValue);
        Clear(ContactPhoneValue);
        Clear(TestModeValue);
    end;
    #endregion Setup Methods
}
