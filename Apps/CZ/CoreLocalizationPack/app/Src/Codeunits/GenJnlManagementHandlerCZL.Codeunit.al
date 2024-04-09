// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Journal;

using System.Security.User;

codeunit 31138 "GenJnlManagement Handler CZL"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::GenJnlManagement, 'OnTemplateSelectionSetFilter', '', false, false)]
    local procedure SetFilterTemplateNameOnTemplateSelectionSetFilter(var GenJnlTemplate: Record "Gen. Journal Template"; var GenJnlLine: Record "Gen. Journal Line")
    begin
        if GenJnlLine.GetFilter("Journal Template Name") <> '' then
            GenJnlLine.CopyFilter("Journal Template Name", GenJnlTemplate.Name);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::GenJnlManagement, 'OnBeforeRunTemplateJournalPage', '', false, false)]
    local procedure ClearFilterTemplateNameOnBeforeRunTemplateJournalPage(var GenJnlLine: Record "Gen. Journal Line")
    begin
        GenJnlLine.SetRange("Journal Template Name");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::GenJnlManagement, 'OnBeforeOpenJnl', '', false, false)]
    local procedure JournalTemplateUserRestrictionsOnBeforeOpenJnl(var CurrentJnlBatchName: Code[10]; var GenJnlLine: Record "Gen. Journal Line")
    var
        UserSetupAdvManagementCZL: Codeunit "User Setup Adv. Management CZL";
        UserSetupLineTypeCZL: Enum "User Setup Line Type CZL";
        JournalTemplateName: Code[10];
    begin
        JournalTemplateName := GenJnlLine.GetRangeMax("Journal Template Name");
        UserSetupLineTypeCZL := UserSetupLineTypeCZL::"General Journal";
        UserSetupAdvManagementCZL.CheckJournalTemplate(UserSetupLineTypeCZL, JournalTemplateName);

        if GenJnlLine.GetFilter("Journal Batch Name") <> '' then begin
            CurrentJnlBatchName := GenJnlLine.GetRangeMax("Journal Batch Name");
            GenJnlLine.SetRange("Journal Batch Name");
        end;
    end;
}