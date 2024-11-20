codeunit 11159 "Create Bank ExpImport Setup AT"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoBank: Codeunit "Contoso Bank";
    begin
        ContosoBank.ContosoBankExportImportSetup(SEPACTAPCT(), SEPACTAPCDescLbl, 0, Codeunit::"SEPA CT APC-Export File", Xmlport::"SEPA CT pain.001.001.03", '', false, Codeunit::"SEPA CT-Check Line");
        ContosoBank.ContosoBankExportImportSetup(SEPACTAPC09(), SEPACTAPC09DescLbl, 0, Codeunit::"SEPA CT APC-Export File", Xmlport::"SEPA CT pain.001.001.09", '', false, Codeunit::"SEPA CT-Check Line");
    end;

    procedure SEPACTAPCT(): Code[20]
    begin
        exit(SEPACTAPCTok);
    end;

    procedure SEPACTAPC09(): Code[20]
    begin
        exit(SEPACTAPC09Tok);
    end;



    var
        SEPACTAPCTok: Label 'SEPACTAPC', MaxLength = 20;
        SEPACTAPC09Tok: Label 'SEPACTAPC09', MaxLength = 20;
        SEPACTAPCDescLbl: Label 'SEPA Credit Transfer APC', MaxLength = 100;
        SEPACTAPC09DescLbl: Label 'SEPA Credit Transfer APC 09', MaxLength = 100;
}