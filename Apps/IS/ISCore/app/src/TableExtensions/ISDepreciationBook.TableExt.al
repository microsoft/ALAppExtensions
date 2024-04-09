// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets.Depreciation;

tableextension 14601 "IS Depreciation Book" extends "Depreciation Book"
{
    fields
    {

        field(14600; "Revalue in Year Prch."; Boolean)
        {
            Caption = 'Revalue in Year Purch.';
            DataClassification = CustomerContent;
        }

        field(14601; "Residual Val. %"; Decimal)
        {
            Caption = 'Residual Value %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 0;
        }

    }
}
