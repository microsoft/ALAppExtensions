// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Inventory.Ledger;
using Microsoft.Sales.Document;

tableextension 31303 "Item Ledger Entry CZ" extends "Item Ledger Entry"
{
    fields
    {
        field(31300; "Statistic Indication CZ"; Code[10])
        {
            Caption = 'Statistic Indication';
            TableRelation = "Statistic Indication CZ".Code;
        }
        field(31305; "Physical Transfer CZ"; Boolean)
        {
            Caption = 'Physical Transfer';
            DataClassification = CustomerContent;
        }
    }

    var
        IntrastatReportManagementCZ: Codeunit IntrastatReportManagementCZ;

    procedure GetDocumentCZ(var SalesHeader: Record "Sales Header"): Boolean
    var
        ValueEntry: Record "Value Entry";
    begin
        if FindValueEntryFromItemLedgEntry(Rec, ValueEntry) then
            exit(GetDocumentFromValueEntry(ValueEntry, SalesHeader));
        exit(IntrastatReportManagementCZ.GetDocument(Rec."Document Type", Rec."Document No.", SalesHeader));
    end;

    local procedure FindValueEntryFromItemLedgEntry(ItemLedgerEntry: Record "Item Ledger Entry"; var ValueEntry: Record "Value Entry"): Boolean
    begin
        if not ItemLedgerEntry."Completely Invoiced" then
            exit(false);

        ValueEntry.Reset();
        ValueEntry.SetCurrentKey("Item Ledger Entry No.");
        ValueEntry.SetRange("Item Ledger Entry No.", ItemLedgerEntry."Entry No.");
        ValueEntry.SetFilter("Invoiced Quantity", '<>%1', 0);
        exit(ValueEntry.FindFirst());
    end;

    local procedure GetDocumentFromValueEntry(ValueEntry: Record "Value Entry"; var SalesHeader: Record "Sales Header"): Boolean
    begin
        exit(IntrastatReportManagementCZ.GetDocument(ValueEntry."Document Type", ValueEntry."Document No.", SalesHeader));
    end;

    internal procedure GetIntrastatReportLineType(): Enum "Intrastat Report Line Type"
    begin
        if (("Entry Type" = "Entry Type"::Purchase) and "Physical Transfer CZ") or
           (("Entry Type" = "Entry Type"::Sale) and not "Physical Transfer CZ") or
           (("Entry Type" = "Entry Type"::Transfer) and (Quantity < 0))
        then
            exit(Enum::"Intrastat Report Line Type"::Shipment);
        exit(Enum::"Intrastat Report Line Type"::Receipt);
    end;

    internal procedure GetIntrastatAmountSign(): Integer
    begin
        exit(GetIntrastatQuantitySign());
    end;

    internal procedure GetIntrastatQuantitySign(): Integer
    begin
        if (not "Physical Transfer CZ") and
           ((("Entry Type" = "Entry Type"::Purchase) and (Quantity < 0)) or
            (("Entry Type" = "Entry Type"::Sale) and (Quantity > 0)))
        then
            exit(-1);
        exit(1);
    end;

    internal procedure IsCreditDocType(): Boolean
    begin
        exit("Document Type" in ["Document Type"::"Purchase Credit Memo", "Document Type"::"Purchase Return Shipment",
                                 "Document Type"::"Sales Credit Memo", "Document Type"::"Sales Return Receipt",
                                 "Document Type"::"Service Credit Memo"]);
    end;
}