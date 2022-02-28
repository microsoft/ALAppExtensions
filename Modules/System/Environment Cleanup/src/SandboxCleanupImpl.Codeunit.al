#if not CLEAN20
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1885 "Sandbox Cleanup Impl."
{
    ObsoleteReason = 'Replaced by Environment Cleanup module.';
    ObsoleteState = Pending;
    ObsoleteTag = '20.0';

    Access = Internal;
    Permissions = tabledata Company = r;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Triggers", 'OnAfterCopyEnvironmentToSandbox', '', false, false)]
    local procedure FireIntegrationEvent()
    var
        SandboxCleanup: Codeunit "Sandbox Cleanup";
    begin
#if not CLEAN17
#pragma warning disable AL0432
        SandboxCleanup.OnClearConfiguration('');
#pragma warning restore
#endif
        SandboxCleanup.OnClearDatabaseConfiguration();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Triggers", 'OnAfterCopyEnvironmentToSandboxPerCompany', '', false, false)]
    local procedure FireIntegrationEventPerCompany()
    var
        SandboxCleanup: Codeunit "Sandbox Cleanup";
    begin
#if not CLEAN17
#pragma warning disable AL0432
        SandboxCleanup.OnClearConfiguration(CompanyName());
#pragma warning restore
#endif
        SandboxCleanup.OnClearCompanyConfiguration(CompanyName());
    end;
}
#endif

