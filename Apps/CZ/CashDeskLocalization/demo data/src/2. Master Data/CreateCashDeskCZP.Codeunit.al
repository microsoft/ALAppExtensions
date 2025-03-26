#pragma warning disable AA0247
codeunit 31342 "Create Cash Desk CZP"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCashDeskCZP: Codeunit "Contoso Cash Desk CZP";
        CreateBankAccPostGrpCZ: Codeunit "Create Bank Acc. Post. Grp CZ";
        CreateGLAccountCZ: Codeunit "Create G/L Account CZ";
        CreateRoundingMethodCZP: Codeunit "Create Rounding Method CZP";
        CreateNoSeriesCZ: Codeunit "Create No. Series CZ";
    begin
        ContosoCashDeskCZP.InsertCashDesk(CashDeskOne(), CashDeskOneNameLbl, CreateBankAccPostGrpCZ.CashDesk(), CreateRoundingMethodCZP.Crowns(),
            CreateGLAccountCZ.Otherfinancialexpenses(), CreateGLAccountCZ.Otherfinancialrevenues(),
            10000.0, 270000.0, 270000.0, CreateNoSeriesCZ.CashDocumentReceipt(), CreateNoSeriesCZ.CashDocumentWithdrawal());
    end;

    procedure CashDeskOne(): Code[20]
    begin
        exit(CashDeskOneLbl);
    end;

    var
        CashDeskOneLbl: Label 'CD01', MaxLength = 20;
        CashDeskOneNameLbl: Label 'Cash Desk 1', MaxLength = 100;
}
