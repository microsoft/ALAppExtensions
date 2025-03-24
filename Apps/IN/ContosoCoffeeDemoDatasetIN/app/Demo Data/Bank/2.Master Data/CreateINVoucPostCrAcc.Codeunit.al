codeunit 19035 "Create IN Vouc. Post. Cr. Acc."
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoINGeneralLedger: Codeunit "Contoso IN General Ledger";
        CreateINBankAccount: Codeunit "Create IN Bank Account";
        CreateGLAccount: Codeunit "Create G/L Account";
        CreateINLocation: Codeunit "Create IN Location";
    begin
        ContosoINGeneralLedger.InsertVoucherPostingCreditAccount('', Enum::"Gen. Journal Template Type"::"Cash Payment Voucher", Enum::"Gen. Journal Account Type"::"G/L Account", CreateGLAccount.Cash());
        ContosoINGeneralLedger.InsertVoucherPostingCreditAccount('', Enum::"Gen. Journal Template Type"::"Bank Payment Voucher", Enum::"Gen. Journal Account Type"::"Bank Account", CreateINBankAccount.Giro());
        ContosoINGeneralLedger.InsertVoucherPostingCreditAccount(CreateINLocation.BlueLocation(), Enum::"Gen. Journal Template Type"::"Cash Payment Voucher", Enum::"Gen. Journal Account Type"::"G/L Account", CreateGLAccount.Cash());
        ContosoINGeneralLedger.InsertVoucherPostingCreditAccount(CreateINLocation.BlueLocation(), Enum::"Gen. Journal Template Type"::"Bank Payment Voucher", Enum::"Gen. Journal Account Type"::"Bank Account", CreateINBankAccount.Giro());
        ContosoINGeneralLedger.InsertVoucherPostingCreditAccount(CreateINLocation.RedLocation(), Enum::"Gen. Journal Template Type"::"Cash Payment Voucher", Enum::"Gen. Journal Account Type"::"G/L Account", CreateGLAccount.Cash());
        ContosoINGeneralLedger.InsertVoucherPostingCreditAccount(CreateINLocation.RedLocation(), Enum::"Gen. Journal Template Type"::"Bank Payment Voucher", Enum::"Gen. Journal Account Type"::"Bank Account", CreateINBankAccount.Giro());
    end;
}