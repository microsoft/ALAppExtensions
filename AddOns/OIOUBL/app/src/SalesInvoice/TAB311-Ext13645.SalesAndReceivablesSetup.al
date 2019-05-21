// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

tableextension 13645 "OIOUBL-Sales&Receivables Setup" extends "Sales & Receivables Setup"
{
    fields
    {
        field(13630; "OIOUBL-Invoice Path"; Text[250])
        {
            Caption = 'Invoice Path';
        }
        field(13631; "OIOUBL-Cr. Memo Path"; Text[250])
        {
            Caption = 'Cr. Memo Path';
        }
        field(13632; "OIOUBL-Reminder Path"; Text[250])
        {
            Caption = 'Reminder Path';
        }
        field(13633; "OIOUBL-Fin. Chrg. Memo Path"; Text[250])
        {
            Caption = 'Fin. Chrg. Memo Path';
        }
        field(13634; "OIOUBL-Default Profile Code"; Code[10])
        {
            Caption = 'Default Profile Code';
            TableRelation = "OIOUBL-Profile";

            trigger OnValidate()
            var
                OIOUBLProfile: Record "OIOUBL-Profile";
            begin
                OIOUBLProfile.UpdateEmptyOIOUBLProfileCodes("OIOUBL-Default Profile Code", xRec."OIOUBL-Default Profile Code");
            end;
        }
    }
    keys
    {
    }

    var
        SetupOIOUBLQst: Label 'OIOUBL path of the OIOMXL file is missing. Do you want to update it now?';
        MissingSetupOIOUBLErr: Label 'OIOUBL path of the OIOMXL file is missing. Please Correct it.';

    local procedure IsOIOUBLPathSetupAvailble("Document Type": Option Quote, Order, Invoice, "Credit Memo", "Blanket Order", "Return Order", "Finance Charge", Reminder): Boolean;
    var
        FileMgt: Codeunit "File Management";
    begin
        if not FileMgt.IsLocalFileSystemAccessible() then
            exit(TRUE);
        case "Document Type" of
            "Document Type"::Order, "Document Type"::Invoice:
                exit("OIOUBL-Invoice Path" <> '');
            "Document Type"::"Return Order", "Document Type"::"Credit Memo":
                exit("OIOUBL-Cr. Memo Path" <> '');
            "Document Type"::"Finance Charge":
                exit("OIOUBL-Fin. Chrg. Memo Path" <> '');
            "Document Type"::Reminder:
                exit("OIOUBL-Reminder Path" <> '');
        else 
        exit(TRUE);
        end;
    end;

    procedure VerifyAndSetOIOUBLSetupPath("Document Type": Option Quote, Order, Invoice, "Credit Memo", "Blanket Order", "Return Order", "Finance Charge", Reminder);
    var
        OIOUBLsetupPage: Page "OIOUBL-setup";
    begin
        GET();
        if IsOIOUBLPathSetupAvailble("Document Type") then
            EXIT;

        if CONFIRM(SetupOIOUBLQst, TRUE) then begin
            OIOUBLsetupPage.SETRECORD(Rec);
            OIOUBLsetupPage.EDITABLE(TRUE);
            if OIOUBLsetupPage.RUNMODAL() = ACTION::OK then
                OIOUBLsetupPage.GETRECORD(Rec);
        end;

        if NOT IsOIOUBLPathSetupAvailble("Document Type") then
            ERROR(MissingSetupOIOUBLErr);
    end;

}