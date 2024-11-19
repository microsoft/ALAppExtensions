codeunit 17114 "Create NZ Source Code Setup"
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
        CreateNZSourceCode: Codeunit "Create NZ Source Code";
    begin
        SourceCodeSetup.Get();

        SourceCodeSetup.Validate("G/L Currency Revaluation", CreateNZSourceCode.GLCurrencyRevaluation());
        SourceCodeSetup.Modify(true);
    end;
}