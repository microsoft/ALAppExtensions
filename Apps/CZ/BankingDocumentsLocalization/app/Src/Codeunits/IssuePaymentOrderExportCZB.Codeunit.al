// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

codeunit 31231 "Issue Payment Order Export CZB"
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

    local procedure Code()
    var
        IssPaymentOrderHeaderCZB: Record "Iss. Payment Order Header CZB";
        SuppressCommit: Boolean;
    begin
        Codeunit.Run(Codeunit::"Issue Payment Order CZB", PaymentOrderHeaderCZB);
        OnCodeOnBeforeCommit(PaymentOrderHeaderCZB, SuppressCommit);
        if not SuppressCommit then
            Commit();

        IssPaymentOrderHeaderCZB.Get(PaymentOrderHeaderCZB."Last Issuing No.");
        IssPaymentOrderHeaderCZB.SetRecFilter();
        IssPaymentOrderHeaderCZB.ExportPaymentOrder();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCodeOnBeforeCommit(PaymentOrderHeaderCZB: Record "Payment Order Header CZB"; var SuppressCommit: Boolean)
    begin
    end;
}

