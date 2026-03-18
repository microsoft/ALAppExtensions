// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Peppol.BE;

using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.Company;
using Microsoft.Inventory.Location;
using Microsoft.Peppol;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using System.Reflection;

codeunit 37311 "PEPPOL30 BE Sales Validation" implements "PEPPOL30 Validation"
{
    TableNo = "Sales Header";
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        PEPPOL30SalesValidation: Codeunit "PEPPOL30 Sales Validation";
        MissingCompInfGLNOrVATRegNoOrEnterpNoErr: Label 'You must specify either GLN, VAT Registration No. or Enterprise No. in %1.', Comment = '%1=Company Information';
        MissingCustGLNOrVATRegNoOrEnterpNoErr: Label 'You must specify either GLN, VAT Registration No. or Enterprise No. for Customer %1.', Comment = '%1 = Customer No.';

    trigger OnRun()
    begin
        ValidateDocument(Rec);
        ValidateDocumentLines(Rec);
    end;

    procedure ValidateDocument(RecordVariant: Variant)
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader := RecordVariant;
        CheckSalesDocument(SalesHeader);
    end;

    procedure ValidateDocumentLines(RecordVariant: Variant)
    begin
        PEPPOL30SalesValidation.ValidateDocumentLines(RecordVariant);
    end;

    procedure ValidateDocumentLine(RecordVariant: Variant)
    begin
        PEPPOL30SalesValidation.ValidateDocumentLine(RecordVariant);
    end;

    procedure ValidateLineTypeAndDescription(RecordVariant: Variant): Boolean
    begin
        exit(PEPPOL30SalesValidation.ValidateLineTypeAndDescription(RecordVariant));
    end;

    procedure ValidatePostedDocument(RecordVariant: Variant)
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesHeader: Record "Sales Header";
        DataTypeMgt: Codeunit "Data Type Management";
        RecordRef: RecordRef;
        UnsupportedDocumentErr: Label 'The posted sales document type is not supported for PEPPOL 3.0 validation.';
    begin
        if not DataTypeMgt.GetRecordRef(RecordVariant, RecordRef) then
            exit;

        // BE-specific: Validate document header with Enterprise No. check, then delegate line validation to W1
        case RecordRef.Number() of
            Database::"Sales Invoice Header":
                begin
                    SalesInvoiceHeader := RecordVariant;
                    SalesHeader.TransferFields(SalesInvoiceHeader);
                    SalesHeader."Document Type" := SalesHeader."Document Type"::Invoice;
                    CheckSalesDocument(SalesHeader);
                    PEPPOL30SalesValidation.ValidateDocumentLines(SalesHeader);
                end;
            Database::"Sales Cr.Memo Header":
                begin
                    SalesCrMemoHeader := RecordVariant;
                    SalesHeader.TransferFields(SalesCrMemoHeader);
                    SalesHeader."Document Type" := SalesHeader."Document Type"::"Credit Memo";
                    CheckSalesDocument(SalesHeader);
                    PEPPOL30SalesValidation.ValidateDocumentLines(SalesHeader);
                end;
            else
                Error(UnsupportedDocumentErr);
        end;
    end;

    local procedure CheckSalesDocument(SalesHeader: Record "Sales Header")
    var
        CompanyInfo: Record "Company Information";
        Customer: Record Customer;
        GLSetup: Record "General Ledger Setup";
        ResponsibilityCenter: Record "Responsibility Center";
    begin
        CompanyInfo.Get();
        GLSetup.Get();

        PEPPOL30SalesValidation.CheckCurrencyCode(SalesHeader."Currency Code");

        if SalesHeader."Responsibility Center" <> '' then begin
            ResponsibilityCenter.Get(SalesHeader."Responsibility Center");
            ResponsibilityCenter.TestField(Name);
            ResponsibilityCenter.TestField(Address);
            ResponsibilityCenter.TestField(City);
            ResponsibilityCenter.TestField("Post Code");
            ResponsibilityCenter.TestField("Country/Region Code");
        end else begin
            CompanyInfo.TestField(Name);
            CompanyInfo.TestField(Address);
            CompanyInfo.TestField(City);
            CompanyInfo.TestField("Post Code");
        end;

        CompanyInfo.TestField("Country/Region Code");
        PEPPOL30SalesValidation.CheckCountryRegionCode(CompanyInfo."Country/Region Code");

        // BE-specific: Include Enterprise No. in the check
        if CompanyInfo.GLN + CompanyInfo."VAT Registration No." + CompanyInfo."Enterprise No." = '' then
            Error(MissingCompInfGLNOrVATRegNoOrEnterpNoErr, CompanyInfo.TableCaption());

        SalesHeader.TestField("Bill-to Name");
        SalesHeader.TestField("Bill-to Address");
        SalesHeader.TestField("Bill-to City");
        SalesHeader.TestField("Bill-to Post Code");
        SalesHeader.TestField("Bill-to Country/Region Code");
        PEPPOL30SalesValidation.CheckCountryRegionCode(SalesHeader."Bill-to Country/Region Code");

        // BE-specific: Include Enterprise No. in the check

        if (SalesHeader."Document Type" in [SalesHeader."Document Type"::Invoice, SalesHeader."Document Type"::Order, SalesHeader."Document Type"::"Credit Memo"]) and
           Customer.Get(SalesHeader."Bill-to Customer No.")
        then
            if (Customer.GLN + Customer."VAT Registration No." + Customer."Enterprise No.") = '' then
                Error(MissingCustGLNOrVATRegNoOrEnterpNoErr, Customer."No.");

        if SalesHeader."Document Type" = SalesHeader."Document Type"::"Credit Memo" then
            if SalesHeader."Applies-to Doc. Type" = SalesHeader."Applies-to Doc. Type"::Invoice then
                SalesHeader.TestField("Applies-to Doc. No.");

        if SalesHeader."Document Type" in [SalesHeader."Document Type"::Invoice, SalesHeader."Document Type"::Order] then
            SalesHeader.TestField("Shipment Date");

        SalesHeader.TestField("Your Reference");

        PEPPOL30SalesValidation.CheckShipToAddress(SalesHeader);
        SalesHeader.TestField("Due Date");

        if CompanyInfo.IBAN = '' then
            CompanyInfo.TestField("Bank Account No.");
        CompanyInfo.TestField("Bank Branch No.");
        CompanyInfo.TestField("SWIFT Code");
    end;
}
