// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.EU3PartyTrade;

using Microsoft.Finance.VAT.Setup;
using System.Environment.Configuration;

codeunit 4881 "EU3 Party Trade Feature Mgt."
{
    Permissions = TableData "Feature Key" = rm,
                TableData "VAT Setup" = r;
    Access = Internal;
    InherentPermissions = X;
    InherentEntitlements = X;

    procedure IsEnabled(): Boolean
    var
        VATSetup: Record "VAT Setup";
    begin
        if not VATSetup.ReadPermission() then
           exit(false);
        if not VATSetup.Get() then
            exit(false);
        exit(VATSetup."Enable EU 3-Party Purchase");
    end;

    procedure IsFeatureKeyEnabled(): Boolean
    begin
        exit(true);
    end;
}