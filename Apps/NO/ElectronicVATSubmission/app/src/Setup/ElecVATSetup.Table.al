// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using System.Privacy;

table 10686 "Elec. VAT Setup"
{
    Caption = 'Electronic VAT Setup';
    fields
    {
        field(1; "Primary Key"; Integer)
        {
            Caption = 'Primary Key';
        }
        field(2; Enabled; Boolean)
        {
            Caption = 'Enabled';

            trigger OnValidate()
            var
                CustomerConsentMgt: Codeunit "Customer Consent Mgt.";
                ElectVATSetupConsentProvidedLbl: Label 'NO Elect. VAT Setup - consent provided by UserSecurityId %1.', Locked = true;
            begin
                if Enabled then
                    Enabled := CustomerConsentMgt.ConfirmUserConsent();
                if Enabled then
                    Session.LogAuditMessage(StrSubstNo(ElectVATSetupConsentProvidedLbl, UserSecurityId()), SecurityOperationResult::Success, AuditCategory::ApplicationManagement, 4, 0);
            end;
        }
        field(3; "OAuth Feature GUID"; GUID)
        {
            Caption = 'OAuth 2.0 Code';
        }
        field(5; "Validate VAT Return Url"; Text[250])
        {
            Caption = 'Validate VAT Return URL';
        }
        field(4; "Authentication URL"; Text[250])
        {
            Caption = 'Authentication URL';

            trigger OnValidate()
            var
                ElecVATOAuthMgt: Codeunit "Elec. VAT OAuth Mgt.";
            begin
                ElecVATOAuthMgt.UpdateElecVATOAuthSetupRecordsWithAuthenticationURL("Authentication URL");
            end;
        }
        field(6; "Exchange ID-Porten Token Url"; Text[250])
        {
            Caption = 'Exchange ID-Porten Token URL';
        }
        field(7; "Submission Environment URL"; Text[250])
        {
            Caption = 'Submission Environment URL';
        }
        field(8; "Submission App URL"; Text[250])
        {
            Caption = 'Submission App URL';
        }
        field(9; "Redirect URL"; Text[250])
        {
            Caption = 'Redirect URL';

            trigger OnValidate()
            var
                ElecVATOAuthMgt: Codeunit "Elec. VAT OAuth Mgt.";
            begin
                ElecVATOAuthMgt.UpdateElecVATOAuthSetupRecordsWithRedirectURL("Redirect URL");
            end;
        }
        field(10; "Client ID"; Guid)
        {
            Caption = 'Client ID';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(11; "Client Secret"; Guid)
        {
            Caption = 'Client Secret';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(12; "Disable Checks On Release"; Boolean)
        {
            Caption = 'Disable Checks On Release';
        }
        field(20; "Login URL"; Text[250])
        {
            Caption = 'Login URL';
            DataClassification = EndUserIdentifiableInformation;
        }
    }

    trigger OnDelete()
    begin
        DeleteToken("Client ID");
        DeleteToken("Client Secret");
    end;

    var
        RecordHasBeenRead: Boolean;

    procedure GetRecordOnce(): Boolean
    begin
        if RecordHasBeenRead then
            exit(true);
        if not Get() then
            exit(false);
        RecordHasBeenRead := true;
        exit(true);
    end;

    [NonDebuggable]
    [Scope('OnPrem')]
    procedure SetToken(var TokenKey: Guid; TokenValue: SecretText)
    begin
        if IsNullGuid(TokenKey) then
            TokenKey := CreateGuid();

        IsolatedStorage.Set(TokenKey, TokenValue, DataScope::Company);
    end;

    [NonDebuggable]
    [Scope('OnPrem')]
    procedure GetToken(TokenKey: Guid) TokenValue: SecretText
    begin
        if not HasToken(TokenKey) then
            exit;

        IsolatedStorage.Get(TokenKey, DataScope::Company, TokenValue);
    end;

    [Scope('OnPrem')]
    procedure DeleteToken(TokenKey: Guid)
    begin
        if not HasToken(TokenKey) then
            exit;

        IsolatedStorage.Delete(TokenKey, DataScope::Company);
    end;

    [Scope('OnPrem')]
    procedure HasToken(TokenKey: Guid): Boolean
    begin
        exit(not IsNullGuid(TokenKey) and IsolatedStorage.Contains(TokenKey, DataScope::Company));
    end;
}
