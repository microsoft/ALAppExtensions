// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Journal;

using Microsoft.Inventory.Location;

tableextension 18552 "General Journal Batch" extends "Gen. Journal Batch"
{
    fields
    {
        field(18552; "Location Code"; Code[10])
        {
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = Location;
        }
    }
}
