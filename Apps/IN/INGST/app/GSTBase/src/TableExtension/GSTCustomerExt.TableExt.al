// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Customer;

using Microsoft.Finance.GST.Base;

tableextension 18016 "GST Customer Ext" extends Customer
{
    fields
    {
        field(18000; "GST Registration No."; code[20])
        {
            Caption = 'GST Registration No.';
            DataClassification = CustomerContent;
        }
        field(18001; "GST Registration Type"; Enum "GST Registration Type")
        {
            Caption = 'GST Registration Type';
            DataClassification = CustomerContent;
        }
        field(18002; "GST Customer Type"; Enum "GST Customer Type")
        {
            Caption = 'GST Customer Type';
            DataClassification = CustomerContent;
        }
        field(18003; "E-Commerce Operator"; Boolean)
        {
            Caption = 'E-Commerce Operator';
            DataClassification = CustomerContent;
        }
        field(18004; "ARN No."; Code[20])
        {
            Caption = 'ARN No.';
            DataClassification = CustomerContent;
        }
        field(18005; "Post GST to Customer"; Boolean)
        {
            Caption = 'Post GST to Customer';
            DataClassification = CustomerContent;
        }
    }
}
