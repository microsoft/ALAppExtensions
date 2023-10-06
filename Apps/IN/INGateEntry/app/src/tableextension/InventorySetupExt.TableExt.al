// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Setup;

using Microsoft.Foundation.NoSeries;

tableextension 18605 "Inventory Setup Ext" extends "Inventory Setup"
{
    fields
    {
        field(18601; "Inward Gate Entry Nos."; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(18602; "Outward Gate Entry Nos."; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
    }
}
