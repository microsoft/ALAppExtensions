// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.WithholdingTax;

using Microsoft.Purchases.Document;
using Microsoft.Purchases.Vendor;

tableextension 6788 "Withholding Purch. Header Ext" extends "Purchase Header"
{
    fields
    {
        field(6784; "Wthldg. Tax Bus. Post. Group"; Code[20])
        {
            Caption = 'Withholding Tax Bus. Post. Group';
            TableRelation = "Wthldg. Tax Bus. Post. Group";
            DataClassification = CustomerContent;
        }
        field(6785; "Withholding Tax Amount"; Decimal)
        {
            Caption = 'Withholding Tax Amount';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(6793; "WHT Actual Vendor No."; Code[20])
        {
            Caption = 'Actual Vendor No.';
            TableRelation = Vendor;
            DataClassification = CustomerContent;
        }
    }
}