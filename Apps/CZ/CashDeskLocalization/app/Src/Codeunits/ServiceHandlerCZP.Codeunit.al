// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using Microsoft.Bank.BankAccount;
using Microsoft.Service.Document;
using Microsoft.Service.History;
using Microsoft.Service.Posting;

codeunit 11738 "Service Handler CZP"
{
    var
        CashDeskManagementCZP: Codeunit "Cash Desk Management CZP";

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnAfterValidateEvent', 'Payment Method Code', false, false)]
    local procedure UpdateCashDeskOnAfterPaymentMethodValidate(var Rec: Record "Service Header")
    var
        PaymentMethod: Record "Payment Method";
    begin
        if Rec.IsTemporary() then
            exit;
        if Rec."Payment Method Code" = '' then
            Rec.Validate("Cash Desk Code CZP", '')
        else begin
            PaymentMethod.Get(Rec."Payment Method Code");
            Rec.Validate("Cash Desk Code CZP", PaymentMethod."Cash Desk Code CZP");
            Rec.Validate("Cash Document Action CZP", PaymentMethod."Cash Document Action CZP");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Service-Post", 'OnAfterInitialize', '', false, false)]
    local procedure CheckCashDocumentActionOnAfterInitialize(var ServiceHeader: Record "Service Header")
    begin
        if ServiceHeader."Cash Document Action CZP".AsInteger() > ServiceHeader."Cash Document Action CZP"::" ".AsInteger() then
            CashDeskManagementCZP.CheckUserRights(ServiceHeader."Cash Desk Code CZP", ServiceHeader."Cash Document Action CZP"::Create);
        if (ServiceHeader."Cash Document Action CZP" = ServiceHeader."Cash Document Action CZP"::Release) or
           (ServiceHeader."Cash Document Action CZP" = ServiceHeader."Cash Document Action CZP"::"Release and Print")
        then
            CashDeskManagementCZP.CheckUserRights(ServiceHeader."Cash Desk Code CZP", ServiceHeader."Cash Document Action CZP");
        if (ServiceHeader."Cash Document Action CZP" = ServiceHeader."Cash Document Action CZP"::Post) or
           (ServiceHeader."Cash Document Action CZP" = ServiceHeader."Cash Document Action CZP"::"Post and Print")
        then begin
            CashDeskManagementCZP.CheckUserRights(ServiceHeader."Cash Desk Code CZP", ServiceHeader."Cash Document Action CZP"::Release);
            CashDeskManagementCZP.CheckUserRights(ServiceHeader."Cash Desk Code CZP", ServiceHeader."Cash Document Action CZP");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Service-Post", 'OnAfterPostServiceDoc', '', false, false)]
    local procedure CreateCashDocumentOnAfterPostServiceDoc(var ServiceHeader: Record "Service Header"; ServInvoiceNo: Code[20]; ServCrMemoNo: Code[20])
    var
        ServiceInvoiceHeader: Record "Service Invoice Header";
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
    begin
        if ServiceHeader."Cash Desk Code CZP" = '' then
            exit;

        if ServiceHeader."Document Type" in [ServiceHeader."Document Type"::Order, ServiceHeader."Document Type"::Invoice] then begin
            ServiceInvoiceHeader.Get(ServInvoiceNo);
            CashDeskManagementCZP.CreateCashDocumentFromServiceInvoice(ServiceInvoiceHeader);
        end else begin
            ServiceCrMemoHeader.Get(ServCrMemoNo);
            CashDeskManagementCZP.CreateCashDocumentFromServiceCrMemo(ServiceCrMemoHeader);
        end;
    end;
}
