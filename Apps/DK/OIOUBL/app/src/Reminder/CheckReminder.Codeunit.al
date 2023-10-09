// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument;

using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.Company;
using Microsoft.Sales.Reminder;

codeunit 13631 "OIOUBL-Check Reminder"
{
    TableNo = "Reminder Header";

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
        CheckReminderLines(Rec);
    end;

    var
        CompanyInfo: Record "Company Information";
        GLSetup: Record "General Ledger Setup";
        OIOUBLDocumentEncode: Codeunit "OIOUBL-Document Encode";
        GLSetupRead: Boolean;
        CompanyInfoRead: Boolean;
        InvalidGLNErr: Label 'does not contain a valid, 13-digit GLN', Comment = 'starts with some field name';
        EmptyDescriptionErr: Label 'The Reminder %1 contains lines in which the Type and the No. are specified, but the Description is empty. This is not allowed for an OIOUBL document which might be created from the posted document.', Comment = '%1 = No. of the Reminder';
        EmptyFieldsQst: Label 'The Reminder %1 contains lines in which either the Type or the No. is empty. Such lines will not be taken into account when creating an OIOUBL document.\Do you want to continue?', Comment = '%1 = No. of the Reminder';
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

    local procedure CheckReminderLines(ReminderHeader: Record "Reminder Header");
    var
        ReminderLine: Record "Reminder Line";
        EmptyLineFound: Boolean;
    begin
        EmptyLineFound := FALSE;
        WITH ReminderLine do begin
            RESET();
            SETRANGE("Reminder No.", ReminderHeader."No.");
            if FINDSET() then
                repeat
                    if Description = '' then
                        if (Type <> Type::" ") AND ("No." <> '') then
                            ERROR(EmptyDescriptionErr, "Reminder No.");
                    if Type = Type::" " then
                        EmptyLineFound := true;
                    if (Type = Type::"G/L Account") and ("No." = '') then
                        EmptyLineFound := true;
                until (NEXT() = 0);

            if EmptyLineFound then
                if NOT CONFIRM(EmptyFieldsQst, TRUE, "Reminder No.") then
                    ERROR(WarningsExistErr);
        end;
    end;
}
