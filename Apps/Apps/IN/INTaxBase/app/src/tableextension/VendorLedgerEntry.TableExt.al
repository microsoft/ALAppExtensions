// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Payables;

tableextension 18551 "Vendor Ledger Entry" extends "Vendor Ledger Entry"
{
    fields
    {
        field(18543; "TDS Section Code"; Code[10])
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(18544; "Total TDS Including SHE CESS"; decimal)
        {
            DataClassification = EndUserIdentifiableInformation;
        }
    }
}
