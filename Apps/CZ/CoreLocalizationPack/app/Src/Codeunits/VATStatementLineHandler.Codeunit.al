// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
namespace Microsoft.Finance.VAT.Reporting;

using System.Security.User;

codeunit 31322 "VAT Statement Line Handler CZL"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::VATStmtManagement, 'OnBeforeOpenStmt', '', false, false)]
    local procedure JournalTemplateUserRestrictionsOnBeforeOpenStmt(var VATStatementLine: Record "VAT Statement Line")
    var
        UserSetupAdvManagementCZL: Codeunit "User Setup Adv. Management CZL";
        UserSetupLineTypeCZL: Enum "User Setup Line Type CZL";
        JournalTemplateName: Code[10];
    begin
        JournalTemplateName := VATStatementLine.GetRangeMax("Statement Template Name");
        UserSetupLineTypeCZL := UserSetupLineTypeCZL::"VAT Statement";
        UserSetupAdvManagementCZL.CheckJournalTemplate(UserSetupLineTypeCZL, JournalTemplateName);
    end;
}
