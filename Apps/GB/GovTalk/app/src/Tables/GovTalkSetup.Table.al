// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.GovTalk;

using System.Azure.KeyVault;
using System.Environment;
using System.Security.Encryption;

table 10525 "Gov Talk Setup"
{
    Caption = 'GovTalk Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Id; Code[10])
        {
            Caption = 'Id';
        }
        field(2; Username; Text[250])
        {
            Caption = 'Username';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(3; Password; Guid)
        {
            Caption = 'Password';
        }
        field(4; Endpoint; Text[250])
        {
            Caption = 'Endpoint';
        }
        field(5; "Vendor ID"; Guid)
        {
            Caption = 'Vendor ID';
        }
        field(6; "Test Mode"; Boolean)
        {
            Caption = 'Test Mode';
        }
    }

    keys
    {
        key(Key1; Id)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    var
        IsolatedStorageManagement: Codeunit "Isolated Storage Management";
        AzureKeyVaultErr: Label 'Error while retrieving key from Azure Key Vault: %1.', Comment = '%1 = Error string retrieved from the system.';
        AzureKeyVaultGovTalkVendorIdTok: Label 'govtalk-vendorid', Locked = true;

    [NonDebuggable]
    [Scope('OnPrem')]
    procedure SavePassword(PasswordValue: Text[250])
    begin
        Password := SaveEncryptedValue(Password, PasswordValue);
    end;

    [NonDebuggable]
    procedure GetPassword(): Text
    begin
        exit(GetEncryptedValue(Password));
    end;

    [NonDebuggable]
    procedure SaveVendorID(NewVendorId: Text[250])
    begin
        "Vendor ID" := SaveEncryptedValue("Vendor ID", NewVendorId);
    end;

    [NonDebuggable]
    procedure GetVendorID(): Text
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
        EnvironmentInfo: Codeunit "Environment Information";
        Value: Text;
    begin
        if EnvironmentInfo.IsSaaS() then begin
            if not AzureKeyVault.GetAzureKeyVaultSecret(AzureKeyVaultGovTalkVendorIdTok, Value) then
                Error(AzureKeyVaultErr, GetLastErrorText);
            exit(Value);
        end;
        exit(GetEncryptedValue("Vendor ID"));
    end;

    [NonDebuggable]
    local procedure GetEncryptedValue(Value: Guid): Text
    var
        RetrievedValue: Text;
    begin
        IsolatedStorageManagement.Get(Value, DATASCOPE::CompanyAndUser, RetrievedValue);
        exit(RetrievedValue);
    end;

    [NonDebuggable]
    local procedure SaveEncryptedValue(PasswordGuid: Guid; Value: Text[250]): Guid
    begin
        if not IsNullGuid(PasswordGuid) and (Value = '') then
            IsolatedStorageManagement.Delete(PasswordGuid, DATASCOPE::CompanyAndUser)
        else begin
            if IsNullGuid(PasswordGuid) then
                PasswordGuid := CreateGuid();
            IsolatedStorageManagement.Set(PasswordGuid, Value, DATASCOPE::CompanyAndUser);
        end;
        exit(PasswordGuid);
    end;

    [NonDebuggable]
    procedure IsConfigured(): Boolean
    begin
        Get();
        exit((Username <> '') and (not IsNullGuid(Password)));
    end;
}

