// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.History;

using Microsoft.Finance.GST.Base;

tableextension 18155 "GST Sales Shipment Line Ext" extends "Sales Shipment Line"
{
    fields
    {
        field(18141; "GST Place of Supply"; enum "GST Dependency Type")
        {
            Caption = 'GST Place of Supply';
            DataClassification = CustomerContent;
        }
        field(18142; "GST Group Code"; Code[20])
        {
            Caption = 'GST Group Code';
            DataClassification = CustomerContent;
            TableRelation = "GST Group";
        }
        field(18143; "GST Group Type"; Enum "GST Group Type")
        {
            Caption = 'GST Group Type';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(18144; "HSN/SAC Code"; Code[10])
        {
            Caption = 'HSN/SAC Code';
            TableRelation = "HSN/SAC".Code where("GST Group Code" = field("GST Group Code"));
            DataClassification = CustomerContent;
        }
        field(18145; "GST Jurisdiction Type"; Enum "GST Jurisdiction Type")
        {
            Caption = 'GST Jurisdiction Type';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(18146; "Invoice Type"; Enum "Sales Invoice Type")
        {
            Caption = 'Invoice Type';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(18147; Exempted; Boolean)
        {
            Caption = 'Exempted';
            DataClassification = CustomerContent;
        }
        field(18148; "GST Rounding Line"; Boolean)
        {
            Caption = 'GST Rounding Line';
            DataClassification = CustomerContent;
        }
        field(18149; "GST On Assessable Value"; Boolean)
        {
            Caption = 'GST On Assessable Value';
            DataClassification = CustomerContent;
        }
        field(18150; "GST Assessable Value (LCY)"; Decimal)
        {
            Caption = 'GST Assessable Value (LCY)';
            DataClassification = CustomerContent;
        }
        field(18151; "Non-GST Line"; Boolean)
        {
            Caption = 'Non-GST Line';
            DataClassification = CustomerContent;
        }
        field(18152; "Price Exclusive of Tax"; boolean)
        {
            Caption = 'Price Exclusive of Tax';
            DataClassification = CustomerContent;
        }
        field(18153; "GST Credit"; Enum "GST Credit")
        {
            Caption = 'GST Credit';
            DataClassification = CustomerContent;
        }
        field(18155; "Unit Price Incl. of Tax"; Decimal)
        {
            Caption = 'Unit Price Incl. of Tax';
            DataClassification = CustomerContent;
        }
        field(18156; "Total UPIT Amount"; Decimal)
        {
            Caption = 'Total UPIT Amount';
            DataClassification = CustomerContent;
        }
    }
}
