codeunit 12233 "Create Bill Code IT"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoBill: Codeunit "Contoso Bill";
        CreateNoSeriesIT: Codeunit "Create No. Series IT";
        CreateSourceCodeIT: Codeunit "Create Source Code IT";
        CreateITGLAccounts: Codeunit "Create IT GL Accounts";
    begin
        ContosoBill.InsertBillCode(BB(), BankTransferLbl, false, false, '', '', '', '', '', CreateNoSeriesIT.VendorBillsBRNo(), CreateNoSeriesIT.VendorBillsBRList(), CreateSourceCodeIT.BankTransf());
        ContosoBill.InsertBillCode(RB(), CustomerBillLbl, true, true, CreateITGLAccounts.ExpenseBills(), CreateNoSeriesIT.TemporaryCustomerBillNo(), CreateNoSeriesIT.CustBills(), CreateNoSeriesIT.CustomerBillListJnl(), CreateSourceCodeIT.RIBA(), '', '', '');
    end;

    procedure BB(): Code[20]
    begin
        exit(BBTok);
    end;

    procedure RB(): Code[20]
    begin
        exit(RBTok);
    end;

    var
        RBTok: Label 'RB', MaxLength = 20;
        BBTok: Label 'BB', MaxLength = 20;
        BankTransferLbl: Label 'Bank Transfer', MaxLength = 30;
        CustomerBillLbl: Label 'Customer Bill', MaxLength = 30;
}