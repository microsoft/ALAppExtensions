// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Bank.Documents;

tableextension 31041 "Match Bank Payment Buffer CZZ" extends "Match Bank Payment Buffer CZB"
{
    fields
    {
        field(31010; "Advance Letter No. CZZ"; Code[20])
        {
            Caption = 'Advance Letter No.';
            DataClassification = CustomerContent;
        }
    }

    procedure InsertFromSalesAdvanceCZZ(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; UseLCYAmounts: Boolean)
    begin
        Clear(Rec);
        "Account Type" := "Account Type"::Customer;
        "Account No." := SalesAdvLetterHeaderCZZ."Bill-to Customer No.";
        "Due Date" := SalesAdvLetterHeaderCZZ."Advance Due Date";
        "Posting Date" := SalesAdvLetterHeaderCZZ."Posting Date";
        "Specific Symbol" := SalesAdvLetterHeaderCZZ."Specific Symbol";
        "Variable Symbol" := SalesAdvLetterHeaderCZZ."Variable Symbol";
        "Constant Symbol" := SalesAdvLetterHeaderCZZ."Constant Symbol";
        SalesAdvLetterHeaderCZZ.CalcFields("To Pay", "To Pay (LCY)");
        if UseLCYAmounts then
            "Remaining Amount" := SalesAdvLetterHeaderCZZ."To Pay (LCY)"
        else
            "Remaining Amount" := SalesAdvLetterHeaderCZZ."To Pay";
        "Remaining Amt. Incl. Discount" := "Remaining Amount";
        "Advance Letter No. CZZ" := SalesAdvLetterHeaderCZZ."No.";
        OnBeforeInsertFromSalesAdvanceCZZ(Rec, SalesAdvLetterHeaderCZZ);
        Insert(true);
    end;

    procedure InsertFromPurchAdvanceCZZ(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; UseLCYAmounts: Boolean)
    begin
        Clear(Rec);
        "Account Type" := "Account Type"::Vendor;
        "Account No." := PurchAdvLetterHeaderCZZ."Pay-to Vendor No.";
        "Due Date" := PurchAdvLetterHeaderCZZ."Advance Due Date";
        "Posting Date" := PurchAdvLetterHeaderCZZ."Posting Date";
        "Specific Symbol" := PurchAdvLetterHeaderCZZ."Specific Symbol";
        "Variable Symbol" := PurchAdvLetterHeaderCZZ."Variable Symbol";
        "Constant Symbol" := PurchAdvLetterHeaderCZZ."Constant Symbol";
        PurchAdvLetterHeaderCZZ.CalcFields("To Pay", "To Pay (LCY)");
        if UseLCYAmounts then
            "Remaining Amount" := PurchAdvLetterHeaderCZZ."To Pay (LCY)"
        else
            "Remaining Amount" := PurchAdvLetterHeaderCZZ."To Pay";
        "Remaining Amt. Incl. Discount" := "Remaining Amount";
        "Advance Letter No. CZZ" := PurchAdvLetterHeaderCZZ."No.";
        OnBeforeInsertFromPurchAdvanceCZZ(Rec, PurchAdvLetterHeaderCZZ);
        Insert(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertFromSalesAdvanceCZZ(var MatchBankPaymentBufferCZB: Record "Match Bank Payment Buffer CZB"; SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertFromPurchAdvanceCZZ(var MatchBankPaymentBufferCZB: Record "Match Bank Payment Buffer CZB"; PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
    end;
}
