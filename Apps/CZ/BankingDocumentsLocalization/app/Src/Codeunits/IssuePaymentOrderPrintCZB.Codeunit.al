// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using System.Utilities;

codeunit 31355 "Issue Payment Order Print CZB"
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
        ConfirmManagement: Codeunit "Confirm Management";
        IssueAndPrintPaymentOrderQst: Label 'Do you want to issue and print the Payment Order?';
        IssuedSuccesfullyMsg: Label 'Payment Order was successfully issued.';

    local procedure Code()
    var
        IssPaymentOrderHeaderCZB: Record "Iss. Payment Order Header CZB";
        SuppressCommit: Boolean;
    begin
        if not ConfirmManagement.GetResponseOrDefault(IssueAndPrintPaymentOrderQst, true) then
            exit;

        Codeunit.Run(Codeunit::"Issue Payment Order CZB", PaymentOrderHeaderCZB);
        OnCodeOnBeforeCommit(PaymentOrderHeaderCZB, SuppressCommit);
        if not SuppressCommit then
            Commit();
        Message(IssuedSuccesfullyMsg);

        IssPaymentOrderHeaderCZB.Get(PaymentOrderHeaderCZB."Last Issuing No.");
        IssPaymentOrderHeaderCZB.SetRecFilter();
        IssPaymentOrderHeaderCZB.PrintRecords(false);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCodeOnBeforeCommit(PaymentOrderHeaderCZB: Record "Payment Order Header CZB"; var SuppressCommit: Boolean)
    begin
    end;
}
