// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1885 "Sandbox Cleanup Impl."
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Triggers", 'OnAfterCopyEnvironmentToSandbox', '', false, false)]
    local procedure FireIntegrationEvent()
    begin
        RaiseEventForEveryCompany();
    end;

    local procedure RaiseEventForEveryCompany()
    var
        Company: Record Company;
        SandboxCleanup: Codeunit "Sandbox Cleanup";
    begin
        if Company.FindSet() then
            repeat
                SandboxCleanup.OnClearConfiguration(Company.Name);
                SandboxCleanup.OnClearCompanyConfiguration(Company.Name);
            until Company.Next() = 0;

        SandboxCleanup.OnClearConfiguration('');
        SandboxCleanup.OnClearDatabaseConfiguration();
    end;
}

