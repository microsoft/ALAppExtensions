// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Calculation;

using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.VAT.Ledger;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Foundation.Enums;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;

table 11727 "VAT LCY Correction Buffer CZL"
{
    Caption = 'VAT LCY Correction Buffer';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            Editable = false;
        }
        field(4; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            Editable = false;
        }
        field(5; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            Editable = false;
        }
        field(6; "Document Type"; Enum "Gen. Journal Document Type")
        {
            Caption = 'Document Type';
            Editable = false;
        }
        field(7; Type; Enum "General Posting Type")
        {
            Caption = 'Type';
            Editable = false;
        }
        field(8; "VAT Base"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'VAT Base';
            Editable = false;
        }
        field(9; "VAT Amount"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'VAT Amount';
            Editable = false;
        }
        field(11; "VAT Date"; Date)
        {
            Caption = 'VAT Date';
            Editable = false;
        }
        field(12; "Bill-to/Pay-to No."; Code[20])
        {
            Caption = 'Bill-to/Pay-to No.';
            Editable = false;
            TableRelation = if (Type = const(Purchase)) Vendor else
            if (Type = const(Sale)) Customer;
        }
        field(15; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
            Editable = false;
            TableRelation = "Source Code";
        }
        field(19; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            Editable = false;
            TableRelation = "Country/Region";
        }
        field(39; "VAT Bus. Posting Group"; Code[20])
        {
            Caption = 'VAT Bus. Posting Group';
            Editable = false;
            TableRelation = "VAT Business Posting Group";
        }
        field(40; "VAT Prod. Posting Group"; Code[20])
        {
            Caption = 'VAT Prod. Posting Group';
            Editable = false;
            TableRelation = "VAT Product Posting Group";
        }
        field(41; "VAT %"; Decimal)
        {
            Caption = 'VAT %';
            DecimalPlaces = 0 : 5;
            Editable = false;
            MaxValue = 100;
            MinValue = 0;
        }
        field(50; "VAT Correction Amount"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'VAT Correction Amount';
            Editable = false;
        }
        field(55; "Corrected VAT Amount"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Corrected VAT Amount';

            trigger OnValidate()
            begin
                CalcVATCorrectionAmount();
            end;
        }
        field(60; "VAT LCY Correction"; Boolean)
        {
            Caption = 'VAT LCY Correction';
            Editable = false;
        }
        field(65; "VAT Registration No."; Text[20])
        {
            Caption = 'VAT Registration No.';
            Editable = false;
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";
        }
        field(11781; "Registration No."; Text[20])
        {
            Caption = 'Registration No.';
            Editable = false;
        }
        field(11782; "Tax Registration No."; Text[20])
        {
            Caption = 'Tax Registration No.';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
    }

    var
        ExceedingMaxDifferenceErr: Label '%1 must not exceed %2 = %3.', Comment = '%1 = correction fieldcaption, %2= max. difference fieldcaption, %3 = max. difference amount';

    procedure CalcVATCorrectionAmount()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        Rec."VAT Correction Amount" := Rec."Corrected VAT Amount" - Rec."VAT Amount";

        if not GeneralLedgerSetup.Get() then
            GeneralLedgerSetup.Init();
        if Abs(Rec."VAT Correction Amount") > GeneralLedgerSetup."Max. VAT Difference Allowed" then
            Error(
              ExceedingMaxDifferenceErr, Rec.FieldCaption("VAT Correction Amount"),
              GeneralLedgerSetup.FieldCaption("Max. VAT Difference Allowed"), GeneralLedgerSetup."Max. VAT Difference Allowed");
    end;

    procedure InsertFromVATEntry(VATEntry: Record "VAT Entry")
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        Clear(Rec);
        Rec."Entry No." := VATEntry."Entry No.";
        Rec."Posting Date" := VATEntry."Posting Date";
        Rec."Document No." := VATEntry."Document No.";
        Rec."Document Type" := VATEntry."Document Type";
        Rec.Type := VATEntry.Type;
        Rec."VAT Base" := VATEntry.Base;
        Rec."VAT Amount" := VATEntry.Amount;
        Rec."VAT Date" := VATEntry."VAT Reporting Date";
        Rec."Bill-to/Pay-to No." := VATEntry."Bill-to/Pay-to No.";
        Rec."Source Code" := VATEntry."Source Code";
        Rec."Country/Region Code" := VATEntry."Country/Region Code";
        Rec."VAT Bus. Posting Group" := VATEntry."VAT Bus. Posting Group";
        Rec."VAT Prod. Posting Group" := VATEntry."VAT Prod. Posting Group";
        Rec.Validate("Corrected VAT Amount", Rec."VAT Amount");

        if VATPostingSetup.Get(Rec."VAT Bus. Posting Group", Rec."VAT Prod. Posting Group") then
            Rec."VAT %" := VATPostingSetup."VAT %";
        Rec."VAT Registration No." := VATEntry."VAT Registration No.";
        Rec."Registration No." := VATEntry."Registration No. CZL";
        Rec."Tax Registration No." := VATEntry."Tax Registration No. CZL";

        OnBeforeInsertFromVATEntry(Rec, VATEntry);
        Insert(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertFromVATEntry(var VATLCYCorrectionBufferCZL: Record "VAT LCY Correction Buffer CZL"; VATEntry: Record "VAT Entry")
    begin
    end;
}
