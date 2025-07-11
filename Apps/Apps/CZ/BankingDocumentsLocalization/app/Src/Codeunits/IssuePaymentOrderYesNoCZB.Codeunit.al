// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

codeunit 31354 "Issue Payment Order YesNo CZB"
{
    TableNo = "Payment Order Header CZB";

    trigger OnRun()
    begin
        PaymentOrderHeaderCZB.Copy(Rec);
        Code();
        Rec := PaymentOrderHeaderCZB;
    end;

    var
        PaymentOrderHeaderCZB: Record "Payment Order Header CZB";
        IssueQst: Label '&Issue,Issue and &Export';

    local procedure Code()
    var
        IssPaymentOrderHeaderCZB: Record "Iss. Payment Order Header CZB";
        Selection: Integer;
        SuppressCommit: Boolean;
    begin
        Selection := StrMenu(IssueQst, 1);
        if Selection = 0 then
            exit;

        Codeunit.Run(Codeunit::"Issue Payment Order CZB", PaymentOrderHeaderCZB);
        OnCodeOnBeforeCommit(PaymentOrderHeaderCZB, SuppressCommit);
        if not SuppressCommit then
            Commit();

        if Selection = 2 then begin
            IssPaymentOrderHeaderCZB.Get(PaymentOrderHeaderCZB."Last Issuing No.");
            IssPaymentOrderHeaderCZB.SetRecFilter();
            IssPaymentOrderHeaderCZB.ExportPaymentOrder();
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCodeOnBeforeCommit(PaymentOrderHeaderCZB: Record "Payment Order Header CZB"; var SuppressCommit: Boolean)
    begin
    end;
}
