// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance;

#if CLEAN24
using System.Upgrade;
#endif

codeunit 14602 "IS Core Upgrade"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
    begin
        TransferISCpecificData();
    end;

    local procedure TransferISCpecificData()
    var
#if CLEAN24
        UpgradeTag: Codeunit "Upgrade Tag";
        EnableISCoreApp: Codeunit "Enable IS Core App";
#endif
    begin
#if CLEAN24
        if UpgradeTag.HasUpgradeTag(EnableISCoreApp.GetISCoreAppUpdateTag()) then
            exit;
            
        EnableISCoreApp.TransferData();

        UpgradeTag.SetUpgradeTag(EnableISCoreApp.GetISCoreAppUpdateTag());
#endif
    end;
}