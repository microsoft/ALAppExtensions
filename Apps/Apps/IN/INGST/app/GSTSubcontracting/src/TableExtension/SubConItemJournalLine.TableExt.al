// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Journal;

tableextension 18466 "SubconItemJournalLine" extends "Item Journal Line"
{
    fields
    {
        field(18451; "Subcon Order No."; Code[20])
        {
            Caption = 'Subcon Order No.';
            DataClassification = EndUserIdentifiableInformation;
        }
    }

}
