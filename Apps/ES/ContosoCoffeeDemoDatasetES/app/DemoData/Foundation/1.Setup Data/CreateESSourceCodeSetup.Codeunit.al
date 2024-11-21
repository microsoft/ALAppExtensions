codeunit 10789 "Create ES Source Code Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        UpdateSourceCodeSetup();
    end;

    local procedure UpdateSourceCodeSetup()
    var
        SourceCodeSetup: Record "Source Code Setup";
        CreateESSourceCode: Codeunit "Create ES Source Code";
    begin
        SourceCodeSetup.Get();

        SourceCodeSetup.Validate("G/L Currency Revaluation", CreateESSourceCode.GLCurrencyRevaluation());
        SourceCodeSetup.Validate("Cartera Journal", CreateESSourceCode.CarteraJournal());
        SourceCodeSetup.Modify(true);
    end;
}