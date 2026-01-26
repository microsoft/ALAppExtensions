// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Purchases.Payables;
using Microsoft.Sales.Receivables;

table 31014 "Advance Posting Parameters CZZ"
{
    Caption = 'Advance Posting Parameters';
    TableType = Temporary;
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = SystemMetadata;
        }
        field(2; "Document Type"; Enum "Gen. Journal Document Type")
        {
            Caption = 'Document Type';
            DataClassification = SystemMetadata;
        }
        field(3; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = SystemMetadata;
        }
        field(4; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
            DataClassification = SystemMetadata;
        }
        field(6; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
            DataClassification = SystemMetadata;
        }
        field(7; "Posting Description"; Text[100])
        {
            Caption = 'Posting Description';
            DataClassification = SystemMetadata;
        }
        field(10; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = SystemMetadata;
        }
        field(11; "Document Date"; Date)
        {
            Caption = 'Document Date';
            DataClassification = SystemMetadata;
        }
        field(12; "VAT Date"; Date)
        {
            Caption = 'VAT Date';
            DataClassification = SystemMetadata;
        }
        field(13; "Original Document VAT Date"; Date)
        {
            Caption = 'Original Document VAT Date';
            DataClassification = SystemMetadata;
        }
        field(15; "Amount to Link"; Decimal)
        {
            Caption = 'Amount to Link';
            DataClassification = SystemMetadata;
        }
        field(20; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
        }
        field(21; "Currency Factor"; Decimal)
        {
            Caption = 'Currency Factor';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 15;
            MinValue = 0;
        }
        field(22; "Additional Currency Factor"; Decimal)
        {
            Caption = 'Additional Currency Factor';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 15;
            MinValue = 0;
        }
        field(25; "Temporary Entries Only"; Boolean)
        {
            Caption = 'Temporary Entries Only';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
    }

    var
        EmptyDatesErr: Label 'Dates cannot be empty.';
        EmptyDocNoErr: Label 'Document No. cannot be empty.';
        EmptyExternalDocumentNoErr: Label 'External Document No. cannot be empty.';
        OriginalDocVATDateErr: Label 'Original Document VAT Date (%1) must be less or equal to VAT Date (%2).', Comment = '%1 = OriginalDocVATDate, %2 = VATDate';

    procedure CopyFromCustLedgerEntry(CustLedgerEntry: Record "Cust. Ledger Entry")
    begin
        "Document No." := CustLedgerEntry."Document No.";
        "External Document No." := CustLedgerEntry."External Document No.";
        "Source Code" := CustLedgerEntry."Source Code";
        "Posting Description" := CustLedgerEntry.Description;
        "Posting Date" := CustLedgerEntry."Posting Date";
        "Document Date" := CustLedgerEntry."Document Date";
        "VAT Date" := CustLedgerEntry."VAT Date CZL";
        OnAfterCopyFromCustLedgerEntry(CustLedgerEntry, Rec);
    end;

    procedure CopyFromVendorLedgerEntry(VendorLedgerEntry: Record "Vendor Ledger Entry")
    begin
        "Document No." := VendorLedgerEntry."Document No.";
        "External Document No." := VendorLedgerEntry."External Document No.";
        "Source Code" := VendorLedgerEntry."Source Code";
        "Posting Description" := VendorLedgerEntry.Description;
        "Posting Date" := VendorLedgerEntry."Posting Date";
        "Document Date" := VendorLedgerEntry."Document Date";
        "VAT Date" := VendorLedgerEntry."VAT Date CZL";
        "Original Document VAT Date" := VendorLedgerEntry."VAT Date CZL";
        OnAfterCopyFromVendorLedgerEntry(VendorLedgerEntry, Rec);
    end;

    procedure CopyFromSalesAdvLetterEntry(SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ")
    begin
        "Document No." := SalesAdvLetterEntryCZZ."Document No.";
        "Posting Date" := SalesAdvLetterEntryCZZ."Posting Date";
        "Document Date" := SalesAdvLetterEntryCZZ."Posting Date";
        "VAT Date" := SalesAdvLetterEntryCZZ."VAT Date";
        "Currency Code" := SalesAdvLetterEntryCZZ."Currency Code";
        "Currency Factor" := SalesAdvLetterEntryCZZ."Currency Factor";
        "Additional Currency Factor" := SalesAdvLetterEntryCZZ."Additional Currency Factor";
        OnAfterCopyFromSalesAdvLetterEntry(SalesAdvLetterEntryCZZ, Rec);
    end;

    procedure CopyFromPurchAdvLetterEntry(PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ")
    begin
        "Document No." := PurchAdvLetterEntryCZZ."Document No.";
        "External Document No." := PurchAdvLetterEntryCZZ."External Document No.";
        "Posting Date" := PurchAdvLetterEntryCZZ."Posting Date";
        "Document Date" := PurchAdvLetterEntryCZZ."Posting Date";
        "VAT Date" := PurchAdvLetterEntryCZZ."VAT Date";
        "Original Document VAT Date" := PurchAdvLetterEntryCZZ."Original Document VAT Date";
        if "Original Document VAT Date" = 0D then
            "Original Document VAT Date" := PurchAdvLetterEntryCZZ."VAT Date";
        "Currency Code" := PurchAdvLetterEntryCZZ."Currency Code";
        "Currency Factor" := PurchAdvLetterEntryCZZ."Currency Factor";
        "Additional Currency Factor" := PurchAdvLetterEntryCZZ."Additional Currency Factor";
        OnAfterCopyFromPurchAdvLetterEntry(PurchAdvLetterEntryCZZ, Rec);
    end;

    internal procedure InitNew(AdvancePostingParameters: Record "Advance Posting Parameters CZZ")
    begin
        Clear(Rec);
        Rec := AdvancePostingParameters;
    end;

    internal procedure CheckPurchaseDates()
    begin
        if ("Posting Date" = 0D) or ("VAT Date" = 0D) or ("Original Document VAT Date" = 0D) then
            Error(EmptyDatesErr);
        if "Original Document VAT Date" > "VAT Date" then
            Error(OriginalDocVATDateErr, "Original Document VAT Date", "VAT Date");
    end;

    internal procedure CheckSalesDates()
    begin
        if ("Posting Date" = 0D) or ("VAT Date" = 0D) then
            Error(EmptyDatesErr);
    end;

    internal procedure CheckDocumentNo()
    begin
        if "Document No." = '' then
            Error(EmptyDocNoErr);
    end;

    internal procedure CheckExternalDocumentNo()
    begin
        if "External Document No." = '' then
            Error(EmptyExternalDocumentNoErr);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyFromVendorLedgerEntry(VendorLedgerEntry: Record "Vendor Ledger Entry"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyFromCustLedgerEntry(CustLedgerEntry: Record "Cust. Ledger Entry"; var Rec: Record "Advance Posting Parameters CZZ" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyFromSalesAdvLetterEntry(SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyFromPurchAdvLetterEntry(PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ")
    begin
    end;
}

