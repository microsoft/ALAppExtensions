codeunit 11515 "Create No. Series NL"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    trigger OnRun()
    var
        ContosoNoSeries: Codeunit "Contoso No Series";
        ContosoNoSeriesNL: Codeunit "Contoso No Series NL";
    begin
        ContosoNoSeries.InsertNoSeries(ELICLDecl(), ELICLDeclLbl, 'ICP00001', 'ICP99999', '', '', 1, Enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeries.InsertNoSeries(ELVATDecl(), ELVATDeclLbl, 'VAT00001', 'VAT99999', '', '', 1, Enum::"No. Series Implementation"::Normal, true);

        ContosoNoSeriesNL.InsertNoSeries(AbnBankJnl(), ABNBankJournalLbl, 'ABNBANK0001', 1, Enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeriesNL.InsertNoSeries(Cash(), CashLbl, 'CASH0001', 1, Enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeriesNL.InsertNoSeries(GiroJnl(), GiroJnlLbl, 'GIRO0001', 1, Enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeriesNL.InsertNoSeries(TelebankingIdentification(), TelebankingIdentificationLbl, '1', 1, Enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeriesNL.InsertNoSeries(PaymentsProcess(), PaymentsProcessLbl, 'PAYMTPROC1', 1, Enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeriesNL.InsertNoSeries(ReceiptsProcess(), ReceiptsProcessLbl, 'RECPTSPROC1', 1, Enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeriesNL.InsertNoSeries(TelebankingRunNos(), TelebankingRunNosLbl, '1', 1, Enum::"No. Series Implementation"::Normal, true);
    end;

    procedure AbnBankJnl(): Code[20]
    begin
        exit(AbnBankJnlTok);
    end;

    procedure Cash(): Code[20]
    begin
        exit(CashTok);
    end;

    procedure ElICLDecl(): Code[20]
    begin
        exit(ELICLDeclTok);
    end;

    procedure ElVATDecl(): Code[20]
    begin
        exit(ELVATDeclTok);
    end;

    procedure GiroJnl(): Code[20]
    begin
        exit(GiroJnlTok);
    end;

    procedure TelebankingIdentification(): Code[20]
    begin
        exit(TelebankingIdentificationTok);
    end;

    procedure PaymentsProcess(): Code[20]
    begin
        exit(PaymentsProcessTok);
    end;

    procedure ReceiptsProcess(): Code[20]
    begin
        exit(ReceiptsProcessTok);
    end;

    procedure TelebankingRunNos(): Code[20]
    begin
        exit(TelebankingRunNosTok);
    end;

    var
        AbnBankJnlTok: Label 'ABNBANKJNL', MaxLength = 20, Locked = true;
        ABNBankJournalLbl: Label 'ABN Bank Journal', MaxLength = 100;
        CashTok: Label 'CASH', MaxLength = 20, Locked = true;
        CashLbl: Label 'Cash Journal', MaxLength = 100;
        ELICLDeclTok: Label 'ELICLDECL', MaxLength = 20, Locked = true;
        ELICLDeclLbl: Label 'Elec. ICL Declarations', MaxLength = 100;
        ELVATDeclTok: Label 'ELVATDECL', MaxLength = 20, Locked = true;
        ELVATDeclLbl: Label 'Elec. VAT Declarations', MaxLength = 100;
        GiroJnlTok: Label 'GIROJNL', MaxLength = 20, Locked = true;
        GiroJnlLbl: Label 'Giro Journal', MaxLength = 100;
        TelebankingIdentificationTok: Label 'IDENTIFIC', MaxLength = 20, Locked = true;
        TelebankingIdentificationLbl: Label 'Telebanking Identification', MaxLength = 100;
        PaymentsProcessTok: Label 'PAYMTPROC', MaxLength = 20, Locked = true;
        PaymentsProcessLbl: Label 'Payments in Process', MaxLength = 100;
        ReceiptsProcessTok: Label 'RECPTSPROC', MaxLength = 20, Locked = true;
        ReceiptsProcessLbl: Label 'Receipts in Process', MaxLength = 100;
        TelebankingRunNosTok: Label 'RUNNO', MaxLength = 20, Locked = true;
        TelebankingRunNosLbl: Label 'Telebanking Run Nos.', MaxLength = 100;
}