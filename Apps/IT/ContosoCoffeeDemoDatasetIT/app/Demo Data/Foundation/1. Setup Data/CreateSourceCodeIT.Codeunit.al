codeunit 12227 "Create Source Code IT"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoSourceCode: Codeunit "Contoso Source Code";
    begin
        ContosoSourceCode.SetOverwriteData(true);
        ContosoSourceCode.InsertSourceCode(BankTransf(), BankTransfersLbl);
        ContosoSourceCode.InsertSourceCode(Start(), OpeningEntriesLbl);
        ContosoSourceCode.InsertSourceCode(GLCurReval(), GLCurrencyRevaluationLbl);
        ContosoSourceCode.InsertSourceCode(RIBA(), BankReceiptsLbl);
        ContosoSourceCode.InsertSourceCode(ExchRatAdj(), ExchangeRatesAdjustmentLbl);
        ContosoSourceCode.SetOverwriteData(false);
    end;

    procedure BankTransf(): Code[10]
    begin
        exit(BankTransfTok);
    end;

    procedure RIBA(): Code[10]
    begin
        exit(RIBATok);
    end;

    procedure Start(): Code[10]
    begin
        exit(StartTok);
    end;

    procedure GLCurReval(): Code[10]
    begin
        exit(GLCurRevalTok);
    end;

    procedure ExchRatAdj(): Code[10]
    begin
        exit(ExchRatAdjTok);
    end;

    var
        ExchRatAdjTok: Label 'EXCHRATADJ', MaxLength = 10;
        RIBATok: Label 'RIBA', MaxLength = 10;
        BankTransfTok: Label 'BANKTRANSF', MaxLength = 10;
        StartTok: Label 'START', MaxLength = 10;
        GLCurRevalTok: Label 'GLCURREVAL', MaxLength = 10;
        BankTransfersLbl: Label 'Bank Transfers', MaxLength = 100;
        OpeningEntriesLbl: Label 'Opening Entries', MaxLength = 100;
        GLCurrencyRevaluationLbl: Label 'G/L Currency Revaluation', MaxLength = 100;
        BankReceiptsLbl: Label 'Bank Receipts', MaxLength = 100;
        ExchangeRatesAdjustmentLbl: Label 'Exchange Rates Adjustment', MaxLength = 100;
}