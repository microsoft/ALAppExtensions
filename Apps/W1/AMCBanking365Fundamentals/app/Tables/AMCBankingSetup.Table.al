// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using System.Integration;
using System.Privacy;

table 20101 "AMC Banking Setup"
{
    Caption = 'AMC Banking Setup';

    fields
    {
        field(20100; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(20101; "User Name"; Text[50])
        {
            Caption = 'User Name';
            DataClassification = EndUserIdentifiableInformation;
            Editable = true;
        }
        field(20102; "Password Key"; Guid)
        {
            Caption = 'Password Key';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(20103; "Sign-up URL"; Text[250])
        {
            Caption = 'Sign-up URL';
            ExtendedDatatype = URL;
            DataClassification = CustomerContent;
        }
        field(20104; "Service URL"; Text[250])
        {
            Caption = 'Service URL';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                WebRequestHelper: Codeunit "Web Request Helper";
            begin
                if "Service URL" <> '' then begin
                    WebRequestHelper.IsSecureHttpUrl("Service URL");
                    ClearCredentials();
                end;
            end;
        }
        field(20105; "Support URL"; Text[250])
        {
            Caption = 'Support URL';
            ExtendedDatatype = URL;
            DataClassification = CustomerContent;
        }
        field(20106; "Namespace API Version"; Text[10])
        {
            Caption = 'Namespace API Version';
            DataClassification = CustomerContent;
        }
        field(20107; "Solution"; Text[50])
        {
            Caption = 'Solution';
            DataClassification = CustomerContent;
        }
        field(20108; "AMC Enabled"; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = SystemMetadata;
            trigger OnValidate()
            var
                CustomerConsentMgt: Codeunit "Customer Consent Mgt.";
                AMCBankingConsentProvidedLbl: Label 'AMC Banking Fundamentals - consent provided by UserSecurityId %1.', Locked = true;
            begin
                if not xRec."AMC Enabled" and Rec."AMC Enabled" then
                    Rec."AMC Enabled" := CustomerConsentMgt.ConfirmUserConsent();
                if Rec."AMC Enabled" then
                    Session.LogAuditMessage(StrSubstNo(AMCBankingConsentProvidedLbl, UserSecurityId()), SecurityOperationResult::Success, AuditCategory::ApplicationManagement, 4, 0);
            end;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        DeletePassword();
    end;

    trigger OnInsert()
    var
        AMCBankingMgt: Codeunit "AMC Banking Mgt.";
    begin
        if "User Name" = '' then begin
            "User Name" := GetUserName(); // Set username to demo user, if new record for user to try the funtionality
            if "User Name" <> '' then
                SavePassword(GetPassword()); // Set Password to demo password, if new record for user to try the funtionality
            if "User Name" = GetDemoUserName() then
                Solution := AMCBankingMgt.GetDemoSolutionCode();
        end;
        AMCBankingMgt.InitDefaultURLs(Rec);
    end;

    var
        DemoUserNameTxt: Label 'demouser', Locked = true;
        DemoPasswordTxt: Label 'Demo Password', Locked = true;

    internal procedure SavePassword(PasswordText: SecretText)
    begin
        if IsNullGuid("Password Key") then
            "Password Key" := CreateGuid();

        if (not PasswordText.IsEmpty()) then begin
            if not EncryptionEnabled() then
                IsolatedStorage.Set(CopyStr("Password Key", 1, 200), PasswordText, Datascope::Company)
            else
                IsolatedStorage.SetEncrypted(CopyStr("Password Key", 1, 200), PasswordText, Datascope::Company);
        end
        else
            if HasPassword() then
                DeletePassword();
    end;

    internal procedure GetUserName(): Text[50]
    var
        ServiceUserName: Text[50];
    begin
        if ("User Name" = '') then
            exit(GetDemoUserName());

        ServiceUserName := "User Name";
        OnGetUserName(ServiceUserName);

        exit(ServiceUserName);
    end;

    internal procedure GetPassword(): SecretText
    var
        Value: SecretText;
    begin
        if ("User Name" = GetDemoUserName()) then
            exit(GetDemoPass());

        if not IsolatedStorage.Get(CopyStr("Password Key", 1, 200), Datascope::Company, Value) then;
        exit(Value);
    end;

    internal procedure DeletePassword()
    begin
        if IsolatedStorage.Contains(CopyStr("Password Key", 1, 200), Datascope::Company) then
            IsolatedStorage.Delete(CopyStr("Password Key", 1, 200), DataScope::Company);
    end;

    procedure HasUserName(): Boolean
    begin
        exit("User Name" <> '');
    end;

    internal procedure HasPassword(): Boolean
    begin
        if ("User Name" = GetDemoUserName()) then
            exit(true);

        exit(IsolatedStorage.Contains(CopyStr("Password Key", 1, 200), Datascope::Company));
    end;

    procedure SetURLsToDefault()
    var
        AMCBankingMgt: Codeunit "AMC Banking Mgt.";
    begin
        AMCBankingMgt.SetURLsToDefault(Rec);
    end;

    procedure GetDemoUserName(): Text[50]
    begin
        exit(CopyStr(DemoUserNameTxt, 1, 50));
    end;

    local procedure GetDemoPass(): Text
    begin
        exit(DemoPasswordTxt);
    end;

    local procedure ClearCredentials()
    begin
        if xRec."Service URL" = '' then
            exit;

        if xRec."Service URL" = Rec."Service URL" then
            exit;

        Clear(Rec."User Name");
        DeletePassword();
    end;

    [IntegrationEvent(false, false)]
    procedure OnGetUserName(var UserName: Text[50])
    begin
    end;
}

