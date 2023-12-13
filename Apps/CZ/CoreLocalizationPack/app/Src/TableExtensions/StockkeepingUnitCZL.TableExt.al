// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Location;

using Microsoft.Finance.GeneralLedger.Setup;

tableextension 11767 "Stockkeeping Unit CZL" extends "Stockkeeping Unit"
{
    fields
    {
        field(31069; "Gen. Prod. Posting Group CZL"; Code[20])
        {
            Caption = 'Gen. Prod. Posting Group';
            TableRelation = "Gen. Product Posting Group";
            DataClassification = CustomerContent;
        }
    }
}
