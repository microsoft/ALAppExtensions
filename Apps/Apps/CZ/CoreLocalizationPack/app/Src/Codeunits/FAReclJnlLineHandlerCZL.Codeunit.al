// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets.Journal;

using System.Security.User;

codeunit 31323 "FA Recl. Jnl. Line Handler CZL"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::FAReclassJnlManagement, 'OnBeforeOpenJournal', '', false, false)]
    local procedure JournalTemplateUserRestrictionsOnBeforeOpenJournal(var FAReclassJournalLine: Record "FA Reclass. Journal Line")
    var
        UserSetupAdvManagementCZL: Codeunit "User Setup Adv. Management CZL";
        UserSetupLineTypeCZL: Enum "User Setup Line Type CZL";
        JournalTemplateName: Code[10];
    begin
        JournalTemplateName := FAReclassJournalLine.GetRangeMax("Journal Template Name");
        UserSetupLineTypeCZL := UserSetupLineTypeCZL::"FA Reclass. Journal";
        UserSetupAdvManagementCZL.CheckJournalTemplate(UserSetupLineTypeCZL, JournalTemplateName);
    end;
}
