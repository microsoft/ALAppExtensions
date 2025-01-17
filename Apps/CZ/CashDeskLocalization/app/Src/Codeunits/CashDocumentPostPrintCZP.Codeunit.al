// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

codeunit 11721 "Cash Document-Post + Print CZP"
{
    TableNo = "Cash Document Header CZP";

    trigger OnRun()
    begin
        CashDocumentHeaderCZP.Copy(Rec);
        Code();
        Rec := CashDocumentHeaderCZP;
    end;

    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        WithoutConfirmation: Boolean;

    procedure PostWithoutConfirmation(var ParmCashDocumentHeaderCZP: Record "Cash Document Header CZP")
    begin
        WithoutConfirmation := true;
        CashDocumentHeaderCZP.Copy(ParmCashDocumentHeaderCZP);
        Code();
        ParmCashDocumentHeaderCZP := CashDocumentHeaderCZP;
    end;

    local procedure Code()
    begin
        if WithoutConfirmation then
            Codeunit.Run(Codeunit::"Cash Document-Post CZP", CashDocumentHeaderCZP)
        else
            Codeunit.Run(Codeunit::"Cash Document-Post(Yes/No) CZP", CashDocumentHeaderCZP);
        Commit();
        GetReport(CashDocumentHeaderCZP);
    end;

    procedure GetReport(var CashDocumentHeaderCZP: Record "Cash Document Header CZP")
    var
        PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeGetReport(CashDocumentHeaderCZP, IsHandled);
        if IsHandled then
            exit;

        PostedCashDocumentHdrCZP.Get(CashDocumentHeaderCZP."Cash Desk No.", CashDocumentHeaderCZP."No.");
        PostedCashDocumentHdrCZP.SetRecFilter();
        PostedCashDocumentHdrCZP.PrintRecords(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetReport(var CashDocumentHeaderCZP: Record "Cash Document Header CZP"; var IsHandled: Boolean)
    begin
    end;
}
