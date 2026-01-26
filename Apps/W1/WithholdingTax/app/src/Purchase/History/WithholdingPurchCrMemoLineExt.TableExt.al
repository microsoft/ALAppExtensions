// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.WithholdingTax;

using Microsoft.Purchases.History;

tableextension 6794 "WithholdingPurchCrMemoLineExt" extends "Purch. Cr. Memo Line"
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
        field(6787; "WHT Paid Amount Incl. VAT"; Decimal)
        {
            Caption = 'Paid Amount Incl. VAT';
            DataClassification = CustomerContent;
        }
        field(6788; "WHT Paid VAT"; Decimal)
        {
            Caption = 'Paid VAT';
            DataClassification = CustomerContent;
        }
        field(6789; "WHT External Document No."; Code[35])
        {
            Caption = 'External Document No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
    }
}