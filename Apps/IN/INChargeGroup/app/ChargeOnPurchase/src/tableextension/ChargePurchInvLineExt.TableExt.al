// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.History;

tableextension 18538 "Charge Purch. Inv. Line Ext." extends "Purch. Inv. Line"
{
    fields
    {
        field(18680; "Charge Group Code"; Code[10])
        {
            Caption = 'Charge Group Code';
            DataClassification = CustomerContent;
        }
        field(18681; "Charge Group Line No."; Integer)
        {
            Caption = 'Charge Group Line No.';
            DataClassification = CustomerContent;
        }
    }
}
