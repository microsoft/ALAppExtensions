// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Agent.SalesOrderTaker.Integration;

using System.Upgrade;

codeunit 4589 "SOA Upgrade"
{
    Access = Internal;
    Subtype = Upgrade;

    InherentEntitlements = X;
    InherentPermissions = X;

    var
        SOAImpl: Codeunit "SOA Impl";

    trigger OnUpgradePerDatabase()
    begin
        RegisterCapability();
    end;

    local procedure RegisterCapability()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if not UpgradeTag.HasUpgradeTag(GetRegisterMarketingTextCapabilityTag()) then begin
            SOAImpl.RegisterCapability();

            UpgradeTag.SetUpgradeTag(GetRegisterMarketingTextCapabilityTag());
        end;
    end;

    internal procedure GetRegisterMarketingTextCapabilityTag(): Code[250]
    begin
        exit('MS-539550-RegisterMarketingTextCapability-20240802');
    end;

}