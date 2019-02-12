// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 13634 "OIOUBL-Check Issued Fin. Chrg"
{
    TableNo = "Issued Fin. Charge Memo Header";
    trigger OnRun();
    var
        OIOUBLManagement: Codeunit "OIOUBL-Management";
    begin
        if NOT OIOUBLManagement.IsOIOUBLCheckRequired("OIOUBL-GLN", "Customer No.") then
            exit;

        if NOT OIOUBLDocumentEncode.IsValidGLN("OIOUBL-GLN") then
            FIELDERROR("OIOUBL-GLN", InvalidGLNErr);

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

        OIOUBLDocumentEncode.GetOIOUBLCountryRegionCode("Country/Region Code");
        OIOUBLDocumentEncode.GetOIOUBLCountryRegionCode(CompanyInfo."Country/Region Code");
        OIOUBLDocumentEncode.IsValidCountryCode("Country/Region Code");
        TESTFIELD(Name);
        TESTFIELD(Address);
        TESTFIELD(City);
        TESTFIELD("Post Code");
        TESTFIELD(Contact);
        "Currency Code" := OIOUBLDocumentEncode.GetOIOUBLCurrencyCode("Currency Code");
    end;

    var
        GLSetup: Record "General Ledger Setup";
        CompanyInfo: Record "Company Information";
        OIOUBLDocumentEncode: Codeunit "OIOUBL-Document Encode";
        CompanyInfoRead: Boolean;
        GLSetupRead: Boolean;
        InvalidGLNErr: Label 'does not contain a valid, 13-digit GLN', Comment = 'starts with some field name';

    local procedure ReadCompanyInfo();
    begin
        if NOT CompanyInfoRead then begin
            CompanyInfo.GET();
            CompanyInfoRead := TRUE;
        end;
    end;

    procedure ReadGLSetup();
    begin
        if NOT GLSetupRead then begin
            GLSetup.GET();
            GLSetupRead := TRUE;
        end;
    end;
}