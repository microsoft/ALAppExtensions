codeunit 31373 "Gen. Jnl.Post Line Handler CZA"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Check Line", 'OnBeforeCheckAppliesToDocNo', '', false, false)]
    local procedure EnableGLAccountApplicationOnBeforeCheckAppliesToDocNo(GenJnlLine: Record "Gen. Journal Line"; var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterInsertGlobalGLEntry', '', false, false)]
    local procedure GLEntryPostApplicationOnAfterInsertGlobalGLEntry(var GLEntry: Record "G/L Entry")
    var
        GLEntryPostApplicationCZA: Codeunit "G/L Entry Post Application CZA";
    begin
        if GLEntry."Applies-to ID CZA" <> '' then begin
            GLEntryPostApplicationCZA.NotUseRequestPage();
            GLEntryPostApplicationCZA.PostApplyGLEntry(GLEntry);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnPostGLAccOnBeforeInsertGLEntry', '', false, false)]
    local procedure GLEntryPostApplicationOnPostGLAccOnBeforeInsertGLEntry(var GenJournalLine: Record "Gen. Journal Line"; var GLEntry: Record "G/L Entry")
    var
        GLEntryPostApplicationCZA: Codeunit "G/L Entry Post Application CZA";
    begin
        GLEntryPostApplicationCZA.AutomatedGLEntryApplication(GenJournalLine, GLEntry);
    end;
}
