// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets.Insurance;

using System.Security.User;

codeunit 31314 "Ins. Jnl.CheckLine Handler CZL"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Insurance Jnl.-Check Line", 'OnRunCheckOnBeforeCheckDimIDComb', '', false, false)]
    local procedure UserChecksAllowedOnRunCheckOnBeforeCheckDimIDComb(var InsuranceJnlLine: Record "Insurance Journal Line")
    begin
        if UserSetupAdvManagementCZL.IsCheckAllowed() then
            UserSetupAdvManagementCZL.CheckInsuranceJournalLine(InsuranceJnlLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::InsuranceJnlManagement, 'OnBeforeOpenJournal', '', false, false)]
    local procedure JournalTemplateUserRestrictionsOnBeforeOpenJournal(var InsuranceJournalLine: Record "Insurance Journal Line")
    var
        UserSetupLineTypeCZL: Enum "User Setup Line Type CZL";
        JournalTemplateName: Code[10];
    begin
        JournalTemplateName := InsuranceJournalLine.GetRangeMax("Journal Template Name");
        UserSetupLineTypeCZL := UserSetupLineTypeCZL::"Insurance Journal";
        UserSetupAdvManagementCZL.CheckJournalTemplate(UserSetupLineTypeCZL, JournalTemplateName);
    end;

    var
        UserSetupAdvManagementCZL: Codeunit "User Setup Adv. Management CZL";
}
