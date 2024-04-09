codeunit 5112 "Contoso General Ledger"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "Gen. Journal Template" = rim,
        tabledata "Gen. Journal Batch" = rim;

    var
        OverwriteData: Boolean;

    procedure InsertGeneralJournalTemplate(Name: Code[10]; Description: Text[80]; Type: Enum "Gen. Journal Template Type"; Recurring: Boolean; NoSeries: Code[20]; SourceCode: Code[10])
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        Exists: Boolean;
    begin
        if GenJournalTemplate.Get(Name) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        GenJournalTemplate.Validate(Name, Name);
        GenJournalTemplate.Validate(Description, Description);
        GenJournalTemplate.Validate(Type, Type);
        GenJournalTemplate.Validate(Recurring, Recurring);
        GenJournalTemplate.Validate("No. Series", NoSeries);

        if Exists then
            GenJournalTemplate.Modify(true)
        else
            GenJournalTemplate.Insert(true);

        if SourceCode <> '' then begin
            GenJournalTemplate.Validate("Source Code", SourceCode);
            GenJournalTemplate.Modify(true);
        end;
    end;

    procedure InsertGeneralJournalBatch(TemplateName: Code[10]; Name: Code[10]; Description: Text[100])
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        Exists: Boolean;
    begin
        if GenJournalBatch.Get(TemplateName, Name) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        GenJournalBatch.Validate("Journal Template Name", TemplateName);
        GenJournalBatch.SetupNewBatch();
        GenJournalBatch.Validate(Name, Name);
        GenJournalBatch.Validate(Description, Description);

        if Exists then
            GenJournalBatch.Modify(true)
        else
            GenJournalBatch.Insert(true);
    end;
}