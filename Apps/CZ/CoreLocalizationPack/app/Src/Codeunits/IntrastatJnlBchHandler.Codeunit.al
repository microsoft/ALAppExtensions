codeunit 31049 "Intrastat Jnl. Bch Handler CZL"
{
    [EventSubscriber(ObjectType::Table, Database::"Intrastat Jnl. Batch", 'OnBeforeValidateEvent', 'Statistics Period', false, false)]
    local procedure CheckLBatchOnBeforeStatisticsPeriodValidate(var Rec: Record "Intrastat Jnl. Batch"; var xRec: Record "Intrastat Jnl. Batch")
    begin
        Rec.CheckUniqueDeclarationNoCZL();
        if xRec."Statistics Period" <> '' then
            Rec.CheckJnlLinesExistCZL(Rec.FieldNo("Statistics Period"));
    end;
}