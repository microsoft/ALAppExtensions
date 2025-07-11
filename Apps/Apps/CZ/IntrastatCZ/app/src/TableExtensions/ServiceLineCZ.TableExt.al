// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Service.Document;

tableextension 31318 "Service Line CZ" extends "Service Line"
{
    fields
    {
        field(31300; "Statistic Indication CZ"; Code[10])
        {
            Caption = 'Statistic Indication';
            TableRelation = "Statistic Indication CZ".Code where("Tariff No." = field("Tariff No. CZL"));
        }
        field(31305; "Physical Transfer CZ"; Boolean)
        {
            Caption = 'Physical Transfer';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Physical Transfer CZ" then begin
                    TestField(Type, Type::Item);
                    if "Document Type" = "Document Type"::"Credit Memo" then
                        FieldError("Document Type");
                end;
            end;
        }
        modify("Tariff No. CZL")
        {
            trigger OnAfterValidate()
            begin
                if "Tariff No. CZL" <> xRec."Tariff No. CZL" then
                    "Statistic Indication CZ" := '';
            end;
        }
    }
}