// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.WithholdingTax;

using Microsoft.Purchases.History;

tableextension 6791 "Withholding Purch Inv Line Ext" extends "Purch. Inv. Line"
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
            AutoFormatType = 1;
            AutoFormatExpression = GetCurrencyCode();
            Caption = 'Withholding Tax Absorb Base';
            DataClassification = CustomerContent;
        }
    }
}