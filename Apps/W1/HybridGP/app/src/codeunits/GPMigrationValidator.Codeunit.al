namespace Microsoft.DataMigration.GP;

using Microsoft.DataMigration;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.Analysis.StatisticalAccount;
using Microsoft.Bank.BankAccount;
using Microsoft.Sales.Customer;
using Microsoft.Inventory.Item;
using Microsoft.Purchases.Vendor;
using Microsoft.Purchases.Document;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Purchases.Remittance;
using Microsoft.Finance.Currency;

codeunit 40903 "GP Migration Validator"
{
    trigger OnRun()
    var
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
    begin
        if not GPCompanyAdditionalSettings.Get(CompanyName()) then
            exit;

        ValidatorCodeLbl := GetValidatorCode();
        CompanyNameTxt := CompanyName();
        DefaultCurrency.InitRoundingPrecision();

        GetUnpostedBatchCounts();

        RunGLAccountMigrationValidation(GPCompanyAdditionalSettings);
        RunStatisticalAccountMigrationValidation(GPCompanyAdditionalSettings);
        RunBankAccountMigrationValidation(GPCompanyAdditionalSettings);
        RunCustomerMigrationValidation(GPCompanyAdditionalSettings);
        RunItemMigrationValidation(GPCompanyAdditionalSettings);
        RunPurchaseOrderMigrationValidation(GPCompanyAdditionalSettings);
        RunVendorMigrationValidation(GPCompanyAdditionalSettings);

        MigrationValidation.ReportCompanyValidated();
    end;

    local procedure GetUnpostedBatchCounts()
    var
        HelperFunctions: Codeunit "Helper Functions";
    begin
        TotalUnpostedGLBatchCount := 0;
        TotalUnpostedStatisticalBatchCount := 0;
        TotalUnpostedBankBatchCount := 0;
        TotalUnpostedCustomerBatchCount := 0;
        TotalUnpostedItemBatchCount := 0;
        TotalUnpostedVendorBatchCount := 0;

        HelperFunctions.GetUnpostedBatchCountForCompany(CompanyName(), TotalUnpostedGLBatchCount, TotalUnpostedStatisticalBatchCount, TotalUnpostedBankBatchCount, TotalUnpostedCustomerBatchCount, TotalUnpostedItemBatchCount, TotalUnpostedVendorBatchCount);
    end;

    local procedure RunGLAccountMigrationValidation(var GPCompanyAdditionalSettings: Record "GP Company Additional Settings")
    var
        GLAccount: Record "G/L Account";
        GPAccount: Record "GP Account";
        FirstAccount: Record "GP GL00100";
        GPGL00100: Record "GP GL00100";
        GPGL10111: Record "GP GL10111";
        GPGL40200: Record "GP GL40200";
        GPSY00300: Record "GP SY00300";
        GPGLTransactions: Record "GP GLTransactions";
        GPFiscalPeriods: Record "GP Fiscal Periods";
        HelperFunctions: Codeunit "Helper Functions";
        BalanceFailureShouldBeWarning: Boolean;
        GPAccountNo: Code[20];
        GPAccountBeginningBalance: Decimal;
        AccountFilter: Text;
        EntityType: Text[50];
        GPAccountDescription: Text[100];
    begin
        if CompanyValidationProgress.Get(CompanyNameTxt, ValidatorCodeLbl, ValidationStepGLAccountLbl) then
            exit;

        EntityType := GlAccountEntityCaptionLbl;
        BalanceFailureShouldBeWarning := (TotalUnpostedGLBatchCount > 0);

        // GP
        if GPCompanyAdditionalSettings.GetGLModuleEnabled() then begin
            GPGL00100.SetRange(ACCTTYPE, 1);
            GPGL00100.SetFilter(MNACSGMT, '<>%1', '');
            if GPGL00100.FindSet() then
                repeat
                    GPAccountBeginningBalance := 0;
                    GPAccountNo := CopyStr(GPGL00100.MNACSGMT.TrimEnd(), 1, MaxStrLen(GPAccountNo));
                    MigrationValidation.SetContext(ValidatorCodeLbl, EntityType, GPAccountNo);

                    GPSY00300.SetRange(MNSEGIND, true);
                    if GPSY00300.FindFirst() then begin
                        GPGL40200.SetRange(SGMNTID, GPGL00100.MNACSGMT);
                        GPGL40200.SetRange(SGMTNUMB, GPSY00300.SGMTNUMB);
                        if GPGL40200.FindFirst() then
                            GPAccountDescription := CopyStr(GPGL40200.DSCRIPTN.TrimEnd(), 1, MaxStrLen(GPAccountDescription));
                    end;

                    if GPAccountDescription = '' then begin
                        FirstAccount.SetCurrentKey(ACTINDX);
                        FirstAccount.SetRange(MNACSGMT, GPGL00100.MNACSGMT);
                        FirstAccount.SetRange(ACCTTYPE, 1);
                        if FirstAccount.FindFirst() then
                            GPAccountDescription := CopyStr(FirstAccount.ACTDESCR.TrimEnd(), 1, MaxStrLen(GPAccountDescription));
                    end;

                    Clear(GPAccount);
                    GPAccount.AcctNum := GPAccountNo;
                    GPAccount.AcctIndex := GPGL00100.ACTINDX;
                    GPAccount.Name := CopyStr(GPAccountDescription.Trim(), 1, MaxStrLen(GLAccount.Name));
                    GPAccount.SearchName := GPAccount.Name;
                    GPAccount.AccountCategory := GPGL00100.ACCATNUM;
                    GPAccount.IncomeBalance := GPGL00100.PSTNGTYP = 1;
                    GPAccount.DebitCredit := GPGL00100.TPCLBLNC;
                    GPAccount.Active := GPGL00100.ACTIVE;
                    GPAccount.DirectPosting := GPGL00100.ACCTENTR;
                    GPAccount.AccountSubcategoryEntryNo := GPGL00100.ACCATNUM;
                    GPAccount.AccountType := GPGL00100.ACCTTYPE;

                    if not GPCompanyAdditionalSettings.GetMigrateOnlyGLMaster() then
                        if not GPCompanyAdditionalSettings.GetSkipPostingAccountBatches() then
                            if GPGL00100.PSTNGTYP = 0 then begin
                                AccountFilter := GetAccountFilter(GPAccountNo, 1);

                                if AccountFilter <> '' then begin

                                    // Beginning Balance
                                    GPGL10111.SetFilter(ACTINDX, AccountFilter);
                                    GPGL10111.SetRange(PERIODID, 0);
                                    GPGL10111.SetRange(YEAR1, GPCompanyAdditionalSettings."Oldest GL Year to Migrate");
                                    if GPGL10111.FindSet() then
                                        repeat
                                            GPAccountBeginningBalance += RoundWithSpecPrecision(GPGL10111.PERDBLNC);
                                        until GPGL10111.Next() = 0;

                                    // Trx summary
                                    GPGLTransactions.SetCurrentKey(YEAR1, PERIODID, ACTINDX);
                                    GPGLTransactions.SetFilter(ACTINDX, AccountFilter);

                                    if GPCompanyAdditionalSettings."Oldest GL Year to Migrate" > 0 then
                                        GPGLTransactions.SetFilter(YEAR1, '>= %1', GPCompanyAdditionalSettings."Oldest GL Year to Migrate");

                                    if GPGLTransactions.FindSet() then
                                        repeat
                                            if GPFiscalPeriods.Get(GPGLTransactions.PERIODID, GPGLTransactions.YEAR1) then
                                                GPAccountBeginningBalance += RoundWithSpecPrecision(GPGLTransactions.PERDBLNC);
                                        until GPGLTransactions.Next() = 0;
                                end;
                            end;

                    Clear(GLAccount);
                    GLAccount.SetLoadFields("No.", Name, "Account Type", "Account Category", "Debit/Credit", "Account Subcategory Entry No.", "Income/Balance", Balance);
                    if not MigrationValidation.ValidateRecordExists(Test_ACCOUNTEXISTS_Tok, GLAccount.Get(GPAccount.AcctNum), StrSubstNo(MissingEntityTok, EntityType)) then
                        continue;

                    GLAccount.CalcFields(Balance);

                    MigrationValidation.ValidateAreEqual(Test_ACCOUNTNAME_Tok, GPAccount.Name, GLAccount.Name, AccountNameLbl, true);
                    MigrationValidation.ValidateAreEqual(Test_ACCOUNTTYPE_Tok, Format(GLAccount."Account Type"::Posting), Format(GLAccount."Account Type"), AccountTypeLbl);
                    MigrationValidation.ValidateAreEqual(Test_ACCOUNTCATEGORY_Tok, HelperFunctions.ConvertAccountCategory(GPAccount), GLAccount."Account Category".AsInteger(), AccountCategoryLbl);
                    MigrationValidation.ValidateAreEqual(Test_ACCOUNTDEBCRED_Tok, HelperFunctions.ConvertDebitCreditType(GPAccount), GLAccount."Debit/Credit", AccountDebitCreditLbl);
                    MigrationValidation.ValidateAreEqual(Test_ACCOUNTSUBCATEGORY_Tok, HelperFunctions.AssignSubAccountCategory(GPAccount), GLAccount."Account Subcategory Entry No.", AccountSubcategoryLbl);
                    MigrationValidation.ValidateAreEqual(Test_ACCOUNTINCBAL_Tok, HelperFunctions.ConvertIncomeBalanceType(GPAccount), GLAccount."Income/Balance".AsInteger(), AccountIncomeBalanceLbl);
                    MigrationValidation.ValidateAreEqual(Test_ACCOUNTBALANCE_Tok, GPAccountBeginningBalance, GLAccount.Balance, BeginningBalanceLbl, BalanceFailureShouldBeWarning);
                until GPGL00100.Next() = 0;
        end;

        LogValidationProgress(ValidationStepGLAccountLbl);
        Commit();
    end;

    local procedure RunStatisticalAccountMigrationValidation(var GPCompanyAdditionalSettings: Record "GP Company Additional Settings")
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        FirstAccount: Record "GP GL00100";
        GPGL00100: Record "GP GL00100";
        GPGL10111: Record "GP GL10111";
        GPGL40200: Record "GP GL40200";
        GPSY00300: Record "GP SY00300";
        GPGLTransactions: Record "GP GLTransactions";
        GPFiscalPeriods: Record "GP Fiscal Periods";
        StatisticalAccount: Record "Statistical Account";
        BalanceFailureShouldBeWarning: Boolean;
        DimensionCode1: Code[20];
        DimensionCode2: Code[20];
        GPAccountNo: Code[20];
        GPAccountBeginningBalance: Decimal;
        AccountFilter: Text;
        EntityType: Text[50];
        GPAccountDescription: Text[100];
    begin
        if CompanyValidationProgress.Get(CompanyNameTxt, ValidatorCodeLbl, ValidationStepStatAccountLbl) then
            exit;

        EntityType := StatisticalAccountEntityCaptionLbl;
        BalanceFailureShouldBeWarning := (TotalUnpostedStatisticalBatchCount > 0);

        if GeneralLedgerSetup.Get() then begin
            DimensionCode1 := GeneralLedgerSetup."Global Dimension 1 Code";
            DimensionCode2 := GeneralLedgerSetup."Global Dimension 2 Code";
        end;

        if GPCompanyAdditionalSettings.GetGLModuleEnabled() then begin
            GPGL00100.SetRange(ACCTTYPE, 2);
            GPGL00100.SetFilter(MNACSGMT, '<>%1', '');
            if GPGL00100.FindSet() then
                repeat
                    GPAccountBeginningBalance := 0;
                    GPAccountNo := CopyStr(GPGL00100.MNACSGMT.TrimEnd(), 1, MaxStrLen(GPAccountNo));
                    MigrationValidation.SetContext(ValidatorCodeLbl, EntityType, GPAccountNo);

                    GPSY00300.SetRange(MNSEGIND, true);
                    if GPSY00300.FindFirst() then begin
                        GPGL40200.SetRange(SGMNTID, GPGL00100.MNACSGMT);
                        GPGL40200.SetRange(SGMTNUMB, GPSY00300.SGMTNUMB);
                        if GPGL40200.FindFirst() then
                            GPAccountDescription := CopyStr(GPGL40200.DSCRIPTN.TrimEnd(), 1, MaxStrLen(GPAccountDescription));
                    end;

                    if GPAccountDescription = '' then begin
                        FirstAccount.SetCurrentKey(ACTINDX);
                        FirstAccount.SetRange(MNACSGMT, GPGL00100.MNACSGMT);
                        FirstAccount.SetRange(ACCTTYPE, 2);
                        if FirstAccount.FindFirst() then
                            GPAccountDescription := CopyStr(FirstAccount.ACTDESCR.TrimEnd(), 1, MaxStrLen(GPAccountDescription));
                    end;

                    if not GPCompanyAdditionalSettings.GetMigrateOnlyGLMaster() then
                        if not GPCompanyAdditionalSettings.GetSkipPostingAccountBatches() then begin
                            Clear(GPGL10111);
                            AccountFilter := GetAccountFilter(GPAccountNo, 2);

                            if AccountFilter <> '' then begin

                                // Beginning Balance
                                GPGL10111.SetFilter(ACTINDX, AccountFilter);
                                GPGL10111.SetRange(PERIODID, 0);
                                GPGL10111.SetRange(YEAR1, GPCompanyAdditionalSettings."Oldest GL Year to Migrate");
                                if GPGL10111.FindSet() then
                                    repeat
                                        GPAccountBeginningBalance += RoundWithSpecPrecision(GPGL10111.PERDBLNC);
                                    until GPGL10111.Next() = 0;

                                // Trx summary
                                GPGLTransactions.SetCurrentKey(YEAR1, PERIODID, ACTINDX);
                                GPGLTransactions.SetFilter(ACTINDX, AccountFilter);

                                if GPCompanyAdditionalSettings."Oldest GL Year to Migrate" > 0 then
                                    GPGLTransactions.SetFilter(YEAR1, '>= %1', GPCompanyAdditionalSettings."Oldest GL Year to Migrate");

                                if GPGLTransactions.FindSet() then
                                    repeat
                                        if GPFiscalPeriods.Get(GPGLTransactions.PERIODID, GPGLTransactions.YEAR1) then
                                            GPAccountBeginningBalance += RoundWithSpecPrecision(GPGLTransactions.PERDBLNC);
                                    until GPGLTransactions.Next() = 0;
                            end;
                        end;

                    Clear(StatisticalAccount);
                    StatisticalAccount.SetLoadFields("No.", Name, "Global Dimension 1 Code", "Global Dimension 2 Code", Balance);
                    if not MigrationValidation.ValidateRecordExists(Test_STATACCOUNTEXISTS_Tok, StatisticalAccount.Get(GPAccountNo), StrSubstNo(MissingEntityTok, EntityType)) then
                        continue;

                    StatisticalAccount.CalcFields(Balance);

                    MigrationValidation.ValidateAreEqual(Test_STATACCOUNTNAME_Tok, GPAccountDescription, StatisticalAccount.Name, AccountNameLbl, true);
                    MigrationValidation.ValidateAreEqual(Test_STATACCOUNTDIM1_Tok, DimensionCode1, StatisticalAccount."Global Dimension 1 Code", Dimension1Lbl);
                    MigrationValidation.ValidateAreEqual(Test_STATACCOUNTDIM2_Tok, DimensionCode2, StatisticalAccount."Global Dimension 2 Code", Dimension2Lbl);
                    MigrationValidation.ValidateAreEqual(Test_STATACCOUNTBALANCE_Tok, GPAccountBeginningBalance, StatisticalAccount.Balance, BeginningBalanceLbl, BalanceFailureShouldBeWarning);
                until GPGL00100.Next() = 0;
        end;

        LogValidationProgress(ValidationStepStatAccountLbl);
        Commit();
    end;

    local procedure RunBankAccountMigrationValidation(var GPCompanyAdditionalSettings: Record "GP Company Additional Settings")
    var
        BankAccount: Record "Bank Account";
        GPBankMSTR: Record "GP Bank MSTR";
        GPCheckbookMSTR: Record "GP Checkbook MSTR";
        GPCheckbookTransactions: Record "GP Checkbook Transactions";
        GPCM20600: Record "GP CM20600";
        BalanceFailureShouldBeWarning: Boolean;
        ShouldFlipSign: Boolean;
        ShouldInclude: Boolean;
        GPAccountNo: Code[20];
        GPAccountBalance: Decimal;
        EntityType: Text[50];
    begin
        if CompanyValidationProgress.Get(CompanyNameTxt, ValidatorCodeLbl, ValidationStepBankAccountLbl) then
            exit;

        EntityType := BankAccountEntityCaptionLbl;
        BalanceFailureShouldBeWarning := (TotalUnpostedBankBatchCount > 0);

        if GPCompanyAdditionalSettings.GetBankModuleEnabled() then
            if GPCheckbookMSTR.FindSet() then
                repeat
                    GPAccountNo := CopyStr(GPCheckbookMSTR.CHEKBKID.TrimEnd(), 1, MaxStrLen(GPAccountNo));
                    MigrationValidation.SetContext(ValidatorCodeLbl, EntityType, GPAccountNo);
                    ShouldInclude := true;
                    GPAccountBalance := 0;

                    if not GPCompanyAdditionalSettings.GetMigrateInactiveCheckbooks() then
                        if GPCheckbookMSTR.INACTIVE then
                            ShouldInclude := false;

                    if ShouldInclude then begin

                        // Balance
                        if not GPCompanyAdditionalSettings.GetMigrateOnlyBankMaster() then
                            if not GPCompanyAdditionalSettings.GetSkipPostingBankBatches() then begin
                                GPAccountBalance := GPCheckbookMSTR.Last_Reconciled_Balance;

                                GPCheckbookTransactions.SetRange(CHEKBKID, GPCheckbookMSTR.CHEKBKID);
                                GPCheckbookTransactions.SetRange(Recond, false);
                                GPCheckbookTransactions.SetFilter(TRXAMNT, '<>%1', 0);
                                if GPCheckbookTransactions.FindSet() then
                                    repeat
                                        ShouldFlipSign := false;

                                        if GPCheckbookTransactions.ShouldFlipSign() then
                                            ShouldFlipSign := true;

                                        if GPCheckbookTransactions.CMTrxType = 7 then begin
                                            GPCM20600.SetRange(CMXFRNUM, GPCheckbookTransactions.CMTrxNum);
                                            GPCM20600.SetRange(CMFRMRECNUM, GPCheckbookTransactions.CMRECNUM);
                                            if GPCM20600.FindFirst() then
                                                if GPCM20600.Xfr_Record_Number > 0 then
                                                    ShouldFlipSign := true;
                                        end;

                                        if ShouldFlipSign then
                                            GPCheckbookTransactions.TRXAMNT := GPCheckbookTransactions.TRXAMNT * -1;

                                        GPAccountBalance := GPAccountBalance + RoundWithSpecPrecision(GPCheckbookTransactions.TRXAMNT);
                                    until GPCheckbookTransactions.Next() = 0;
                            end;

                        Clear(BankAccount);
                        BankAccount.SetLoadFields("No.", Name, "Bank Account No.", Balance, Address, "Address 2", City, "Phone No.", "Transit No.", "Fax No.", County, "Post Code", "Bank Branch No.");
                        if not MigrationValidation.ValidateRecordExists(Test_BANKACCOUNTEXISTS_Tok, BankAccount.Get(GPAccountNo), StrSubstNo(MissingEntityTok, EntityType)) then
                            continue;

                        BankAccount.CalcFields(Balance);

                        MigrationValidation.ValidateAreEqual(Test_BANKACCOUNTNAME_Tok, CopyStr(GPCheckbookMSTR.DSCRIPTN.TrimEnd(), 1, MaxStrLen(BankAccount.Name)), BankAccount.Name, NameLbl, true);
                        MigrationValidation.ValidateAreEqual(Test_BANKACCOUNTNO_Tok, CopyStr(GPCheckbookMSTR.BNKACTNM.TrimEnd(), 1, MaxStrLen(BankAccount."Bank Account No.")), BankAccount."Bank Account No.", BankAccountNumberLbl, false, true);
                        MigrationValidation.ValidateAreEqual(Test_BANKACCOUNTADDR_Tok, CopyStr(GPBankMSTR.ADDRESS1.TrimEnd(), 1, MaxStrLen(BankAccount.Address)), BankAccount.Address, AddressLbl, true);
                        MigrationValidation.ValidateAreEqual(Test_BANKACCOUNTADDR2_Tok, CopyStr(GPBankMSTR.ADDRESS2.TrimEnd(), 1, MaxStrLen(BankAccount."Address 2")), BankAccount."Address 2", Address2Lbl, true);
                        MigrationValidation.ValidateAreEqual(Test_BANKACCOUNTCITY_Tok, CopyStr(GPBankMSTR.CITY.TrimEnd(), 1, MaxStrLen(BankAccount.City)), BankAccount.City, CityLbl, true);
                        MigrationValidation.ValidateAreEqual(Test_BANKACCOUNTCOUNTY_Tok, CopyStr(GPBankMSTR.STATE.TrimEnd(), 1, MaxStrLen(BankAccount.County)), BankAccount.County, CountyLbl, true);
                        MigrationValidation.ValidateAreEqual(Test_BANKACCOUNTPOSTCODE_Tok, CopyStr(GPBankMSTR.ZIPCODE.TrimEnd(), 1, MaxStrLen(BankAccount."Post Code")), BankAccount."Post Code", PostCodeLbl, true);
                        MigrationValidation.ValidateAreEqual(Test_BANKACCOUNTPHN_Tok, CopyStr(GPBankMSTR.PHNUMBR1.TrimEnd(), 1, MaxStrLen(BankAccount."Phone No.")), BankAccount."Phone No.", PhoneLbl, true);
                        MigrationValidation.ValidateAreEqual(Test_BANKACCOUNTFAX_Tok, CopyStr(GPBankMSTR.FAXNUMBR.TrimEnd(), 1, MaxStrLen(BankAccount."Fax No.")), BankAccount."Fax No.", FaxLbl, true);
                        MigrationValidation.ValidateAreEqual(Test_BANKACCOUNTTRANSITNO_Tok, CopyStr(GPBankMSTR.TRNSTNBR.TrimEnd(), 1, MaxStrLen(BankAccount."Transit No.")), BankAccount."Transit No.", TransitNoLbl, true);
                        MigrationValidation.ValidateAreEqual(Test_BANKACCOUNTBRANCHNO_Tok, CopyStr(GPBankMSTR.BNKBRNCH.TrimEnd(), 1, MaxStrLen(BankAccount."Bank Branch No.")), BankAccount."Bank Branch No.", BankBranchNoLbl, true);
                        MigrationValidation.ValidateAreEqual(Test_BANKACCOUNTBALANCE_Tok, GPAccountBalance, BankAccount.Balance, BalanceLbl, BalanceFailureShouldBeWarning);
                    end;
                until GPCheckbookMSTR.Next() = 0;
        LogValidationProgress(ValidationStepBankAccountLbl);
        Commit();
    end;

    local procedure RunCustomerMigrationValidation(var GPCompanyAdditionalSettings: Record "GP Company Additional Settings")
    var
        Customer: Record Customer;
        GPCustomer: Record "GP Customer";
        GPRM00101: Record "GP RM00101";
        GPRM20101: record "GP RM20101";
        GPPaymentTerms: Record "GP Payment Terms";
        GPPopulateCombinedTables: Codeunit "GP Populate Combined Tables";
        HelperFunctions: Codeunit "Helper Functions";
        BalanceFailureShouldBeWarning: Boolean;
        ShouldInclude: Boolean;
        ClassName: Code[20];
        CustomerNo: Code[20];
        TaxLiable: Boolean;
        PhoneNo: Text[30];
        FaxNo: Text[30];
        PaymentTerms: Code[10];
        GPCustomerBalance: Decimal;
        EntityType: Text[50];
    begin
        if CompanyValidationProgress.Get(CompanyNameTxt, ValidatorCodeLbl, ValidationStepCustomerLbl) then
            exit;

        EntityType := CustomerEntityCaptionLbl;
        BalanceFailureShouldBeWarning := (TotalUnpostedCustomerBatchCount > 0);

        if GPCompanyAdditionalSettings.GetReceivablesModuleEnabled() then begin
            GPRM00101.SetFilter(CUSTNMBR, '<>%1', '');
            if GPRM00101.FindSet() then
                repeat
                    CustomerNo := CopyStr(GPRM00101.CUSTNMBR.TrimEnd(), 1, MaxStrLen(CustomerNo));
                    MigrationValidation.SetContext(ValidatorCodeLbl, EntityType, CustomerNo);
                    GPCustomerBalance := 0;
                    ShouldInclude := true;

                    if not GPCompanyAdditionalSettings.GetMigrateInactiveCustomers() then
                        if GPRM00101.INACTIVE then
                            ShouldInclude := false;

                    if ShouldInclude then begin
                        if GPCompanyAdditionalSettings.GetMigrateCustomerClasses() then
                            ClassName := CopyStr(GPRM00101.CUSTCLAS.TrimEnd(), 1, MaxStrLen(ClassName));

                        if ClassName = '' then
                            ClassName := DefaultClassNameTok;

                        Clear(GPCustomer);
                        GPPopulateCombinedTables.SetGPCustomerFields(GPCustomer, GPRM00101);

                        GPCustomer.PHONE1 := HelperFunctions.CleanGPPhoneOrFaxNumber(GPCustomer.PHONE1);
                        GPCustomer.FAX := HelperFunctions.CleanGPPhoneOrFaxNumber(GPCustomer.FAX);

                        if not GPCompanyAdditionalSettings.GetMigrateOnlyReceivablesMaster() then
                            if not GPCompanyAdditionalSettings.GetSkipPostingCustomerBatches() then begin
                                GPRM20101.SetRange(CUSTNMBR, GPRM00101.CUSTNMBR);
                                GPRM20101.SetRange(RMDTYPAL, 1, 9);
                                GPRM20101.SetRange(VOIDSTTS, 0);
                                GPRM20101.SetFilter(CURTRXAM, '>=0.01');
                                if GPRM20101.FindSet() then
                                    repeat
                                        if GPRM20101.RMDTYPAL < 7 then
                                            GPCustomerBalance := RoundWithSpecPrecision(GPCustomerBalance + GPRM20101.CURTRXAM)
                                        else
                                            GPCustomerBalance := GPCustomerBalance + RoundWithSpecPrecision(GPRM20101.CURTRXAM * -1);
                                    until GPRM20101.Next() = 0;
                            end;

                        if not MigrationValidation.ValidateRecordExists(Test_CUSTOMEREXISTS_Tok, Customer.Get(CustomerNo), StrSubstNo(MissingEntityTok, EntityType)) then
                            continue;

                        Customer.CalcFields(Balance);

                        MigrationValidation.ValidateAreEqual(Test_CUSTOMERNAME_Tok, CopyStr(GPRM00101.CUSTNAME.TrimEnd(), 1, MaxStrLen(Customer.Name)), Customer.Name, NameLbl, true);
                        MigrationValidation.ValidateAreEqual(Test_CUSTOMERPOSTINGGROUP_Tok, ClassName, Customer."Customer Posting Group", CustomerPostingGroupLbl);
                        MigrationValidation.ValidateAreEqual(Test_CUSTOMERADDR_Tok, CopyStr(GPCustomer.ADDRESS1, 1, MaxStrLen(Customer.Address)), Customer.Address, AddressLbl, true);
                        MigrationValidation.ValidateAreEqual(Test_CUSTOMERADDR2_Tok, CopyStr(GPCustomer.ADDRESS2, 1, MaxStrLen(Customer."Address 2")), Customer."Address 2", Address2Lbl, true);
                        MigrationValidation.ValidateAreEqual(Test_CUSTOMERCITY_Tok, CopyStr(GPCustomer.CITY, 1, MaxStrLen(Customer.City)), Customer.City, CityLbl, true);
                        MigrationValidation.ValidateAreEqual(Test_CUSTOMERNAME2_Tok, CopyStr(GPCustomer.STMTNAME, 1, MaxStrLen(Customer."Name 2")), Customer."Name 2", Name2Lbl, true);
                        MigrationValidation.ValidateAreEqual(Test_CUSTOMERCREDITLMT_Tok, GPCustomer.CRLMTAMT, Customer."Credit Limit (LCY)", CreditLimitLbl, true);
                        MigrationValidation.ValidateAreEqual(Test_CUSTOMERCONTACT_Tok, CopyStr(GPCustomer.CNTCPRSN, 1, MaxStrLen(Customer.Contact)), Customer.Contact, ContactLbl, true);
                        MigrationValidation.ValidateAreEqual(Test_CUSTOMERSALESPERSON_Tok, UpperCase(GPCustomer.SLPRSNID.TrimEnd()), Customer."Salesperson Code", SalesPersonLbl, true);
                        MigrationValidation.ValidateAreEqual(Test_CUSTOMERSHIPMETHOD_Tok, UpperCase(CopyStr(GPCustomer.SHIPMTHD, 1, MaxStrLen(Customer."Shipment Method Code")).TrimEnd()), Customer."Shipment Method Code", ShipmentMethodLbl, true);
                        MigrationValidation.ValidateAreEqual(Test_CUSTOMERTERRITORY_Tok, UpperCase(CopyStr(GPCustomer.SALSTERR, 1, MaxStrLen(Customer."Territory Code")).TrimEnd()), Customer."Territory Code", TerritoryLbl, true);
                        MigrationValidation.ValidateAreEqual(Test_CUSTOMERTAXAREA_Tok, UpperCase(GPCustomer.TAXSCHID.TrimEnd()), Customer."Tax Area Code", TaxAreaLbl, true);
                        MigrationValidation.ValidateAreEqual(Test_CUSTOMERBALANCE_Tok, GPCustomerBalance, Customer.Balance, BalanceLbl, BalanceFailureShouldBeWarning);

                        TaxLiable := (GPCustomer.TAXSCHID <> '');
                        MigrationValidation.ValidateAreEqual(Test_CUSTOMERTAXLIABLE_Tok, TaxLiable, Customer."Tax Liable", TaxLiableLbl, true);

                        PhoneNo := '';
                        if GPCustomer.PHONE1 <> '' then
                            if not HelperFunctions.ContainsAlphaChars(GPCustomer.PHONE1) then
                                PhoneNo := GPCustomer.PHONE1;

                        FaxNo := '';
                        if GPCustomer.FAX <> '' then
                            if not HelperFunctions.ContainsAlphaChars(GPCustomer.FAX) then
                                FaxNo := GPCustomer.FAX;

                        MigrationValidation.ValidateAreEqual(Test_CUSTOMERPHN_Tok, PhoneNo, Customer."Phone No.", PhoneLbl, true);
                        MigrationValidation.ValidateAreEqual(Test_CUSTOMERFAX_Tok, FaxNo, Customer."Fax No.", FaxLbl, true);

                        PaymentTerms := '';
                        if GPCustomer.PYMTRMID <> '' then
                            if GPPaymentTerms.Get(GPCustomer.PYMTRMID) then begin
                                PaymentTerms := CopyStr(GPCustomer.PYMTRMID, 1, MaxStrLen(Customer."Payment Terms Code"));
                                if GPPaymentTerms.PYMTRMID_New <> '' then
                                    PaymentTerms := GPPaymentTerms.PYMTRMID_New;
                            end;

                        MigrationValidation.ValidateAreEqual(Test_CUSTOMERPMTTERMS_Tok, PaymentTerms, Customer."Payment Terms Code", PaymentTermsLbl, true);

                        ValidateCustomerShipToAddresses(Customer);
                    end;
                until GPRM00101.Next() = 0;
        end;

        LogValidationProgress(ValidationStepCustomerLbl);
        Commit();
    end;

    local procedure ValidateCustomerShipToAddresses(var Customer: Record Customer)
    var
        GPCustomerAddress: Record "GP Customer Address";
        ShipToAddress: Record "Ship-to Address";
        AddressCode: Code[10];
        EntityType: Text[50];
        ContextCode: Text[250];
    begin
        EntityType := CustomerAddressEntityCaptionLbl;

        GPCustomerAddress.SetRange(CUSTNMBR, Customer."No.");
        if GPCustomerAddress.FindSet() then
            repeat
                AddressCode := CopyStr(GPCustomerAddress.ADRSCODE, 1, MaxStrLen(AddressCode));
                ContextCode := Customer."No." + '-' + AddressCode;

                MigrationValidation.SetContext(ValidatorCodeLbl, EntityType, ContextCode);

                if not MigrationValidation.ValidateRecordExists(Test_SHIPADDREXISTS_Tok, ShipToAddress.Get(Customer."No.", AddressCode), StrSubstNo(MissingEntityTok, EntityType)) then
                    continue;

                if (CopyStr(GPCustomerAddress.PHONE1, 1, 14) = '00000000000000') then
                    GPCustomerAddress.PHONE1 := '';

                if (CopyStr(GPCustomerAddress.FAX, 1, 14) = '00000000000000') then
                    GPCustomerAddress.FAX := '';

                MigrationValidation.ValidateAreEqual(Test_SHIPADDRNAME_Tok, Customer.Name, ShipToAddress.Name, NameLbl, true);
                MigrationValidation.ValidateAreEqual(Test_SHIPADDRADDR_Tok, GPCustomerAddress.ADDRESS1.TrimEnd(), ShipToAddress.Address, AddressLbl, true);
                MigrationValidation.ValidateAreEqual(Test_SHIPADDRADDR2_Tok, CopyStr(GPCustomerAddress.ADDRESS2.TrimEnd(), 1, MaxStrLen(ShipToAddress."Address 2")), ShipToAddress."Address 2", Address2Lbl, true);
                MigrationValidation.ValidateAreEqual(Test_SHIPADDRCITY_Tok, CopyStr(GPCustomerAddress.CITY.TrimEnd(), 1, MaxStrLen(ShipToAddress.City)), ShipToAddress.City, CityLbl, true);
                MigrationValidation.ValidateAreEqual(Test_SHIPADDRPOSTCODE_Tok, UpperCase(GPCustomerAddress.ZIP.TrimEnd()), ShipToAddress."Post Code", PostCodeLbl, true);
                MigrationValidation.ValidateAreEqual(Test_SHIPADDRPHN_Tok, GPCustomerAddress.PHONE1.TrimEnd(), ShipToAddress."Phone No.", PhoneLbl, true);
                MigrationValidation.ValidateAreEqual(Test_SHIPADDRFAX_Tok, GPCustomerAddress.FAX.TrimEnd(), ShipToAddress."Fax No.", FaxLbl, true);
                MigrationValidation.ValidateAreEqual(Test_SHIPADDRCONTACT_Tok, GPCustomerAddress.CNTCPRSN.TrimEnd(), ShipToAddress.Contact, ContactLbl, true);
                MigrationValidation.ValidateAreEqual(Test_SHIPADDRSHIPMETHOD_Tok, CopyStr(GPCustomerAddress.SHIPMTHD.TrimEnd(), 1, MaxStrLen(ShipToAddress."Shipment Method Code")), ShipToAddress."Shipment Method Code", ShipmentMethodLbl, true);
                MigrationValidation.ValidateAreEqual(Test_SHIPADDRCOUNTY_Tok, GPCustomerAddress.STATE.TrimEnd(), ShipToAddress.County, CountyLbl, true);
                MigrationValidation.ValidateAreEqual(Test_SHIPADDRTAXAREA_Tok, GPCustomerAddress.TAXSCHID.TrimEnd(), ShipToAddress."Tax Area Code", TaxAreaLbl, true);

            until GPCustomerAddress.Next() = 0;
    end;

    local procedure RunItemMigrationValidation(var GPCompanyAdditionalSettings: Record "GP Company Additional Settings")
    var
        GPItem: Record "GP Item";
        GPIV00101: Record "GP IV00101";
        GPIV00200: Record "GP IV00200";
        GPIV00300: Record "GP IV00300";
        GPIV10200: Record "GP IV10200";
        GPIV00104: Record "GP IV00104";
        Item: Record Item;
        GPPopulateCombinedTables: Codeunit "GP Populate Combined Tables";
        IsDiscontinued: Boolean;
        IsInactive: Boolean;
        IsInventoryOrDiscontinued: Boolean;
        QuantityFailureShouldBeWarning: Boolean;
        ShouldInclude: Boolean;
        ClassName: Code[20];
        ItemType: Enum "Item Type";
        CostingMethod: Enum "Costing Method";
        ItemNo: Code[20];
        Quantity: Decimal;
        KitItemNo: Code[20];
        Kits: List of [Code[20]];
        EntityType: Text[50];
    begin
        if CompanyValidationProgress.Get(CompanyNameTxt, ValidatorCodeLbl, ValidationStepItemLbl) then
            exit;

        EntityType := ItemEntityCaptionLbl;
        QuantityFailureShouldBeWarning := (TotalUnpostedItemBatchCount > 0);

        if GPCompanyAdditionalSettings.GetInventoryModuleEnabled() then begin
            if GPCompanyAdditionalSettings.GetMigrateKitItems() then
                if GPIV00104.FindSet() then
                    repeat
                        KitItemNo := CopyStr(GPIV00104.CMPTITNM.TrimEnd(), 1, MaxStrLen(KitItemNo));
                        if not Kits.Contains(KitItemNo) then
                            Kits.Add(KitItemNo);
                    until GPIV00104.Next() = 0;

            GPIV00101.SetFilter(ITEMNMBR, '<>%1', '');
            if not GPCompanyAdditionalSettings.GetMigrateKitItems() then
                GPIV00101.SetFilter(ITEMTYPE, '<>%1', 3);

            if GPIV00101.FindSet() then
                repeat
                    ItemNo := CopyStr(GPIV00101.ITEMNMBR.TrimEnd(), 1, MaxStrLen(ItemNo));
                    MigrationValidation.SetContext(ValidatorCodeLbl, EntityType, ItemNo);

                    Quantity := 0;
                    ClassName := '';
                    ShouldInclude := true;
                    IsInventoryOrDiscontinued := (GPIV00101.ITEMTYPE < 4);
                    IsInactive := (GPIV00101.ITEMTYPE = 2) or (GPIV00101.INACTIVE);
                    IsDiscontinued := GPIV00101.ITEMTYPE = 2;

                    if not GPCompanyAdditionalSettings.GetMigrateInactiveItems() then
                        if IsInactive then
                            ShouldInclude := false;

                    if ShouldInclude then
                        if not GPCompanyAdditionalSettings.GetMigrateDiscontinuedItems() then
                            if IsDiscontinued then
                                ShouldInclude := false;

                    if ShouldInclude then begin
                        if IsInventoryOrDiscontinued then
                            if GPCompanyAdditionalSettings.GetMigrateItemClasses() then begin
                                ClassName := CopyStr(GPIV00101.ITMCLSCD.TrimEnd(), 1, MaxStrLen(ClassName));

                                if ClassName = '' then
                                    ClassName := DefaultClassNameTok;
                            end else
                                ClassName := DefaultClassNameTok;

                        if not GPCompanyAdditionalSettings.GetSkipPostingItemBatches() then
                            if not GPCompanyAdditionalSettings.GetMigrateOnlyInventoryMaster() then begin
                                GPIV10200.SetRange(ITEMNMBR, GPIV00101.ITEMNMBR);
                                GPIV10200.SetRange(RCPTSOLD, false);
                                GPIV10200.SetRange(QTYTYPE, 1);
                                if GPIV10200.FindSet() then
                                    repeat
                                        // Serial
                                        if GPIV00101.ITMTRKOP = 2 then begin
                                            GPIV00200.SetRange(ITEMNMBR, GPIV10200.ITEMNMBR);
                                            GPIV00200.SetRange(LOCNCODE, GPIV10200.TRXLOCTN);
                                            GPIV00200.SetRange(DATERECD, GPIV10200.DATERECD);
                                            GPIV00200.SetRange(RCTSEQNM, GPIV10200.RCTSEQNM);
                                            GPIV00200.SetRange(QTYTYPE, 1);
                                            Quantity := Quantity + GPIV00200.Count();
                                        end;

                                        // Lot
                                        if GPIV00101.ITMTRKOP = 3 then begin
                                            GPIV00300.SetRange(ITEMNMBR, GPIV00101.ITEMNMBR);
                                            GPIV00300.SetRange(LOCNCODE, GPIV10200.TRXLOCTN);
                                            GPIV00300.SetRange(DATERECD, GPIV10200.DATERECD);
                                            GPIV00300.SetRange(RCTSEQNM, GPIV10200.RCTSEQNM);
                                            GPIV00300.SetRange(QTYTYPE, 1);
                                            if GPIV00300.FindSet() then
                                                repeat
                                                    Quantity := Quantity + (GPIV00300.QTYRECVD - GPIV00300.QTYSOLD);
                                                until GPIV00300.Next() = 0;
                                        end;

                                        if (GPIV00101.ITMTRKOP <> 2) and (GPIV00101.ITMTRKOP <> 3) then
                                            Quantity := Quantity + (GPIV10200.QTYRECVD - GPIV10200.QTYSOLD);
                                    until GPIV10200.Next() = 0;
                            end;

                        Clear(GPItem);
                        GPPopulateCombinedTables.SetGPItemFields(GPItem, GPIV00101);

                        if not MigrationValidation.ValidateRecordExists(Test_ITEMEXISTS_Tok, Item.Get(ItemNo), StrSubstNo(MissingEntityTok, EntityType)) then
                            continue;

                        Item.CalcFields(Inventory);

                        MigrationValidation.ValidateAreEqual(Test_ITEMDESC_Tok, GPItem.Description, Item.Description, DescriptionLbl, true);
                        MigrationValidation.ValidateAreEqual(Test_ITEMDESC2_Tok, GPItem.ShortName, Item."Description 2", Description2Lbl, true);
                        MigrationValidation.ValidateAreEqual(Test_ITEMSEARCHDESC_Tok, GPItem.SearchDescription, Item."Search Description", SearchDescription2Lbl, true);
                        MigrationValidation.ValidateAreEqual(Test_ITEMPOSTINGGROUP_Tok, ClassName, Item."Inventory Posting Group", ItemPostingGroupLbl, true);
                        MigrationValidation.ValidateAreEqual(Test_ITEMUNITLISTPRICE_Tok, GPItem.UnitListPrice, Item."Unit List Price", UnitListPriceLbl, true);
                        MigrationValidation.ValidateAreEqual(Test_ITEMBASEUOFM_Tok, GPItem.BaseUnitOfMeasure, Item."Base Unit of Measure", BaseUofMLbl, true);
                        MigrationValidation.ValidateAreEqual(Test_ITEMPURCHUOFM_Tok, GPItem.PurchUnitOfMeasure, Item."Purch. Unit of Measure", PurchUofMLbl, true);
                        MigrationValidation.ValidateAreEqual(Test_ITEMTRACKINGCODE_Tok, GPItem.ItemTrackingCode, Item."Item Tracking Code", ItemTrackingCodeLbl, true);
                        MigrationValidation.ValidateAreEqual(Test_ITEMINVENTORY_Tok, Quantity, Item.Inventory, QuantityLbl, QuantityFailureShouldBeWarning);

                        if (GPItem.ItemType in [0, 2]) then
                            ItemType := ItemType::Inventory
                        else
                            if not Kits.Contains(ItemNo) then
                                ItemType := ItemType::Service
                            else
                                ItemType := ItemType::"Non-Inventory";

                        if ItemType = ItemType::Service then
                            CostingMethod := CostingMethod::FIFO
                        else
                            case GPItem.CostingMethod of
                                '0':
                                    CostingMethod := CostingMethod::FIFO;
                                '1':
                                    CostingMethod := CostingMethod::LIFO;
                                '2':
                                    CostingMethod := CostingMethod::Specific;
                                '3':
                                    CostingMethod := CostingMethod::Average;
                                '4':
                                    CostingMethod := CostingMethod::Standard;
                            end;

                        MigrationValidation.ValidateAreEqual(Test_ITEMTYPE_Tok, ItemType, Item.Type, TypeLbl);
                        MigrationValidation.ValidateAreEqual(Test_ITEMCOSTMETHOD_Tok, CostingMethod, Item."Costing Method", CostingMethodLbl, true);
                    end;
                until GPIV00101.Next() = 0;
        end;

        LogValidationProgress(ValidationStepItemLbl);
        Commit();
    end;

    local procedure RunPurchaseOrderMigrationValidation(var GPCompanyAdditionalSettings: Record "GP Company Additional Settings")
    var
        GPPOP10100: Record "GP POP10100";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        GPPOHeaderValidationBuffer: Record "Migration Validation Buffer";
        GPPOLineValidationBuffer: Record "Migration Validation Buffer";
        PONumber: Code[20];
        EntityType: Text[50];
        LineEntityType: Text[50];
    begin
        if CompanyValidationProgress.Get(CompanyNameTxt, ValidatorCodeLbl, ValidationStepPurchaseOrderLbl) then
            exit;

        EntityType := 'Purchase Order';
        LineEntityType := 'Purchase Line';

        // GP
        if GPCompanyAdditionalSettings.GetMigrateOpenPOs() then begin
            GPPOP10100.SetRange(POTYPE, GPPOP10100.POTYPE::Standard);
            GPPOP10100.SetRange(POSTATUS, 1, 4);
            GPPOP10100.SetFilter(VENDORID, '<>%1', '');
            if GPPOP10100.FindSet() then
                repeat
                    PONumber := CopyStr(GPPOP10100.PONUMBER.TrimEnd(), 1, MaxStrLen(PurchaseHeader."No."));
                    if Vendor.Get(GPPOP10100.VENDORID) then
                        if not GPPOHeaderValidationBuffer.Get(PONumber) then begin
                            GPPOHeaderValidationBuffer."No." := PONumber;
                            GPPOHeaderValidationBuffer."Text 1" := CopyStr(GPPOP10100.VENDORID.TrimEnd(), 1, MaxStrLen(Vendor."No."));
                            GPPOHeaderValidationBuffer."Date 1" := GPPOP10100.DOCDATE;
                            GPPOHeaderValidationBuffer.Insert();

                            if not PopulatePOLineBuffer(PONumber, GPPOLineValidationBuffer) then
                                GPPOHeaderValidationBuffer.Delete();
                        end;
                until GPPOP10100.Next() = 0;
        end;

        // Validate - Purchase Orders
        if GPPOHeaderValidationBuffer.FindSet() then
            repeat
                MigrationValidation.SetContext(ValidatorCodeLbl, EntityType, GPPOHeaderValidationBuffer."No.");

                if not MigrationValidation.ValidateRecordExists(Test_POEXISTS_Tok, PurchaseHeader.Get("Purchase Document Type"::Order, GPPOHeaderValidationBuffer."No."), StrSubstNo(MissingEntityTok, EntityType)) then
                    continue;

                MigrationValidation.ValidateAreEqual(Test_POBUYFROMVEND_Tok, GPPOHeaderValidationBuffer."Text 1", PurchaseHeader."Buy-from Vendor No.", PurchaseOrderBuyFromVendorNoLbl);
                MigrationValidation.ValidateAreEqual(Test_POPAYTOVEND_Tok, GPPOHeaderValidationBuffer."Text 1", PurchaseHeader."Pay-to Vendor No.", PurchaseOrderPayToVendorNoLbl);
                MigrationValidation.ValidateAreEqual(Test_PODOCDATE_Tok, GPPOHeaderValidationBuffer."Date 1", PurchaseHeader."Document Date", DocumentDateLbl);

                // Lines
                GPPOLineValidationBuffer.Reset();
                GPPOLineValidationBuffer.SetRange("Parent No.", GPPOHeaderValidationBuffer."No.");
                if GPPOLineValidationBuffer.FindSet() then
                    repeat
                        MigrationValidation.SetContext(ValidatorCodeLbl, LineEntityType, GPPOLineValidationBuffer."No.");

                        PurchaseLine.SetRange("Document Type", "Purchase Document Type"::Order);
                        PurchaseLine.SetRange("Document No.", GPPOHeaderValidationBuffer."No.");
                        PurchaseLine.SetRange("No.", GPPOLineValidationBuffer."Text 1");
                        if not MigrationValidation.ValidateRecordExists(Test_POLINEEXISTS_Tok, PurchaseLine.FindFirst(), StrSubstNo(MissingEntityTok, LineEntityType)) then
                            continue;

                        MigrationValidation.ValidateAreEqual(Test_POLINEQTY_Tok, GPPOLineValidationBuffer."Decimal 1", PurchaseLine.Quantity, QuantityLbl, true);
                        MigrationValidation.ValidateAreEqual(Test_POLINEQTYRECV_Tok, GPPOLineValidationBuffer."Decimal 2", PurchaseLine."Quantity Received", QuantityRecLbl, true);
                    until GPPOLineValidationBuffer.Next() = 0;
            until GPPOHeaderValidationBuffer.Next() = 0;

        LogValidationProgress(ValidationStepPurchaseOrderLbl);
        Commit();
    end;

    local procedure PopulatePOLineBuffer(PONumber: Code[20]; var LineBuffer: Record "Migration Validation Buffer"): Boolean
    var
        GPPOP10110: Record "GP POP10110";
        GPPOPReceiptApply: Record GPPOPReceiptApply;
        GPPOPReceiptApplyLineUnitCost: Record GPPOPReceiptApply;
        Item: Record Item;
        HasLines: Boolean;
        ShouldCreateLine: Boolean;
        LocationCode: Code[10];
        LastLineUnitCost: Decimal;
        LineQtyInvoicedByUnitCost: Decimal;
        LineQtyReceivedByUnitCost: Decimal;
        LineQuantityRemaining: Decimal;
        ItemNo: Text;
        LastLocation: Text[12];
    begin
        GPPOP10110.SetRange(PONUMBER, PONumber);
        if not GPPOP10110.FindSet() then
            exit;

        repeat
            LastLocation := '';
            LastLineUnitCost := 0;
            ShouldCreateLine := true;

            ItemNo := CopyStr(GPPOP10110.ITEMNMBR.Trim(), 1, MaxStrLen(Item."No."));
            Item.SetLoadFields(Blocked);
            if Item.Get(ItemNo) then begin
                if Item.Blocked then
                    ShouldCreateLine := false
            end else
                if GPPOP10110.NONINVEN = 0 then
                    ShouldCreateLine := false;

            if ShouldCreateLine then begin
                LineQuantityRemaining := GPPOP10110.QTYORDER - GPPOP10110.QTYCANCE;
                if LineQuantityRemaining > 0 then begin
                    GPPOPReceiptApplyLineUnitCost.SetLoadFields(TRXLOCTN, PCHRPTCT, UOFM);
                    GPPOPReceiptApplyLineUnitCost.SetCurrentKey(TRXLOCTN, PCHRPTCT);
                    GPPOPReceiptApplyLineUnitCost.SetRange(PONUMBER, GPPOP10110.PONUMBER);
                    GPPOPReceiptApplyLineUnitCost.SetRange(POLNENUM, GPPOP10110.ORD);
                    GPPOPReceiptApplyLineUnitCost.SetRange(Status, GPPOPReceiptApplyLineUnitCost.Status::Posted);
                    GPPOPReceiptApplyLineUnitCost.SetFilter(POPTYPE, '1|3');
                    GPPOPReceiptApplyLineUnitCost.SetFilter(QTYSHPPD, '>%1', 0);
                    GPPOPReceiptApplyLineUnitCost.SetFilter(PCHRPTCT, '>%1', 0);

                    if GPPOPReceiptApplyLineUnitCost.FindSet() then
                        repeat
                            if ((LastLocation <> GPPOPReceiptApplyLineUnitCost.TRXLOCTN) or (LastLineUnitCost <> GPPOPReceiptApplyLineUnitCost.PCHRPTCT)) then begin
                                LocationCode := CopyStr(GPPOPReceiptApplyLineUnitCost.TRXLOCTN, 1, MaxStrLen(LocationCode));
                                LineQtyReceivedByUnitCost := GPPOPReceiptApply.GetSumQtyShippedByUnitCost(GPPOP10110.PONUMBER, GPPOP10110.ORD, LocationCode, GPPOPReceiptApplyLineUnitCost.PCHRPTCT);
                                LineQtyInvoicedByUnitCost := GPPOPReceiptApply.GetSumQtyInvoicedByUnitCost(GPPOP10110.PONUMBER, GPPOP10110.ORD, LocationCode, GPPOPReceiptApplyLineUnitCost.PCHRPTCT);

                                if (LineQtyReceivedByUnitCost > LineQtyInvoicedByUnitCost) then
                                    InsertPOLine(PONumber, GPPOP10110, LineQuantityRemaining, LineQtyReceivedByUnitCost, LineQtyInvoicedByUnitCost, HasLines, LineBuffer)
                                else
                                    LineQuantityRemaining := LineQuantityRemaining - LineQtyReceivedByUnitCost;

                                LastLocation := GPPOPReceiptApplyLineUnitCost.TRXLOCTN;
                                LastLineUnitCost := GPPOPReceiptApplyLineUnitCost.PCHRPTCT;
                            end;
                        until GPPOPReceiptApplyLineUnitCost.Next() = 0;

                    if LineQuantityRemaining > 0 then
                        InsertPOLine(PONumber, GPPOP10110, LineQuantityRemaining, 0, 0, HasLines, LineBuffer);
                end;
            end;
        until GPPOP10110.Next() = 0;

        exit(HasLines);
    end;

    local procedure InsertPOLine(PONumber: Code[20]; var GPPOP10110: Record "GP POP10110"; var LineQuantityRemaining: Decimal; QuantityReceived: Decimal; QuantityInvoiced: Decimal; var HasLines: Boolean; var LineBuffer: Record "Migration Validation Buffer")
    var
        ItemNo: Code[20];
        AdjustedQuantity: Decimal;
        AdjustedQuantityReceived: Decimal;
        QuantityOverReceipt: Decimal;
        POLineIdTxt: Text[50];
    begin
        AdjustedQuantityReceived := SubtractAndZeroIfNegative(QuantityReceived, QuantityInvoiced);
        if AdjustedQuantityReceived > 0 then
            AdjustedQuantity := SubtractAndZeroIfNegative(QuantityReceived, QuantityInvoiced)
        else
            AdjustedQuantity := SubtractAndZeroIfNegative(LineQuantityRemaining, QuantityInvoiced);

        QuantityOverReceipt := SubtractAndZeroIfNegative(AdjustedQuantityReceived, AdjustedQuantity);

        if QuantityOverReceipt > 0 then
            AdjustedQuantity := AdjustedQuantityReceived;

        if AdjustedQuantity > 0 then begin
            POLineIdTxt := CopyStr(PONumber + '_' + CopyStr(GPPOP10110.ITEMNMBR.TrimEnd(), 1, MaxStrLen(ItemNo)), 1, MaxStrLen(POLineIdTxt));
            LineBuffer.SetRange("No.", POLineIdTxt);
            if LineBuffer.FindFirst() then begin
                LineBuffer."Decimal 1" := LineBuffer."Decimal 1" + AdjustedQuantity;
                LineBuffer."Decimal 2" := LineBuffer."Decimal 2" + AdjustedQuantityReceived;
                LineBuffer.Modify();
            end else begin
                LineBuffer."No." := POLineIdTxt;
                LineBuffer."Parent No." := PONumber;
                LineBuffer."Text 1" := CopyStr(CopyStr(GPPOP10110.ITEMNMBR.TrimEnd(), 1, MaxStrLen(ItemNo)), 1, MaxStrLen(LineBuffer."Text 1"));
                LineBuffer."Decimal 1" := AdjustedQuantity;
                LineBuffer."Decimal 2" := AdjustedQuantityReceived;
                LineBuffer.Insert();
            end;

            HasLines := true;
        end;
        LineQuantityRemaining := LineQuantityRemaining - QuantityReceived;
    end;

    local procedure SubtractAndZeroIfNegative(Minuend: Decimal; Subtrahend: Decimal): Decimal
    var
        Difference: Decimal;
    begin
        Difference := Minuend - Subtrahend;

        if Difference < 0 then
            Difference := 0;

        exit(Difference);
    end;

    local procedure RunVendorMigrationValidation(var GPCompanyAdditionalSettings: Record "GP Company Additional Settings")
    var
        GPPM00200: Record "GP PM00200";
        GPPM20000: Record "GP PM20000";
        GPVendor: Record "GP Vendor";
        GPPaymentTerms: Record "GP Payment Terms";
        Vendor: Record Vendor;
        GPPopulateCombinedTables: Codeunit "GP Populate Combined Tables";
        HelperFunctions: Codeunit "Helper Functions";
        BalanceFailureShouldBeWarning: Boolean;
        IsActive: Boolean;
        ShouldInclude: Boolean;
        ClassName: Code[20];
        VendorNo: Code[20];
        Balance: Decimal;
        EntityType: Text[50];
        VendorName2: Text[50];
        PaymentTerms: Code[10];
        TaxLiable: Boolean;
        PhoneNo: Text[30];
        FaxNo: Text[30];
    begin
        if CompanyValidationProgress.Get(CompanyNameTxt, ValidatorCodeLbl, ValidationStepVendorLbl) then
            exit;

        EntityType := VendorEntityCaptionLbl;
        BalanceFailureShouldBeWarning := (TotalUnpostedVendorBatchCount > 0);

        if GPCompanyAdditionalSettings.GetPayablesModuleEnabled() then begin
            GPPM00200.SetFilter(VENDORID, '<>%1', '');
            if GPPM00200.FindSet() then
                repeat
                    VendorNo := CopyStr(GPPM00200.VENDORID.TrimEnd(), 1, MaxStrLen(VendorNo));
                    MigrationValidation.SetContext(ValidatorCodeLbl, EntityType, VendorNo);

                    Balance := 0;
                    ShouldInclude := true;
                    IsActive := (GPPM00200.VENDSTTS = 1) or (GPPM00200.VENDSTTS = 3);

                    if not GPCompanyAdditionalSettings.GetMigrateInactiveVendors() then
                        if not IsActive then
                            ShouldInclude := false;

                    if ShouldInclude then
                        ShouldInclude := ShouldMigrateTemporaryVendor(GPPM00200.VENDORID);

                    if ShouldInclude then begin
                        if GPCompanyAdditionalSettings.GetMigrateVendorClasses() then
                            ClassName := CopyStr(GPPM00200.VNDCLSID.TrimEnd(), 1, MaxStrLen(ClassName));

                        if ClassName = '' then
                            ClassName := DefaultClassNameTok;

                        Clear(GPVendor);
                        GPPopulateCombinedTables.SetGPVendorFields(GPVendor, GPPM00200);

                        GPVendor.PHNUMBR1 := HelperFunctions.CleanGPPhoneOrFaxNumber(GPVendor.PHNUMBR1);
                        GPVendor.FAXNUMBR := HelperFunctions.CleanGPPhoneOrFaxNumber(GPVendor.FAXNUMBR);

                        if not GPCompanyAdditionalSettings.GetMigrateOnlyPayablesMaster() then
                            if not GPCompanyAdditionalSettings.GetSkipPostingVendorBatches() then begin
                                GPPM20000.SetRange(VENDORID, GPPM00200.VENDORID);
                                GPPM20000.SetFilter(DOCTYPE, '<=7');
                                GPPM20000.SetFilter(CURTRXAM, '>=0.01');
                                GPPM20000.SetRange(VOIDED, false);
                                if GPPM20000.FindSet() then
                                    repeat
                                        if GPPM20000.DOCTYPE < 4 then
                                            Balance := Balance + RoundWithSpecPrecision(GPPM20000.CURTRXAM)
                                        else
                                            Balance := Balance + RoundWithSpecPrecision(GPPM20000.CURTRXAM * -1);
                                    until GPPM20000.Next() = 0;
                            end;

                        if not MigrationValidation.ValidateRecordExists(Test_VENDOREXISTS_Tok, Vendor.Get(VendorNo), StrSubstNo(MissingEntityTok, EntityType)) then
                            continue;

                        Vendor.CalcFields(Balance);

                        MigrationValidation.ValidateAreEqual(Test_VENDORNAME_Tok, CopyStr(GPVendor.VENDNAME.TrimEnd(), 1, MaxStrLen(Vendor.Name)), Vendor.Name, NameLbl, true);
                        MigrationValidation.ValidateAreEqual(Test_VENDORPOSTINGGROUP_Tok, ClassName, Vendor."Vendor Posting Group", VendorPostingGroupLbl);
                        MigrationValidation.ValidateAreEqual(Test_VENDORPREFBANKACCT_Tok, GetPreferredGPVendorBankCode(VendorNo), Vendor."Preferred Bank Account Code", PreferredBankAccountLbl);
                        MigrationValidation.ValidateAreEqual(Test_VENDORADDR_Tok, CopyStr(GPVendor.ADDRESS1, 1, MaxStrLen(Vendor.Address)), Vendor.Address, AddressLbl, true);
                        MigrationValidation.ValidateAreEqual(Test_VENDORADDR2_Tok, CopyStr(GPVendor.ADDRESS2, 1, MaxStrLen(Vendor."Address 2")), Vendor."Address 2", Address2Lbl, true);
                        MigrationValidation.ValidateAreEqual(Test_VENDORCITY_Tok, CopyStr(GPVendor.CITY, 1, MaxStrLen(Vendor.City)), Vendor.City, CityLbl, true);
                        MigrationValidation.ValidateAreEqual(Test_VENDORCONTACT_Tok, CopyStr(GPVendor.VNDCNTCT, 1, MaxStrLen(Vendor.Contact)), Vendor.Contact, ContactLbl, true);
                        MigrationValidation.ValidateAreEqual(Test_VENDORSHIPMETHOD_Tok, UpperCase(CopyStr(GPVendor.SHIPMTHD, 1, MaxStrLen(Vendor."Shipment Method Code")).TrimEnd()), Vendor."Shipment Method Code", ShipmentMethodLbl, true);
                        MigrationValidation.ValidateAreEqual(Test_VENDORTAXAREA_Tok, UpperCase(GPVendor.TAXSCHID.TrimEnd()), Vendor."Tax Area Code", TaxAreaLbl, true);
                        MigrationValidation.ValidateAreEqual(Test_VENDORBALANCE_Tok, Balance, Vendor.Balance, BalanceLbl, BalanceFailureShouldBeWarning);

                        TaxLiable := (GPVendor.TAXSCHID <> '');
                        MigrationValidation.ValidateAreEqual(Test_VENDORTAXLIABLE_Tok, TaxLiable, Vendor."Tax Liable", TaxLiableLbl, true);

                        VendorName2 := CopyStr(GPVendor.VNDCHKNM.TrimEnd(), 1, MaxStrLen(Vendor."Name 2"));
                        if HelperFunctions.StringEqualsCaseInsensitive(VendorName2, Vendor.Name) then
                            VendorName2 := '';

                        MigrationValidation.ValidateAreEqual(Test_VENDORNAME2_Tok, VendorName2, Vendor."Name 2", Name2Lbl, true);

                        PhoneNo := '';
                        if GPVendor.PHNUMBR1 <> '' then
                            if not HelperFunctions.ContainsAlphaChars(GPVendor.PHNUMBR1) then
                                PhoneNo := GPVendor.PHNUMBR1;

                        FaxNo := '';
                        if GPVendor.FAXNUMBR <> '' then
                            if not HelperFunctions.ContainsAlphaChars(GPVendor.FAXNUMBR) then
                                FaxNo := GPVendor.FAXNUMBR;

                        MigrationValidation.ValidateAreEqual(Test_VENDORPHN_Tok, PhoneNo, Vendor."Phone No.", PhoneLbl, true);
                        MigrationValidation.ValidateAreEqual(Test_VENDORFAX_Tok, FaxNo, Vendor."Fax No.", FaxLbl, true);

                        PaymentTerms := '';
                        if GPVendor.PYMTRMID <> '' then
                            if GPPaymentTerms.Get(GPVendor.PYMTRMID) then begin
                                PaymentTerms := CopyStr(GPVendor.PYMTRMID, 1, MaxStrLen(Vendor."Payment Terms Code"));
                                if GPPaymentTerms.PYMTRMID_New <> '' then
                                    PaymentTerms := GPPaymentTerms.PYMTRMID_New;
                            end;

                        MigrationValidation.ValidateAreEqual(Test_VENDORPMTTERMS_Tok, PaymentTerms, Vendor."Payment Terms Code", PaymentTermsLbl, true);

                        ValidateVendorAddresses(GPVendor);
                    end;
                until GPPM00200.Next() = 0;
        end;

        LogValidationProgress(ValidationStepVendorLbl);
        Commit();
    end;

    local procedure ValidateVendorAddresses(var GPVendor: Record "GP Vendor")
    var
        GPPM00200: Record "GP PM00200";
        GPVendorAddress: Record "GP Vendor Address";
        Vendor: Record Vendor;
        RemitAddress: Record "Remit Address";
        OrderAddress: Record "Order Address";
        HelperFunctions: Codeunit "Helper Functions";
        AddressCode: Code[10];
        AssignedPrimaryAddressCode: Code[10];
        AssignedRemitToAddressCode: Code[10];
        EntityType: Text[50];
        ContextCode: Text[250];
    begin
        if not Vendor.Get(GPVendor.VENDORID) then
            exit;

        if GPPM00200.Get(GPVendor.VENDORID) then begin
            AssignedPrimaryAddressCode := CopyStr(GPPM00200.VADDCDPR.Trim(), 1, MaxStrLen(AssignedPrimaryAddressCode));
            AssignedRemitToAddressCode := CopyStr(GPPM00200.VADCDTRO.Trim(), 1, MaxStrLen(AssignedRemitToAddressCode));
        end;

        GPVendorAddress.SetRange(VENDORID, Vendor."No.");
        if GPVendorAddress.FindSet() then
            repeat
                AddressCode := CopyStr(GPVendorAddress.ADRSCODE.Trim(), 1, MaxStrLen(AddressCode));
                ContextCode := Vendor."No." + '-' + AddressCode;

                if AddressCode = AssignedRemitToAddressCode then begin
                    EntityType := VendorRemitAddressEntityCaptionLbl;
                    MigrationValidation.SetContext(ValidatorCodeLbl, EntityType, ContextCode);

                    if MigrationValidation.ValidateRecordExists(Test_REMITADDREXISTS_Tok, RemitAddress.Get(AddressCode, Vendor."No."), StrSubstNo(MissingEntityTok, EntityType)) then begin
                        MigrationValidation.ValidateAreEqual(Test_REMITADDRNAME_Tok, Vendor.Name, RemitAddress.Name, NameLbl, true);
                        MigrationValidation.ValidateAreEqual(Test_REMITADDRADDR_Tok, GPVendorAddress.ADDRESS1.TrimEnd(), RemitAddress.Address, AddressLbl, true);
                        MigrationValidation.ValidateAreEqual(Test_REMITADDRADDR2_Tok, CopyStr(GPVendorAddress.ADDRESS2.TrimEnd(), 1, MaxStrLen(RemitAddress."Address 2")), RemitAddress."Address 2", Address2Lbl, true);
                        MigrationValidation.ValidateAreEqual(Test_REMITADDRCITY_Tok, CopyStr(GPVendorAddress.CITY.TrimEnd(), 1, MaxStrLen(RemitAddress.City)), RemitAddress.City, CityLbl, true);
                        MigrationValidation.ValidateAreEqual(Test_REMITADDRPOSTCODE_Tok, UpperCase(GPVendorAddress.ZIPCODE.TrimEnd()), RemitAddress."Post Code", PostCodeLbl, true);
                        MigrationValidation.ValidateAreEqual(Test_REMITADDRPHN_Tok, HelperFunctions.CleanGPPhoneOrFaxNumber(GPVendorAddress.PHNUMBR1), RemitAddress."Phone No.", PhoneLbl, true);
                        MigrationValidation.ValidateAreEqual(Test_REMITADDRFAX_Tok, HelperFunctions.CleanGPPhoneOrFaxNumber(GPVendorAddress.FAXNUMBR), RemitAddress."Fax No.", FaxLbl, true);
                        MigrationValidation.ValidateAreEqual(Test_REMITADDRCOUNTY_Tok, GPVendorAddress.STATE.TrimEnd(), RemitAddress.County, CountyLbl, true);
                        MigrationValidation.ValidateAreEqual(Test_REMITADDRCONTACT_Tok, GPVendorAddress.VNDCNTCT.TrimEnd(), RemitAddress.Contact, ContactLbl, true);
                    end;
                end;

                if (AddressCode = AssignedPrimaryAddressCode) or (AddressCode <> AssignedRemitToAddressCode) then begin
                    EntityType := VendorOrderAddressEntityCaptionLbl;
                    MigrationValidation.SetContext(ValidatorCodeLbl, EntityType, ContextCode);

                    if MigrationValidation.ValidateRecordExists(Test_ORDERADDREXISTS_Tok, OrderAddress.Get(Vendor."No.", AddressCode), StrSubstNo(MissingEntityTok, EntityType)) then begin
                        MigrationValidation.ValidateAreEqual(Test_ORDERADDRNAME_Tok, Vendor.Name, OrderAddress.Name, NameLbl, true);
                        MigrationValidation.ValidateAreEqual(Test_ORDERADDRADDR_Tok, GPVendorAddress.ADDRESS1.TrimEnd(), OrderAddress.Address, AddressLbl, true);
                        MigrationValidation.ValidateAreEqual(Test_ORDERADDRADDR2_Tok, CopyStr(GPVendorAddress.ADDRESS2.TrimEnd(), 1, MaxStrLen(OrderAddress."Address 2")), OrderAddress."Address 2", Address2Lbl, true);
                        MigrationValidation.ValidateAreEqual(Test_ORDERADDRCITY_Tok, CopyStr(GPVendorAddress.CITY.TrimEnd(), 1, MaxStrLen(OrderAddress.City)), OrderAddress.City, CityLbl, true);
                        MigrationValidation.ValidateAreEqual(Test_ORDERADDRPOSTCODE_Tok, UpperCase(GPVendorAddress.ZIPCODE.TrimEnd()), OrderAddress."Post Code", PostCodeLbl, true);
                        MigrationValidation.ValidateAreEqual(Test_ORDERADDRPHN_Tok, HelperFunctions.CleanGPPhoneOrFaxNumber(GPVendorAddress.PHNUMBR1), OrderAddress."Phone No.", PhoneLbl, true);
                        MigrationValidation.ValidateAreEqual(Test_ORDERADDRFAX_Tok, HelperFunctions.CleanGPPhoneOrFaxNumber(GPVendorAddress.FAXNUMBR), OrderAddress."Fax No.", FaxLbl, true);
                        MigrationValidation.ValidateAreEqual(Test_ORDERADDRCOUNTY_Tok, GPVendorAddress.STATE.TrimEnd(), OrderAddress.County, CountyLbl, true);
                        MigrationValidation.ValidateAreEqual(Test_ORDERADDRCONTACT_Tok, GPVendorAddress.VNDCNTCT.TrimEnd(), OrderAddress.Contact, ContactLbl, true);
                    end;
                end
            until GPVendorAddress.Next() = 0;
    end;

    local procedure ShouldMigrateTemporaryVendor(VendorNo: Text[75]): Boolean
    var
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        GPPM00200: Record "GP PM00200";
        GPPOP10100: Record "GP POP10100";
        GPVendorTransactions: Record "GP Vendor Transactions";
        HasOpenPurchaseOrders: Boolean;
        HasOpenTransactions: Boolean;
        IsTemporaryVendor: Boolean;
    begin
        if GPCompanyAdditionalSettings.GetMigrateTemporaryVendors() then
            exit(true);

        GPPM00200.SetLoadFields(VENDSTTS);
        if GPPM00200.Get(VendorNo) then
            IsTemporaryVendor := GPPM00200.VENDSTTS = 3;

        if not IsTemporaryVendor then
            exit(true);

        // Check for open POs
        GPPOP10100.SetRange(POTYPE, GPPOP10100.POTYPE::Standard);
        GPPOP10100.SetRange(POSTATUS, 1, 4);
        GPPOP10100.SetRange(VENDORID, VendorNo);
        HasOpenPurchaseOrders := GPPOP10100.Count() > 0;

        // Check for open AP transactions
        GPVendorTransactions.SetRange(VENDORID, VendorNo);
        HasOpenTransactions := GPVendorTransactions.Count() > 0;

        if not HasOpenPurchaseOrders then
            if not HasOpenTransactions then
                exit(false);

        exit(true);
    end;

    local procedure GetPreferredGPVendorBankCode(VendorNo: Code[20]): Code[20]
    var
        GPPM00200: Record "GP PM00200";
        GPSY06000: Record "GP SY06000";
        SearchGPSY06000: Record "GP SY06000";
        AddressCode: Code[10];
        PrimaryAddressCode: Code[10];
        RemitToAddressCode: Code[10];
        GeneratedBankCode: Code[20];
        PreferredBankCode: Code[20];
        BankAccountCounter: Integer;
        MaxSupportedVendorNoLength: Integer;
        NumberOfAccounts: Integer;
    begin
        PreferredBankCode := '';
        BankAccountCounter := 0;

        GPPM00200.SetLoadFields(VADDCDPR, VADCDTRO);
        if not GPPM00200.Get(VendorNo) then
            exit;

        GPSY06000.SetLoadFields(CustomerVendor_ID);
        GPSY06000.SetRange(CustomerVendor_ID, VendorNo);
        GPSY06000.SetRange(INACTIVE, false);
        NumberOfAccounts := GPSY06000.Count();

        if NumberOfAccounts = 0 then
            exit;

        // Single bank account, then return the VendorNo as the bank code
        if NumberOfAccounts = 1 then
            exit(VendorNo);

        // Multiple bank accounts, duplicate migration logic for multiple account handling
        PrimaryAddressCode := CopyStr(GPPM00200.VADDCDPR.Trim(), 1, MaxStrLen(PrimaryAddressCode));
        RemitToAddressCode := CopyStr(GPPM00200.VADCDTRO.Trim(), 1, MaxStrLen(RemitToAddressCode));
        MaxSupportedVendorNoLength := MaxStrLen(GeneratedBankCode) - StrLen(Format(NumberOfAccounts)) - 1;

        if StrLen(VendorNo) > MaxSupportedVendorNoLength then
#pragma warning disable AA0139
            VendorNo := CopyStr(VendorNo, 1, MaxSupportedVendorNoLength);
#pragma warning restore AA0139

        GPSY06000.SetLoadFields(ADRSCODE);
        if GPSY06000.FindSet() then
            repeat
                BankAccountCounter := BankAccountCounter + 1;
                GeneratedBankCode := CopyStr(VendorNo + '-' + Format(BankAccountCounter), 1, MaxStrLen(GeneratedBankCode));
                AddressCode := CopyStr(GPSY06000.ADRSCODE.TrimEnd(), 1, MaxStrLen(AddressCode));

                if AddressCode = RemitToAddressCode then
                    PreferredBankCode := GeneratedBankCode
                else
                    if AddressCode = PrimaryAddressCode then begin
                        SearchGPSY06000.SetRange("CustomerVendor_ID", VendorNo);
                        SearchGPSY06000.SetRange("ADRSCODE", RemitToAddressCode);
                        SearchGPSY06000.SetRange("INACTIVE", false);
                        if SearchGPSY06000.IsEmpty() then
                            PreferredBankCode := GeneratedBankCode;
                    end;
            until GPSY06000.Next() = 0;

        exit(PreferredBankCode);
    end;

    local procedure GetAccountFilter(AccountNo: Text[50]; ACCTYPE: Integer): Text
    var
        GPGL00100: Record "GP GL00100";
        FilterText: Text;
    begin
        GPGL00100.SetLoadFields(ACTINDX);
        GPGL00100.SetRange(ACCTTYPE, ACCTYPE);
        GPGL00100.SetRange(MNACSGMT, AccountNo);
        GPGL00100.SetRange(PSTNGTYP, 0);
        GPGL00100.SetRange(Clear_Balance, false);
        if GPGL00100.FindSet() then
            repeat
                if FilterText <> '' then
                    FilterText += '|' + Format(GPGL00100.ACTINDX)
                else
                    FilterText := Format(GPGL00100.ACTINDX);
            until GPGL00100.Next() = 0;

        exit(FilterText);
    end;

    internal procedure RoundWithSpecPrecision(Amount: Decimal): Decimal
    begin
        exit(Round(Amount, DefaultCurrency."Amount Rounding Precision"));
    end;

    local procedure LogValidationProgress(ValidationStep: Code[20])
    begin
        Clear(CompanyValidationProgress);
        CompanyValidationProgress.Validate("Company Name", CompanyNameTxt);
        CompanyValidationProgress.Validate("Validator Code", ValidatorCodeLbl);
        CompanyValidationProgress.Validate("Validation Step", ValidationStep);
        CompanyValidationProgress.Insert(true);
    end;

    internal procedure GetValidatorCode(): Code[20];
    begin
        exit('GP');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Cloud Management", OnPrepareMigrationValidation, '', false, false)]
    local procedure OnPrepareMigrationValidation(ProductID: Text[250])
    var
        HybridGPWizard: Codeunit "Hybrid GP Wizard";
    begin
        if ProductID <> HybridGPWizard.ProductId() then
            exit;

        RegisterValidator();

        AddTest(Test_ACCOUNTEXISTS_Tok, 'G/L Account', 'Missing Account');
        AddTest(Test_ACCOUNTNAME_Tok, 'G/L Account', 'Name');
        AddTest(Test_ACCOUNTTYPE_Tok, 'G/L Account', 'Account Type');
        AddTest(Test_ACCOUNTCATEGORY_Tok, 'G/L Account', 'Account Category');
        AddTest(Test_ACCOUNTDEBCRED_Tok, 'G/L Account', 'Debit/Credit');
        AddTest(Test_ACCOUNTSUBCATEGORY_Tok, 'G/L Account', 'Account Subcategory');
        AddTest(Test_ACCOUNTINCBAL_Tok, 'G/L Account', 'Income/Balance');
        AddTest(Test_ACCOUNTBALANCE_Tok, 'G/L Account', 'Balance');
        AddTest(Test_STATACCOUNTEXISTS_Tok, 'Statistical Account', 'Missing Account');
        AddTest(Test_STATACCOUNTNAME_Tok, 'Statistical Account', 'Name');
        AddTest(Test_STATACCOUNTDIM1_Tok, 'Statistical Account', 'Dimension 1');
        AddTest(Test_STATACCOUNTDIM2_Tok, 'Statistical Account', 'Dimension 2');
        AddTest(Test_STATACCOUNTBALANCE_Tok, 'Statistical Account', 'Balance');
        AddTest(Test_BANKACCOUNTEXISTS_Tok, 'Bank Account', 'Missing Bank Account');
        AddTest(Test_BANKACCOUNTNAME_Tok, 'Bank Account', 'Name');
        AddTest(Test_BANKACCOUNTNO_Tok, 'Bank Account', 'Bank Account No.');
        AddTest(Test_BANKACCOUNTADDR_Tok, 'Bank Account', 'Address');
        AddTest(Test_BANKACCOUNTADDR2_Tok, 'Bank Account', 'Address 2');
        AddTest(Test_BANKACCOUNTCITY_Tok, 'Bank Account', 'City');
        AddTest(Test_BANKACCOUNTCOUNTY_Tok, 'Bank Account', 'County (State)');
        AddTest(Test_BANKACCOUNTPOSTCODE_Tok, 'Bank Account', 'Post Code');
        AddTest(Test_BANKACCOUNTPHN_Tok, 'Bank Account', 'Phone');
        AddTest(Test_BANKACCOUNTFAX_Tok, 'Bank Account', 'Fax');
        AddTest(Test_BANKACCOUNTTRANSITNO_Tok, 'Bank Account', 'Transit No.');
        AddTest(Test_BANKACCOUNTBRANCHNO_Tok, 'Bank Account', 'Bank Branch No.');
        AddTest(Test_BANKACCOUNTBALANCE_Tok, 'Bank Account', 'Balance');
        AddTest(Test_CUSTOMEREXISTS_Tok, 'Customer', 'Missing Customer');
        AddTest(Test_CUSTOMERNAME_Tok, 'Customer', 'Name');
        AddTest(Test_CUSTOMERPOSTINGGROUP_Tok, 'Customer', 'Customer Posting Group');
        AddTest(Test_CUSTOMERADDR_Tok, 'Customer', 'Address');
        AddTest(Test_CUSTOMERADDR2_Tok, 'Customer', 'Address 2');
        AddTest(Test_CUSTOMERCITY_Tok, 'Customer', 'City');
        AddTest(Test_CUSTOMERPHN_Tok, 'Customer', 'Phone');
        AddTest(Test_CUSTOMERFAX_Tok, 'Customer', 'Fax');
        AddTest(Test_CUSTOMERNAME2_Tok, 'Customer', 'Name 2');
        AddTest(Test_CUSTOMERCREDITLMT_Tok, 'Customer', 'Credit Limit');
        AddTest(Test_CUSTOMERCONTACT_Tok, 'Customer', 'Contact');
        AddTest(Test_CUSTOMERSALESPERSON_Tok, 'Customer', 'Sales Person');
        AddTest(Test_CUSTOMERSHIPMETHOD_Tok, 'Customer', 'Shipment Method');
        AddTest(Test_CUSTOMERPMTTERMS_Tok, 'Customer', 'Payment Terms');
        AddTest(Test_CUSTOMERTERRITORY_Tok, 'Customer', 'Territory');
        AddTest(Test_CUSTOMERTAXAREA_Tok, 'Customer', 'Tax Area');
        AddTest(Test_CUSTOMERTAXLIABLE_Tok, 'Customer', 'Tax Liable');
        AddTest(Test_CUSTOMERBALANCE_Tok, 'Customer', 'Balance');
        AddTest(Test_SHIPADDREXISTS_Tok, 'Customer - Ship-to Address', 'Missing address');
        AddTest(Test_SHIPADDRNAME_Tok, 'Customer - Ship-to Address', 'Name');
        AddTest(Test_SHIPADDRADDR_Tok, 'Customer - Ship-to Address', 'Address');
        AddTest(Test_SHIPADDRADDR2_Tok, 'Customer - Ship-to Address', 'Address 2');
        AddTest(Test_SHIPADDRCITY_Tok, 'Customer - Ship-to Address', 'City');
        AddTest(Test_SHIPADDRPOSTCODE_Tok, 'Customer - Ship-to Address', 'Post Code');
        AddTest(Test_SHIPADDRPHN_Tok, 'Customer - Ship-to Address', 'Phone');
        AddTest(Test_SHIPADDRFAX_Tok, 'Customer - Ship-to Address', 'Fax');
        AddTest(Test_SHIPADDRCONTACT_Tok, 'Customer - Ship-to Address', 'Contact');
        AddTest(Test_SHIPADDRSHIPMETHOD_Tok, 'Customer - Ship-to Address', 'Shipment Method');
        AddTest(Test_SHIPADDRCOUNTY_Tok, 'Customer - Ship-to Address', 'County (State)');
        AddTest(Test_SHIPADDRTAXAREA_Tok, 'Customer - Ship-to Address', 'Tax Area');
        AddTest(Test_ITEMEXISTS_Tok, 'Item', 'Missing Item');
        AddTest(Test_ITEMTYPE_Tok, 'Item', 'Type');
        AddTest(Test_ITEMDESC_Tok, 'Item', 'Description');
        AddTest(Test_ITEMDESC2_Tok, 'Item', 'Description 2');
        AddTest(Test_ITEMSEARCHDESC_Tok, 'Item', 'Search Description');
        AddTest(Test_ITEMPOSTINGGROUP_Tok, 'Item', 'Inventory Posting Group');
        AddTest(Test_ITEMUNITLISTPRICE_Tok, 'Item', 'Unit List Price');
        AddTest(Test_ITEMUNITCOST_Tok, 'Item', 'Unit Cost');
        AddTest(Test_ITEMSTANDARDCOST_Tok, 'Item', 'Standard Cost');
        AddTest(Test_ITEMCOSTMETHOD_Tok, 'Item', 'Costing Method');
        AddTest(Test_ITEMBASEUOFM_Tok, 'Item', 'Base Unit of Measure');
        AddTest(Test_ITEMPURCHUOFM_Tok, 'Item', 'Purch. Unit of Measure');
        AddTest(Test_ITEMTRACKINGCODE_Tok, 'Item', 'Item Tracking Code');
        AddTest(Test_ITEMINVENTORY_Tok, 'Item', 'Inventory');
        AddTest(Test_POEXISTS_Tok, 'Purchase Order', 'Missing Purchase Order');
        AddTest(Test_POBUYFROMVEND_Tok, 'Purchase Order', 'Buy-from Vendor No.');
        AddTest(Test_POPAYTOVEND_Tok, 'Purchase Order', 'Pay-to Vendor No.');
        AddTest(Test_PODOCDATE_Tok, 'Purchase Order', 'Document Date');
        AddTest(Test_POLINEEXISTS_Tok, 'Purchase Order - Line', 'Missing PO Line');
        AddTest(Test_POLINEQTY_Tok, 'Purchase Order - Line', 'Quantity');
        AddTest(Test_POLINEQTYRECV_Tok, 'Purchase Order - Line', 'Quantity Received');
        AddTest(Test_VENDOREXISTS_Tok, 'Vendor', 'Missing Vendor');
        AddTest(Test_VENDORNAME_Tok, 'Vendor', 'Name');
        AddTest(Test_VENDORNAME2_Tok, 'Vendor', 'Name 2');
        AddTest(Test_VENDORPOSTINGGROUP_Tok, 'Vendor', 'Vendor Posting Group');
        AddTest(Test_VENDORPREFBANKACCT_Tok, 'Vendor', 'Preferred Bank Account');
        AddTest(Test_VENDORADDR_Tok, 'Vendor', 'Address');
        AddTest(Test_VENDORADDR2_Tok, 'Vendor', 'Address 2');
        AddTest(Test_VENDORCITY_Tok, 'Vendor', 'City');
        AddTest(Test_VENDORPHN_Tok, 'Vendor', 'Phone');
        AddTest(Test_VENDORFAX_Tok, 'Vendor', 'Fax');
        AddTest(Test_VENDORCONTACT_Tok, 'Vendor', 'Contact');
        AddTest(Test_VENDORSHIPMETHOD_Tok, 'Vendor', 'Shipment Method');
        AddTest(Test_VENDORPMTTERMS_Tok, 'Vendor', 'Payment Terms');
        AddTest(Test_VENDORTERRITORY_Tok, 'Vendor', 'Territory');
        AddTest(Test_VENDORTAXAREA_Tok, 'Vendor', 'Tax Area');
        AddTest(Test_VENDORTAXLIABLE_Tok, 'Vendor', 'Tax Liable');
        AddTest(Test_VENDORBALANCE_Tok, 'Vendor', 'Balance');
        AddTest(Test_ORDERADDREXISTS_Tok, 'Vendor - Order Address', 'Missing address');
        AddTest(Test_ORDERADDRNAME_Tok, 'Vendor - Order Address', 'Name');
        AddTest(Test_ORDERADDRADDR_Tok, 'Vendor - Order Address', 'Address');
        AddTest(Test_ORDERADDRADDR2_Tok, 'Vendor - Order Address', 'Address 2');
        AddTest(Test_ORDERADDRCITY_Tok, 'Vendor - Order Address', 'City');
        AddTest(Test_ORDERADDRPOSTCODE_Tok, 'Vendor - Order Address', 'Post Code');
        AddTest(Test_ORDERADDRPHN_Tok, 'Vendor - Order Address', 'Phone');
        AddTest(Test_ORDERADDRFAX_Tok, 'Vendor - Order Address', 'Fax');
        AddTest(Test_ORDERADDRCOUNTY_Tok, 'Vendor - Order Address', 'County (State)');
        AddTest(Test_ORDERADDRCONTACT_Tok, 'Vendor - Order Address', 'Contact');
        AddTest(Test_REMITADDREXISTS_Tok, 'Vendor - Remit Address', 'Missing address');
        AddTest(Test_REMITADDRNAME_Tok, 'Vendor - Remit Address', 'Name');
        AddTest(Test_REMITADDRADDR_Tok, 'Vendor - Remit Address', 'Address');
        AddTest(Test_REMITADDRADDR2_Tok, 'Vendor - Remit Address', 'Address 2');
        AddTest(Test_REMITADDRCITY_Tok, 'Vendor - Remit Address', 'City');
        AddTest(Test_REMITADDRPOSTCODE_Tok, 'Vendor - Remit Address', 'Post Code');
        AddTest(Test_REMITADDRPHN_Tok, 'Vendor - Remit Address', 'Phone');
        AddTest(Test_REMITADDRFAX_Tok, 'Vendor - Remit Address', 'Fax');
        AddTest(Test_REMITADDRCOUNTY_Tok, 'Vendor - Remit Address', 'County (State)');
        AddTest(Test_REMITADDRCONTACT_Tok, 'Vendor - Remit Address', 'Contact');
    end;

    local procedure RegisterValidator()
    var
        MigrationValidatorRegistry: Record "Migration Validator Registry";
        GPMigrationValidator: Codeunit "GP Migration Validator";
        HybridGPWizard: Codeunit "Hybrid GP Wizard";
        ValidatorCode: Code[20];
        MigrationType: Text[250];
        ValidatorCodeunitId: Integer;
    begin
        ValidatorCode := GPMigrationValidator.GetValidatorCode();
        MigrationType := HybridGPWizard.ProductId();
        ValidatorCodeunitId := Codeunit::"GP Migration Validator";
        if not MigrationValidatorRegistry.Get(ValidatorCode) then begin
            MigrationValidatorRegistry.Validate("Validator Code", ValidatorCode);
            MigrationValidatorRegistry.Validate("Migration Type", MigrationType);
            MigrationValidatorRegistry.Validate(Description, ValidatorDescriptionLbl);
            MigrationValidatorRegistry.Validate("Codeunit Id", ValidatorCodeunitId);
            MigrationValidatorRegistry.Validate(Automatic, false);
            MigrationValidatorRegistry.Insert(true);
        end;
    end;

    local procedure AddTest(Code: Code[30]; Entity: Text[50]; Description: Text)
    var
        MigrationValidationTest: Record "Migration Validation Test";
        GPMigrationValidator: Codeunit "GP Migration Validator";
    begin
        if not MigrationValidationTest.Get(Code, GPMigrationValidator.GetValidatorCode()) then begin
            MigrationValidationTest.Validate(Code, Code);
            MigrationValidationTest.Validate("Validator Code", GPMigrationValidator.GetValidatorCode());
            MigrationValidationTest.Validate(Entity, Entity);
            MigrationValidationTest.Validate("Test Description", Description);
            MigrationValidationTest.Insert(true);
        end;
    end;

    var
        DefaultCurrency: Record Currency;
        CompanyValidationProgress: Record "Company Validation Progress";
        MigrationValidation: Codeunit "Migration Validation";
        ValidatorCodeLbl: Code[20];
        CompanyNameTxt: Text;
        TotalUnpostedBankBatchCount: Integer;
        TotalUnpostedCustomerBatchCount: Integer;
        TotalUnpostedGLBatchCount: Integer;
        TotalUnpostedItemBatchCount: Integer;
        TotalUnpostedStatisticalBatchCount: Integer;
        TotalUnpostedVendorBatchCount: Integer;
        AccountCategoryLbl: Label 'Account Category';
        AccountDebitCreditLbl: Label 'Debit/Credit';
        AccountIncomeBalanceLbl: Label 'Income/Balance';
        AccountNameLbl: Label 'Name';
        AccountSubcategoryLbl: Label 'Account Subcategory';
        AccountTypeLbl: Label 'Account Type';
        Address2Lbl: Label 'Address 2';
        AddressLbl: Label 'Address';
        BalanceLbl: Label 'Balance';
        BankAccountEntityCaptionLbl: Label 'Bank Account', MaxLength = 50;
        BankAccountNumberLbl: Label 'Account Number';
        BankBranchNoLbl: Label 'Bank Branch No.';
        BaseUofMLbl: Label 'Base UofM';
        BeginningBalanceLbl: Label 'Beginning Balance';
        CityLbl: Label 'City';
        ContactLbl: Label 'Contact';
        CostingMethodLbl: Label 'Costing Method';
        CountyLbl: Label 'County';
        CreditLimitLbl: Label 'Credit Limit';
        CustomerAddressEntityCaptionLbl: Label 'Customer Ship-to Address', MaxLength = 50;
        CustomerEntityCaptionLbl: Label 'Customer', MaxLength = 50;
        CustomerPostingGroupLbl: Label 'Customer Posting Group';
        DefaultClassNameTok: Label 'GP', MaxLength = 20, Locked = true;
        Description2Lbl: Label 'Description 2';
        DescriptionLbl: Label 'Description';
        Dimension1Lbl: Label 'Dimension 1';
        Dimension2Lbl: Label 'Dimension 2';
        DocumentDateLbl: Label 'Document Date';
        FaxLbl: Label 'Fax';
        GlAccountEntityCaptionLbl: Label 'G/L Account', MaxLength = 50;
        ItemEntityCaptionLbl: Label 'Item', MaxLength = 50;
        ItemPostingGroupLbl: Label 'Item Posting Group';
        ItemTrackingCodeLbl: Label 'Item Tracking Code';
        MissingEntityTok: Label 'Missing %1', Comment = '%1 = the entity being validated';
        Name2Lbl: Label 'Name 2';
        NameLbl: Label 'Name';
        PaymentTermsLbl: Label 'Payment Terms';
        PhoneLbl: Label 'Phone';
        PostCodeLbl: Label 'Post Code';
        PreferredBankAccountLbl: Label 'Preferred Bank Account';
        PurchaseOrderBuyFromVendorNoLbl: Label 'Buy-from Vendor No.';
        PurchaseOrderPayToVendorNoLbl: Label 'Pay-to Vendor No.';
        PurchUofMLbl: Label 'Purch. UofM';
        QuantityLbl: Label 'Quantity';
        QuantityRecLbl: Label 'Quantity Received';
        SalesPersonLbl: Label 'Sales Person';
        SearchDescription2Lbl: Label 'Search Description';
        ShipmentMethodLbl: Label 'Shipment Method';
        StatisticalAccountEntityCaptionLbl: Label 'Statistical Account', MaxLength = 50;
        TaxAreaLbl: Label 'Tax Area';
        TaxLiableLbl: Label 'Tax Liable';
        TerritoryLbl: Label 'Territory';
        TransitNoLbl: Label 'Transit No.';
        TypeLbl: Label 'Type';
        UnitListPriceLbl: Label 'Unit List Price';
        VendorEntityCaptionLbl: Label 'Vendor', MaxLength = 50;
        VendorOrderAddressEntityCaptionLbl: Label 'Vendor Order Address', MaxLength = 50;
        VendorPostingGroupLbl: Label 'Vendor Posting Group';
        VendorRemitAddressEntityCaptionLbl: Label 'Vendor Remit Address', MaxLength = 50;
        ValidationStepGLAccountLbl: Label 'GLACCOUNT', MaxLength = 20;
        ValidationStepStatAccountLbl: Label 'STATACCOUNT', MaxLength = 20;
        ValidationStepBankAccountLbl: Label 'BANKACCOUNT', MaxLength = 20;
        ValidationStepCustomerLbl: Label 'CUSTOMER', MaxLength = 20;
        ValidationStepItemLbl: Label 'ITEM', MaxLength = 20;
        ValidationStepPurchaseOrderLbl: Label 'PURCHASEORDER', MaxLength = 20;
        ValidationStepVendorLbl: Label 'VENDOR', MaxLength = 20;
        ValidatorDescriptionLbl: Label 'GP migration validator', MaxLength = 250;
        Test_ACCOUNTEXISTS_Tok: Label 'ACCOUNTEXISTS', Locked = true;
        Test_ACCOUNTNAME_Tok: Label 'ACCOUNTNAME', Locked = true;
        Test_ACCOUNTTYPE_Tok: Label 'ACCOUNTTYPE', Locked = true;
        Test_ACCOUNTCATEGORY_Tok: Label 'ACCOUNTCATEGORY', Locked = true;
        Test_ACCOUNTDEBCRED_Tok: Label 'ACCOUNTDEBCRED', Locked = true;
        Test_ACCOUNTSUBCATEGORY_Tok: Label 'ACCOUNTSUBCATEGORY', Locked = true;
        Test_ACCOUNTINCBAL_Tok: Label 'ACCOUNTINCBAL', Locked = true;
        Test_ACCOUNTBALANCE_Tok: Label 'ACCOUNTBALANCE', Locked = true;
        Test_STATACCOUNTEXISTS_Tok: Label 'STATACCOUNTEXISTS', Locked = true;
        Test_STATACCOUNTNAME_Tok: Label 'STATACCOUNTNAME', Locked = true;
        Test_STATACCOUNTDIM1_Tok: Label 'STATACCOUNTDIM1', Locked = true;
        Test_STATACCOUNTDIM2_Tok: Label 'STATACCOUNTDIM2', Locked = true;
        Test_STATACCOUNTBALANCE_Tok: Label 'STATACCOUNTBALANCE', Locked = true;
        Test_BANKACCOUNTEXISTS_Tok: Label 'BANKACCOUNTEXISTS', Locked = true;
        Test_BANKACCOUNTNAME_Tok: Label 'BANKACCOUNTNAME', Locked = true;
        Test_BANKACCOUNTNO_Tok: Label 'BANKACCOUNTNO', Locked = true;
        Test_BANKACCOUNTADDR_Tok: Label 'BANKACCOUNTADDR', Locked = true;
        Test_BANKACCOUNTADDR2_Tok: Label 'BANKACCOUNTADDR2', Locked = true;
        Test_BANKACCOUNTCITY_Tok: Label 'BANKACCOUNTCITY', Locked = true;
        Test_BANKACCOUNTCOUNTY_Tok: Label 'BANKACCOUNTCOUNTY', Locked = true;
        Test_BANKACCOUNTPOSTCODE_Tok: Label 'BANKACCOUNTPOSTCODE', Locked = true;
        Test_BANKACCOUNTPHN_Tok: Label 'BANKACCOUNTPHN', Locked = true;
        Test_BANKACCOUNTFAX_Tok: Label 'BANKACCOUNTFAX', Locked = true;
        Test_BANKACCOUNTTRANSITNO_Tok: Label 'BANKACCOUNTTRANSITNO', Locked = true;
        Test_BANKACCOUNTBRANCHNO_Tok: Label 'BANKACCOUNTBRANCHNO', Locked = true;
        Test_BANKACCOUNTBALANCE_Tok: Label 'BANKACCOUNTBALANCE', Locked = true;
        Test_CUSTOMEREXISTS_Tok: Label 'CUSTOMEREXISTS', Locked = true;
        Test_CUSTOMERNAME_Tok: Label 'CUSTOMERNAME', Locked = true;
        Test_CUSTOMERPOSTINGGROUP_Tok: Label 'CUSTOMERPOSTINGGROUP', Locked = true;
        Test_CUSTOMERADDR_Tok: Label 'CUSTOMERADDR', Locked = true;
        Test_CUSTOMERADDR2_Tok: Label 'CUSTOMERADDR2', Locked = true;
        Test_CUSTOMERCITY_Tok: Label 'CUSTOMERCITY', Locked = true;
        Test_CUSTOMERPHN_Tok: Label 'CUSTOMERPHN', Locked = true;
        Test_CUSTOMERFAX_Tok: Label 'CUSTOMERFAX', Locked = true;
        Test_CUSTOMERNAME2_Tok: Label 'CUSTOMERNAME2', Locked = true;
        Test_CUSTOMERCREDITLMT_Tok: Label 'CUSTOMERCREDITLMT', Locked = true;
        Test_CUSTOMERCONTACT_Tok: Label 'CUSTOMERCONTACT', Locked = true;
        Test_CUSTOMERSALESPERSON_Tok: Label 'CUSTOMERSALESPERSON', Locked = true;
        Test_CUSTOMERSHIPMETHOD_Tok: Label 'CUSTOMERSHIPMETHOD', Locked = true;
        Test_CUSTOMERPMTTERMS_Tok: Label 'CUSTOMERPMTTERMS', Locked = true;
        Test_CUSTOMERTERRITORY_Tok: Label 'CUSTOMERTERRITORY', Locked = true;
        Test_CUSTOMERTAXAREA_Tok: Label 'CUSTOMERTAXAREA', Locked = true;
        Test_CUSTOMERTAXLIABLE_Tok: Label 'CUSTOMERTAXLIABLE', Locked = true;
        Test_CUSTOMERBALANCE_Tok: Label 'CUSTOMERBALANCE', Locked = true;
        Test_SHIPADDREXISTS_Tok: Label 'SHIPADDREXISTS', Locked = true;
        Test_SHIPADDRNAME_Tok: Label 'SHIPADDRNAME', Locked = true;
        Test_SHIPADDRADDR_Tok: Label 'SHIPADDRADDR', Locked = true;
        Test_SHIPADDRADDR2_Tok: Label 'SHIPADDRADDR2', Locked = true;
        Test_SHIPADDRCITY_Tok: Label 'SHIPADDRCITY', Locked = true;
        Test_SHIPADDRPOSTCODE_Tok: Label 'SHIPADDRPOSTCODE', Locked = true;
        Test_SHIPADDRPHN_Tok: Label 'SHIPADDRPHN', Locked = true;
        Test_SHIPADDRFAX_Tok: Label 'SHIPADDRFAX', Locked = true;
        Test_SHIPADDRCONTACT_Tok: Label 'SHIPADDRCONTACT', Locked = true;
        Test_SHIPADDRSHIPMETHOD_Tok: Label 'SHIPADDRSHIPMETHOD', Locked = true;
        Test_SHIPADDRCOUNTY_Tok: Label 'SHIPADDRCOUNTY', Locked = true;
        Test_SHIPADDRTAXAREA_Tok: Label 'SHIPADDRTAXAREA', Locked = true;
        Test_ITEMEXISTS_Tok: Label 'ITEMEXISTS', Locked = true;
        Test_ITEMTYPE_Tok: Label 'ITEMTYPE', Locked = true;
        Test_ITEMDESC_Tok: Label 'ITEMDESC', Locked = true;
        Test_ITEMDESC2_Tok: Label 'ITEMDESC2', Locked = true;
        Test_ITEMSEARCHDESC_Tok: Label 'ITEMSEARCHDESC', Locked = true;
        Test_ITEMPOSTINGGROUP_Tok: Label 'ITEMPOSTINGGROUP', Locked = true;
        Test_ITEMUNITLISTPRICE_Tok: Label 'ITEMUNITLISTPRICE', Locked = true;
        Test_ITEMUNITCOST_Tok: Label 'ITEMUNITCOST', Locked = true;
        Test_ITEMSTANDARDCOST_Tok: Label 'ITEMSTANDARDCOST', Locked = true;
        Test_ITEMCOSTMETHOD_Tok: Label 'ITEMCOSTMETHOD', Locked = true;
        Test_ITEMBASEUOFM_Tok: Label 'ITEMBASEUOFM', Locked = true;
        Test_ITEMPURCHUOFM_Tok: Label 'ITEMPURCHUOFM', Locked = true;
        Test_ITEMTRACKINGCODE_Tok: Label 'ITEMTRACKINGCODE', Locked = true;
        Test_ITEMINVENTORY_Tok: Label 'ITEMINVENTORY', Locked = true;
        Test_POEXISTS_Tok: Label 'POEXISTS', Locked = true;
        Test_POBUYFROMVEND_Tok: Label 'POBUYFROMVEND', Locked = true;
        Test_POPAYTOVEND_Tok: Label 'POPAYTOVEND', Locked = true;
        Test_PODOCDATE_Tok: Label 'PODOCDATE', Locked = true;
        Test_POLINEEXISTS_Tok: Label 'POLINEEXISTS', Locked = true;
        Test_POLINEQTY_Tok: Label 'POLINEQTY', Locked = true;
        Test_POLINEQTYRECV_Tok: Label 'POLINEQTYRECV', Locked = true;
        Test_VENDOREXISTS_Tok: Label 'VENDOREXISTS', Locked = true;
        Test_VENDORNAME_Tok: Label 'VENDORNAME', Locked = true;
        Test_VENDORNAME2_Tok: Label 'VENDORNAME2', Locked = true;
        Test_VENDORPOSTINGGROUP_Tok: Label 'VENDORPOSTINGGROUP', Locked = true;
        Test_VENDORPREFBANKACCT_Tok: Label 'VENDORPREFBANKACCT', Locked = true;
        Test_VENDORADDR_Tok: Label 'VENDORADDR', Locked = true;
        Test_VENDORADDR2_Tok: Label 'VENDORADDR2', Locked = true;
        Test_VENDORCITY_Tok: Label 'VENDORCITY', Locked = true;
        Test_VENDORPHN_Tok: Label 'VENDORPHN', Locked = true;
        Test_VENDORFAX_Tok: Label 'VENDORFAX', Locked = true;
        Test_VENDORCONTACT_Tok: Label 'VENDORCONTACT', Locked = true;
        Test_VENDORSHIPMETHOD_Tok: Label 'VENDORSHIPMETHOD', Locked = true;
        Test_VENDORPMTTERMS_Tok: Label 'VENDORPMTTERMS', Locked = true;
        Test_VENDORTERRITORY_Tok: Label 'VENDORTERRITORY', Locked = true;
        Test_VENDORTAXAREA_Tok: Label 'VENDORTAXAREA', Locked = true;
        Test_VENDORTAXLIABLE_Tok: Label 'VENDORTAXLIABLE', Locked = true;
        Test_VENDORBALANCE_Tok: Label 'VENDORBALANCE', Locked = true;
        Test_ORDERADDREXISTS_Tok: Label 'ORDERADDREXISTS', Locked = true;
        Test_ORDERADDRNAME_Tok: Label 'ORDERADDRNAME', Locked = true;
        Test_ORDERADDRADDR_Tok: Label 'ORDERADDRADDR', Locked = true;
        Test_ORDERADDRADDR2_Tok: Label 'ORDERADDRADDR2', Locked = true;
        Test_ORDERADDRCITY_Tok: Label 'ORDERADDRCITY', Locked = true;
        Test_ORDERADDRPOSTCODE_Tok: Label 'ORDERADDRPOSTCODE', Locked = true;
        Test_ORDERADDRPHN_Tok: Label 'ORDERADDRPHN', Locked = true;
        Test_ORDERADDRFAX_Tok: Label 'ORDERADDRFAX', Locked = true;
        Test_ORDERADDRCOUNTY_Tok: Label 'ORDERADDRCOUNTY', Locked = true;
        Test_ORDERADDRCONTACT_Tok: Label 'ORDERADDRCONTACT', Locked = true;
        Test_REMITADDREXISTS_Tok: Label 'REMITADDREXISTS', Locked = true;
        Test_REMITADDRNAME_Tok: Label 'REMITADDRNAME', Locked = true;
        Test_REMITADDRADDR_Tok: Label 'REMITADDRADDR', Locked = true;
        Test_REMITADDRADDR2_Tok: Label 'REMITADDRADDR2', Locked = true;
        Test_REMITADDRCITY_Tok: Label 'REMITADDRCITY', Locked = true;
        Test_REMITADDRPOSTCODE_Tok: Label 'REMITADDRPOSTCODE', Locked = true;
        Test_REMITADDRPHN_Tok: Label 'REMITADDRPHN', Locked = true;
        Test_REMITADDRFAX_Tok: Label 'REMITADDRFAX', Locked = true;
        Test_REMITADDRCOUNTY_Tok: Label 'REMITADDRCOUNTY', Locked = true;
        Test_REMITADDRCONTACT_Tok: Label 'REMITADDRCONTACT', Locked = true;

}