// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Vendor;

table 11753 "Unreliable Payer Entry CZL"
{
    Caption = 'Unreliable Payer Entry';
    DrillDownPageId = "Unreliable Payer Entries CZL";
    LookupPageId = "Unreliable Payer Entries CZL";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(8; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            TableRelation = Vendor;
            DataClassification = CustomerContent;
        }
        field(20; "Check Date"; Date)
        {
            Caption = 'Check Date';
            DataClassification = CustomerContent;
        }
        field(21; "Public Date"; Date)
        {
            Caption = 'Public Date';
            DataClassification = CustomerContent;
        }
        field(22; "End Public Date"; Date)
        {
            Caption = 'End Public Date';
            DataClassification = CustomerContent;
        }
        field(25; "Unreliable Payer"; Option)
        {
            Caption = 'Unreliable Payer';
            OptionCaption = ' ,NO,YES,NOTFOUND';
            OptionMembers = " ",NO,YES,NOTFOUND;
            DataClassification = CustomerContent;
        }
        field(30; "Entry Type"; Option)
        {
            Caption = 'Entry Type';
            OptionCaption = 'Payer,Bank Account';
            OptionMembers = Payer,"Bank Account";
            DataClassification = CustomerContent;
        }
        field(40; "VAT Registration No."; Code[20])
        {
            Caption = 'VAT Registration No.';
            DataClassification = CustomerContent;
        }
        field(50; "Tax Office Number"; Code[10])
        {
            Caption = 'Tax Office Number';
            DataClassification = CustomerContent;
        }
        field(60; "Full Bank Account No."; Code[50])
        {
            Caption = 'Full Bank Account No.';
            DataClassification = CustomerContent;
        }
        field(61; "Bank Account No. Type"; Option)
        {
            Caption = 'Bank Account No. Type';
            OptionCaption = 'Standard,Nonstandard';
            OptionMembers = Standard,"Not Standard";
            DataClassification = CustomerContent;
        }
        field(70; "Vendor Name"; Text[100])
        {
            CalcFormula = lookup(Vendor.Name where("No." = field("Vendor No.")));
            Caption = 'Vendor Name';
            FieldClass = FlowField;
            Editable = false;
        }
    }
    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Vendor No.", "Check Date")
        {
        }
        key(Key3; "VAT Registration No.", "Vendor No.", "Check Date")
        {
        }
        key(Key4; "Vendor No.", "Entry Type", "Full Bank Account No.", "End Public Date")
        {
        }
    }

    procedure CreateVendorBankAccountCZL(UnreliablePayerNoCZL: Code[20]);
    var
        VendorBankAccount: Record "Vendor Bank Account";
        GetVendBankAccCodeCZL: Page "Get Vend. Bank Acc. Code CZL";
        VendorBankAccountCode: Code[10];
        VendorBankAccountName: Text[100];
        VendorBankAccountAlreadyExistsErr: Label '%1 %2 already exists.', Comment = '%1 = TableCaption, ;%2 = Bank Account No.';
        UnknownPayerNoErr: Label '%1 cannot be created because %2 is not specified.', Comment = '%1 = Vendor Bank Account TableCaption, %2 = Vendor No. FieldCaption';
    begin
        if UnreliablePayerNoCZL = '' then
            UnreliablePayerNoCZL := Rec."Vendor No.";
        if UnreliablePayerNoCZL = '' then
            Error(UnknownPayerNoErr, VendorBankAccount.TableCaption(), Rec.FieldCaption("Vendor No."));

        TestField("Entry Type", "Entry Type"::"Bank Account");
        TestField("Full Bank Account No.");
        VendorBankAccount.SetRange("Vendor No.", UnreliablePayerNoCZL);
        case "Bank Account No. Type" of
            "Bank Account No. Type"::Standard:
                VendorBankAccount.SetRange("Bank Account No.", "Full Bank Account No.");
            "Bank Account No. Type"::"Not Standard":
                VendorBankAccount.SetRange(IBAN, "Full Bank Account No.");
        end;
        if VendorBankAccount.FindFirst() then
            Error(VendorBankAccountAlreadyExistsErr, VendorBankAccount.TableCaption, VendorBankAccount.Code);

        GetVendBankAccCodeCZL.SetValue(UnreliablePayerNoCZL);
        if GetVendBankAccCodeCZL.RunModal() = Action::OK then begin
            GetVendBankAccCodeCZL.GetValue(VendorBankAccountCode, VendorBankAccountName);
            Clear(VendorBankAccount);
            VendorBankAccount.Validate("Vendor No.", UnreliablePayerNoCZL);
            VendorBankAccount.Validate(Code, VendorBankAccountCode);
            VendorBankAccount.TestField(Code);
            VendorBankAccount.Validate(Name, VendorBankAccountName);
            case "Bank Account No. Type" of
                "Bank Account No. Type"::Standard:
                    VendorBankAccount.Validate("Bank Account No.", "Full Bank Account No.");
                "Bank Account No. Type"::"Not Standard":
                    VendorBankAccount.Validate(IBAN, "Full Bank Account No.");
            end;
            VendorBankAccount.Insert(true);
        end;
    end;
}
