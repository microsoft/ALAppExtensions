// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Setup;

using Microsoft.Sales.History;

tableextension 10565 "Sales Invoice Line" extends "Sales Invoice Line"
{
    fields
    {
        field(10507; "Reverse Charge Item GB"; Boolean)
        {
            Caption = 'Reverse Charge Item';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(10508; "Reverse Charge GB"; Decimal)
        {
            Caption = 'Reverse Charge';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            AutoFormatExpression = GetCurrencyCode();
        }
    }
}