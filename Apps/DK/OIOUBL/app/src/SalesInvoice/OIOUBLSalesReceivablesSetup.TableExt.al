// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Setup;

using Microsoft.EServices.EDocument;

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
        field(13635; "Document No. as Ext. Doc. No."; Boolean)
        {
            Caption = 'Document No. as External Doc. No.';
        }
    }
    keys
    {
    }
}
