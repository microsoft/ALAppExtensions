// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Copilot;

using System.Upgrade;

codeunit 6294 "Sust. Emission Info. Upgrade"
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
        SustainabilityImp: Codeunit "Sust. Emis. Suggestion Impl.";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if not UpgradeTag.HasUpgradeTag(GetRegisterSustEmissionInfoCapabilityTag()) then begin
            SustainabilityImp.RegisterCapability();
            UpgradeTag.SetUpgradeTag(GetRegisterSustEmissionInfoCapabilityTag());
        end;
    end;

    internal procedure GetRegisterSustEmissionInfoCapabilityTag(): Code[250]
    begin
        exit('MS-506684-RegisterSustEmissionInfoCapability-20240917');
    end;
}