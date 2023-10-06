// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Foundation.Shipping;

tableextension 18156 "GST Shipping Agent Ext" extends "Shipping Agent"
{
    fields
    {
        field(18141; "GST Registration No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'GST Registration No.';
        }
    }
}
