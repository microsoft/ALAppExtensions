codeunit 17159 "Create AU Source Code Setup"
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
        CreateAUSourceCode: Codeunit "Create AU Source Code";
    begin
        SourceCodeSetup.Get();

        SourceCodeSetup.Validate("WHT Settlement", CreateAUSourceCode.WithholdingTaxStatement());
        SourceCodeSetup.Modify(true);
    end;
}