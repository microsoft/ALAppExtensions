// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Sales;

using Microsoft.Finance.TaxBase;
using Microsoft.Sales.Document;
using Microsoft.Utilities;

codeunit 18142 "GST Sales Posting No. Series"
{
    var
        PostingNoSeries: Record "Posting No. Series";

    //No Series for Sales 
    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterInsertEvent(var Rec: Record "Sales Header")
    var
        Record: Variant;
    begin
        if not Rec.IsTemporary() then begin
            Record := Rec;
            PostingNoSeries.GetPostingNoSeriesCode(Record);
            Rec := Record;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Sell-to Customer No.', false, false)]
    local procedure SelltoCustomer(var Rec: Record "Sales Header")
    var
        Record: Variant;
    begin
        Record := Rec;
        PostingNoSeries.GetPostingNoSeriesCode(Record);
        Rec := Record;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Bill-to Customer no.', false, false)]
    local procedure BilltoCustomer(var Rec: Record "Sales Header")
    var
        Record: Variant;
    begin
        Record := Rec;
        PostingNoSeries.GetPostingNoSeriesCode(Record);
        Rec := Record;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Sell-to Contact No.', false, false)]
    local procedure SelltoContact(var Rec: Record "Sales Header")
    var
        Record: Variant;
    begin
        Record := Rec;
        PostingNoSeries.GetPostingNoSeriesCode(Record);
        Rec := Record;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Sell-to Customer Templ. Code', false, false)]
    local procedure SelltoCustomerTemplateCode(var Rec: Record "Sales Header")
    var
        Record: Variant;
    begin
        Record := Rec;
        PostingNoSeries.GetPostingNoSeriesCode(Record);
        Rec := Record;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Bill-to Contact No.', false, false)]
    local procedure BilltoContact(var Rec: Record "Sales Header")
    var
        Record: Variant;
    begin
        Record := Rec;
        PostingNoSeries.GetPostingNoSeriesCode(Record);
        Rec := Record;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Bill-to Customer Templ. Code', false, false)]
    local procedure BilltoCustomerTemplateCode(var Rec: Record "Sales Header")
    var
        Record: Variant;
    begin
        Record := Rec;
        PostingNoSeries.GetPostingNoSeriesCode(Record);
        Rec := Record;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Trading', false, false)]
    local procedure Trading(var Rec: Record "Sales Header")
    var
        Record: Variant;
    begin
        Record := Rec;
        PostingNoSeries.GetPostingNoSeriesCode(Record);
        Rec := Record;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeValidateEvent', 'Location Code', false, false)]
    local procedure Location(var Rec: Record "Sales Header")
    var
        Record: Variant;
    begin
        Record := Rec;
        PostingNoSeries.GetPostingNoSeriesCode(Record);
        Rec := Record;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Invoice Type', false, false)]
    local procedure PurchaseInvoiceType(var Rec: Record "Sales Header")
    var
        Record: Variant;
    begin
        Record := Rec;
        PostingNoSeries.GetPostingNoSeriesCode(Record);
        Rec := Record;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Shortcut Dimension 1 Code', false, false)]
    local procedure DepartmentCode(var Rec: Record "Sales Header")
    var
        Record: Variant;
    begin
        Record := Rec;
        PostingNoSeries.GetPostingNoSeriesCode(Record);
        Rec := Record;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnAfterCopyFieldsFromOldSalesHeader', '', false, false)]
    local procedure OnAfterCopyFieldsFromOldSalesHeader(var ToSalesHeader: Record "Sales Header")
    var
        Record: Variant;
    begin
        Record := ToSalesHeader;
        PostingNoSeries.GetPostingNoSeriesCode(Record);
        ToSalesHeader := Record;
    end;
}
