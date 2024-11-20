codeunit 11527 "Contoso General Ledger NL"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "Gen. Journal Template" = rim;

    var
        OverwriteData: Boolean;

    procedure InsertGeneralJournalTemplate(Name: Code[10]; Description: Text[80]; Type: Enum "Gen. Journal Template Type"; BalAccountType: Enum "Gen. Journal Account Type"; BalAccountNo: Code[20]; PageID: Integer; NoSeries: Code[20]; SourceCode: Code[10])
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
        GenJournalTemplate.Validate("Bal. Account Type", BalAccountType);
        GenJournalTemplate.Validate("Bal. Account No.", BalAccountNo);
        GenJournalTemplate.Validate("Page ID", PageID);
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
}