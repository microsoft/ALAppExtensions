codeunit 10788 "Create ES Source Code"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoSourceCode: Codeunit "Contoso Source Code";
    begin
        ContosoSourceCode.SetOverwriteData(true);
        ContosoSourceCode.InsertSourceCode(CarteraJournal(), CarteraJournalLbl);
        ContosoSourceCode.InsertSourceCode(GLCurrencyRevaluation(), GLCurrencyRevaluationLbl);
        ContosoSourceCode.SetOverwriteData(false);
    end;

    procedure CarteraJournal(): Code[10]
    begin
        exit(CarteraJournalTok);
    end;

    procedure GLCurrencyRevaluation(): Code[10]
    begin
        exit(GLCurrencyRevaluationTok);
    end;

    var
        CarteraJournalTok: Label 'CARJNL', MaxLength = 10;
        CarteraJournalLbl: Label 'Cartera Journal', MaxLength = 100;
        GLCurrencyRevaluationTok: Label 'GLCURREVAL', MaxLength = 10;
        GLCurrencyRevaluationLbl: Label 'G/L Currency Revaluation', MaxLength = 100;
}