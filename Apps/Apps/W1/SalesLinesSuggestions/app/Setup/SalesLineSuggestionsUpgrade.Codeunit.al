// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

using System.Upgrade;

codeunit 7278 "Sales Line Suggestions Upgrade"
{
    Subtype = Upgrade;
    InherentPermissions = X;
    InherentEntitlements = X;

    trigger OnUpgradePerDatabase()
    begin
        RegisterCapability();
    end;

    local procedure RegisterCapability()
    var
        SalesLinesSuggestionsImpl: Codeunit "Sales Lines Suggestions Impl.";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if not UpgradeTag.HasUpgradeTag(GetRegisterSalesLinesSuggestionsCapabilityTag()) then begin
            SalesLinesSuggestionsImpl.RegisterCapability();
            UpgradeTag.SetUpgradeTag(GetRegisterSalesLinesSuggestionsCapabilityTag());
        end;
    end;


    internal procedure GetRegisterSalesLinesSuggestionsCapabilityTag(): Code[250]
    begin
        exit('MS-485919-RegisterSalesLinesSuggestionsCapability-20240209');
    end;

}