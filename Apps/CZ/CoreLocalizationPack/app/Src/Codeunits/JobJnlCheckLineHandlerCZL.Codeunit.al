// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Projects.Project.Posting;

using Microsoft.Projects.Project.Journal;
using System.Security.User;

codeunit 31312 "Job Jnl.Check Line Handler CZL"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Job Jnl.-Check Line", 'OnAfterRunCheck', '', false, false)]
    local procedure UserChecksAllowedOnAfterRunCheck(var JobJnlLine: Record "Job Journal Line")
    begin
        if UserSetupAdvManagementCZL.IsCheckAllowed() then
            UserSetupAdvManagementCZL.CheckJobJournalLine(JobJnlLine);
    end;

    var
        UserSetupAdvManagementCZL: Codeunit "User Setup Adv. Management CZL";
}
