// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

tableextension 13634 "OIOUBL-Customer" extends Customer
{
    fields
    {
        modify(GLN)
        {
            trigger OnAfterValidate();
            begin
                if GLN = '' then
                    EXIT;
                if NOT OIOXMLDocumentEncode.IsValidGLN(GLN) then
                    FIELDERROR(GLN, InvalidGLNErr);
                if (GLN <> '') AND ("OIOUBL-Profile Code" = '') then
                    SetDefaultProfileCode();
            end;
        }
        field(13631; "OIOUBL-Account Code"; Text[30])
        {
            Caption = 'Account Code';
        }
        field(13632; "OIOUBL-Profile Code"; Code[10])
        {
            Caption = 'Profile Code';
            TableRelation = "OIOUBL-Profile";
        }
        field(13633; "OIOUBL-Profile Code Required"; Boolean)
        {
            Caption = 'Profile Code Required';
        }
    }

    var
        SalesSetup: Record "Sales & Receivables Setup";
        OIOXMLDocumentEncode: Codeunit "OIOUBL-Document Encode";
        InvalidGLNErr: Label 'does not contain a valid, 13-digit GLN', Comment = 'starts with some field name';

    procedure SetDefaultProfileCode();
    begin
        SalesSetup.GET();
        "OIOUBL-Profile Code" := SalesSetup."OIOUBL-Default Profile Code";
    end;
}