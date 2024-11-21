codeunit 12228 "Create Source Code Setup IT"
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
        CreateSourceCodeIT: Codeunit "Create Source Code IT";
    begin
        SourceCodeSetup.Get();

        SourceCodeSetup.Validate("G/L Currency Revaluation", CreateSourceCodeIT.GLCurReval());
        SourceCodeSetup.Modify(true);
    end;
}