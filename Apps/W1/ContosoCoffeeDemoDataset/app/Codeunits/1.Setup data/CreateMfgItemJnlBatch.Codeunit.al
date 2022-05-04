codeunit 4765 "Create Mfg Item Jnl Batch"
{
    Permissions = tabledata "Item Journal Batch" = ri;

    trigger OnRun()
    begin
        InsertData(XITEMTok);
    end;

    var
        XITEMTok: Label 'ITEM', MaxLength = 10, Comment = 'Must be the same as XITEMTok in CreateMfgJnlBatch codeunit';
        XDEFAULTTok: Label 'DEFAULT', MaxLength = 10;
        XDefaultJournalTok: Label 'Default Journal', MaxLength = 100;

    local procedure InsertData(JournalTemplateName: Code[10])
    var
        ItemJournalBatch: Record "Item Journal Batch";
    begin
        ItemJournalBatch.Init();
        ItemJournalBatch.Validate("Journal Template Name", JournalTemplateName);
        ItemJournalBatch.SetupNewBatch();
        ItemJournalBatch.Validate(Name, XDEFAULTTok);
        ItemJournalBatch.Validate(Description, XDefaultJournalTok);
        ItemJournalBatch.Insert(true);
    end;
}