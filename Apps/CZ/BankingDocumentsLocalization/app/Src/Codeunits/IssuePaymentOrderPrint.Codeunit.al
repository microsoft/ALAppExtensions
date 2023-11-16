// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

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
        IssueQst: Label '&Issue,Issue and &Export';
        IssuedSuccesfullyMsg: Label 'Payment Order was successfully issued.';

    local procedure Code()
    var
        IssPaymentOrderHeaderCZB: Record "Iss. Payment Order Header CZB";
        Selection: Integer;
    begin
        Selection := StrMenu(IssueQst, 1);
        if Selection = 0 then
            exit;

        Codeunit.Run(Codeunit::"Issue Payment Order CZB", PaymentOrderHeaderCZB);
        Commit();
        Message(IssuedSuccesfullyMsg);

        IssPaymentOrderHeaderCZB.Get(PaymentOrderHeaderCZB."Last Issuing No.");
        IssPaymentOrderHeaderCZB.SetRecFilter();
        if Selection = 2 then
            IssPaymentOrderHeaderCZB.ExportPaymentOrder();
        IssPaymentOrderHeaderCZB.PrintRecords(false);
    end;
}
