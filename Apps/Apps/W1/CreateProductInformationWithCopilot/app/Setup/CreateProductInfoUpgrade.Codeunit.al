// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Item.Substitution;

using System.Upgrade;

codeunit 7332 "Create Product Info. Upgrade"
{
    Access = Internal;
    Subtype = Upgrade;
    InherentPermissions = X;
    InherentEntitlements = X;

    trigger OnUpgradePerDatabase()
    begin
        RegisterCapability();
    end;

    local procedure RegisterCapability()
    var
        ItemSubstSuggestUtility: Codeunit "Create Product Info. Utility";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if not UpgradeTag.HasUpgradeTag(GetRegisterCreateProductInfoCapabilityTag()) then begin
            ItemSubstSuggestUtility.RegisterCapability();
            UpgradeTag.SetUpgradeTag(GetRegisterCreateProductInfoCapabilityTag());
        end;
    end;

    internal procedure GetRegisterCreateProductInfoCapabilityTag(): Code[250]
    begin
        exit('MS-485571-RegisterCreateProductInfoCapability-20240319');
    end;
}