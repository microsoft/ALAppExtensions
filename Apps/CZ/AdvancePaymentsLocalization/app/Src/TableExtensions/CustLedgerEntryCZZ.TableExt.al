// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Sales.Receivables;

tableextension 31001 "Cust. Ledger Entry CZZ" extends "Cust. Ledger Entry"
{
    fields
    {
        field(31010; "Advance Letter No. CZZ"; Code[20])
        {
            Caption = 'Advance Letter No.';
            DataClassification = CustomerContent;
            TableRelation = "Sales Adv. Letter Header CZZ";
        }
        field(31011; "Adv. Letter Template Code CZZ"; Code[20])
        {
            Caption = 'Advance Letter Template Code';
            DataClassification = CustomerContent;
            TableRelation = "Advance Letter Template CZZ" where("Sales/Purchase" = const(Sales));
        }
    }

    internal procedure SetApplication(AdvanceLetterCode: Code[20]; AdvanceLetterNo: Code[20])
    begin
        CalcFields("Remaining Amount");
        "Amount to Apply" := "Remaining Amount";
        "Applies-to ID" := CopyStr("Document No." + Format("Entry No.", 0, '<Integer>'), 1, MaxStrLen("Applies-to ID"));
        Prepayment := false;
        if AdvanceLetterCode <> '' then
            "Adv. Letter Template Code CZZ" := AdvanceLetterCode;
        if AdvanceLetterNo <> '' then
            "Advance Letter No. CZZ" := AdvanceLetterNo;
        OnSetApplicationOnBeforeCustEntryEditCZZ(Rec);
        Codeunit.Run(Codeunit::"Cust. Entry-Edit", Rec);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetApplicationOnBeforeCustEntryEditCZZ(var CustLedgerEntry: Record "Cust. Ledger Entry")
    begin
    end;
}
