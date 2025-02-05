codeunit 5306 "Create Bank Ex/Import Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoBank: Codeunit "Contoso Bank";
        CreateDataExchange: Codeunit "Create Data Exchange";
    begin
        ContosoBank.ContosoBankExportImportSetup(SEPACAMT(), SEPACAMTTok, 1, Codeunit::"Exp. Launcher Gen. Jnl.", 0, CreateDataExchange.SEPACAMT(), true, 0);
        ContosoBank.ContosoBankExportImportSetup(SEPACT(), SEPACTDescLbl, 0, Codeunit::"SEPA CT-Export File", Xmlport::"SEPA CT pain.001.001.03", '', false, Codeunit::"SEPA CT-Check Line");
        ContosoBank.ContosoBankExportImportSetup(SEPADD(), SEPADDDescLbl, 0, Codeunit::"SEPA DD-Export File", Xmlport::"SEPA DD pain.008.001.02", '', false, Codeunit::"SEPA DD-Check Line");
    end;

    procedure SEPACAMT(): Code[20]
    begin
        exit(SEPACAMTTok);
    end;

    procedure SEPACT(): Code[20]
    begin
        exit(SEPACTTok);
    end;

    procedure SEPADD(): Code[20]
    begin
        exit(SEPADDTok);
    end;

    var
        SEPACAMTTok: Label 'SEPA CAMT', MaxLength = 20;
        SEPACTTok: Label 'SEPACT', MaxLength = 20;
        SEPADDTok: Label 'SEPADD', MaxLength = 20;
        SEPACTDescLbl: Label 'SEPA Credit Transfer', MaxLength = 100;
        SEPADDDescLbl: Label 'SEPA Direct Debit', MaxLength = 100;
}
