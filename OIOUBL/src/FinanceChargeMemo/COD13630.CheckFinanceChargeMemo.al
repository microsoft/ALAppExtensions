// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 13630 "OIOUBL-Check Fin. Charge Memo"
{
    TableNo = "Finance Charge Memo Header";
    trigger OnRun();
    var
        OIOUBLManagement: Codeunit "OIOUBL-Management";
    begin
        if NOT OIOUBLManagement.IsOIOUBLCheckRequired("OIOUBL-GLN", "Customer No.") then
            exit;
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
        OIOUBLDocumentEncode.GetOIOUBLCountryRegionCode("Country/Region Code");
        OIOUBLDocumentEncode.GetOIOUBLCountryRegionCode(CompanyInfo."Country/Region Code");
        OIOUBLDocumentEncode.IsValidCountryCode("Country/Region Code");
        TESTFIELD(Name);
        TESTFIELD(Address);
        TESTFIELD(City);
        TESTFIELD("Post Code");
        TESTFIELD(Contact);
        CheckFinChargeMemoLines(Rec);
    end;

    var
        CompanyInfo: Record "Company Information";
        GLSetup: Record "General Ledger Setup";
        OIOUBLDocumentEncode: Codeunit "OIOUBL-Document Encode";
        CompanyInfoRead: Boolean;
        GLSetupRead: Boolean;
        InvalidGLNErr: Label 'does not contain a valid, 13-digit GLN', Comment = 'starts with some field name';
        EmptyDescriptionErr: Label 'The Finance Charge Memo %1 contains lines in which the Type and the No. are specified, but the Description is empty. This is not allowed for an OIOUBL document which might be created from the posted document.', Comment = '%1 = No. of the Finance Charege memo';
        EmptyFieldsQst: Label 'The Finance Charge Memo %1 contains lines in which either the Document No. or the No. is empty. Such lines will not be taken into account when creating an OIOUBL document./Do you want to continue?', Comment = '%1 = No. of the Finance Charege memo';
        WarningsExistErr: Label 'The issuing has been interrupted to respect the warning.';

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
            GLSetup.GET();
            GLSetupRead := TRUE;
        end;
    end;

    local procedure CheckFinChargeMemoLines(FinChargeMemoHeader: Record "Finance Charge Memo Header");
    var
        FinChargeMemoLine: Record "Finance Charge Memo Line";
        EmptyLineFound: Boolean;
    begin
        EmptyLineFound := FALSE;
        WITH FinChargeMemoLine do begin
            RESET();
            SETRANGE("Finance Charge Memo No.", FinChargeMemoHeader."No.");
            if FINDSET() then
                repeat
                    if Description = '' then
                        if (Type <> Type::" ") AND ("No." <> '') then
                            ERROR(EmptyDescriptionErr, "Finance Charge Memo No.");
                    if Type = Type::" " then
                        EmptyLineFound := TRUE;
                    if (Type = Type::"G/L Account") AND ("No." = '') then
                        EmptyLineFound := TRUE;
                    if (Type = Type::"Customer Ledger Entry") AND ("Document No." = '') then
                        EmptyLineFound := TRUE;
                until (NEXT() = 0);

            if EmptyLineFound then
                if NOT CONFIRM(EmptyFieldsQst, TRUE, "Finance Charge Memo No.") then
                    ERROR(WarningsExistErr);
        end;
    end;
}