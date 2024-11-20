codeunit 17113 "Create NZ Source Code"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoSourceCode: Codeunit "Contoso Source Code";
    begin
        ContosoSourceCode.SetOverwriteData(true);
        ContosoSourceCode.InsertSourceCode(GLCurrencyRevaluation(), GLCurrencyRevaluationLbl);
        ContosoSourceCode.SetOverwriteData(false);
    end;

    procedure GLCurrencyRevaluation(): Code[10]
    begin
        exit(GLCurrencyRevaluationTok);
    end;

    var
        GLCurrencyRevaluationTok: Label 'GLCURREVAL', MaxLength = 10;
        GLCurrencyRevaluationLbl: Label 'G/L Currency Revaluation', MaxLength = 100;
}