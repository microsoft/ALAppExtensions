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