// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.GeneralLedger.Posting;

codeunit 31006 "Gen.Jnl-Post Batch Handler CZZ"
{
    SingleInstance = true;

    var
        TempSalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ" temporary;
        UseBuffer: Boolean;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Batch", 'OnBeforeProcessLines', '', false, false)]
    local procedure GenJnlPostBatchOnBeforeProcessLines()
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Batch", 'OnAfterProcessLines', '', false, false)]
    local procedure GenJnlPostBatchOnAfterProcessLines()
    begin
        PostAdvancePaymentVAT();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Batch", 'OnBeforeThrowPreviewError', '', false, false)]
    local procedure GenJnlPostBatchOnBeforeThrowPreviewError()
    begin
        PostAdvancePaymentVAT();
    end;

    local procedure PostAdvancePaymentVAT()
    var
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterManagement: Codeunit "SalesAdvLetterManagement CZZ";
    begin
        if TempSalesAdvLetterEntryCZZ.FindSet() then begin
            repeat
                SalesAdvLetterHeaderCZZ.Get(TempSalesAdvLetterEntryCZZ."Sales Adv. Letter No.");
                if SalesAdvLetterHeaderCZZ."Automatic Post VAT Document" then
                    SalesAdvLetterManagement.PostAdvancePaymentVAT(TempSalesAdvLetterEntryCZZ, 0D);
            until TempSalesAdvLetterEntryCZZ.Next() = 0;

            TempSalesAdvLetterEntryCZZ.DeleteAll();
        end;

        UseBuffer := false;
    end;
}
