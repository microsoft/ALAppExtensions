// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Projects.Project.Job;

using System.Security.User;

codeunit 31324 "Job Handler CZL"
{
    [EventSubscriber(ObjectType::Table, Database::Job, 'OnBeforeChangeJobCompletionStatus', '', false, false)]
    local procedure CheckCompleteJobOnBeforeChangeJobCompletionStatus()
    begin
        if UserSetupAdvManagementCZL.IsCheckAllowed() then
            UserSetupAdvManagementCZL.CheckCompleteJob();
    end;

    var
        UserSetupAdvManagementCZL: Codeunit "User Setup Adv. Management CZL";
}
