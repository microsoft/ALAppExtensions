// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.WithholdingTax;

using Microsoft.Purchases.Archive;

tableextension 6803 "WHT Purchase Header Archive" extends "Purchase Header Archive"
{
    fields
    {
        field(6784; "Wthldg. Tax Bus. Post. Group"; Code[20])
        {
            Caption = 'Withholding Tax Bus. Post. Group';
            TableRelation = "Wthldg. Tax Bus. Post. Group";
            DataClassification = CustomerContent;
        }
    }
}