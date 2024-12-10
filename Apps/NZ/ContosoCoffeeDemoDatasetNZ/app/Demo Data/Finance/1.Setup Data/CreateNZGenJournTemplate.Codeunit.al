codeunit 17146 "Create NZ Gen. Journ. Template"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoGeneralLedger: Codeunit "Contoso General Ledger";
    begin
        ContosoGeneralLedger.InsertGeneralJournalTemplate(PostDated(), PostDatedChecksLbl, Enum::"Gen. Journal Template Type"::"Post Dated", Page::"General Journal", '', false);
        UpdateSourceCodeOnGenJournalTemplate(PostDated(), PostDatedSourceCodeLbl);
    end;

    local procedure UpdateSourceCodeOnGenJournalTemplate(TemplateName: Code[10]; SourceCode: Code[10])
    var
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        if GenJournalTemplate.Get(TemplateName) then begin
            GenJournalTemplate.Validate("Source Code", SourceCode);
            GenJournalTemplate.Modify(true);
        end;
    end;

    procedure PostDated(): Code[10]
    begin
        exit(PostDatedTok);
    end;

    var
        PostDatedChecksLbl: Label 'Post Dated Checks', MaxLength = 80;
        PostDatedTok: Label 'POSTDATED', MaxLength = 10;
        PostDatedSourceCodeLbl: Label 'GENJNL', MaxLength = 10;
}