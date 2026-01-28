// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.WithholdingTax;

using Microsoft.Purchases.Document;

tableextension 6789 "Withholding Purch. Line Ext" extends "Purchase Line"
{
    fields
    {
        field(6784; "Wthldg. Tax Bus. Post. Group"; Code[20])
        {
            Caption = 'Withholding Tax Bus. Post. Group';
            TableRelation = "Wthldg. Tax Bus. Post. Group";
            DataClassification = CustomerContent;
        }
        field(6785; "Wthldg. Tax Prod. Post. Group"; Code[20])
        {
            Caption = 'Withholding Tax Prod. Post. Group';
            TableRelation = "Wthldg. Tax Prod. Post. Group";
            DataClassification = CustomerContent;
        }
        field(6786; "Withholding Tax Absorb Base"; Decimal)
        {
            Caption = 'Withholding Tax Absorb Base';
            DataClassification = CustomerContent;
        }
    }
}