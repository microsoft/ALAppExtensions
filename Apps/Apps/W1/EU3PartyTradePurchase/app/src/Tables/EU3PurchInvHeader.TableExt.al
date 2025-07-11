// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.EU3PartyTrade;

using Microsoft.Purchases.History;

tableextension 4883 "EU3 Purch. Inv. Header" extends "Purch. Inv. Header"
{
    fields
    {
        field(4881; "EU 3 Party Trade"; Boolean)
        {
            Caption = 'EU 3-Party Trade';
        }
    }
}
