// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.EU3PartyTrade;

permissionset 4880 "EU3PartyTrade - Objects"
{
    Assignable = false;
    Access = Public;
    Caption = 'EU3PartyTrade - Objects';
    Permissions = codeunit "EU3 Gen. Jnl. Subscribers" = X,
        codeunit "EU3 Party Trade Feature Mgt." = X,
        codeunit "EU3 Purch.-Get Drop Shpt Sbscr" = X,
        codeunit "EU3 Req. Wksh. Subscribers" = X,
        codeunit "EU3 VAT Stat. Subscribers" = X;
}