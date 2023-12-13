// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Archive;

using Microsoft.Finance.ChargeGroup.ChargeGroupBase;

tableextension 18536 "Charge Purch. Header Arch. Ext" extends "Purchase Header Archive"
{
    fields
    {
        field(18675; "Charge Group Code"; Code[10])
        {
            Caption = 'Charge Group Code';
            DataClassification = CustomerContent;
            TableRelation = "Charge Group Header";
        }
        field(18676; "Third Party"; Boolean)
        {
            Caption = 'Third Party';
            DataClassification = CustomerContent;
        }
        field(18677; "Charge Refernce Invoice No."; Code[20])
        {
            Caption = 'Charge Refernce Invoice No.';
            DataClassification = CustomerContent;
        }
    }
}
