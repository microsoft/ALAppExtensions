// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument;

using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.Company;
using Microsoft.Sales.Customer;
using Microsoft.Service.Document;

codeunit 13649 "OIOUBL-Check Service Header"
{
    TableNo = "Service Header";
    trigger OnRun();
    var
        OIOUBLManagement: Codeunit "OIOUBL-Management";
    begin
        if NOT OIOUBLManagement.IsOIOUBLCheckRequired("OIOUBL-GLN", "Customer No.") then
            exit;
        CheckOIOUBLProfile(Rec);
        ReadCompanyInfo();
        ReadGLSetup();

        CompanyInfo.TESTFIELD("VAT Registration No.");
        CompanyInfo.TESTFIELD(Name);
        CompanyInfo.TESTFIELD(Address);
        CompanyInfo.TESTFIELD(City);
        CompanyInfo.TESTFIELD("Post Code");
        CompanyInfo.TESTFIELD("Country/Region Code");
        if CompanyInfo.IBAN = '' then
            CompanyInfo.TESTFIELD("Bank Account No.");
        CompanyInfo.TESTFIELD("Bank Branch No.");

        if NOT OIOUBLDocumentEncode.IsValidGLN("OIOUBL-GLN") then
            FIELDERROR("OIOUBL-GLN", InvalidGLNErr);

        TESTFIELD("Your Reference");

        if "Document Type" in ["Document Type"::Invoice, "Document Type"::Order] then begin
            TESTFIELD("Payment Terms Code");
            TESTFIELD("Order Date");
        end;
        TESTFIELD("Bill-to Name");
        TESTFIELD("Bill-to Address");
        TESTFIELD("Bill-to City");
        TESTFIELD("Bill-to Post Code");

        OIOUBLDocumentEncode.GetOIOUBLCountryRegionCode("Bill-to Country/Region Code");
        OIOUBLDocumentEncode.GetOIOUBLCountryRegionCode(CompanyInfo."Country/Region Code");
        OIOUBLDocumentEncode.IsValidCountryCode("Country/Region Code");
        TESTFIELD("Contact Name");
        TESTFIELD("VAT Registration No.");

        OIOUBLDocumentEncode.GetOIOUBLCurrencyCode("Currency Code");
        CheckServiceLines(Rec);
    end;

    var
        GLSetup: Record "General Ledger Setup";
        CompanyInfo: Record "Company Information";
        OIOUBLDocumentEncode: Codeunit "OIOUBL-Document Encode";
        GLSetupRead: Boolean;
        CompanyInfoRead: Boolean;
        InvalidGLNErr: Label 'does not contain a valid, 13-digit GLN', Comment = 'starts with some field name';
        EmptyDescriptionErr: Label 'The %1 %2 contains lines in which the Type and the No. are specified, but the Description is empty. This is not allowed for an OIOUBL document which might be created from the posted document.', Comment = '%1 - document type, %2 - document no.';
        EmptyFieldsQst: Label 'The %1 %2 contains lines in which either the Type, the No. or the Description is empty. Please be aware that such lines will not be taken into account when creating an OIOUBL document.\Do you want to continue?', Comment = '%1 - document type, %2 - document no.';
        WarningExistErr: Label 'The posting has been interrupted to respect the warning.';
        EmptyUnitOfMeasureErr: Label 'The %1 %2 contains lines in which the Unit of Measure field is empty. This is not allowed for an OIOUBL document which might be created from the posted document.', Comment = '%1 - document type, %2 - document no.';
        CannotBeNegativeErr: Label 'cannot be negative', Comment = 'starts with some field name';
        AmountCannotBeNegativeErr: Label 'The total Line Amount cannot be negative.';
        DiscountAmountCannotBeNegativeErr: Label 'The total Line Discount Amount cannot be negative.';

    local procedure ReadCompanyInfo();
    begin
        if NOT CompanyInfoRead then begin
            CompanyInfo.GET();
            CompanyInfoRead := TRUE;
        end;
    end;

    local procedure ReadGLSetup();
    begin
        if NOT GLSetupRead then begin
            GLSetup.Get();
            GLSetupRead := true;
        end;
    end;

    local procedure CheckServiceLines(ServiceHeader: Record "Service Header");
    var
        ServiceLine: Record "Service Line";
        EmptyLineFound: Boolean;
        TotalLineAmount: Decimal;
        TotalLineDiscountAmount: Decimal;
    begin
        EmptyLineFound := false;
        TotalLineAmount := 0;
        TotalLineDiscountAmount := 0;
        WITH ServiceLine do begin
            Reset();
            SetRange("Document Type", ServiceHeader."Document Type");
            SetRange("Document No.", ServiceHeader."No.");
            if FindSet() then
                repeat
                    if (Type <> Type::" ") AND ("No." <> '') AND ("Unit of Measure" = '') then
                        if Type <> Type::"G/L Account" then
                            ERROR(EmptyUnitOfMeasureErr, "Document Type", "Document No.");
                    if Description = '' then
                        if (Type <> Type::" ") AND ("No." <> '') then
                            ERROR(EmptyDescriptionErr, "Document Type", "Document No.");
                    TotalLineAmount += "Line Amount";
                    TotalLineDiscountAmount += "Line Discount Amount";
                    if (Type = Type::" ") OR ("No." = '') then
                        EmptyLineFound := TRUE;
                    if "Line Discount %" < 0 then
                        FieldError("Line Discount %", CannotBeNegativeErr);
                until (Next() = 0);
            if TotalLineAmount < 0 then
                Error(AmountCannotBeNegativeErr);
            if TotalLineDiscountAmount < 0 then
                Error(DiscountAmountCannotBeNegativeErr);

            if EmptyLineFound then
                if NOT Confirm(EmptyFieldsQst, true, "Document Type", "Document No.") then
                    Error(WarningExistErr);
        end;
    end;

    procedure CheckOIOUBLProfile(ServiceHeader: Record "Service Header");
    var
        OIOUBLProfile: Record "OIOUBL-Profile";
        Customer: Record Customer;
    begin
        Customer.GET(ServiceHeader."Customer No.");
        if Customer."OIOUBL-Profile Code Required" then begin
            ServiceHeader.TestField("OIOUBL-Profile Code");
            OIOUBLProfile.GET(ServiceHeader."OIOUBL-Profile Code");
            OIOUBLProfile.TestField("OIOUBL-Profile ID");
        end;
    end;
}
