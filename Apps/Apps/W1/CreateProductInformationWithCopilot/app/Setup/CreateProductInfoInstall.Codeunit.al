// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Item.Substitution;

codeunit 7331 "Create Product Info. Install"
{
    Access = Internal;
    Subtype = Install;
    InherentPermissions = X;
    InherentEntitlements = X;

    trigger OnInstallAppPerCompany()
    var
        ItemSubstSuggestUtility: Codeunit "Create Product Info. Utility";
    begin
        ItemSubstSuggestUtility.RegisterCapability();
    end;
}