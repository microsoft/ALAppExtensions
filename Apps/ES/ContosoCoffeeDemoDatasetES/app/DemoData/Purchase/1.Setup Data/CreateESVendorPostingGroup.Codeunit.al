codeunit 10816 "Create ES Vendor Posting Group"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
        CreateVendorPostingGroup: Codeunit "Create Vendor Posting Group";
        CreateESGLAccount: Codeunit "Create ES GL Accounts";
    begin
        ContosoPostingGroup.SetOverwriteData(true);
        ContosoPostingGroup.InsertVendorPostingGroup(CreateVendorPostingGroup.Domestic(), CreateESGLAccount.NationalTradeCreditors(), CreateESGLAccount.OtherServices(), '', CreateESGLAccount.ExpenOnRoundOffEur(), CreateESGLAccount.ExpenOnRoundOffEur(), CreateESGLAccount.IncomeOnRoundOffEuros(), CreateESGLAccount.ExpenOnRoundOffEur(), CreateESGLAccount.ExpenOnRoundOffEur(), '', CreateESGLAccount.OtherFinancialIncome(), CreateESGLAccount.OtherFinancialIncome(), DomesticVendorsLbl, false);
        ContosoPostingGroup.InsertVendorPostingGroup(CreateVendorPostingGroup.EU(), CreateESGLAccount.NationalTradeCreditors(), CreateESGLAccount.OtherServices(), '', CreateESGLAccount.ExpenOnRoundOffEur(), CreateESGLAccount.ExpenOnRoundOffEur(), CreateESGLAccount.IncomeOnRoundOffEuros(), CreateESGLAccount.ExpenOnRoundOffEur(), CreateESGLAccount.ExpenOnRoundOffEur(), '', CreateESGLAccount.OtherFinancialIncome(), CreateESGLAccount.OtherFinancialIncome(), EUVendorsLbl, false);
        ContosoPostingGroup.InsertVendorPostingGroup(CreateVendorPostingGroup.Foreign(), CreateESGLAccount.InternatTradeCreditors(), CreateESGLAccount.OtherServices(), '', CreateESGLAccount.ExpenOnRoundOffEur(), CreateESGLAccount.ExpenOnRoundOffEur(), CreateESGLAccount.IncomeOnRoundOffEuros(), CreateESGLAccount.ExpenOnRoundOffEur(), CreateESGLAccount.ExpenOnRoundOffEur(), '', CreateESGLAccount.OtherFinancialIncome(), CreateESGLAccount.OtherFinancialIncome(), ForeignVendorsLbl, false);
        ContosoPostingGroup.SetOverwriteData(false);

        UpdateVendorPostingGroup();
    end;

    local procedure UpdateVendorPostingGroup()
    var
        CreateVendorPostingGroup: Codeunit "Create Vendor Posting Group";
        CreateESGLAccounts: Codeunit "Create ES GL Accounts";
    begin
        UpdateRecordFields(CreateVendorPostingGroup.Domestic(), CreateESGLAccounts.BillExPayNational(), CreateESGLAccounts.BillExInPaymtOrder(), CreateESGLAccounts.InvUnderPaymentOrder());
        UpdateRecordFields(CreateVendorPostingGroup.EU(), CreateESGLAccounts.BillExPayNational(), CreateESGLAccounts.BillExInPaymtOrder(), CreateESGLAccounts.InvUnderPaymentOrder());
    end;

    local procedure UpdateRecordFields(Code: Code[20]; BillsAccount: Code[20]; BillsinPaymentOrderAcc: Code[20]; InvoicesinPmtOrdAcc: Code[20])
    var
        VendorPostingGroup: Record "Vendor Posting Group";
    begin
        if VendorPostingGroup.Get(Code) then begin
            VendorPostingGroup.Validate("Bills Account", BillsAccount);
            VendorPostingGroup.Validate("Bills in Payment Order Acc.", BillsinPaymentOrderAcc);
            VendorPostingGroup.Validate("Invoices in  Pmt. Ord. Acc.", InvoicesinPmtOrdAcc);
            VendorPostingGroup.Modify(true);
        end;
    end;

    var
        DomesticVendorsLbl: Label 'Domestic vendors', MaxLength = 100;
        EUVendorsLbl: Label 'Vendors in EU', MaxLength = 100;
        ForeignVendorsLbl: Label 'Foreign vendors (not EU)', MaxLength = 100;
}