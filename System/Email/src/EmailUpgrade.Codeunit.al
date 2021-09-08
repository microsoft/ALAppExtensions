// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1597 "Email Upgrade"
{
    Subtype = Upgrade;
    Access = Internal;

    trigger OnUpgradePerCompany()
    var
        EmailInstaller: Codeunit "Email Installer";
    begin
        EmailInstaller.AddRetentionPolicyAllowedTables(); // also sets the tag
    end;
}