codeunit 11549 "Create Bank Ex/Import NL"
{
    trigger OnRun()
    var
        BankExportImportSetup: Record "Bank Export/Import Setup";
        ContosoBank: Codeunit "Contoso Bank";
        CreateDataExchangeNL: Codeunit "Create Data Exchange NL";
        CreateBankExImportSetup: Codeunit "Create Bank Ex/Import Setup";
    begin
        BankExportImportSetup.Get(CreateBankExImportSetup.SEPACAMT());
        BankExportImportSetup.Validate("Data Exch. Def. Code", CreateDataExchangeNL.SEPACAMTNL());
        BankExportImportSetup.Modify(true);

        ContosoBank.ContosoBankExportImportSetup(SEPACTPAIN00100109(), SEPACTPAIN00100109Lbl, 0, Codeunit::"SEPA CT-Export File", Xmlport::"SEPA CT pain.001.001.09", '', false, Codeunit::"SEPA CT-Check Line");
        ContosoBank.ContosoBankExportImportSetup(SEPADDPAIN00800108(), SEPADDPAIN00800108Lbl, 0, Codeunit::"SEPA DD-Export File", Xmlport::"SEPA DD pain.008.001.08", '', false, Codeunit::"SEPA DD-Check Line");

    end;

    procedure SEPACTPAIN00100109(): Code[20]
    begin
        exit(SEPACTPAIN00100109Tok);
    end;

    procedure SEPADDPAIN00800108(): Code[20]
    begin
        exit(SEPADDPAIN00800108Tok);
    end;


    var
        SEPACTPAIN00100109Tok: Label 'SEPACTPAIN00100109', MaxLength = 20;
        SEPACTPAIN00100109Lbl: Label 'SEPA Credit Transfer pain.001.001.09', MaxLength = 100;
        SEPADDPAIN00800108Tok: Label 'SEPADD PAIN00800108', MaxLength = 20;
        SEPADDPAIN00800108Lbl: Label 'SEPA Direct Debit pain.008.001.08', MaxLength = 100;
}