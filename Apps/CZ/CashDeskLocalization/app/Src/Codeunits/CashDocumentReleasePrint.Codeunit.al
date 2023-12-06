// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

codeunit 11726 "Cash Document-ReleasePrint CZP"
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
        ApprovalProcessErr: Label 'This document can only be released when the approval process is complete.';

    local procedure Code()
    begin
        Codeunit.Run(Codeunit::"Cash Document-Release CZP", CashDocumentHeaderCZP);
        Commit();
        GetReport(CashDocumentHeaderCZP);
    end;

    procedure PerformManualRelease(var CashDocumentHeaderCZP: Record "Cash Document Header CZP")
    var
        CashDocumentApprovMgtCZP: Codeunit "Cash Document Approv. Mgt. CZP";
    begin
        if CashDocumentApprovMgtCZP.IsCashDocApprovalsWorkflowEnabled(CashDocumentHeaderCZP) and
           (CashDocumentHeaderCZP.Status = CashDocumentHeaderCZP.Status::Open)
        then
            Error(ApprovalProcessErr);

        Codeunit.Run(Codeunit::"Cash Document-ReleasePrint CZP", CashDocumentHeaderCZP);
    end;

    procedure GetReport(var CashDocumentHeaderCZP: Record "Cash Document Header CZP")
    begin
        CashDocumentHeaderCZP.Reset();
        CashDocumentHeaderCZP.SetRecFilter();
        CashDocumentHeaderCZP.PrintRecords(true);
    end;
}
