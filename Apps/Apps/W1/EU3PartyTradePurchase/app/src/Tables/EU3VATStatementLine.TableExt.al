// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.EU3PartyTrade;

using Microsoft.Finance.VAT.Reporting;

tableextension 4881 "EU3 VAT Statement Line" extends "VAT Statement Line"
{
    fields
    {
        field(4881; "EU 3 Party Trade"; Enum "EU3 Party Trade Filter")
        {
            Caption = 'EU 3-Party Trade Filter';
        }
    }
}
