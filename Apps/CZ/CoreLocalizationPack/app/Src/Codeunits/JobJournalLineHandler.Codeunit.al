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

    [EventSubscriber(ObjectType::Table, Database::"Job Journal Line", 'OnAfterAssignItemValues', '', false, false)]
    local procedure CopyFromItemOnAfterAssignItemValues(var JobJournalLine: Record "Job Journal Line"; Item: Record Item)
    begin
        JobJournalLine."Tariff No. CZL" := Item."Tariff No.";
        JobJournalLine."Statistic Indication CZL" := Item."Statistic Indication CZL";
        JobJournalLine."Net Weight CZL" := Item."Net Weight";
        JobJournalLine."Country/Reg. of Orig. Code CZL" := Item."Country/Region of Origin Code";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Job Journal Line", 'OnCheckJobJournalTemplateUserRestrictions', '', false, false)]
    local procedure CheckJobJournalTemplateUserRestrictions(JournalTemplateName: Code[10])
    var
        DummyUserSetupLineCZL: Record "User Setup Line CZL";
        UserSetupAdvManagementCZL: Codeunit "User Setup Adv. Management CZL";
    begin
        UserSetupAdvManagementCZL.CheckJournalTemplate(DummyUserSetupLineCZL.Type::"Job Journal", JournalTemplateName);
    end;
}
