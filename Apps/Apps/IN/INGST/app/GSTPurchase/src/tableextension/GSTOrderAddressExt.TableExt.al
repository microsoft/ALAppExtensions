// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Vendor;

using Microsoft.Finance.TaxBase;

tableextension 18080 "GST Order Address Ext" extends "Order Address"
{
    fields
    {
        field(18080; State; Code[10])
        {
            Caption = 'State';
            DataClassification = CustomerContent;
            TableRelation = State;
        }
        field(18081; "GST Registration No."; Code[20])
        {
            Caption = 'GST Registration No.';
            DataClassification = CustomerContent;
        }
        field(18082; "ARN No."; Code[20])
        {
            Caption = 'ARN No.';
            DataClassification = CustomerContent;
        }
    }
}
