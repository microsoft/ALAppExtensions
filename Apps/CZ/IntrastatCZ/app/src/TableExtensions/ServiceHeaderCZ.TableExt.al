// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Service.Document;

tableextension 31344 "Service Header CZ" extends "Service Header"
{
    fields
    {
        field(31305; "Physical Transfer CZ"; Boolean)
        {
            Caption = 'Physical Transfer';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Physical Transfer CZ" then
                    if "Document Type" <> "Document Type"::"Credit Memo" then
                        FieldError("Document Type");
                UpdateServLinesByFieldNo(FieldNo("Physical Transfer CZ"), false);
            end;
        }
    }
}