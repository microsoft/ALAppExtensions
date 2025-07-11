// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using Microsoft.Finance.GeneralLedger.Account;

table 5261 "G/L Account Mapping Line"
{
    DataClassification = CustomerContent;
    Caption = 'G/L Account Mapping Line';

    fields
    {
        field(1; "G/L Account Mapping Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'G/L Account Mapping Code';
            TableRelation = "G/L Account Mapping Header";
            Editable = false;
            NotBlank = true;
        }
        field(2; "G/L Account No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'G/L Account No.';
            TableRelation = "G/L Account";
            Editable = false;
            NotBlank = true;
        }
        field(3; "Standard Account Type"; enum "Standard Account Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Standard Account Type';
        }
        field(4; "Standard Account Category No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Standard Account Category No.';
            TableRelation = "Standard Account Category"."No." where("Standard Account Type" = field("Standard Account Type"));

            trigger OnValidate()
            begin
                "Standard Account No." := '';
            end;
        }
        field(5; "Standard Account No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Standard Account No.';
            TableRelation = "Standard Account"."No." where(Type = field("Standard Account Type"));

            trigger OnLookup()
            var
                StandardAccount: Record "Standard Account";
                StandardAccounts: Page "Standard Accounts";
            begin
                if "Standard Account Category No." <> '' then
                    StandardAccount.SetRange("Category No.", "Standard Account Category No.");
                StandardAccount.SetRange(Type, "Standard Account Type");
                StandardAccounts.SetTableView(StandardAccount);
                StandardAccounts.LookupMode(true);
                if StandardAccounts.RunModal() = Action::LookupOK then begin
                    StandardAccounts.GetRecord(StandardAccount);
                    "Standard Account No." := StandardAccount."No.";
                end;
            end;
        }
        field(6; "G/L Entries Exists"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'G/L Entries Exists';
            Editable = false;
        }
        field(50; "G/L Account Name"; Text[100])
        {
            Caption = 'G/L Account Name';
            FieldClass = FlowField;
            CalcFormula = lookup("G/L Account".Name where("No." = field("G/L Account No.")));
        }
    }

    keys
    {
        key(PK; "G/L Account Mapping Code", "G/L Account No.")
        {
            Clustered = true;
        }
    }
}
