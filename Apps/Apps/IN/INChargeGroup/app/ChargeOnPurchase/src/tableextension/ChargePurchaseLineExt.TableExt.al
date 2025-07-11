// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Document;

using Microsoft.Finance.ChargeGroup.ChargeGroupBase;

tableextension 18533 "Charge Purchase Line Ext" extends "Purchase Line"
{
    fields
    {
        field(18680; "Charge Group Code"; Code[10])
        {
            Caption = 'Charge Group Code';
            DataClassification = CustomerContent;
            TableRelation = "Charge Group Header";
        }
        field(18681; "Charge Group Line No."; Integer)
        {
            Caption = 'Charge Group Line No.';
            DataClassification = CustomerContent;
        }
    }
}
