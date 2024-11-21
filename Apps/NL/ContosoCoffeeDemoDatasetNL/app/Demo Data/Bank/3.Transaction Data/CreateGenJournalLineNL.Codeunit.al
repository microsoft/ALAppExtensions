codeunit 11544 "Create Gen. Journal Line NL"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;


    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertGenJournalLine(var Rec: Record "Gen. Journal Line")
    var
        CreateGenJournalTemplate: Codeunit "Create Gen. Journal Template";
        CreateBankJnlBatch: Codeunit "Create Bank Jnl. Batches";
    begin
        if (Rec."Journal Template Name" = CreateGenJournalTemplate.General()) and (Rec."Journal Batch Name" = CreateBankJnlBatch.Daily()) then
            case Rec."Line No." of
                10000:
                    Rec.Validate(Amount, -2757.62);
                20000:
                    Rec.Validate(Amount, -4136.43);
                30000:
                    Rec.Validate(Amount, -5515.24);
                40000:
                    Rec.Validate(Amount, -5515.24);
            end;
    end;
}