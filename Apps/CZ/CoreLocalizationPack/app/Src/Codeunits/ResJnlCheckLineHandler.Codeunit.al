// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Projects.Resources.Journal;

using System.Security.User;

codeunit 31308 "Res.Jnl.Check Line Handler CZL"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Res. Jnl.-Check Line", 'OnAfterRunCheck', '', false, false)]
    local procedure UserChecksAllowedOnAfterRunCheck(var ResJournalLine: Record "Res. Journal Line")
    begin
        if UserSetupAdvManagementCZL.IsCheckAllowed() then
            UserSetupAdvManagementCZL.CheckResJournalLine(ResJournalLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::ResJnlManagement, 'OnBeforeOpenJnl', '', false, false)]
    local procedure JournalTemplateUserRestrictionsOnBeforeOpenJnl(var ResJournalLine: Record "Res. Journal Line")
    var
        UserSetupLineTypeCZL: Enum "User Setup Line Type CZL";
        JournalTemplateName: Code[10];
    begin
        JournalTemplateName := ResJournalLine.GetRangeMax("Journal Template Name");
        UserSetupLineTypeCZL := UserSetupLineTypeCZL::"Resource Journal";
        UserSetupAdvManagementCZL.CheckJournalTemplate(UserSetupLineTypeCZL, JournalTemplateName);
    end;

    var
        UserSetupAdvManagementCZL: Codeunit "User Setup Adv. Management CZL";
}
