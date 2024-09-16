namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Utilities;

codeunit 8074 "Document Change Management"
{
    Access = Internal;
    SingleInstance = true;

    var
        HeaderCannotBeChangedErr: Label 'You cannot make this change because the document is linked to a contract. If you still want to change the field, first delete this document and then make the change to the contract.';
        HeaderDimCannotBeChangedErr: Label 'You cannot change the dimensions because the document %1 %2 is linked to a contract. If you still want to change the dimensions, first delete this document and then change the dimensions on the contract.', Comment = '%1 = Document Type, %2 = Document No.';
        LineCannotBeChangedErr: Label 'You cannot make this change because the line is linked to contract %1. If you still want to change the field, first delete this document or document line and then make the change to the corresponding contract line.', Comment = '%1 = Contract No.';
        LineDimCannotBeChangedErr: Label 'You cannot change the dimensions because the line %2 %3 %4 is linked to contract %1. If you still want to change the dimensions, first delete this document or document line and then change the dimensions on the corresponding contract line.', Comment = '%1 = Contract No., %2 = Document Type, %3 = Document No., %4 = Line No.';

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnBeforeValidateEvent, "Sell-to Customer No.", false, false)]
    local procedure PreventSelltoCustomerNo(var Rec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnBeforeValidateEvent, "Bill-to Customer No.", false, false)]
    local procedure PreventChangeSalesHdrBilltoCustomerNo(var Rec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnBeforeValidateEvent, "Customer Posting Group", false, false)]
    local procedure SalesHeaderOnBeforeValidateSCustomerPostingGroup(var Rec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnBeforeValidateEvent, "Gen. Bus. Posting Group", false, false)]
    local procedure SalesHeaderOnBeforeValidateGenBusPostingGroup(var Rec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnBeforeValidateEvent, "VAT Bus. Posting Group", false, false)]
    local procedure SalesHeaderOnBeforeValidateVATBusPostingGroup(var Rec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnBeforeValidateEvent, "Bill-to Name", false, false)]
    local procedure PreventChangeSalesHdrBilltoName(var Rec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnBeforeValidateEvent, "Bill-to Name 2", false, false)]
    local procedure PreventChangeSalesHdrBilltoName2(var Rec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnBeforeValidateEvent, "Bill-to Address", false, false)]
    local procedure PreventChangeSalesHdrBilltoAddress(var Rec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnBeforeValidateEvent, "Bill-to Address 2", false, false)]
    local procedure PreventChangeSalesHdrBilltoAddress2(var Rec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnBeforeValidateEvent, "Bill-to City", false, false)]
    local procedure PreventChangeSalesHdrBilltoCity(var Rec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnBeforeValidateEvent, "Bill-to Contact", false, false)]
    local procedure PreventChangeSalesHdrBilltoContact(var Rec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnBeforeValidateEvent, "Ship-to Code", false, false)]
    local procedure PreventChangeSalesHdrShiptoCode(var Rec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnBeforeValidateEvent, "Ship-to Name", false, false)]
    local procedure PreventChangeSalesHdrShiptoName(var Rec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnBeforeValidateEvent, "Ship-to Name 2", false, false)]
    local procedure PreventChangeSalesHdrShiptoName2(var Rec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnBeforeValidateEvent, "Ship-to Address", false, false)]
    local procedure PreventChangeSalesHdrShiptoAddress(var Rec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnBeforeValidateEvent, "Ship-to Address 2", false, false)]
    local procedure PreventChangeSalesHdrShiptoAddress2(var Rec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnBeforeValidateEvent, "Ship-to City", false, false)]
    local procedure PreventChangeSalesHdrShiptoCity(var Rec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnBeforeValidateEvent, "Ship-to Contact", false, false)]
    local procedure PreventChangeSalesHdrShiptoContact(var Rec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnBeforeValidateEvent, "Shortcut Dimension 1 Code", false, false)]
    local procedure PreventChangeSalesHdrShortcutDimension1Code(var Rec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnBeforeValidateEvent, "Shortcut Dimension 2 Code", false, false)]
    local procedure PreventChangeSalesHdrShortcutDimension2Code(var Rec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnBeforeValidateEvent, "Currency Code", false, false)]
    local procedure PreventChangeSalesHdrCurrencyCode(var Rec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnBeforeValidateEvent, "Prices Including VAT", false, false)]
    local procedure PreventChangeSalesHdrPricesIncludingVAT(var Rec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnBeforeValidateEvent, "EU 3-Party Trade", false, false)]
    local procedure PreventChangeSalesHdrEU3PartyTrade(var Rec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnBeforeValidateEvent, "Transaction Type", false, false)]
    local procedure PreventChangeSalesHdrTransactionType(var Rec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnBeforeValidateEvent, "Transport Method", false, false)]
    local procedure PreventChangeSalesHdrTransportMethod(var Rec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnBeforeValidateEvent, "Sell-to Customer Name", false, false)]
    local procedure PreventChangeSalesHdrSelltoCustomerName(var Rec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnBeforeValidateEvent, "Sell-to Customer Name 2", false, false)]
    local procedure PreventChangeSalesHdrSelltoCustomerName2(var Rec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnBeforeValidateEvent, "Sell-to Address", false, false)]
    local procedure PreventChangeSalesHdrSelltoAddress(var Rec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnBeforeValidateEvent, "Sell-to Address 2", false, false)]
    local procedure PreventChangeSalesHdrSelltoAddress2(var Rec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnBeforeValidateEvent, "Sell-to City", false, false)]
    local procedure PreventChangeSalesHdrSelltoCity(var Rec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnBeforeValidateEvent, "Sell-to Contact", false, false)]
    local procedure PreventChangeSalesHdrSelltoContact(var Rec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnBeforeValidateEvent, "Bill-to Post Code", false, false)]
    local procedure PreventChangeSalesHdrBilltoPostCode(var Rec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnBeforeValidateEvent, "Bill-to County", false, false)]
    local procedure PreventChangeSalesHdrBilltoCounty(var Rec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnBeforeValidateEvent, "Bill-to Country/Region Code", false, false)]
    local procedure PreventChangeSalesHdrBilltoCountryRegionCode(var Rec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnBeforeValidateEvent, "Sell-to Post Code", false, false)]
    local procedure PreventChangeSalesHdrSelltoPostCode(var Rec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnBeforeValidateEvent, "Sell-to County", false, false)]
    local procedure PreventChangeSalesHdrSelltoCounty(var Rec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnBeforeValidateEvent, "Sell-to Country/Region Code", false, false)]
    local procedure PreventChangeSalesHdrSelltoCountryRegionCode(var Rec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnBeforeValidateEvent, "Ship-to Post Code", false, false)]
    local procedure PreventChangeSalesHdrShiptoPostCode(var Rec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnBeforeValidateEvent, "Ship-to County", false, false)]
    local procedure PreventChangeSalesHdrShiptoCounty(var Rec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnBeforeValidateEvent, "Ship-to Country/Region Code", false, false)]
    local procedure PreventChangeSalesHdrShiptoCountryRegionCode(var Rec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnBeforeValidateEvent, "VAT Bus. Posting Group", false, false)]
    local procedure PreventChangeSalesHdrVATBusPostingGroup(var Rec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnBeforeValidateEvent, "Dimension Set ID", false, false)]
    local procedure PreventChangeSalesHdrDimensionSetD(var Rec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnBeforeValidateEvent, "Sell-to Customer Templ. Code", false, false)]
    local procedure PreventChangeSalesHdrSelltoCustomerTemplateCode(var Rec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnBeforeValidateEvent, "Sell-to Contact No.", false, false)]
    local procedure PreventChangeSalesHdrSelltoContactNo(var Rec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnBeforeValidateEvent, "Bill-to Contact No.", false, false)]
    local procedure PreventChangeSalesHdrBilltoContactNo(var Rec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnBeforeValidateEvent, "Bill-to Customer Templ. Code", false, false)]
    local procedure PreventChangeSalesHdrBilltoCustomerTemplateCode(var Rec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", OnBeforeCopySalesDocument, '', false, false)]
    local procedure SetSkipContractSalesHeaderCheckOnBeforeCopySalesDocument(FromDocumentType: Option; FromDocumentNo: Code[20])
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SessionStore: Codeunit "Session Store";
    begin
        if FromDocumentType = "Sales Document Type From"::"Posted Invoice".AsInteger() then
            if SalesInvoiceHeader.Get(FromDocumentNo) then
                if SalesInvoiceHeader."Recurring Billing" then
                    SessionStore.SetBooleanKey('SkipContractSalesHeaderModifyCheck', true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", OnAfterCopySalesDocument, '', false, false)]
    local procedure RemoveSkipContractSalesHeaderCheckOnBeforeCopySalesDocument(var ToSalesHeader: Record "Sales Header")
    var
        SessionStore: Codeunit "Session Store";
    begin
        if ToSalesHeader."Recurring Billing" then
            SessionStore.RemoveBooleanKey('SkipContractSalesHeaderModifyCheck');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnBeforeModifyEvent, '', false, false)]
    local procedure PreventChangeSalesHeader(var Rec: Record "Sales Header")
    var
        xSalesHeader: Record "Sales Header";
        SessionStore: Codeunit "Session Store";
        ContractRenewalMgt: Codeunit "Contract Renewal Mgt.";
    begin
        if Rec.IsTemporary() then
            exit;

        if not Rec."Recurring Billing" then
            if not ContractRenewalMgt.IsContractRenewal(Rec) then
                exit;

        if SessionStore.GetBooleanKey('SkipContractSalesHeaderModifyCheck') then
            exit;

        xSalesHeader.Get(Rec."Document Type", Rec."No.");
        if ((Rec."Shortcut Dimension 1 Code" <> xSalesHeader."Shortcut Dimension 1 Code") or
            (Rec."Shortcut Dimension 2 Code" <> xSalesHeader."Shortcut Dimension 2 Code") or
            (Rec."Dimension Set ID" <> xSalesHeader."Dimension Set ID"))
        then
            Error(HeaderDimCannotBeChangedErr, Rec."Document Type", Rec."No.");

        if ((Rec."Sell-to Customer No." <> xSalesHeader."Sell-to Customer No.") or
            (Rec."Sell-to Address" <> xSalesHeader."Sell-to Address") or
            (Rec."Sell-to Contact" <> xSalesHeader."Sell-to Contact") or
            (Rec."Sell-to Contact No." <> xSalesHeader."Sell-to Contact No.") or
            (Rec."Sell-to Customer Templ. Code" <> xSalesHeader."Sell-to Customer Templ. Code") or
            (Rec."Sell-to Customer Name" <> xSalesHeader."Sell-to Customer Name") or
            (Rec."Sell-to Customer Name 2" <> xSalesHeader."Sell-to Customer Name 2") or
            (Rec."Sell-to Address" <> xSalesHeader."Sell-to Address") or
            (Rec."Sell-to Address 2" <> xSalesHeader."Sell-to Address 2") or
            (Rec."Sell-to City" <> xSalesHeader."Sell-to City") or
            (Rec."Sell-to Country/Region Code" <> xSalesHeader."Sell-to Country/Region Code") or
            (Rec."Sell-to County" <> xSalesHeader."Sell-to County") or
            (Rec."Bill-to Customer No." <> xSalesHeader."Bill-to Customer No.") or
            (Rec."Bill-to Address" <> xSalesHeader."Bill-to Address") or
            (Rec."Bill-to Address 2" <> xSalesHeader."Bill-to Address 2") or
            (Rec."Bill-to City" <> xSalesHeader."Bill-to City") or
            (Rec."Bill-to Contact" <> xSalesHeader."Bill-to Contact") or
            (Rec."Bill-to Contact No." <> xSalesHeader."Bill-to Contact No.") or
            (Rec."Bill-to Country/Region Code" <> xSalesHeader."Bill-to Country/Region Code") or
            (Rec."Bill-to County" <> xSalesHeader."Bill-to County") or
            (Rec."Bill-to Name" <> xSalesHeader."Bill-to Name") or
            (Rec."Bill-to Name 2" <> xSalesHeader."Bill-to Name 2") or
            (Rec."Bill-to Customer Templ. Code" <> xSalesHeader."Bill-to Customer Templ. Code") or
            (Rec."Bill-to Name" <> xSalesHeader."Bill-to Name") or
            (Rec."Bill-to Name 2" <> xSalesHeader."Bill-to Name 2") or
            (Rec."Bill-to Address" <> xSalesHeader."Bill-to Address") or
            (Rec."Bill-to Address 2" <> xSalesHeader."Bill-to Address 2") or
            (Rec."Bill-to City" <> xSalesHeader."Bill-to City") or
            (Rec."Bill-to Country/Region Code" <> xSalesHeader."Bill-to Country/Region Code") or
            (Rec."Bill-to County" <> xSalesHeader."Bill-to County") or
            (Rec."Bill-to Post Code" <> xSalesHeader."Bill-to Post Code") or
            (Rec."Sell-to Post Code" <> xSalesHeader."Sell-to Post Code") or
            (Rec."Ship-to Address" <> xSalesHeader."Ship-to Address") or
            (Rec."Ship-to Address 2" <> xSalesHeader."Ship-to Address 2") or
            (Rec."Ship-to City" <> xSalesHeader."Ship-to City") or
            (Rec."Ship-to Contact" <> xSalesHeader."Ship-to Contact") or
            (Rec."Ship-to Country/Region Code" <> xSalesHeader."Ship-to Country/Region Code") or
            (Rec."Ship-to County" <> xSalesHeader."Ship-to County") or
            (Rec."Ship-to Post Code" <> xSalesHeader."Ship-to Post Code") or
            (Rec."Currency Code" <> xSalesHeader."Currency Code") or
            (Rec."Prices Including VAT" <> xSalesHeader."Prices Including VAT") or
            (Rec."VAT Bus. Posting Group" <> xSalesHeader."VAT Bus. Posting Group") or
            (Rec."EU 3-Party Trade" <> xSalesHeader."EU 3-Party Trade") or
            (Rec."Invoice Discount Amount" <> xSalesHeader."Invoice Discount Amount") or
             (Rec."Invoice Discount Value" <> xSalesHeader."Invoice Discount Value") or
            (Rec."Recurring Billing" <> xSalesHeader."Recurring Billing"))
        then
            Error(HeaderCannotBeChangedErr);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Invoice Subform", OnAfterValidateEvent, "Invoice Disc. Pct.", false, false)]
    local procedure PreventChangeSalesHeaderInvoiceDiscPct(var Rec: Record "Sales Line")
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.Get(Rec."Document Type", Rec."Document No.");
        if not SalesHeader."Recurring Billing" then
            exit;
        Error(HeaderCannotBeChangedErr);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Invoice Subform", OnAfterValidateEvent, "Invoice Discount Amount", false, false)]
    local procedure PreventChangeSalesHeaderInvoiceDiscAmount(var Rec: Record "Sales Line")
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.Get(Rec."Document Type", Rec."Document No.");
        if not SalesHeader."Recurring Billing" then
            exit;
        Error(HeaderCannotBeChangedErr);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Cr. Memo Subform", OnAfterValidateEvent, "Invoice Disc. Pct.", false, false)]
    local procedure PreventChangeSalesCrMemoInvoiceDiscPct(var Rec: Record "Sales Line")
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.Get(Rec."Document Type", Rec."Document No.");
        if not SalesHeader."Recurring Billing" then
            exit;
        Error(HeaderCannotBeChangedErr);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Cr. Memo Subform", OnAfterValidateEvent, "Invoice Discount Amount", false, false)]
    local procedure PreventChangeSalesCrMemoInvoiceDiscAmount(var Rec: Record "Sales Line")
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.Get(Rec."Document Type", Rec."Document No.");
        if not SalesHeader."Recurring Billing" then
            exit;
        Error(HeaderCannotBeChangedErr);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Quote Subform", OnAfterValidateEvent, "Invoice Disc. Pct.", false, false)]
    local procedure PreventChangeSalesQuoteInvoiceDiscPct(var Rec: Record "Sales Line")
    var
        ContractRenewalMgt: Codeunit "Contract Renewal Mgt.";
    begin
        if not ContractRenewalMgt.IsContractRenewal(Rec) then
            exit;
        Error(HeaderCannotBeChangedErr);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Quote Subform", OnAfterValidateEvent, "Invoice Discount Amount", false, false)]
    local procedure PreventChangeSalesQuoteInvoiceDiscAmount(var Rec: Record "Sales Line")
    var
        ContractRenewalMgt: Codeunit "Contract Renewal Mgt.";
    begin
        if not ContractRenewalMgt.IsContractRenewal(Rec) then
            exit;
        Error(HeaderCannotBeChangedErr);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purch. Invoice Subform", OnAfterValidateEvent, "Invoice Disc. Pct.", false, false)]
    local procedure PreventChangePurchHeaderInvoiceDiscPct(var Rec: Record "Purchase Line")
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        PurchaseHeader.Get(Rec."Document Type", Rec."Document No.");
        if not PurchaseHeader."Recurring Billing" then
            exit;
        Error(HeaderCannotBeChangedErr);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purch. Invoice Subform", OnAfterValidateEvent, InvoiceDiscountAmount, false, false)]
    local procedure PreventChangePurchHeaderInvoiceDiscAmount(var Rec: Record "Purchase Line")
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        PurchaseHeader.Get(Rec."Document Type", Rec."Document No.");
        if not PurchaseHeader."Recurring Billing" then
            exit;
        Error(HeaderCannotBeChangedErr);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purch. Cr. Memo Subform", OnAfterValidateEvent, "Invoice Disc. Pct.", false, false)]
    local procedure PreventChangePurchCrMemoInvoiceDiscPct(var Rec: Record "Purchase Line")
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        PurchaseHeader.Get(Rec."Document Type", Rec."Document No.");
        if not PurchaseHeader."Recurring Billing" then
            exit;
        Error(HeaderCannotBeChangedErr);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purch. Cr. Memo Subform", OnAfterValidateEvent, "Invoice Discount Amount", false, false)]
    local procedure PreventChangePurchCrMemoInvoiceDiscAmount(var Rec: Record "Purchase Line")
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        PurchaseHeader.Get(Rec."Document Type", Rec."Document No.");
        if not PurchaseHeader."Recurring Billing" then
            exit;
        Error(HeaderCannotBeChangedErr);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnBeforeModifyEvent, '', false, false)]
    local procedure PreventChangeOnSalesLine(var Rec: Record "Sales Line"; RunTrigger: Boolean)
    var
        xSalesLine: Record "Sales Line";
        BillingLine: Record "Billing Line";
    begin
        if Rec.IsTemporary() then
            exit;

        if not Rec.IsLineAttachedToBillingLine() then
            exit;
        if not RunTrigger then
            exit;

        xSalesLine.Get(Rec."Document Type", Rec."Document No.", Rec."Line No.");
        BillingLine.FilterBillingLineOnDocumentLine(BillingLine.GetBillingDocumentTypeFromSalesDocumentType(xSalesLine."Document Type"), xSalesLine."Document No.", xSalesLine."Line No.");
        BillingLine.FindFirst();

        if ((Rec."Shortcut Dimension 1 Code" <> xSalesLine."Shortcut Dimension 1 Code") or
            (Rec."Shortcut Dimension 2 Code" <> xSalesLine."Shortcut Dimension 2 Code") or
            (Rec."Dimension Set ID" <> xSalesLine."Dimension Set ID")) then
            Error(LineDimCannotBeChangedErr, BillingLine."Contract No.", Rec."Document Type", Rec."Document No.", Rec."Line No.");

        if ((Rec.Type <> xSalesLine.Type) or
            (Rec."No." <> xSalesLine."No.") or
            (Rec."Quantity" <> xSalesLine."Quantity") or
            (Rec."Unit of Measure Code" <> xSalesLine."Unit of Measure Code") or
            (Rec."Unit Price" <> xSalesLine."Unit Price") or
            (Rec.Amount <> xSalesLine.Amount) or
            (Rec."Amount Including VAT" <> xSalesLine."Amount Including VAT") or
            (Rec."Line Discount %" <> xSalesLine."Line Discount %") or
            (Rec."Line Discount Amount" <> xSalesLine."Line Discount Amount") or
            (Rec."Line Amount" <> xSalesLine."Line Amount") or
            (Rec."Recurring Billing to" <> xSalesLine."Recurring Billing to") or
            (Rec."Recurring Billing from" <> xSalesLine."Recurring Billing from"))
        then
            Error(LineCannotBeChangedErr, BillingLine."Contract No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnBeforeValidateEvent, "Shortcut Dimension 1 Code", false, false)]
    local procedure PreventChangeSalesLineShortcutDimension1Code(var Rec: Record "Sales Line"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnBeforeValidateEvent, "Shortcut Dimension 2 Code", false, false)]
    local procedure PreventChangeSalesLineShortcutDimension2Code(var Rec: Record "Sales Line"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnBeforeValidateEvent, Amount, false, false)]
    local procedure PreventChangeSalesLineAmount(var Rec: Record "Sales Line"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnBeforeValidateEvent, "Amount Including VAT", false, false)]
    local procedure PreventChangeSalesLineAmountIncludingVAT(var Rec: Record "Sales Line"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnBeforeValidateEvent, "Line Discount %", false, false)]
    local procedure PreventChangeSalesLineLineDiscount(var Rec: Record "Sales Line"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnBeforeValidateEvent, "Line Discount Amount", false, false)]
    local procedure PreventChangeSalesLineLineDiscountAmount(var Rec: Record "Sales Line"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnBeforeValidateEvent, "Line Amount", false, false)]
    local procedure PreventChangeSalesLineLineAmount(var Rec: Record "Sales Line"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnBeforeValidateEvent, Type, false, false)]
    local procedure PreventChangeSalesLineType(var Rec: Record "Sales Line")
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, Rec.FieldNo(Type));
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnBeforeValidateEvent, "No.", false, false)]
    local procedure PreventChangeSalesLineNo(var Rec: Record "Sales Line"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnBeforeValidateEvent, "Unit Price", false, false)]
    local procedure PreventChangeSalesLineUnitPrice(var Rec: Record "Sales Line"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnBeforeValidateEvent, "Unit of Measure Code", false, false)]
    local procedure PreventChangeSalesLineUnitofMeasureCode(var Rec: Record "Sales Line"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnBeforeValidateEvent, Quantity, false, false)]
    local procedure PreventChangeSalesLineQuantity(var Rec: Record "Sales Line"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnBeforeValidateEvent, "Recurring Billing from", false, false)]
    local procedure PreventChangeSalesLineRecurringBillingfrom(var Rec: Record "Sales Line"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnBeforeValidateEvent, "Recurring Billing to", false, false)]
    local procedure PreventChangeSalesLineRecurringBillingto(var Rec: Record "Sales Line"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", OnBeforeValidateEvent, "Buy-from Vendor No.", false, false)]
    local procedure PreventChangePurchHdrSelltoVendorNo(var Rec: Record "Purchase Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", OnBeforeValidateEvent, "Pay-to Vendor No.", false, false)]
    local procedure PreventChangePurchHdrBilltoVendorNo(var Rec: Record "Purchase Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", OnBeforeValidateEvent, "Pay-to Name", false, false)]
    local procedure PreventChangePurchHdrBilltoName(var Rec: Record "Purchase Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", OnBeforeValidateEvent, "Pay-to Name 2", false, false)]
    local procedure PreventChangePurchHdrBilltoName2(var Rec: Record "Purchase Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", OnBeforeValidateEvent, "Pay-to Address", false, false)]
    local procedure PreventChangePurchHdrBilltoAddress(var Rec: Record "Purchase Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", OnBeforeValidateEvent, "Pay-to Address 2", false, false)]
    local procedure PreventChangePurchHdrBilltoAddress2(var Rec: Record "Purchase Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", OnBeforeValidateEvent, "Pay-to City", false, false)]
    local procedure PreventChangePurchHdrBilltoCity(var Rec: Record "Purchase Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", OnBeforeValidateEvent, "Pay-to Contact", false, false)]
    local procedure PreventChangePurchHdrBilltoContact(var Rec: Record "Purchase Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", OnBeforeValidateEvent, "Ship-to Code", false, false)]
    local procedure PreventChangePurchHdrShiptoCode(var Rec: Record "Purchase Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", OnBeforeValidateEvent, "Ship-to Name", false, false)]
    local procedure PreventChangePurchHdrShiptoName(var Rec: Record "Purchase Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", OnBeforeValidateEvent, "Ship-to Name 2", false, false)]
    local procedure PreventChangePurchHdrShiptoName2(var Rec: Record "Purchase Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", OnBeforeValidateEvent, "Ship-to Address", false, false)]
    local procedure PreventChangePurchHdrShiptoAddress(var Rec: Record "Purchase Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", OnBeforeValidateEvent, "Ship-to Address 2", false, false)]
    local procedure PreventChangePurchHdrShiptoAddress2(var Rec: Record "Purchase Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", OnBeforeValidateEvent, "Ship-to City", false, false)]
    local procedure PreventChangePurchHdrShiptoCity(var Rec: Record "Purchase Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", OnBeforeValidateEvent, "Ship-to Contact", false, false)]
    local procedure PreventChangePurchHdrShiptoContact(var Rec: Record "Purchase Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", OnBeforeValidateEvent, "Shortcut Dimension 1 Code", false, false)]
    local procedure PreventChangePurchHdrShortcutDimension1Code(var Rec: Record "Purchase Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", OnBeforeValidateEvent, "Shortcut Dimension 2 Code", false, false)]
    local procedure PreventChangePurchHdrShortcutDimension2Code(var Rec: Record "Purchase Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", OnBeforeValidateEvent, "Currency Code", false, false)]
    local procedure PreventChangePurchHdrCurrencyCode(var Rec: Record "Purchase Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", OnBeforeValidateEvent, "Prices Including VAT", false, false)]
    local procedure PreventChangePurchHdrPricesIncludingVAT(var Rec: Record "Purchase Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", OnBeforeValidateEvent, "Transaction Type", false, false)]
    local procedure PreventChangePurchHdrTransactionType(var Rec: Record "Purchase Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", OnBeforeValidateEvent, "Transport Method", false, false)]
    local procedure PreventChangePurchHdrTransportMethod(var Rec: Record "Purchase Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", OnBeforeValidateEvent, "Buy-from Vendor Name", false, false)]
    local procedure PreventChangePurchHdrSelltoVendorName(var Rec: Record "Purchase Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", OnBeforeValidateEvent, "Buy-from Vendor Name 2", false, false)]
    local procedure PreventChangePurchHdrSelltoVendorName2(var Rec: Record "Purchase Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", OnBeforeValidateEvent, "Buy-from Address", false, false)]
    local procedure PreventChangePurchHdrSelltoAddress(var Rec: Record "Purchase Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", OnBeforeValidateEvent, "Buy-from Address 2", false, false)]
    local procedure PreventChangePurchHdrSelltoAddress2(var Rec: Record "Purchase Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", OnBeforeValidateEvent, "Buy-from City", false, false)]
    local procedure PreventChangePurchHdrSelltoCity(var Rec: Record "Purchase Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", OnBeforeValidateEvent, "Buy-from Contact", false, false)]
    local procedure PreventChangePurchHdrSelltoContact(var Rec: Record "Purchase Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", OnBeforeValidateEvent, "Pay-to Post Code", false, false)]
    local procedure PreventChangePurchHdrBilltoPostCode(var Rec: Record "Purchase Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", OnBeforeValidateEvent, "Pay-to County", false, false)]
    local procedure PreventChangePurchHdrBilltoCounty(var Rec: Record "Purchase Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", OnBeforeValidateEvent, "Pay-to Country/Region Code", false, false)]
    local procedure PreventChangePurchHdrBilltoCountryRegionCode(var Rec: Record "Purchase Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", OnBeforeValidateEvent, "Buy-from Post Code", false, false)]
    local procedure PreventChangePurchHdrSelltoPostCode(var Rec: Record "Purchase Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", OnBeforeValidateEvent, "Buy-from County", false, false)]
    local procedure PreventChangePurchHdrSelltoCounty(var Rec: Record "Purchase Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", OnBeforeValidateEvent, "Buy-from Country/Region Code", false, false)]
    local procedure PreventChangePurchHdrSelltoCountryRegionCode(var Rec: Record "Purchase Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", OnBeforeValidateEvent, "Ship-to Post Code", false, false)]
    local procedure PreventChangePurchHdrShiptoPostCode(var Rec: Record "Purchase Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", OnBeforeValidateEvent, "Ship-to County", false, false)]
    local procedure PreventChangePurchHdrShiptoCounty(var Rec: Record "Purchase Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", OnBeforeValidateEvent, "Ship-to Country/Region Code", false, false)]
    local procedure PreventChangePurchHdrShiptoCountryRegionCode(var Rec: Record "Purchase Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", OnBeforeValidateEvent, "VAT Bus. Posting Group", false, false)]
    local procedure PreventChangePurchHdrVATBusPostingGroup(var Rec: Record "Purchase Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", OnBeforeValidateEvent, "Dimension Set ID", false, false)]
    local procedure PreventChangePurchHdrDimensionSetD(var Rec: Record "Purchase Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", OnBeforeValidateEvent, "Buy-from Contact No.", false, false)]
    local procedure PreventChangePurchHdrSelltoContactNo(var Rec: Record "Purchase Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", OnBeforeValidateEvent, "Pay-to Contact No.", false, false)]
    local procedure PreventChangePurchHdrBilltoContactNo(var Rec: Record "Purchase Header"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Correct Posted Purch. Invoice", OnAfterCreateCopyDocument, '', false, false)]
    local procedure RemoveBooleanKeyOnAfterCreateCopyPurchaseDocument(var PurchaseHeader: Record "Purchase Header")
    var
        SessionStore: Codeunit "Session Store";
    begin
        if PurchaseHeader."Recurring Billing" then
            SessionStore.RemoveBooleanKey('SkipContractPurchaseHeaderModifyCheck');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", OnBeforeCopyPurchaseDocument, '', false, false)]
    local procedure SetBooleanKeyOnBeforeCopyPurchaseDocument(FromDocumentType: Option; FromDocumentNo: Code[20])
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        SessionStore: Codeunit "Session Store";
    begin
        if FromDocumentType = "Purchase Document Type From"::"Posted Invoice".AsInteger() then
            if PurchInvHeader.Get(FromDocumentNo) then
                if PurchInvHeader."Recurring Billing" then
                    SessionStore.SetBooleanKey('SkipContractPurchaseHeaderModifyCheck', true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", OnAfterCopyPurchaseDocument, '', false, false)]
    local procedure RemoveBooleanKeyOnAfterCopyPurchaseDocument(var ToPurchaseHeader: Record "Purchase Header")
    var
        SessionStore: Codeunit "Session Store";
    begin
        if ToPurchaseHeader."Recurring Billing" then
            SessionStore.RemoveBooleanKey('SkipContractPurchaseHeaderModifyCheck');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", OnBeforeModifyEvent, '', false, false)]
    local procedure PreventChangePurchaseHeader(var Rec: Record "Purchase Header")
    var
        xPurchaseHeader: Record "Purchase Header";
        SessionStore: Codeunit "Session Store";
    begin
        if Rec.IsTemporary() then
            exit;

        if not Rec."Recurring Billing" then
            exit;
        if SessionStore.GetBooleanKey('SkipContractPurchaseHeaderModifyCheck') then
            exit;
        xPurchaseHeader.Get(Rec."Document Type", Rec."No.");
        if ((Rec."Shortcut Dimension 1 Code" <> xPurchaseHeader."Shortcut Dimension 1 Code") or
            (Rec."Shortcut Dimension 2 Code" <> xPurchaseHeader."Shortcut Dimension 2 Code") or
            (Rec."Dimension Set ID" <> xPurchaseHeader."Dimension Set ID")) then
            Error(HeaderDimCannotBeChangedErr, Rec."Document Type", Rec."No.");

        if ((Rec."Buy-from Vendor No." <> xPurchaseHeader."Buy-from Vendor No.") or
             (Rec."Buy-from Address" <> xPurchaseHeader."Buy-from Address") or
            (Rec."Buy-from Contact" <> xPurchaseHeader."Buy-from Contact") or
            (Rec."Buy-from Contact No." <> xPurchaseHeader."Buy-from Contact No.") or
            (Rec."Buy-from Vendor Name" <> xPurchaseHeader."Buy-from Vendor Name") or
            (Rec."Buy-from Vendor Name 2" <> xPurchaseHeader."Buy-from Vendor Name 2") or
            (Rec."Buy-from Address" <> xPurchaseHeader."Buy-from Address") or
            (Rec."Buy-from Address 2" <> xPurchaseHeader."Buy-from Address 2") or
            (Rec."Buy-from City" <> xPurchaseHeader."Buy-from City") or
            (Rec."Buy-from Country/Region Code" <> xPurchaseHeader."Buy-from Country/Region Code") or
            (Rec."Buy-from County" <> xPurchaseHeader."Buy-from County") or
            (Rec."Pay-to Vendor No." <> xPurchaseHeader."Pay-to Vendor No.") or
            (Rec."Pay-to Address" <> xPurchaseHeader."Pay-to Address") or
            (Rec."Pay-to Address 2" <> xPurchaseHeader."Pay-to Address 2") or
            (Rec."Pay-to City" <> xPurchaseHeader."Pay-to City") or
            (Rec."Pay-to Contact" <> xPurchaseHeader."Pay-to Contact") or
            (Rec."Pay-to Contact No." <> xPurchaseHeader."Pay-to Contact No.") or
            (Rec."Pay-to Country/Region Code" <> xPurchaseHeader."Pay-to Country/Region Code") or
            (Rec."Pay-to County" <> xPurchaseHeader."Pay-to County") or
            (Rec."Pay-to Name" <> xPurchaseHeader."Pay-to Name") or
            (Rec."Pay-to Name 2" <> xPurchaseHeader."Pay-to Name 2") or
            (Rec."Pay-to Name" <> xPurchaseHeader."Pay-to Name") or
            (Rec."Pay-to Name 2" <> xPurchaseHeader."Pay-to Name 2") or
            (Rec."Pay-to Address" <> xPurchaseHeader."Pay-to Address") or
            (Rec."Pay-to Address 2" <> xPurchaseHeader."Pay-to Address 2") or
            (Rec."Pay-to City" <> xPurchaseHeader."Pay-to City") or
            (Rec."Pay-to Country/Region Code" <> xPurchaseHeader."Pay-to Country/Region Code") or
            (Rec."Pay-to County" <> xPurchaseHeader."Pay-to County") or
            (Rec."Pay-to Post Code" <> xPurchaseHeader."Pay-to Post Code") or
            (Rec."Buy-from Post Code" <> xPurchaseHeader."Buy-from Post Code") or
            (Rec."Ship-to Address" <> xPurchaseHeader."Ship-to Address") or
            (Rec."Ship-to Address 2" <> xPurchaseHeader."Ship-to Address 2") or
            (Rec."Ship-to City" <> xPurchaseHeader."Ship-to City") or
            (Rec."Ship-to Contact" <> xPurchaseHeader."Ship-to Contact") or
            (Rec."Ship-to Country/Region Code" <> xPurchaseHeader."Ship-to Country/Region Code") or
            (Rec."Ship-to County" <> xPurchaseHeader."Ship-to County") or
            (Rec."Ship-to Post Code" <> xPurchaseHeader."Ship-to Post Code") or
            (Rec."Currency Code" <> xPurchaseHeader."Currency Code") or
            (Rec."Prices Including VAT" <> xPurchaseHeader."Prices Including VAT") or
            (Rec."VAT Bus. Posting Group" <> xPurchaseHeader."VAT Bus. Posting Group") or
            (Rec."Recurring Billing" <> xPurchaseHeader."Recurring Billing")) then
            Error(HeaderCannotBeChangedErr);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", OnBeforeValidateEvent, "Shortcut Dimension 1 Code", false, false)]
    local procedure PreventChangePurchaseLineShortcutDimension1Code(var Rec: Record "Purchase Line"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", OnBeforeValidateEvent, "Shortcut Dimension 2 Code", false, false)]
    local procedure PreventChangePurchaseLineShortcutDimension2Code(var Rec: Record "Purchase Line"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", OnBeforeValidateEvent, Amount, false, false)]
    local procedure PreventChangePurchaseLineAmount(var Rec: Record "Purchase Line"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", OnBeforeValidateEvent, "Amount Including VAT", false, false)]
    local procedure PreventChangePurchaseLineAmountIncludingVAT(var Rec: Record "Purchase Line"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", OnBeforeValidateEvent, "Line Discount %", false, false)]
    local procedure PreventChangePurchaseLineLineDiscount(var Rec: Record "Purchase Line"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", OnBeforeValidateEvent, "Line Discount Amount", false, false)]
    local procedure PreventChangePurchaseLineLineDiscountAmount(var Rec: Record "Purchase Line"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", OnBeforeValidateEvent, "Line Amount", false, false)]
    local procedure PreventChangePurchaseLineLineAmount(var Rec: Record "Purchase Line"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", OnBeforeValidateEvent, Type, false, false)]
    local procedure PreventChangePurchaseLineType(var Rec: Record "Purchase Line"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, Rec.FieldNo(Type));
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", OnBeforeValidateEvent, "No.", false, false)]
    local procedure PreventChangePurchaseLineNo(var Rec: Record "Purchase Line"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", OnBeforeValidateEvent, "Unit Cost", false, false)]
    local procedure PreventChangePurchaseLineUnitPrice(var Rec: Record "Purchase Line"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", OnBeforeValidateEvent, "Unit of Measure Code", false, false)]
    local procedure PreventChangePurchaseLineUnitofMeasureCode(var Rec: Record "Purchase Line"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", OnBeforeValidateEvent, Quantity, false, false)]
    local procedure PreventChangePurchaseLineQuantity(var Rec: Record "Purchase Line"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", OnBeforeValidateEvent, "Recurring Billing from", false, false)]
    local procedure PreventChangePurchaseLineRecurringBillingfrom(var Rec: Record "Purchase Line"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", OnBeforeValidateEvent, "Recurring Billing to", false, false)]
    local procedure PreventChangePurchaseLineRecurringBillingto(var Rec: Record "Purchase Line"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;
        PreventChangeOnDocumentHeaderOrLine(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", OnBeforeModifyEvent, '', false, false)]
    local procedure PreventChangeOnPurchaseLine(var Rec: Record "Purchase Line"; RunTrigger: Boolean)
    var
        xPurchaseLine: Record "Purchase Line";
        BillingLine: Record "Billing Line";
    begin
        if Rec.IsTemporary() then
            exit;
        if (not Rec.IsLineAttachedToBillingLine()) then
            exit;
        if not RunTrigger then
            exit;

        xPurchaseLine.Get(Rec."Document Type", Rec."Document No.", Rec."Line No.");
        BillingLine.FilterBillingLineOnDocumentLine(BillingLine.GetBillingDocumentTypeFromPurchaseDocumentType(xPurchaseLine."Document Type"), xPurchaseLine."Document No.", xPurchaseLine."Line No.");
        BillingLine.FindFirst();

        if ((Rec."Shortcut Dimension 1 Code" <> xPurchaseLine."Shortcut Dimension 1 Code") or
            (Rec."Shortcut Dimension 2 Code" <> xPurchaseLine."Shortcut Dimension 2 Code") or
            (Rec."Dimension Set ID" <> xPurchaseLine."Dimension Set ID")) then
            Error(LineDimCannotBeChangedErr, BillingLine."Contract No.", Rec."Document Type", Rec."Document No.", Rec."Line No.");

        if ((Rec.Type <> xPurchaseLine.Type) or
            (Rec."No." <> xPurchaseLine."No.") or
            (Rec."Quantity" <> xPurchaseLine."Quantity") or
            (Rec."Unit of Measure Code" <> xPurchaseLine."Unit of Measure Code") or
            (Rec."Unit Cost" <> xPurchaseLine."Unit Cost") or
            (Rec.Amount <> xPurchaseLine.Amount) or
            (Rec."Amount Including VAT" <> xPurchaseLine."Amount Including VAT") or
            (Rec."Line Discount %" <> xPurchaseLine."Line Discount %") or
            (Rec."Line Discount Amount" <> xPurchaseLine."Line Discount Amount") or
            (Rec."Recurring Billing to" <> xPurchaseLine."Recurring Billing to") or
            (Rec."Recurring Billing from" <> xPurchaseLine."Recurring Billing from")) then
            Error(LineCannotBeChangedErr, BillingLine."Contract No.");
    end;

    procedure PreventChangeOnDocumentHeaderOrLine(RecVariant: Variant; CurrFieldNo: Integer)
    var
        ContractRenewalMgt: Codeunit "Contract Renewal Mgt.";
        RRef: RecordRef;
        FRef: FieldRef;
        FRef2: FieldRef;
        xFRef: FieldRef;
        xRRef: RecordRef;
        ContractNo: Code[20];
        DocumentType: Text;
        DocumentNo: Code[20];
        LineNo: Integer;
    begin
        if CurrFieldNo = 0 then
            exit;
        RRef.GetTable(RecVariant);
        if not IsRecurringBillingDocument(RRef) then
            if not ContractRenewalMgt.IsContractRenewal(RRef) then
                exit;

        xRRef.GetTable(RecVariant);
        xRRef.SetRecFilter();
        xRRef.FindFirst();
        FRef := RRef.Field(CurrFieldNo);
        xFRef := xRRef.Field(CurrFieldNo);

        case RRef.Number of
            Database::"Purchase Header", Database::"Sales Header":
                begin
                    if CurrFieldNo in [29, 30, 480] then begin
                        FRef2 := RRef.Field(1);
                        DocumentType := FRef2.Value;
                        FRef2 := RRef.Field(3);
                        DocumentNo := FRef2.Value;
                        Error(HeaderDimCannotBeChangedErr, DocumentType, DocumentNo);
                    end;
                    if FRef.Value <> xFRef.Value then
                        Error(HeaderCannotBeChangedErr);
                end;
            Database::"Purchase Line", Database::"Sales Line":
                begin
                    FRef2 := RRef.Field(8051);
                    ContractNo := FRef2.Value;
                    FRef2 := RRef.Field(1);
                    DocumentType := FRef2.Value;
                    FRef2 := RRef.Field(3);
                    DocumentNo := FRef2.Value;
                    FRef2 := RRef.Field(4);
                    LineNo := FRef2.Value;

                    if CurrFieldNo in [29, 30, 480] then
                        Error(LineDimCannotBeChangedErr, ContractNo, DocumentType, DocumentNo, LineNo);
                    if FRef.Value <> xFRef.Value then
                        Error(LineCannotBeChangedErr, ContractNo);
                end;
        end;
    end;

    local procedure IsRecurringBillingDocument(RRef: RecordRef) RecurringBilling: Boolean
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        FRef: FieldRef;
    begin
        case RRef.Number of
            Database::"Purchase Header", Database::"Sales Header":
                begin
                    FRef := RRef.Field(8051);   //Recurring Billing in Header Tables //Contract No. in Line tables
                    RecurringBilling := FRef.Value;
                end;
            Database::"Purchase Line":
                begin
                    RRef.SetTable(PurchaseLine);
                    PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.");
                    RecurringBilling := PurchaseHeader."Recurring Billing";
                end;
            Database::"Sales Line":
                begin
                    RRef.SetTable(SalesLine);
                    SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
                    RecurringBilling := SalesHeader."Recurring Billing";
                end;
        end;
    end;
}