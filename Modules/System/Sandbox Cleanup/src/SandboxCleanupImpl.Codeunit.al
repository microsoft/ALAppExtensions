// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1885 "Sandbox Cleanup Impl."
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Triggers", 'OnAfterCopyEnvironmentToSandbox', '', false, false)]
    local procedure FireIntegrationEvent()
    var
        SandboxCleanup: Codeunit "Sandbox Cleanup";
    begin
#if not CLEAN17
        SandboxCleanup.OnClearConfiguration('');
#endif
        SandboxCleanup.OnClearDatabaseConfiguration();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Triggers", 'OnAfterCopyEnvironmentToSandboxPerCompany', '', false, false)]
    local procedure FireIntegrationEventPerCompany()
    var
        SandboxCleanup: Codeunit "Sandbox Cleanup";
    begin
#if not CLEAN17
        SandboxCleanup.OnClearConfiguration(CompanyName());
#endif
        SandboxCleanup.OnClearCompanyConfiguration(CompanyName());
    end;
}

