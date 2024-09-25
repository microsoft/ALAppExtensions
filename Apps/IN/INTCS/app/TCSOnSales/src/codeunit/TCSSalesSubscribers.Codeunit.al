// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TCS.TCSOnSales;

using Microsoft.Sales.Document;
using Microsoft.Finance.TCS.TCSBase;
using Microsoft.Sales.Customer;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Foundation.Company;
using Microsoft.Inventory.Location;
using Microsoft.Finance.TaxBase;
using Microsoft.Finance.TaxEngine.PostingHandler;
using Microsoft.Sales.Posting;
using Microsoft.Utilities;

codeunit 18838 "TCS Sales Subscribers"
{
    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterValidateEvent', 'No.', false, false)]
    local procedure AssignNOC(
        var Rec: Record "Sales Line";
        var xRec: Record "Sales Line";
        CurrFieldNo: Integer)
    var
        AllowedNOC: Record "Allowed NOC";
    begin
        if Rec."Document Type" = Rec."Document Type"::"Blanket Order" then
            exit;

        AllowedNOC.Reset();
        AllowedNOC.SetRange("customer No.", Rec."Sell-to Customer No.");
        AllowedNOC.SetRange(AllowedNOC."Default Noc", true);
        if AllowedNOC.FindFirst() then
            Rec.Validate("TCS Nature of Collection", AllowedNOC."TCS Nature of Collection")
        else
            Rec.Validate("TCS Nature of Collection", '');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterInitHeaderDefaults', '', false, false)]
    local procedure AssesseeCodeSalesLine(var SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header")
    begin
        if SalesLine."Document Type" <> SalesLine."Document Type"::"Blanket Order" then
            SalesLine."Assessee Code" := SalesHeader."Assessee Code"
        else
            SalesLine."Assessee Code" := '';
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterCheckSellToCust', '', false, false)]
    local procedure AssesseeCode(var SalesHeader: Record "Sales Header"; Customer: Record Customer)
    begin
        if SalesHeader."Document Type" <> SalesHeader."Document Type"::"Blanket Order" then
            SalesHeader."Assessee Code" := Customer."Assessee Code"
        else
            SalesHeader."Assessee Code" := '';
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Post Invoice Events", 'OnPostLedgerEntryOnBeforeGenJnlPostLine', '', false, false)]
    local procedure OnPostLedgerEntryOnBeforeGenJnlPostLine(
        var GenJnlLine: Record "Gen. Journal Line";
        var SalesHeader: Record "Sales Header";
        var TotalSalesLine: Record "Sales Line";
        var TotalSalesLineLCY: Record "Sales Line")
    var
        SalesLine: Record "Sales Line";
        CompanyInformation: Record "Company Information";
        Location: Record Location;
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindFirst() then
            GenJnlLine."TCS Nature of Collection" := SalesLine."TCS Nature of Collection";

        if GenJnlLine."Location Code" <> '' then begin
            Location.Get(GenJnlLine."Location Code");
            if Location."T.C.A.N. No." <> '' then
                GenJnlLine."T.C.A.N. No." := Location."T.C.A.N. No."
        end else begin
            CompanyInformation.Get();
            GenJnlLine."T.C.A.N. No." := CompanyInformation."T.C.A.N. No.";
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterValidateEvent', 'TCS Nature of Collection', false, false)]
    local procedure TCSNOCValidation(var Rec: Record "Sales Line"; var xRec: Record "Sales Line")
    var
        SalesHeader: Record "Sales Header";
        TCSNatureOfCollection: Record "TCS Nature Of Collection";
        AllowedNOC: Record "Allowed NOC";
    begin
        if Rec."TCS Nature of Collection" = '' then
            exit;

        if not TCSNatureOfCollection.Get(Rec."TCS Nature of Collection") then
            Error(NOCTypeErr, Rec."TCS Nature of Collection", TCSNatureOfCollection.TableCaption());

        if not AllowedNOC.Get(Rec."Bill-to Customer No.", Rec."TCS Nature of Collection") then
            Error(NOCNotDefinedErr, Rec."TCS Nature of Collection", Rec."Bill-to Customer No.");

        SalesHeader.Get(Rec."Document Type", Rec."Document No.");
        if SalesHeader."Applies-to Doc. No." <> '' then
            SalesHeader.TestField("Applies-to Doc. No.", '');

        if (SalesHeader."Applies-to ID" <> '') and (Rec."TCS Nature of Collection" <> xRec."TCS Nature of Collection") then
            SalesHeader.TestField("Applies-to ID", '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnAfterCopySalesLineFromSalesDocSalesLine', '', false, false)]
    local procedure CallTaxEngineOnAfterCopySalesLineFromSalesDocSalesLine(var ToSalesLine: Record "Sales Line"; RecalculateLines: Boolean)
    var
        CalculateTax: Codeunit "Calculate Tax";
    begin
        if not RecalculateLines then
            CalculateTax.CallTaxEngineOnSalesLine(ToSalesLine, ToSalesLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Get Shipment", 'OnAfterInsertLine', '', false, false)]
    local procedure CallTaxEngineOnAfterInsertLine(var SalesLine: Record "Sales Line")
    var
        CalculateTax: Codeunit "Calculate Tax";
    begin
        if SalesLine."TCS Nature of Collection" <> '' then
            CalculateTax.CallTaxEngineOnSalesLine(SalesLine, SalesLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Posting Buffer Mgmt.", 'OnBeforeInitTempGroupTaxPostingBuffer2', '', false, false)]
    local procedure OnBeforeInitTempGroupTaxPostingBuffer2(var TempGroupTaxPostingBuffer2: Record "Transaction Posting Buffer" temporary; var TempGroupTaxPostingBuffer: Record "Transaction Posting Buffer" temporary; TaxID: Guid; var IsHandled: Boolean)
    begin
        TempGroupTaxPostingBuffer.Reset();
        TempGroupTaxPostingBuffer.SetRange("Tax Id", TaxID);
        TempGroupTaxPostingBuffer.SetRange("Tax Type", 'TCS');
        TempGroupTaxPostingBuffer.SetRange("Skip Posting", false);
        TempGroupTaxPostingBuffer.SetFilter("Account No.", '<>%1', '');
        if not TempGroupTaxPostingBuffer.IsEmpty() then begin
            TempGroupTaxPostingBuffer.SetFilter("Account No.", '%1', '');
            if TempGroupTaxPostingBuffer.FindFirst() then
                TempGroupTaxPostingBuffer.Delete();
        end;
    end;

    var
        NOCTypeErr: Label '%1 does not exist in table %2.', Comment = '%1=TCS Nature of Collection., %2=The Table Name.';
        NOCNotDefinedErr: Label 'TCS Nature of Collection %1 is not defined for Customer no. %2.', Comment = '%1= TCS Nature of Collection, %2=Customer No.';
}
