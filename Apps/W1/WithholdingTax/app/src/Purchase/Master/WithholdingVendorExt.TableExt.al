// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.WithholdingTax;

using Microsoft.Purchases.Vendor;

tableextension 6784 "Withholding Vendor Ext" extends Vendor
{
    fields
    {
        field(6784; "Wthldg. Tax Bus. Post. Group"; Code[20])
        {
            Caption = 'Withholding Tax Bus. Post. Group';
            TableRelation = "Wthldg. Tax Bus. Post. Group";
            DataClassification = CustomerContent;
        }
        field(6789; "Withholding Tax Reg. ID"; Text[20])
        {
            Caption = 'Withholding Tax Registration ID';
            OptimizeForTextSearch = true;
        }
        field(6790; "Withholding Tax Liable"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Withholding Tax Liable';
        }
    }
}