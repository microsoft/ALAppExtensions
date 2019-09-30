// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1442 "Satisfaction Survey Upgr. Tag"
{
    Access = Internal;

    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerDatabaseUpgradeTags', '', false, false)]
    local procedure RegisterPerDatabaseTags(var PerDatabaseUpgradeTags: List of [Code[250]])
    begin
        PerDatabaseUpgradeTags.Add(GetRegisterControlAddInTag());
    end;

    procedure GetRegisterControlAddInTag(): Code[250]
    begin
        exit('MS-317654-RegistedSATControlAddIn-20190902');
    end;
}
