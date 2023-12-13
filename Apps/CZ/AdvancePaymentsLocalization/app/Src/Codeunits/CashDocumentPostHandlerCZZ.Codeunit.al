// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance;
using Microsoft.Finance.CashDesk;
using Microsoft.Finance.GeneralLedger.Journal;

codeunit 31065 "Cash Document-Post Handler CZZ"
{
    SingleInstance = true;
    Permissions = tabledata "EET Entry CZL" = rm;

    var
        TempSalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ" temporary;
        UseBuffer: Boolean;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cash Document-Post CZP", 'OnBeforePostCashDocLine', '', false, false)]
    local procedure CashDocumentPostCZPOnBeforePostCashDocLine(var CashDocumentLineCZP: Record "Cash Document Line CZP"; var GenJournalLine: Record "Gen. Journal Line")
    begin
        GenJournalLine."Advance Letter No. CZZ" := CashDocumentLineCZP."Advance Letter No. CZZ";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cash Document-Post CZP", 'OnBeforePostCashDoc', '', false, false)]
    local procedure CashDocumentPostOnBeforePostCashDoc()
    begin
        if not TempSalesAdvLetterEntryCZZ.IsEmpty() then
            TempSalesAdvLetterEntryCZZ.DeleteAll();

        UseBuffer := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"SalesAdvLetterManagement CZZ", 'OnAfterInsertAdvEntry', '', false, false)]
    local procedure SalesAdvLetterManagementCZZOnAfterInsertAdvEntry(var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ")
    begin
        if (SalesAdvLetterEntryCZZ.IsTemporary()) or (not UseBuffer) then
            exit;

        if SalesAdvLetterEntryCZZ."Entry Type" = SalesAdvLetterEntryCZZ."Entry Type"::Payment then begin
            TempSalesAdvLetterEntryCZZ := SalesAdvLetterEntryCZZ;
            TempSalesAdvLetterEntryCZZ.Insert();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cash Document-Post CZP", 'OnAfterPostLines', '', false, false)]
    local procedure PostAdvancePaymentVATOnAfterPostLines()
    var
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterManagementCZZ: Codeunit "SalesAdvLetterManagement CZZ";
    begin
        if TempSalesAdvLetterEntryCZZ.FindSet() then begin
            repeat
                SalesAdvLetterHeaderCZZ.Get(TempSalesAdvLetterEntryCZZ."Sales Adv. Letter No.");
                if SalesAdvLetterHeaderCZZ."Automatic Post VAT Document" then
                    SalesAdvLetterManagementCZZ.PostAdvancePaymentVAT(TempSalesAdvLetterEntryCZZ, 0D);
            until TempSalesAdvLetterEntryCZZ.Next() = 0;
            TempSalesAdvLetterEntryCZZ.DeleteAll();
        end;
        UseBuffer := false;
    end;
}
