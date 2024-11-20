codeunit 5132 "Contoso Posting Group"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "VAT Product Posting Group" = rim,
        tabledata "VAT Business Posting Group" = rim,
        tabledata "Gen. Product Posting Group" = rim,
        tabledata "Gen. Business Posting Group" = rim,
        tabledata "Customer Posting Group" = rim,
        tabledata "Vendor Posting Group" = rim,
        tabledata "Inventory Posting Group" = rim,
        tabledata "Tax Group" = rim,
        tabledata "Bank Account Posting Group" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertTaxGroup(TaxGroupCode: Code[20]; Description: Text[100])
    var
        TaxGroup: Record "Tax Group";
        Exists: Boolean;
    begin
        if TaxGroup.Get(TaxGroupCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        TaxGroup.Validate(Code, TaxGroupCode);
        TaxGroup.Validate(Description, Description);

        if Exists then
            TaxGroup.Modify(true)
        else
            TaxGroup.Insert(true);
    end;

    procedure InsertVATProductPostingGroup(ProductGroupCode: Code[20]; Description: Text[100])
    var
        VATProductPostingGroup: Record "VAT Product Posting Group";
        Exists: Boolean;
    begin
        if VATProductPostingGroup.Get(ProductGroupCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        VATProductPostingGroup.Validate(Code, ProductGroupCode);
        VATProductPostingGroup.Validate(Description, Description);

        if Exists then
            VATProductPostingGroup.Modify(true)
        else
            VATProductPostingGroup.Insert(true);
    end;

    procedure InsertVATBusinessPostingGroup(BusinessGroupCode: Code[20]; Description: Text[100])
    var
        VATBusinessPostingGroup: Record "VAT Business Posting Group";
        Exists: Boolean;
    begin
        if VATBusinessPostingGroup.Get(BusinessGroupCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        VATBusinessPostingGroup.Validate(Code, BusinessGroupCode);
        VATBusinessPostingGroup.Validate(Description, Description);

        if Exists then
            VATBusinessPostingGroup.Modify(true)
        else
            VATBusinessPostingGroup.Insert(true);
    end;

    procedure InsertGenProductPostingGroup(ProductGroupCode: Code[20]; Description: Text[100]; DefaultVATProdPostingGroup: Code[20])
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        GenProductPostingGroup: Record "Gen. Product Posting Group";
        Exists: Boolean;
    begin
        ContosoCoffeeDemoDataSetup.Get();

        if GenProductPostingGroup.Get(ProductGroupCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        GenProductPostingGroup.Validate(Code, ProductGroupCode);
        GenProductPostingGroup.Validate(Description, Description);

        if ContosoCoffeeDemoDataSetup."Company Type" = ContosoCoffeeDemoDataSetup."Company Type"::VAT then
            GenProductPostingGroup.Validate("Def. VAT Prod. Posting Group", DefaultVATProdPostingGroup);

        if Exists then
            GenProductPostingGroup.Modify(true)
        else
            GenProductPostingGroup.Insert(true);
    end;

    procedure InsertGenBusinessPostingGroup(BusinessGroupCode: Code[20]; Description: Text[100]; DefaultVATBusPostingGroup: Code[20])
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        GenBusinessPostingGroup: Record "Gen. Business Posting Group";
        Exists: Boolean;
    begin
        ContosoCoffeeDemoDataSetup.Get();

        if GenBusinessPostingGroup.Get(BusinessGroupCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        GenBusinessPostingGroup.Validate(Code, BusinessGroupCode);
        GenBusinessPostingGroup.Validate(Description, Description);

        if ContosoCoffeeDemoDataSetup."Company Type" = ContosoCoffeeDemoDataSetup."Company Type"::VAT then begin
            GenBusinessPostingGroup.Validate("Def. VAT Bus. Posting Group", DefaultVATBusPostingGroup);
            GenBusinessPostingGroup.Validate("Auto Insert Default", true);
        end;

        if Exists then
            GenBusinessPostingGroup.Modify(true)
        else
            GenBusinessPostingGroup.Insert(true);
    end;

    procedure InsertCustomerPostingGroup(CustomerGroupCode: Code[20]; Description: Text[100]; ReceivablesAccountNo: Code[20])
    begin
        InsertCustomerPostingGroup(CustomerGroupCode, ReceivablesAccountNo, '', '', '', '', '', '', '', '', '', '', '', '', Description);
    end;

    procedure InsertVendorPostingGroup(VendorGroupCode: Code[20]; Description: Text[100]; PayablesAccountNo: Code[20])
    begin
        InsertVendorPostingGroup(VendorGroupCode, PayablesAccountNo, '', '', '', '', '', '', '', '', '', '', Description, false);
    end;

    procedure InsertVendorPostingGroup(Code: Code[20]; PayablesAccount: Code[20]; ServiceChargeAcc: Code[20]; PaymentDiscDebitAcc: Code[20]; InvoiceRoundingAccount: Code[20]; DebitCurrApplnRndgAcc: Code[20]; CreditCurrApplnRndgAcc: Code[20]; DebitRoundingAccount: Code[20]; CreditRoundingAccount: Code[20]; PaymentDiscCreditAcc: Code[20]; PaymentToleranceDebitAcc: Code[20]; PaymentToleranceCreditAcc: Code[20]; Description: Text[100]; ViewAllAccountsonLookup: Boolean)
    var
        VendorPostingGroup: Record "Vendor Posting Group";
        Exists: Boolean;
    begin
        if VendorPostingGroup.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        VendorPostingGroup.Validate(Code, Code);
        VendorPostingGroup.Validate("Payables Account", PayablesAccount);
        VendorPostingGroup.Validate("Service Charge Acc.", ServiceChargeAcc);
        VendorPostingGroup.Validate("Payment Disc. Debit Acc.", PaymentDiscDebitAcc);
        VendorPostingGroup.Validate("Invoice Rounding Account", InvoiceRoundingAccount);
        VendorPostingGroup.Validate("Debit Curr. Appln. Rndg. Acc.", DebitCurrApplnRndgAcc);
        VendorPostingGroup.Validate("Credit Curr. Appln. Rndg. Acc.", CreditCurrApplnRndgAcc);
        VendorPostingGroup.Validate("Debit Rounding Account", DebitRoundingAccount);
        VendorPostingGroup.Validate("Credit Rounding Account", CreditRoundingAccount);
        VendorPostingGroup.Validate("Payment Disc. Credit Acc.", PaymentDiscCreditAcc);
        VendorPostingGroup.Validate("Payment Tolerance Debit Acc.", PaymentToleranceDebitAcc);
        VendorPostingGroup.Validate("Payment Tolerance Credit Acc.", PaymentToleranceCreditAcc);
        VendorPostingGroup.Validate(Description, Description);
        VendorPostingGroup.Validate("View All Accounts on Lookup", ViewAllAccountsonLookup);

        if Exists then
            VendorPostingGroup.Modify(true)
        else
            VendorPostingGroup.Insert(true);
    end;

    procedure InsertInventoryPostingGroup(Code: Code[20]; Description: Text[100])
    var
        InventoryPostingGroup: Record "Inventory Posting Group";
        Exists: Boolean;
    begin
        if InventoryPostingGroup.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        InventoryPostingGroup.Validate("Code", Code);
        InventoryPostingGroup.Validate("Description", Description);

        if Exists then
            InventoryPostingGroup.Modify(true)
        else
            InventoryPostingGroup.Insert(true);
    end;

    procedure InsertCustomerPostingGroup(Code: Code[20]; ReceivablesAccount: Code[20]; ServiceChargeAcc: Code[20]; PaymentDiscDebitAcc: Code[20]; InvoiceRoundingAccount: Code[20]; AdditionalFeeAccount: Code[20]; InterestAccount: Code[20]; DebitCurrApplnRndgAcc: Code[20]; CreditCurrApplnRndgAcc: Code[20]; DebitRoundingAccount: Code[20]; CreditRoundingAccount: Code[20]; PaymentDiscCreditAcc: Code[20]; PaymentToleranceDebitAcc: Code[20]; PaymentToleranceCreditAcc: Code[20]; Description: Text[100])
    var
        CustomerPostingGroup: Record "Customer Posting Group";
        Exists: Boolean;
    begin
        if CustomerPostingGroup.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        CustomerPostingGroup.Validate(Code, Code);
        CustomerPostingGroup.Validate("Receivables Account", ReceivablesAccount);
        CustomerPostingGroup.Validate("Service Charge Acc.", ServiceChargeAcc);
        CustomerPostingGroup.Validate("Payment Disc. Debit Acc.", PaymentDiscDebitAcc);
        CustomerPostingGroup.Validate("Invoice Rounding Account", InvoiceRoundingAccount);
        CustomerPostingGroup.Validate("Additional Fee Account", AdditionalFeeAccount);
        CustomerPostingGroup.Validate("Interest Account", InterestAccount);
        CustomerPostingGroup.Validate("Debit Curr. Appln. Rndg. Acc.", DebitCurrApplnRndgAcc);
        CustomerPostingGroup.Validate("Credit Curr. Appln. Rndg. Acc.", CreditCurrApplnRndgAcc);
        CustomerPostingGroup.Validate("Debit Rounding Account", DebitRoundingAccount);
        CustomerPostingGroup.Validate("Credit Rounding Account", CreditRoundingAccount);
        CustomerPostingGroup.Validate("Payment Disc. Credit Acc.", PaymentDiscCreditAcc);
        CustomerPostingGroup.Validate("Payment Tolerance Debit Acc.", PaymentToleranceDebitAcc);
        CustomerPostingGroup.Validate("Payment Tolerance Credit Acc.", PaymentToleranceCreditAcc);
        CustomerPostingGroup.Validate(Description, Description);

        if Exists then
            CustomerPostingGroup.Modify(true)
        else
            CustomerPostingGroup.Insert(true);
    end;

    procedure InsertBankAccountPostingGroup(Code: Code[20]; GLAccountNo: Code[20])
    var
        BankAccountPostingGroup: Record "Bank Account Posting Group";
        Exists: Boolean;
    begin
        if BankAccountPostingGroup.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        BankAccountPostingGroup.Validate(Code, Code);
        BankAccountPostingGroup.Validate("G/L Account No.", GLAccountNo);

        if Exists then
            BankAccountPostingGroup.Modify(true)
        else
            BankAccountPostingGroup.Insert(true);
    end;
}