#if not CLEANSCHEMA26
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.EU3PartyTrade;

codeunit 4888 "Upgrade EU3 Party Purchase"
{
    ObsoleteReason = 'EU 3rd party purchase app is moved to a new app.';
    ObsoleteState = Pending;
    ObsoleteTag = '26.0';

    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
    begin
    end;
}
#endif