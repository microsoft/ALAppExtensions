// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using Microsoft.Bank.BankAccount;
using Microsoft.Finance.AllocationAccount;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.VAT.Setup;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.HumanResources.Employee;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Utilities;

table 11746 "Cash Desk Event CZP"
{
    Caption = 'Cash Desk Event';
    LookupPageID = "Cash Desk Events CZP";

    fields
    {
        field(1; Code; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(2; "Cash Desk No."; Code[20])
        {
            Caption = 'Cash Desk No.';
            TableRelation = "Cash Desk CZP";
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                CashDeskCZP: Record "Cash Desk CZP";
            begin
                if "Cash Desk No." <> '' then begin
                    CashDeskCZP.Get("Cash Desk No.");
                    CashDeskCZP.TestField(Blocked, false);
                end;
            end;
        }
        field(5; "Document Type"; Enum "Cash Document Type CZP")
        {
            Caption = 'Cash Document Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                "Gen. Document Type" := "Gen. Document Type"::" ";
                if (("Account Type" = "Account Type"::Vendor) and ("Document Type" = "Document Type"::Withdrawal)) or
                   (("Account Type" = "Account Type"::Customer) and ("Document Type" = "Document Type"::Receipt))
                then
                    "Gen. Document Type" := "Gen. Document Type"::Payment;
                if (("Account Type" = "Account Type"::Customer) and ("Document Type" = "Document Type"::Withdrawal)) or
                   (("Account Type" = "Account Type"::Vendor) and ("Document Type" = "Document Type"::Receipt))
                then
                    "Gen. Document Type" := "Gen. Document Type"::Refund;
            end;
        }
        field(10; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(11; "Account Type"; Enum "Cash Document Account Type CZP")
        {
            Caption = 'Account Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Account Type" <> xRec."Account Type" then begin
                    Validate("Document Type");
                    Validate("Account No.", '');
                    Validate("Gen. Posting Type", "Gen. Posting Type"::" ");
                    Validate("VAT Bus. Posting Group", '');
                    Validate("VAT Prod. Posting Group", '');
                end;
            end;
        }
        field(12; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            TableRelation = if ("Account Type" = const(" ")) "Standard Text" else
            if ("Account Type" = const("G/L Account")) "G/L Account" else
            if ("Account Type" = const(Customer)) Customer else
            if ("Account Type" = const(Vendor)) Vendor else
            if ("Account Type" = const(Employee)) Employee else
            if ("Account Type" = const("Bank Account")) "Bank Account" where("Account Type CZP" = const("Bank Account")) else
            if ("Account Type" = const("Fixed Asset")) "Fixed Asset" else
            if ("Account Type" = const("Allocation Account")) "Allocation Account";
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                StandardText: Record "Standard Text";
                GLAccount: Record "G/L Account";
                Customer: Record Customer;
                Vendor: Record Vendor;
                BankAccount: Record "Bank Account";
                FixedAsset: Record "Fixed Asset";
                Employee: Record Employee;
            begin
                if ("Account No." <> xRec."Account No.") and ("Account No." <> '') then
                    case "Account Type" of
                        "Account Type"::" ":
                            begin
                                StandardText.Get("Account No.");
                                Description := StandardText.Description;
                            end;
                        "Account Type"::"G/L Account":
                            begin
                                GLAccount.Get("Account No.");
                                Description := GLAccount.Name;
                                "Gen. Posting Type" := GLAccount."Gen. Posting Type".AsInteger();
                                "VAT Bus. Posting Group" := GLAccount."VAT Bus. Posting Group";
                                "VAT Prod. Posting Group" := GLAccount."VAT Prod. Posting Group";
                            end;
                        "Account Type"::Customer:
                            begin
                                Customer.Get("Account No.");
                                Description := Customer.Name;
                                "Gen. Posting Type" := "Gen. Posting Type"::" ";
                                "VAT Bus. Posting Group" := '';
                                "VAT Prod. Posting Group" := '';
                            end;
                        "Account Type"::Vendor:
                            begin
                                Vendor.Get("Account No.");
                                Description := Vendor.Name;
                                "Gen. Posting Type" := "Gen. Posting Type"::" ";
                                "VAT Bus. Posting Group" := '';
                                "VAT Prod. Posting Group" := '';
                            end;
                        "Account Type"::"Fixed Asset":
                            begin
                                FixedAsset.Get("Account No.");
                                Description := FixedAsset.Description;
                                "Gen. Posting Type" := "Gen. Posting Type"::" ";
                                "VAT Bus. Posting Group" := '';
                                "VAT Prod. Posting Group" := '';
                            end;
                        "Account Type"::"Bank Account":
                            begin
                                BankAccount.Get("Account No.");
                                Description := BankAccount.Name;
                                "Gen. Posting Type" := "Gen. Posting Type"::" ";
                                "VAT Bus. Posting Group" := '';
                                "VAT Prod. Posting Group" := '';
                            end;
                        "Account Type"::Employee:
                            begin
                                Employee.Get("Account No.");
                                Description := CopyStr(Employee.FullName(), 1, MaxStrLen(Description));
                                "Gen. Posting Type" := "Gen. Posting Type"::" ";
                                "VAT Bus. Posting Group" := '';
                                "VAT Prod. Posting Group" := '';
                            end;
                    end;
            end;
        }
        field(14; "Gen. Document Type"; Enum "Cash Document Gen.Doc.Type CZP")
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
        }
        field(29; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Global Dimension 1 Code");
            end;
        }
        field(30; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2));
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Global Dimension 2 Code");
            end;
        }
        field(72; "Gen. Posting Type"; Option)
        {
            Caption = 'Gen. Posting Type';
            OptionCaption = ' ,Purchase,Sale';
            OptionMembers = " ",Purchase,Sale;
            DataClassification = CustomerContent;
        }
        field(101; "EET Transaction"; Boolean)
        {
            Caption = 'EET Transaction';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "EET Transaction" then
                    if not ("Account Type" in ["Account Type"::"G/L Account", "Account Type"::Customer]) then
                        FieldError("Account Type");
            end;
        }
        field(116; "VAT Bus. Posting Group"; Code[20])
        {
            Caption = 'VAT Bus. Posting Group';
            TableRelation = "VAT Business Posting Group";
            DataClassification = CustomerContent;
        }
        field(117; "VAT Prod. Posting Group"; Code[20])
        {
            Caption = 'VAT Prod. Posting Group';
            TableRelation = "VAT Product Posting Group";
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; Code)
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    begin
        DimensionManagement.DeleteDefaultDim(Database::"Cash Desk Event CZP", Code);
    end;

    trigger OnRename()
    begin
        DimensionManagement.RenameDefaultDim(Database::"Cash Desk Event CZP", xRec.Code, Code);
    end;

    var
        DimensionManagement: Codeunit DimensionManagement;

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        OnBeforeValidateShortcutDimCode(Rec, xRec, FieldNumber, ShortcutDimCode);

        DimensionManagement.ValidateDimValueCode(FieldNumber, ShortcutDimCode);
        if not IsTemporary then begin
            DimensionManagement.SaveDefaultDim(DATABASE::"Cash Desk Event CZP", Code, FieldNumber, ShortcutDimCode);
            Modify();
        end;

        OnAfterValidateShortcutDimCode(Rec, xRec, FieldNumber, ShortcutDimCode);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateShortcutDimCode(var CashDeskEventCZP: Record "Cash Desk Event CZP"; var xCashDeskEventCZP: Record "Cash Desk Event CZP"; FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterValidateShortcutDimCode(var CashDeskEventCZP: Record "Cash Desk Event CZP"; var xCashDeskEventCZP: Record "Cash Desk Event CZP"; FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
    end;
}
