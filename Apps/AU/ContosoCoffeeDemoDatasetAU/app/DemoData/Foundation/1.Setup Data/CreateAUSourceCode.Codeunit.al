codeunit 17158 "Create AU Source Code"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoSourceCode: Codeunit "Contoso Source Code";
    begin
        ContosoSourceCode.InsertSourceCode(CompressWHT(), DateCompressWHTEntriesLbl);
        ContosoSourceCode.InsertSourceCode(Start(), OpeningEntriesLbl);
        ContosoSourceCode.InsertSourceCode(WithholdingTaxStatement(), WithholdingTaxStatementLbl);
    end;

    procedure CompressWHT(): Code[10]
    begin
        exit(CompressWHTTok);
    end;

    procedure Start(): Code[10]
    begin
        exit(StartTok);
    end;

    procedure WithholdingTaxStatement(): Code[10]
    begin
        exit(WithholdingTaxStatementTok);
    end;

    var
        CompressWHTTok: Label 'COMPRWHT', MaxLength = 10;
        StartTok: Label 'START', MaxLength = 10;
        WithholdingTaxStatementTok: Label 'WHTSTMT', MaxLength = 10;
        DateCompressWHTEntriesLbl: Label 'Date Compress WHT Entries', MaxLength = 100;
        OpeningEntriesLbl: Label 'Opening Entries', MaxLength = 100;
        WithholdingTaxStatementLbl: Label 'Withholding Tax Statement', MaxLength = 100;
}