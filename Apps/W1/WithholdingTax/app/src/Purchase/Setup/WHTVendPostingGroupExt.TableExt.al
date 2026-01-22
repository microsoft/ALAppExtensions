// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.WithholdingTax;

using Microsoft.Purchases.Vendor;

tableextension 6804 "WHT Vend Posting Group Ext" extends "Vendor Posting Group"
{
    fields
    {
        field(6804; "WHT Non-Taxable"; Boolean)
        {
            Caption = 'Non-Taxable';
            DataClassification = CustomerContent;
        }
    }
}