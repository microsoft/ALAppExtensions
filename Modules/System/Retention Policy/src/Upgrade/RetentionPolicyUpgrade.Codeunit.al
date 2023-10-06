// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.DataAdministration;

codeunit 3914 "Retention Policy Upgrade"
{
    Subtype = Upgrade;
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnUpgradePerCompany()
    var
        RetentionPolicyInstaller: Codeunit "Retention Policy Installer";
    begin
        RetentionPolicyInstaller.AddAllowedTables(); // also sets the tag!
    end;
}