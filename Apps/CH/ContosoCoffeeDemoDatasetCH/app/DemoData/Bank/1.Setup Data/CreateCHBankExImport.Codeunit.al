codeunit 11587 "Create CH Bank Ex/Import"
{
    trigger OnRun()
    var
        ContosoBank: Codeunit "Contoso Bank";
        CreateCHDataExchange: Codeunit "Create CH Data Exchange";
    begin
        ContosoBank.ContosoBankExportImportSetup(SEPACAMT054(), SEPACAMT054Tok, 1, Codeunit::"Exp. Launcher Gen. Jnl.", 0, CreateCHDataExchange.CEPACAMT054(), true, 0);
        ContosoBank.ContosoBankExportImportSetup(SEPACAMT05302(), SEPACAMT05302Tok, 1, Codeunit::"Exp. Launcher Gen. Jnl.", 0, CreateCHDataExchange.CEPACAMT05302(), true, 0);
        ContosoBank.ContosoBankExportImportSetup(SEPACAMT05304(), SEPACAMT05304Tok, 1, Codeunit::"Exp. Launcher Gen. Jnl.", 0, CreateCHDataExchange.CEPACAMT05304(), true, 0);

        ContosoBank.ContosoBankExportImportSetup(SEPASwiss(), SEPASwissLbl, 0, Codeunit::"Swiss SEPA CT-Export File", Xmlport::"SEPA CT pain.001.001.03", '', false, Codeunit::"SEPA CT-Check Line");
        ContosoBank.ContosoBankExportImportSetup(SEPACTPAIN00100109(), SEPACTPAIN00100109Lbl, 0, Codeunit::"SEPA CT-Export File", Xmlport::"SEPA CT pain.001.001.09", '', false, Codeunit::"SEPA CT-Check Line");
        ContosoBank.ContosoBankExportImportSetup(SEPACTSWISS00100109(), SEPACTSWISS00100109Lbl, 0, Codeunit::"Swiss SEPA CT-Export File", Xmlport::"SEPA CT pain.001.001.09", '', false, Codeunit::"SEPA CT-Check Line");

        ContosoBank.ContosoBankExportImportSetup(SEPADDSwiss(), SEPADDSwissLbl, 0, Codeunit::"Swiss SEPA DD-Export File", Xmlport::"SEPA DD pain.008.001.02.ch03", '', false, Codeunit::"SEPA DD-Check Line");
        ContosoBank.ContosoBankExportImportSetup(SEPADDPAIN00800108(), SEPADDPAIN00800108Lbl, 0, Codeunit::"SEPA DD-Export File", Xmlport::"SEPA DD pain.008.001.08", '', false, Codeunit::"SEPA DD-Check Line");
        ContosoBank.ContosoBankExportImportSetup(SEPADDSWISS00800108(), SEPADDSWISS00800108Lbl, 0, Codeunit::"Swiss SEPA DD-Export File", Xmlport::"SEPA DD pain.008.001.08", '', false, Codeunit::"SEPA DD-Check Line");
    end;

    procedure SEPACAMT054(): Code[20]
    begin
        exit(SEPACAMT054Tok);
    end;

    procedure SEPACAMT05302(): Code[20]
    begin
        exit(SEPACAMT05302Tok);
    end;

    procedure SEPACAMT05304(): Code[20]
    begin
        exit(SEPACAMT05304Tok);
    end;

    procedure SEPASwiss(): Code[20]
    begin
        exit(SEPASwissTok);
    end;

    procedure SEPACTPAIN00100109(): Code[20]
    begin
        exit(SEPACTPAIN00100109Tok);
    end;

    procedure SEPACTSWISS00100109(): Code[20]
    begin
        exit(SEPACTSWISS00100109Tok);
    end;

    procedure SEPADDSwiss(): Code[20]
    begin
        exit(SEPADDSwissTok);
    end;

    procedure SEPADDPAIN00800108(): Code[20]
    begin
        exit(SEPADDPAIN00800108Tok);
    end;

    procedure SEPADDSWISS00800108(): Code[20]
    begin
        exit(SEPADDSWISS00800108Tok);
    end;

    var
        SEPACAMT054Tok: Label 'SEPA CAMT 054', MaxLength = 20;
        SEPACAMT05302Tok: Label 'SEPA CAMT 053-02', MaxLength = 20;
        SEPACAMT05304Tok: Label 'SEPA CAMT 053-04', MaxLength = 20;
        SEPASwissTok: Label 'SEPA SWISS', MaxLength = 20;
        SEPASwissLbl: Label 'Swiss SEPA Credit Transfer', MaxLength = 100;
        SEPACTPAIN00100109Tok: Label 'SEPACTPAIN00100109', MaxLength = 20;
        SEPACTPAIN00100109Lbl: Label 'SEPA Credit Transfer pain.001.001.09', MaxLength = 100;
        SEPACTSWISS00100109Tok: Label 'SEPACTSWISS 00100109', MaxLength = 20;
        SEPACTSWISS00100109Lbl: Label 'Swiss SEPA Credit Transfer pain.001.001.09', MaxLength = 100;
        SEPADDSwissTok: Label 'SEPADD SWISS', MaxLength = 20;
        SEPADDSwissLbl: Label 'Swiss SEPA Direct Debit', MaxLength = 100;
        SEPADDPAIN00800108Tok: Label 'SEPADD PAIN00800108', MaxLength = 20;
        SEPADDPAIN00800108Lbl: Label 'SEPA Direct Debit pain.008.001.08', MaxLength = 100;
        SEPADDSWISS00800108Tok: Label 'SEPADD SWISS00800108', MaxLength = 20;
        SEPADDSWISS00800108Lbl: Label 'Swiss SEPA Direct Debit pain.008.001.08', MaxLength = 100;
}