// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.EU3PartyTrade;

enum 4881 "EU3 Party Trade Filter"
{
    Extensible = true;
    value(0; "All")
    {
        Caption = 'All';
    }
    value(1; "EU3")
    {
        Caption = 'EU3';
    }
    value(2; "non-EU3")
    {
        Caption = 'non-EU3';
    }
}