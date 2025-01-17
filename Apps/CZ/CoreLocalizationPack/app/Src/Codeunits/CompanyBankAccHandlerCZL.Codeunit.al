// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank;

using Microsoft.Purchases.Document;
using Microsoft.Sales.Document;
using Microsoft.Sales.FinanceCharge;
using Microsoft.Sales.History;
using Microsoft.Sales.Receivables;
using Microsoft.Sales.Reminder;
using Microsoft.Service.Document;
using Microsoft.Service.History;

codeunit 31447 "Company Bank Acc. Handler CZL"
{
    #region unposted documents
    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Company Bank Account Code', false, false)]
    local procedure SalesUpdateBankAccountCodeCZLOnAfterValidateCompanyBankAccountCode(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsCreditDocType() then
            exit;

        if (CurrFieldNo = Rec.FieldNo("Company Bank Account Code")) and
           (Rec."Company Bank Account Code" <> xRec."Company Bank Account Code")
        then
            Rec.Validate("Bank Account Code CZL", Rec."Company Bank Account Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Currency Code', false, false)]
    local procedure SalesUpdateBankAccountCodeCZLOnAfterSetCompanyBankAccount(var Rec: Record "Sales Header"; var xRec: Record "Sales Header")
    begin
        if Rec.IsCreditDocType() then
            exit;

        if Rec."Currency Code" <> xRec."Currency Code" then
            Rec.Validate("Bank Account Code CZL", Rec.GetDefaulBankAccountNoCZL());
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Responsibility Center', false, false)]
    local procedure SalesUpdateBankAccountCodeCZLOnAfterValidateEventResponsibilityCenter(var Rec: Record "Sales Header"; var xRec: Record "Sales Header")
    begin
        if Rec.IsCreditDocType() then
            exit;
        if (Rec."Currency Code" <> '') and
           (Rec."Bank Account Code CZL" <> '')
        then
            exit;

        if Rec."Responsibility Center" <> xRec."Responsibility Center" then
            Rec.Validate("Bank Account Code CZL", Rec.GetDefaulBankAccountNoCZL());
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterValidateEvent', 'Currency Code', false, false)]
    local procedure PurchaseUpdateBankAccountCodeCZLOnAfterSetCompanyBankAccount(var Rec: Record "Purchase Header"; var xRec: Record "Purchase Header")
    begin
        if not Rec.IsCreditDocType() then
            exit;

        if Rec."Currency Code" <> xRec."Currency Code" then
            Rec.Validate("Bank Account Code CZL", Rec.GetDefaulBankAccountNoCZL());
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterValidateEvent', 'Responsibility Center', false, false)]
    local procedure PurchaseUpdateBankAccountCodeCZLOnAfterValidateEventResponsibilityCenter(var Rec: Record "Purchase Header"; var xRec: Record "Purchase Header")
    begin
        if not Rec.IsCreditDocType() then
            exit;
        if (Rec."Currency Code" <> '') and
           (Rec."Bank Account Code CZL" <> '')
        then
            exit;

        if Rec."Responsibility Center" <> xRec."Responsibility Center" then
            Rec.Validate("Bank Account Code CZL", Rec.GetDefaulBankAccountNoCZL());
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnAfterValidateEvent', 'Company Bank Account Code', false, false)]
    local procedure ServiceUpdateBankAccountCodeCZLOnAfterValidateCompanyBankAccountCode(var Rec: Record "Service Header"; var xRec: Record "Service Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsCreditDocType() then
            exit;

        if (CurrFieldNo = Rec.FieldNo("Company Bank Account Code")) and
           (Rec."Company Bank Account Code" <> xRec."Company Bank Account Code")
        then
            Rec.Validate("Bank Account Code CZL", Rec."Company Bank Account Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnAfterValidateEvent', 'Currency Code', false, false)]
    local procedure ServiceUpdateBankAccountCodeCZLOnAfterSetCompanyBankAccount(var Rec: Record "Service Header"; var xRec: Record "Service Header")
    begin
        if Rec.IsCreditDocType() then
            exit;

        if Rec."Currency Code" <> xRec."Currency Code" then
            Rec.Validate("Bank Account Code CZL", Rec.GetDefaulBankAccountNoCZL());
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnAfterValidateEvent', 'Responsibility Center', false, false)]
    local procedure ServiceUpdateBankAccountCodeCZLOnAfterValidateEventResponsibilityCenter(var Rec: Record "Service Header"; var xRec: Record "Service Header")
    begin
        if Rec.IsCreditDocType() then
            exit;
        if (Rec."Currency Code" <> '') and
           (Rec."Bank Account Code CZL" <> '')
        then
            exit;

        if Rec."Responsibility Center" <> xRec."Responsibility Center" then
            Rec.Validate("Bank Account Code CZL", Rec.GetDefaulBankAccountNoCZL());
    end;

    [EventSubscriber(ObjectType::Table, Database::"Reminder Header", 'OnAfterValidateEvent', 'Company Bank Account Code', false, false)]
    local procedure ReminderUpdateBankAccountCodeCZLOnAfterValidateCompanyBankAccountCode(var Rec: Record "Reminder Header")
    begin
        Rec.Validate("Bank Account Code CZL", Rec."Company Bank Account Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Finance Charge Memo Header", 'OnAfterValidateEvent', 'Company Bank Account Code', false, false)]
    local procedure FinanceChargeMemoUpdateBankAccountCodeCZLOnAfterValidateCompanyBankAccountCode(var Rec: Record "Finance Charge Memo Header")
    begin
        Rec.Validate("Bank Account Code CZL", Rec."Company Bank Account Code");
    end;
    #endregion unposted documents

    #region update posted documents
    [EventSubscriber(ObjectType::Page, Page::"Posted Sales Inv. - Update", 'OnAfterRecordChanged', '', false, false)]
    local procedure SalesInvoiceChangedOnAfterRecordChanged(var SalesInvoiceHeader: Record "Sales Invoice Header"; xSalesInvoiceHeader: Record "Sales Invoice Header"; var IsChanged: Boolean)
    begin
        IsChanged := IsChanged or
          (SalesInvoiceHeader."Specific Symbol CZL" <> xSalesInvoiceHeader."Specific Symbol CZL") or
          (SalesInvoiceHeader."Variable Symbol CZL" <> xSalesInvoiceHeader."Variable Symbol CZL") or
          (SalesInvoiceHeader."Constant Symbol CZL" <> xSalesInvoiceHeader."Constant Symbol CZL");
    end;

    [EventSubscriber(ObjectType::Page, Page::"Posted Service Inv. - Update", 'OnAfterRecordChanged', '', false, false)]
    local procedure ServiceInvoiceChangedOnAfterRecordChanged(var ServiceInvoiceHeader: Record "Service Invoice Header"; xServiceInvoiceHeader: Record "Service Invoice Header"; var IsChanged: Boolean)
    begin
        IsChanged := IsChanged or
          (ServiceInvoiceHeader."Specific Symbol CZL" <> xServiceInvoiceHeader."Specific Symbol CZL") or
          (ServiceInvoiceHeader."Variable Symbol CZL" <> xServiceInvoiceHeader."Variable Symbol CZL") or
          (ServiceInvoiceHeader."Constant Symbol CZL" <> xServiceInvoiceHeader."Constant Symbol CZL");
    end;
    #endregion update posted documents

    #region edit posted documents
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Inv. Header - Edit", 'OnOnRunOnBeforeTestFieldNo', '', false, false)]
    local procedure SalesInvoiceEditOnRunOnBeforeTestFieldNo(var SalesInvoiceHeader: Record "Sales Invoice Header"; SalesInvoiceHeaderRec: Record "Sales Invoice Header")
    begin
        SalesInvoiceHeader.Validate("Specific Symbol CZL", SalesInvoiceHeaderRec."Specific Symbol CZL");
        SalesInvoiceHeader.Validate("Variable Symbol CZL", SalesInvoiceHeaderRec."Variable Symbol CZL");
        SalesInvoiceHeader.Validate("Constant Symbol CZL", SalesInvoiceHeaderRec."Constant Symbol CZL");
        CustLedgerEntryEdit(SalesInvoiceHeader."No.", SalesInvoiceHeader."Bill-to Customer No.",
          SalesInvoiceHeader."Bank Account Code CZL", SalesInvoiceHeader."Specific Symbol CZL", SalesInvoiceHeader."Variable Symbol CZL", SalesInvoiceHeader."Constant Symbol CZL");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Inv. Header - Edit", 'OnRunOnBeforeAssignValues', '', false, false)]
    local procedure SalesInvoiceEditOnRunOnBeforeAssignValues(var SalesInvoiceHeader: Record "Sales Invoice Header"; SalesInvoiceHeaderRec: Record "Sales Invoice Header")
    begin
        if SalesInvoiceHeader."Company Bank Account Code" <> SalesInvoiceHeaderRec."Company Bank Account Code" then
            SalesInvoiceHeader.Validate("Bank Account Code CZL", SalesInvoiceHeaderRec."Company Bank Account Code");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Service Inv. Header - Edit", 'OnOnRunOnBeforeTestFieldNo', '', false, false)]
    local procedure ServiceInvoiceEditOnRunOnBeforeTestFieldNo(var ServiceInvoiceHeader: Record "Service Invoice Header"; ServiceInvoiceHeaderRec: Record "Service Invoice Header")
    begin
        ServiceInvoiceHeader.Validate("Specific Symbol CZL", ServiceInvoiceHeaderRec."Specific Symbol CZL");
        ServiceInvoiceHeader.Validate("Variable Symbol CZL", ServiceInvoiceHeaderRec."Variable Symbol CZL");
        ServiceInvoiceHeader.Validate("Constant Symbol CZL", ServiceInvoiceHeaderRec."Constant Symbol CZL");
        CustLedgerEntryEdit(ServiceInvoiceHeader."No.", ServiceInvoiceHeader."Bill-to Customer No.",
          ServiceInvoiceHeader."Bank Account Code CZL", ServiceInvoiceHeader."Specific Symbol CZL", ServiceInvoiceHeader."Variable Symbol CZL", ServiceInvoiceHeader."Constant Symbol CZL");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Service Inv. Header - Edit", 'OnRunOnBeforeAssignNewValues', '', false, false)]
    local procedure ServiceInvoiceEditOnRunOnBeforeAssignNewValues(var ServiceInvoiceHeader: Record "Service Invoice Header"; ServiceInvoiceHeaderRec: Record "Service Invoice Header")
    begin
        if ServiceInvoiceHeader."Company Bank Account Code" <> ServiceInvoiceHeaderRec."Company Bank Account Code" then
            ServiceInvoiceHeader.Validate("Bank Account Code CZL", ServiceInvoiceHeaderRec."Company Bank Account Code");
    end;

    local procedure CustLedgerEntryEdit(DocumentNo: Code[20]; CustomerNo: Code[20]; BankAccountCodeCZL: Code[20]; SpecificSymbolCZL: Code[10]; VariableSymbolCZL: Code[10]; ConstantSymbolCZL: Code[10])
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.SetCurrentKey("Document No.");
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
        CustLedgerEntry.SetRange("Document No.", DocumentNo);
        CustLedgerEntry.SetRange("Customer No.", CustomerNo);
        if CustLedgerEntry.FindFirst() then begin
            CustLedgerEntry.Validate("Bank Account Code CZL", BankAccountCodeCZL);
            CustLedgerEntry.Validate("Specific Symbol CZL", SpecificSymbolCZL);
            CustLedgerEntry.Validate("Variable Symbol CZL", VariableSymbolCZL);
            CustLedgerEntry.Validate("Constant Symbol CZL", ConstantSymbolCZL);
            Codeunit.Run(Codeunit::"Cust. Entry-Edit", CustLedgerEntry);
        end;
    end;
    #endregion edit posted documents
}
