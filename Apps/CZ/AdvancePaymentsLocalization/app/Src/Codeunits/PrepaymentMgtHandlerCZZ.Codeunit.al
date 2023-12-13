// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.ReceivablesPayables;
using Microsoft.Purchases.Document;
using Microsoft.Sales.Document;

codeunit 148111 "Prepayment Mgt. Handler CZZ"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Prepayment Mgt.", 'OnBeforeTestSalesPrepayment', '', false, false)]
    local procedure SkipOnBeforeTestSalesPrepayment(SalesHeader: Record "Sales Header"; var TestResult: Boolean; var IsHandled: Boolean)
    begin
        if IsHandled then
            exit;

        TestResult := false;
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Prepayment Mgt.", 'OnBeforeTestPurchPrepayment', '', false, false)]
    local procedure SkipOnBeforeTestPurchPrepayment(PurchHeader: Record "Purchase Header"; var TestResult: Boolean; var IsHandled: Boolean)
    begin
        if IsHandled then
            exit;

        TestResult := false;
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Prepayment Mgt.", 'OnBeforeTestSalesPayment', '', false, false)]
    local procedure SkipOnBeforeTestSalesPayment(SalesHeader: Record "Sales Header"; var Result: Boolean; var IsHandled: Boolean)
    begin
        if IsHandled then
            exit;

        Result := false;
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Prepayment Mgt.", 'OnBeforeTestPurchasePayment', '', false, false)]
    local procedure SkipOnBeforeTestPurchasePayment(PurchaseHeader: Record "Purchase Header"; var Result: Boolean; var IsHandled: Boolean)
    begin
        if IsHandled then
            exit;

        Result := false;
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Prepayment Mgt.", 'OnBeforeTestSalesOrderLineForGetShptLines', '', false, false)]
    local procedure SkipOnBeforeTestSalesOrderLineForGetShptLines(var IsHandled: Boolean)
    begin
        if IsHandled then
            exit;

        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Prepayment Mgt.", 'OnBeforeTestPurchaseOrderLineForGetRcptLines', '', false, false)]
    local procedure SkipOnBeforeTestPurchaseOrderLineForGetRcptLines(var IsHandled: Boolean)
    begin
        if IsHandled then
            exit;

        IsHandled := true;
    end;
}
