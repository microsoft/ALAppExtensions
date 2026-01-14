// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.WithholdingTax;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Foundation.NoSeries;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;

table 6790 "Temp Withholding Tax Entry"
{
    Caption = 'Temp Withholding Tax Entry';
    LookupPageID = "Withholding Tax Entry";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(2; "Gen. Bus. Posting Group"; Code[20])
        {
            Caption = 'Gen. Bus. Posting Group';
            DataClassification = SystemMetadata;
            Editable = false;
            TableRelation = "Gen. Business Posting Group";
        }
        field(3; "Gen. Prod. Posting Group"; Code[20])
        {
            Caption = 'Gen. Prod. Posting Group';
            DataClassification = SystemMetadata;
            Editable = false;
            TableRelation = "Gen. Product Posting Group";
        }
        field(4; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(5; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(6; "Document Type"; Enum "Gen. Journal Document Type")
        {
            Caption = 'Document Type';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(8; Base; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Base';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(9; Amount; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(10; "Withholding Tax Calc. Type"; Option)
        {
            Caption = 'Withholding Tax Calculation Type';
            DataClassification = SystemMetadata;
            Editable = false;
            OptionCaption = 'Normal Withholding Tax,Full Withholding Tax';
            OptionMembers = "Normal Withholding Tax","Full Withholding Tax";
        }
        field(11; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = SystemMetadata;
        }
        field(12; "Bill-to/Pay-to No."; Code[20])
        {
            Caption = 'Bill-to/Pay-to No.';
            DataClassification = SystemMetadata;
            TableRelation = if ("Transaction Type" = const(Purchase)) Vendor
            else
            if ("Transaction Type" = const(Sale)) Customer;
        }
        field(14; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
        }
        field(15; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
            DataClassification = SystemMetadata;
            Editable = false;
            TableRelation = "Source Code";
        }
        field(16; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            DataClassification = SystemMetadata;
            Editable = false;
            TableRelation = "Reason Code";
        }
        field(17; "Closed by Entry No."; Integer)
        {
            Caption = 'Closed by Entry No.';
            DataClassification = SystemMetadata;
            Editable = false;
            TableRelation = "Temp Withholding Tax Entry";
        }
        field(18; Closed; Boolean)
        {
            Caption = 'Closed';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(19; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            DataClassification = SystemMetadata;
            TableRelation = "Country/Region";

            trigger OnValidate()
            begin
                Validate("Transaction Type");
            end;
        }
        field(21; "Transaction No."; Integer)
        {
            Caption = 'Transaction No.';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(22; "Unrealized Amount"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Unrealized Amount';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(23; "Unrealized Base"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Unrealized Base';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(24; "Remaining Unrealized Amount"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Remaining Unrealized Amount';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(25; "Remaining Unrealized Base"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Remaining Unrealized Base';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(26; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(27; "Transaction Type"; Option)
        {
            Caption = 'Transaction Type';
            DataClassification = SystemMetadata;
            OptionCaption = ' ,Purchase,Sale,Settlement';
            OptionMembers = " ",Purchase,Sale,Settlement;
        }
        field(28; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            DataClassification = SystemMetadata;
            Editable = false;
            TableRelation = "No. Series";
        }
        field(29; "Unreal. Wthldg. Tax Entry No."; Integer)
        {
            Caption = 'Unrealized Withholding Tax Entry No.';
            DataClassification = SystemMetadata;
            Editable = false;
            TableRelation = "Temp Withholding Tax Entry";
        }
        field(30; "Wthldg. Tax Bus. Post. Group"; Code[20])
        {
            Caption = 'Withholding Tax Bus. Post. Group';
            DataClassification = SystemMetadata;
            Editable = false;
            TableRelation = "Wthldg. Tax Bus. Post. Group";
        }
        field(31; "Wthldg. Tax Prod. Post. Group"; Code[20])
        {
            Caption = 'Withholding Tax Prod. Post. Group';
            DataClassification = SystemMetadata;
            Editable = false;
            TableRelation = "Wthldg. Tax Prod. Post. Group";
        }
        field(32; "Base (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Base (LCY)';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(33; "Amount (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount (LCY)';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(34; "Unrealized Amount (LCY)"; Decimal)
        {
            AutoFormatExpression = GetCurrencyCode();
            AutoFormatType = 1;
            Caption = 'Unrealized Amount (LCY)';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(35; "Unrealized Base (LCY)"; Decimal)
        {
            AutoFormatExpression = GetCurrencyCode();
            AutoFormatType = 1;
            Caption = 'Unrealized Base (LCY)';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(36; "Withholding Tax %"; Decimal)
        {
            Caption = 'Withholding Tax %';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;
            MaxValue = 100;
            MinValue = 0;
        }
        field(37; "Rem Unrealized Amount (LCY)"; Decimal)
        {
            AutoFormatExpression = GetCurrencyCode();
            AutoFormatType = 1;
            Caption = 'Rem Unrealized Amount (LCY)';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(38; "Rem Unrealized Base (LCY)"; Decimal)
        {
            AutoFormatExpression = GetCurrencyCode();
            AutoFormatType = 1;
            Caption = 'Rem Unrealized Base (LCY)';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(39; "Withholding Tax Difference"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Withholding Tax Difference';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(41; "Ship-to/Order Address Code"; Code[10])
        {
            Caption = 'Ship-to/Order Address Code';
            DataClassification = SystemMetadata;
            TableRelation = if ("Transaction Type" = const(Purchase)) "Order Address".Code where("Vendor No." = field("Bill-to/Pay-to No."))
            else
            if ("Transaction Type" = const(Sale)) "Ship-to Address".Code where("Customer No." = field("Bill-to/Pay-to No."));
        }
        field(42; "Document Date"; Date)
        {
            Caption = 'Document Date';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(44; "Actual Vendor No."; Code[20])
        {
            Caption = 'Actual Vendor No.';
            DataClassification = SystemMetadata;
        }
        field(45; "Wthldg. Tax Certificate No."; Code[20])
        {
            Caption = 'Withholding Tax Certificate No.';
            DataClassification = SystemMetadata;
        }
        field(47; "Void Check"; Boolean)
        {
            Caption = 'Void Check';
            DataClassification = SystemMetadata;
        }
        field(48; "Original Document No."; Code[20])
        {
            Caption = 'Original Document No.';
            DataClassification = SystemMetadata;
        }
        field(49; "Void Payment Entry No."; Integer)
        {
            Caption = 'Void Payment Entry No.';
            DataClassification = SystemMetadata;
        }
        field(50; "Wthldg. Tax Report Line No"; Code[20])
        {
            Caption = 'Withholding Tax Report Line No';
            DataClassification = SystemMetadata;
        }
        field(51; "Withholding Tax Report"; Option)
        {
            Caption = 'Withholding Report';
            DataClassification = SystemMetadata;
            OptionCaption = ' ,Por Ngor Dor 1,Por Ngor Dor 2,Por Ngor Dor 3,Por Ngor Dor 53,Por Ngor Dor 54';
            OptionMembers = " ","Por Ngor Dor 1","Por Ngor Dor 2","Por Ngor Dor 3","Por Ngor Dor 53","Por Ngor Dor 54";
        }
        field(52; "Applies-to Doc. Type"; Enum "Gen. Journal Document Type")
        {
            Caption = 'Applies-to Doc. Type';
            DataClassification = SystemMetadata;
        }
        field(53; "Applies-to Doc. No."; Code[20])
        {
            Caption = 'Applies-to Doc. No.';
            DataClassification = SystemMetadata;
        }
        field(54; "Applies-to Entry No."; Integer)
        {
            Caption = 'Applies-to Entry No.';
            DataClassification = SystemMetadata;
        }
        field(55; "Withholding Tax Revenue Type"; Code[10])
        {
            Caption = 'Withholding Tax Revenue Type';
            DataClassification = SystemMetadata;
        }
        field(57; "Payment Amount"; Decimal)
        {
            Caption = 'Payment Amount';
            DataClassification = SystemMetadata;
        }
        field(58; "Reversed by Entry No."; Integer)
        {
            Caption = 'Reversed by Entry No.';
            DataClassification = SystemMetadata;
            TableRelation = "Withholding Tax Entry"."Entry No.";
        }
        field(59; "Reversed Entry No."; Integer)
        {
            Caption = 'Reversed Entry No.';
            DataClassification = SystemMetadata;
            TableRelation = "Withholding Tax Entry"."Entry No.";
        }
        field(60; Reversed; Boolean)
        {
            Caption = 'Reversed';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Transaction Type", Closed, "Withholding Tax Difference", "Amount (LCY)", "Base (LCY)", "Posting Date")
        {
            SumIndexFields = Base, Amount, "Unrealized Amount", "Unrealized Base";
        }
        key(Key3; "Transaction Type", "Country/Region Code", "Withholding Tax Difference", "Posting Date")
        {
            SumIndexFields = Base;
        }
        key(Key4; "Document No.", "Posting Date")
        {
        }
        key(Key5; "Transaction No.")
        {
        }
        key(Key6; "Amount (LCY)", "Unrealized Amount (LCY)", "Unrealized Base (LCY)", "Base (LCY)", "Posting Date")
        {
        }
        key(Key7; "Document Type", "Document No.")
        {
            SumIndexFields = Base, Amount, "Unrealized Amount", "Unrealized Base", "Remaining Unrealized Amount", "Remaining Unrealized Base", "Base (LCY)", "Amount (LCY)", "Unrealized Amount (LCY)", "Unrealized Base (LCY)";
        }
        key(Key8; "Transaction Type", "Document No.", "Document Type", "Bill-to/Pay-to No.")
        {
        }
        key(Key9; "Applies-to Entry No.")
        {
            SumIndexFields = Base, Amount, "Unrealized Amount", "Unrealized Base", "Remaining Unrealized Amount", "Remaining Unrealized Base", "Base (LCY)", "Amount (LCY)", "Unrealized Amount (LCY)", "Unrealized Base (LCY)";
        }
        key(Key10; "Bill-to/Pay-to No.", "Original Document No.", "Withholding Tax Revenue Type")
        {
        }
        key(Key11; "Bill-to/Pay-to No.", "Withholding Tax Revenue Type", "Wthldg. Tax Prod. Post. Group")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Entry No.", "Posting Date", "Document No.", Amount)
        {
        }
    }

    var
        GLSetup: Record "General Ledger Setup";
        GLSetupRead: Boolean;

    procedure GetCurrencyCode(): Code[10]
    begin
        if not GLSetupRead then begin
            GLSetup.Get();
            GLSetupRead := true;
        end;
        exit(GLSetup."Additional Reporting Currency");
    end;
}