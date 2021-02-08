codeunit 31077 "Job Journal Line Handler CZL"
{
    [EventSubscriber(ObjectType::Table, Database::"Job Journal Line", 'OnBeforeValidateEvent', 'Entry Type', false, false)]
    local procedure InvtMovementTemplateOnBeforeValidateEntryType(var Rec: Record "Job Journal Line"; CurrFieldNo: Integer)
    begin
        if (Rec."Invt. Movement Template CZL" <> '') and (CurrFieldNo = Rec.FieldNo("Entry Type")) then
            Rec.TestField("Invt. Movement Template CZL", '');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Job Journal Line", 'OnBeforeValidateEvent', 'Gen. Bus. Posting Group', false, false)]
    local procedure InvtMovementTemplateOnBeforeValidateGenBusPostingGroup(var Rec: Record "Job Journal Line"; CurrFieldNo: Integer)
    begin
        if (Rec."Invt. Movement Template CZL" <> '') and (CurrFieldNo = Rec.FieldNo("Gen. Bus. Posting Group")) then
            Rec.TestField("Invt. Movement Template CZL", '');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Job Journal Line", 'OnAfterSetupNewLine', '', false, false)]
    local procedure InvtMovementTemplateOnAfterSetupNewLine(var JobJournalLine: Record "Job Journal Line"; LastJobJournalLine: Record "Job Journal Line")
    begin
        JobJournalLine.Validate("Invt. Movement Template CZL", LastJobJournalLine."Invt. Movement Template CZL");
    end;
}
