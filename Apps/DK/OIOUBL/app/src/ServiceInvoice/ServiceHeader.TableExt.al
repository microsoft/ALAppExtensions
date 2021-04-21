// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

tableextension 13652 "OIOUBL-Service Header" extends "Service Header"
{
    fields
    {
        field(13630; "OIOUBL-GLN"; Code[13])
        {
            Caption = 'GLN';

            trigger OnValidate();
            begin
                if "OIOUBL-GLN" = '' then
                    EXIT;

                if NOT OIOUBLDocumentEncode.IsValidGLN("OIOUBL-GLN") then
                    FIELDERROR("OIOUBL-GLN", InvalidGLNErr);
            end;
        }
        field(13631; "OIOUBL-Account Code"; Text[30])
        {
            Caption = 'Account Code';

            trigger OnValidate();
            var
                ServLine: Record "Service Line";
            begin
                ServLine.RESET();
                ServLine.SETRANGE("Document Type", "Document Type");
                ServLine.SETRANGE("Document No.", "No.");
                ServLine.SETFILTER("OIOUBL-Account Code", '%1|%2', xRec."OIOUBL-Account Code", '');
                ServLine.MODIFYALL("OIOUBL-Account Code", "OIOUBL-Account Code");
            end;
        }
        field(13632; "OIOUBL-Profile Code"; Code[10])
        {
            Caption = 'Profile Code';
            TableRelation = "OIOUBL-Profile";
        }
        field(13638; "OIOUBL-Contact Role"; Option)
        {
            Caption = 'Contact Role';
            OptionMembers = " ",,,"Purchase Responsible",,,"Accountant",,,"Budget Responsible",,,"Requisitioner";
        }
        modify("Bill-to Customer No.")
        {
            trigger OnAfterValidate()
            var
                Customer: Record Customer;
            begin
                if not Customer.Get("Bill-to Customer No.") then
                    exit;

                "OIOUBL-GLN" := Customer.GLN;
            end;
        }

        modify("Customer No.")
        {
            trigger OnAfterValidate()
            var
                Customer: Record Customer;
            begin
                if not Customer.Get("Bill-to Customer No.") then
                    exit;

                "OIOUBL-Account Code" := Customer."OIOUBL-Account Code";
                "OIOUBL-Profile Code" := Customer."OIOUBL-Profile Code"
            end;
        }
    }

    var
        OIOUBLDocumentEncode: Codeunit "OIOUBL-Document Encode";
        InvalidGLNErr: Label 'does not contain a valid, 13-digit GLN', Comment = 'starts with some field name';
}