#if not CLEAN23
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.EU3PartyTrade;

using System.Environment.Configuration;

enumextension 4880 "Feature To Update - EU3 Party Trade" extends "Feature To Update"
{
    value(4880; EU3PartyTradePurchase)
    {
        Implementation = "Feature Data Update" = "EU3 Feature Data Update";
    }
}
#endif