namespace Microsoft.DataMigration.GP;

using Microsoft.DataMigration;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.Analysis.StatisticalAccount;
using Microsoft.Bank.BankAccount;
using Microsoft.Sales.Customer;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Costing;
using Microsoft.Purchases.Vendor;
using Microsoft.Purchases.Document;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Purchases.Remittance;
using Microsoft.Bank.Ledger;
using Microsoft.Sales.Receivables;
using Microsoft.Purchases.Payables;
using Microsoft.Inventory.Ledger;
using Microsoft.Foundation.PaymentTerms;
using Microsoft.Finance.SalesTax;
using Microsoft.Inventory.Intrastat;
using Microsoft.CRM.Team;
using Microsoft.Foundation.Shipping;
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
        TempGPGLAccount: Record "G/L Account" temporary;
        TempGLEntry: Record "G/L Entry" temporary;
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
            if GPGL00100.FindSet() then
                repeat
                    GPAccountBeginningBalance := 0;
                    GPAccountNo := CopyStr(GPGL00100.MNACSGMT.TrimEnd(), 1, MaxStrLen(GPAccountNo));

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

                    if GPAccountNo <> '' then
                        if not TempGPGLAccount.Get(GPAccountNo) then begin
                            Clear(GPAccount);

                            GPAccount.AcctNum := CopyStr(GPGL00100.MNACSGMT.Trim(), 1, MaxStrLen(GPAccount.AcctNum));
                            GPAccount.AcctIndex := GPGL00100.ACTINDX;
                            GPAccount.Name := CopyStr(GPAccountDescription.Trim(), 1, MaxStrLen(GPAccount.Name));
                            GPAccount.SearchName := GPAccount.Name;
                            GPAccount.AccountCategory := GPGL00100.ACCATNUM;
                            GPAccount.IncomeBalance := GPGL00100.PSTNGTYP = 1;
                            GPAccount.DebitCredit := GPGL00100.TPCLBLNC;
                            GPAccount.Active := GPGL00100.ACTIVE;
                            GPAccount.DirectPosting := GPGL00100.ACCTENTR;
                            GPAccount.AccountSubcategoryEntryNo := GPGL00100.ACCATNUM;
                            GPAccount.AccountType := GPGL00100.ACCTTYPE;

                            // Beginning Balance
                            if GPCompanyAdditionalSettings."Oldest GL Year to Migrate" > 0 then
                                if not GPCompanyAdditionalSettings.GetMigrateOnlyGLMaster() then
                                    if not GPCompanyAdditionalSettings.GetSkipPostingAccountBatches() then
                                        if GPGL00100.PSTNGTYP = 0 then begin
                                            AccountFilter := GetAccountFilter(GPAccountNo, 1);

                                            if AccountFilter <> '' then begin
                                                GPGL10111.SetFilter(ACTINDX, AccountFilter);
                                                GPGL10111.SetRange(PERIODID, 0);
                                                GPGL10111.SetRange(YEAR1, GPCompanyAdditionalSettings."Oldest GL Year to Migrate");
                                                if GPGL10111.FindSet() then
                                                    repeat
                                                        GPAccountBeginningBalance += RoundWithSpecPrecision(GPGL10111.PERDBLNC);
                                                    until GPGL10111.Next() = 0;
                                            end;
                                        end;

                            TempGPGLAccount."No." := GPAccountNo;
                            TempGPGLAccount.Name := GPAccountDescription;
                            TempGPGLAccount."Account Type" := TempGPGLAccount."Account Type"::Posting;
#pragma warning disable AL0603
                            TempGPGLAccount."Account Category" := HelperFunctions.ConvertAccountCategory(GPAccount);
                            TempGPGLAccount."Debit/Credit" := HelperFunctions.ConvertDebitCreditType(GPAccount);
                            TempGPGLAccount."Account Subcategory Entry No." := HelperFunctions.AssignSubAccountCategory(GPAccount);
                            TempGPGLAccount."Income/Balance" := HelperFunctions.ConvertIncomeBalanceType(GPAccount);
#pragma warning restore AL0603
                            TempGPGLAccount.Insert();

                            if GPAccountBeginningBalance <> 0 then begin
                                TempGLEntry."Entry No." := TempGLEntry.Count() + 1;
                                TempGLEntry."G/L Account No." := GPAccountNo;
                                TempGLEntry.Amount := GPAccountBeginningBalance;
                                TempGLEntry.Insert();
                            end;
                        end;
                until GPGL00100.Next() = 0;
        end;

        // Validate - G/L Accounts
        GLAccount.SetLoadFields("No.", Name, "Account Type", "Account Category", "Debit/Credit", "Account Subcategory Entry No.", "Income/Balance");
        if TempGPGLAccount.FindSet() then
            repeat
                MigrationValidationMgmt.SetContext(ValidatorCodeLbl, EntityType, TempGPGLAccount."No.");

                if not MigrationValidationMgmt.ValidateRecordExists('ACCOUNTEXISTS', GLAccount.Get(TempGPGLAccount."No."), StrSubstNo(MissingEntityTok, EntityType)) then
                    continue;

                TempGPGLAccount.CalcFields(Balance);
                GLAccount.CalcFields(Balance);

                MigrationValidationMgmt.ValidateAreEqual('ACCOUNTNAME', TempGPGLAccount.Name, GLAccount.Name, AccountNameLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('ACCOUNTTYPE', TempGPGLAccount."Account Type", GLAccount."Account Type", AccountTypeLbl);
                MigrationValidationMgmt.ValidateAreEqual('ACCOUNTCATEGORY', TempGPGLAccount."Account Category", GLAccount."Account Category", AccountCategoryLbl);
                MigrationValidationMgmt.ValidateAreEqual('ACCOUNTDEBCRED', TempGPGLAccount."Debit/Credit", GLAccount."Debit/Credit", AccountDebitCreditLbl);
                MigrationValidationMgmt.ValidateAreEqual('ACCOUNTSUBCATEGORY', TempGPGLAccount."Account Subcategory Entry No.", GLAccount."Account Subcategory Entry No.", AccountSubcategoryLbl);
                MigrationValidationMgmt.ValidateAreEqual('ACCOUNTINCBAL', TempGPGLAccount."Income/Balance", GLAccount."Income/Balance", AccountIncomeBalanceLbl);
                MigrationValidationMgmt.ValidateAreEqual('ACCOUNTBALANCE', TempGPGLAccount.Balance, GLAccount.Balance, BeginningBalanceLbl, BalanceFailureShouldBeWarning);
            until TempGPGLAccount.Next() = 0;

        LogValidationProgress(ValidationStepGLAccountLbl);
    end;

    local procedure RunStatisticalAccountMigrationValidation(var GPCompanyAdditionalSettings: Record "GP Company Additional Settings")
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        FirstAccount: Record "GP GL00100";
        GPGL00100: Record "GP GL00100";
        GPGL10111: Record "GP GL10111";
        GPGL40200: Record "GP GL40200";
        GPSY00300: Record "GP SY00300";
        StatisticalAccount: Record "Statistical Account";
        TempGPStatisticalAccount: Record "Statistical Account" temporary;
        TempStatisticalLedgerEntry: Record "Statistical Ledger Entry" temporary;
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

        // GP
        if GPCompanyAdditionalSettings.GetGLModuleEnabled() then begin
            GPGL00100.SetRange(ACCTTYPE, 2);
            if GPGL00100.FindSet() then
                repeat
                    GPAccountNo := CopyStr(GPGL00100.MNACSGMT.TrimEnd(), 1, MaxStrLen(GPAccountNo));

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

                    if GPAccountNo <> '' then
                        if not TempGPStatisticalAccount.Get(GPAccountNo) then begin
                            GPAccountBeginningBalance := 0;

                            // Beginning Balance
                            if GPCompanyAdditionalSettings."Oldest GL Year to Migrate" > 0 then
                                if not GPCompanyAdditionalSettings.GetMigrateOnlyGLMaster() then
                                    if not GPCompanyAdditionalSettings.GetSkipPostingAccountBatches() then begin
                                        Clear(GPGL10111);
                                        AccountFilter := GetAccountFilter(GPAccountNo, 2);

                                        if AccountFilter <> '' then begin
                                            GPGL10111.SetFilter(ACTINDX, AccountFilter);
                                            GPGL10111.SetRange(PERIODID, 0);
                                            GPGL10111.SetRange(YEAR1, GPCompanyAdditionalSettings."Oldest GL Year to Migrate");
                                            if GPGL10111.FindSet() then
                                                repeat
                                                    GPAccountBeginningBalance += RoundWithSpecPrecision(GPGL10111.PERDBLNC);
                                                until GPGL10111.Next() = 0;
                                        end;
                                    end;

                            TempGPStatisticalAccount."No." := GPAccountNo;
                            TempGPStatisticalAccount.Name := GPAccountDescription;
                            TempGPStatisticalAccount."Global Dimension 1 Code" := DimensionCode1;
                            TempGPStatisticalAccount."Global Dimension 2 Code" := DimensionCode2;
                            TempGPStatisticalAccount.Balance := GPAccountBeginningBalance;
                            TempGPStatisticalAccount.Insert();

                            if GPAccountBeginningBalance <> 0 then begin
                                TempStatisticalLedgerEntry."Entry No." := TempStatisticalLedgerEntry.Count() + 1;
                                TempStatisticalLedgerEntry."Statistical Account No." := GPAccountNo;
                                TempStatisticalLedgerEntry.Amount := GPAccountBeginningBalance;
                                TempStatisticalLedgerEntry.Insert();
                            end;
                        end;
                until GPGL00100.Next() = 0;
        end;

        // Validate - Statistical Accounts
        StatisticalAccount.SetLoadFields("No.", Name, "Global Dimension 1 Code", "Global Dimension 2 Code");
        if TempGPStatisticalAccount.FindSet() then
            repeat
                MigrationValidationMgmt.SetContext(ValidatorCodeLbl, EntityType, TempGPStatisticalAccount."No.");

                if not MigrationValidationMgmt.ValidateRecordExists('STATACCOUNTEXISTS', StatisticalAccount.Get(TempGPStatisticalAccount."No."), StrSubstNo(MissingEntityTok, EntityType)) then
                    continue;

                TempGPStatisticalAccount.CalcFields(Balance);
                StatisticalAccount.CalcFields(Balance);

                MigrationValidationMgmt.ValidateAreEqual('STATACCOUNTNAME', TempGPStatisticalAccount.Name, StatisticalAccount.Name, AccountNameLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('STATACCOUNTDIM1', TempGPStatisticalAccount."Global Dimension 1 Code", StatisticalAccount."Global Dimension 1 Code", Dimension1Lbl);
                MigrationValidationMgmt.ValidateAreEqual('STATACCOUNTDIM2', TempGPStatisticalAccount."Global Dimension 2 Code", StatisticalAccount."Global Dimension 2 Code", Dimension2Lbl);
                MigrationValidationMgmt.ValidateAreEqual('STATACCOUNTBALANCE', TempGPStatisticalAccount.Balance, StatisticalAccount.Balance, BeginningBalanceLbl, BalanceFailureShouldBeWarning);
            until TempGPStatisticalAccount.Next() = 0;

        LogValidationProgress(ValidationStepStatAccountLbl);
    end;

    local procedure RunBankAccountMigrationValidation(var GPCompanyAdditionalSettings: Record "GP Company Additional Settings")
    var
        BankAccount: Record "Bank Account";
        TempGPBankAccount: Record "Bank Account" temporary;
        TempBankAccountLedgerEntry: Record "Bank Account Ledger Entry" temporary;
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

        // GP
        if GPCompanyAdditionalSettings.GetBankModuleEnabled() then
            if GPCheckbookMSTR.FindSet() then
                repeat
                    GPAccountNo := CopyStr(GPCheckbookMSTR.CHEKBKID.TrimEnd(), 1, MaxStrLen(GPAccountNo));
                    ShouldInclude := true;
                    GPAccountBalance := 0;

                    if not GPCompanyAdditionalSettings.GetMigrateInactiveCheckbooks() then
                        if GPCheckbookMSTR.INACTIVE then
                            ShouldInclude := false;

                    if ShouldInclude then begin
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

                        if not TempGPBankAccount.Get(GPAccountNo) then begin
                            TempGPBankAccount."No." := GPAccountNo;
                            TempGPBankAccount.Name := CopyStr(GPCheckbookMSTR.DSCRIPTN.TrimEnd(), 1, MaxStrLen(TempGPBankAccount.Name));
                            TempGPBankAccount."Bank Account No." := CopyStr(GPCheckbookMSTR.BNKACTNM.TrimEnd(), 1, MaxStrLen(TempGPBankAccount."Bank Account No."));

                            if GPBankMSTR.Get(GPCheckbookMSTR.BANKID) then begin
                                TempGPBankAccount.Address := CopyStr(GPBankMSTR.ADDRESS1.TrimEnd(), 1, MaxStrLen(TempGPBankAccount.Address));
                                TempGPBankAccount."Address 2" := CopyStr(GPBankMSTR.ADDRESS2.TrimEnd(), 1, MaxStrLen(TempGPBankAccount."Address 2"));
                                TempGPBankAccount.City := CopyStr(GPBankMSTR.CITY.TrimEnd(), 1, MaxStrLen(TempGPBankAccount.City));
                                TempGPBankAccount."Phone No." := CopyStr(GPBankMSTR.PHNUMBR1.TrimEnd(), 1, MaxStrLen(TempGPBankAccount."Phone No."));
                                TempGPBankAccount."Transit No." := CopyStr(GPBankMSTR.TRNSTNBR.TrimEnd(), 1, MaxStrLen(TempGPBankAccount."Transit No."));
                                TempGPBankAccount."Fax No." := CopyStr(GPBankMSTR.FAXNUMBR.TrimEnd(), 1, MaxStrLen(TempGPBankAccount."Fax No."));
                                TempGPBankAccount.County := CopyStr(GPBankMSTR.STATE.TrimEnd(), 1, MaxStrLen(TempGPBankAccount.County));
                                TempGPBankAccount."Post Code" := CopyStr(GPBankMSTR.ZIPCODE.TrimEnd(), 1, MaxStrLen(TempGPBankAccount."Post Code"));
                                TempGPBankAccount."Bank Branch No." := CopyStr(GPBankMSTR.BNKBRNCH.TrimEnd(), 1, MaxStrLen(TempGPBankAccount."Bank Branch No."));
                            end;

                            TempGPBankAccount.Insert();

                            if GPAccountBalance <> 0 then begin
                                TempBankAccountLedgerEntry."Entry No." := TempBankAccountLedgerEntry.Count() + 1;
                                TempBankAccountLedgerEntry."Bank Account No." := GPAccountNo;
                                TempBankAccountLedgerEntry.Amount := GPAccountBalance;
                                TempBankAccountLedgerEntry.Insert();
                            end;
                        end;
                    end;
                until GPCheckbookMSTR.Next() = 0;

        // Validate - Bank Accounts
        BankAccount.SetLoadFields("No.", Name, "Bank Account No.", Balance, Address, "Address 2", City, "Phone No.", "Transit No.", "Fax No.", County, "Post Code", "Bank Branch No.");
        if TempGPBankAccount.FindSet() then
            repeat
                MigrationValidationMgmt.SetContext(ValidatorCodeLbl, EntityType, TempGPBankAccount."No.");

                if not MigrationValidationMgmt.ValidateRecordExists('BANKACCOUNTEXISTS', BankAccount.Get(TempGPBankAccount."No."), StrSubstNo(MissingEntityTok, EntityType)) then
                    continue;

                TempGPBankAccount.CalcFields(Balance);
                BankAccount.CalcFields(Balance);

                MigrationValidationMgmt.ValidateAreEqual('BANKACCOUNTNAME', TempGPBankAccount.Name, BankAccount.Name, NameLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('BANKACCOUNTNO', TempGPBankAccount."Bank Account No.", BankAccount."Bank Account No.", BankAccountNumberLbl, false, true);
                MigrationValidationMgmt.ValidateAreEqual('BANKACCOUNTADDR', TempGPBankAccount.Address, BankAccount.Address, AddressLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('BANKACCOUNTADDR2', TempGPBankAccount."Address 2", BankAccount."Address 2", Address2Lbl, true);
                MigrationValidationMgmt.ValidateAreEqual('BANKACCOUNTCITY', TempGPBankAccount.City, BankAccount.City, CityLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('BANKACCOUNTCOUNTY', TempGPBankAccount.County, BankAccount.County, CountyLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('BANKACCOUNTPOSTCODE', TempGPBankAccount."Post Code", BankAccount."Post Code", PostCodeLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('BANKACCOUNTPHN', TempGPBankAccount."Phone No.", BankAccount."Phone No.", PhoneLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('BANKACCOUNTFAX', TempGPBankAccount."Fax No.", BankAccount."Fax No.", FaxLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('BANKACCOUNTTRANSITNO', TempGPBankAccount."Transit No.", BankAccount."Transit No.", TransitNoLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('BANKACCOUNTBRANCHNO', TempGPBankAccount."Bank Branch No.", BankAccount."Bank Branch No.", BankBranchNoLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('BANKACCOUNTBALANCE', TempGPBankAccount.Balance, BankAccount.Balance, BalanceLbl, BalanceFailureShouldBeWarning);
            until TempGPBankAccount.Next() = 0;

        LogValidationProgress(ValidationStepBankAccountLbl);
    end;

    local procedure RunCustomerMigrationValidation(var GPCompanyAdditionalSettings: Record "GP Company Additional Settings")
    var
        Customer: Record Customer;
        TempGPCustomer: Record Customer temporary;
        TempDetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry" temporary;
        GPCustomer: Record "GP Customer";
        GPRM00101: Record "GP RM00101";
        GPRM20101: record "GP RM20101";
        GPPaymentTerms: Record "GP Payment Terms";
        GPPopulateCombinedTables: Codeunit "GP Populate Combined Tables";
        HelperFunctions: Codeunit "Helper Functions";
        PaymentTermsFormula: DateFormula;
        BalanceFailureShouldBeWarning: Boolean;
        ShouldInclude: Boolean;
        ClassName: Code[20];
        CustomerNo: Code[20];
        GPCustomerBalance: Decimal;
        EntityType: Text[50];
    begin
        if CompanyValidationProgress.Get(CompanyNameTxt, ValidatorCodeLbl, ValidationStepCustomerLbl) then
            exit;

        EntityType := CustomerEntityCaptionLbl;
        BalanceFailureShouldBeWarning := (TotalUnpostedCustomerBatchCount > 0);
        Evaluate(PaymentTermsFormula, '');

        // GP
        if GPCompanyAdditionalSettings.GetReceivablesModuleEnabled() then begin
            GPRM00101.SetFilter(CUSTNMBR, '<>%1', '');
            if GPRM00101.FindSet() then
                repeat
                    CustomerNo := CopyStr(GPRM00101.CUSTNMBR.TrimEnd(), 1, MaxStrLen(CustomerNo));
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

                        if not TempGPCustomer.Get(CustomerNo) then begin
                            TempGPCustomer."No." := CustomerNo;
                            TempGPCustomer.Name := CopyStr(GPRM00101.CUSTNAME.TrimEnd(), 1, 50);
                            TempGPCustomer."Customer Posting Group" := ClassName;
                            TempGPCustomer.Address := CopyStr(GPCustomer.ADDRESS1, 1, 50);
                            TempGPCustomer."Address 2" := CopyStr(GPCustomer.ADDRESS2, 1, 50);
                            TempGPCustomer.City := CopyStr(GPCustomer.CITY, 1, 30);
                            TempGPCustomer."Name 2" := CopyStr(GPCustomer.STMTNAME, 1, 50);
                            TempGPCustomer."Credit Limit (LCY)" := GPCustomer.CRLMTAMT;
                            TempGPCustomer.Contact := CopyStr(GPCustomer.CNTCPRSN, 1, 50);

                            TempGPCustomer."Salesperson Code" := '';
                            if GPCustomer.SLPRSNID <> '' then begin
                                if not TempSalespersonPurchaser.Get(CopyStr(GPCustomer.SLPRSNID, 1, 20)) then begin
                                    TempSalespersonPurchaser.Validate(Code, CopyStr(GPCustomer.SLPRSNID, 1, 20));
                                    TempSalespersonPurchaser.Insert(true);
                                end;
                                TempGPCustomer."Salesperson Code" := TempSalespersonPurchaser.Code;
                            end;

                            TempGPCustomer."Shipment Method Code" := '';
                            if GPCustomer.SHIPMTHD <> '' then begin
                                if not TempShipmentMethod.Get(CopyStr(GPCustomer.SHIPMTHD, 1, 10)) then begin
                                    TempShipmentMethod.Validate(Code, CopyStr(GPCustomer.SHIPMTHD, 1, 10));
                                    TempShipmentMethod.Insert(true);
                                end;
                                TempGPCustomer."Shipment Method Code" := TempShipmentMethod.Code;
                            end;

                            TempGPCustomer."Payment Terms Code" := '';
                            if GPCustomer.PYMTRMID <> '' then begin
                                if GPPaymentTerms.Get(GPCustomer.PYMTRMID) then
                                    if GPPaymentTerms.PYMTRMID_New <> '' then
                                        GPCustomer.PYMTRMID := GPPaymentTerms.PYMTRMID_New;

                                if not TempPaymentTerms.Get(CopyStr(GPCustomer.PYMTRMID, 1, 10)) then begin
                                    TempPaymentTerms.Validate(Code, CopyStr(GPCustomer.PYMTRMID, 1, 10));
                                    TempPaymentTerms.Validate(Description, GPCustomer.PYMTRMID);
                                    TempPaymentTerms.Validate("Due Date Calculation", PaymentTermsFormula);
                                    TempPaymentTerms.Insert(true);
                                end;
                                TempGPCustomer."Payment Terms Code" := TempPaymentTerms.Code;
                            end;

                            TempGPCustomer."Territory Code" := '';
                            if GPCustomer.SALSTERR <> '' then begin
                                if not TempTerritory.Get(CopyStr(GPCustomer.SALSTERR, 1, 10)) then begin
                                    TempTerritory.Validate(Code, CopyStr(GPCustomer.SALSTERR, 1, 10));
                                    TempTerritory.Insert(true);
                                end;
                                TempGPCustomer."Territory Code" := TempTerritory.Code;
                            end;

                            TempGPCustomer."Tax Area Code" := '';
                            TempGPCustomer."Tax Liable" := false;
                            if GPCustomer.TAXSCHID <> '' then begin
                                if not TempTaxArea.Get(GPCustomer.TAXSCHID) then begin
                                    TempTaxArea.Validate(Code, GPCustomer.TAXSCHID);
                                    TempTaxArea.Insert(true);
                                end;
                                TempGPCustomer."Tax Area Code" := TempTaxArea.Code;
                                TempGPCustomer."Tax Liable" := true;
                            end;

                            TempGPCustomer."Phone No." := '';
                            if GPCustomer.PHONE1 <> '' then
                                if not HelperFunctions.ContainsAlphaChars(GPCustomer.PHONE1) then
                                    TempGPCustomer."Phone No." := GPCustomer.PHONE1;

                            TempGPCustomer."Fax No." := '';
                            if GPCustomer.FAX <> '' then
                                if not HelperFunctions.ContainsAlphaChars(GPCustomer.FAX) then
                                    TempGPCustomer."Fax No." := GPCustomer.FAX;

                            TempGPCustomer.Insert();

                            if GPCustomerBalance <> 0 then begin
                                TempDetailedCustLedgEntry."Entry No." := TempDetailedCustLedgEntry.Count() + 1;
                                TempDetailedCustLedgEntry."Customer No." := CustomerNo;
                                TempDetailedCustLedgEntry.Amount := GPCustomerBalance;
                                TempDetailedCustLedgEntry.Insert();
                            end;
                        end;
                    end;
                until GPRM00101.Next() = 0;
        end;

        // Validate - Customers
        if TempGPCustomer.FindSet() then
            repeat
                MigrationValidationMgmt.SetContext(ValidatorCodeLbl, EntityType, TempGPCustomer."No.");

                if not MigrationValidationMgmt.ValidateRecordExists('CUSTOMEREXISTS', Customer.Get(TempGPCustomer."No."), StrSubstNo(MissingEntityTok, EntityType)) then
                    continue;

                TempGPCustomer.CalcFields(Balance);
                Customer.CalcFields(Balance);

                MigrationValidationMgmt.ValidateAreEqual('CUSTOMERNAME', TempGPCustomer.Name, Customer.Name, NameLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('CUSTOMERPOSTINGGROUP', TempGPCustomer."Customer Posting Group", Customer."Customer Posting Group", CustomerPostingGroupLbl);
                MigrationValidationMgmt.ValidateAreEqual('CUSTOMERADDR', TempGPCustomer.Address, Customer.Address, AddressLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('CUSTOMERADDR2', TempGPCustomer."Address 2", Customer."Address 2", Address2Lbl, true);
                MigrationValidationMgmt.ValidateAreEqual('CUSTOMERCITY', TempGPCustomer.City, Customer.City, CityLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('CUSTOMERPHN', TempGPCustomer."Phone No.", Customer."Phone No.", PhoneLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('CUSTOMERFAX', TempGPCustomer."Fax No.", Customer."Fax No.", FaxLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('CUSTOMERNAME2', TempGPCustomer."Name 2", Customer."Name 2", Name2Lbl, true);
                MigrationValidationMgmt.ValidateAreEqual('CUSTOMERCREDITLMT', TempGPCustomer."Credit Limit (LCY)", Customer."Credit Limit (LCY)", CreditLimitLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('CUSTOMERCONTACT', TempGPCustomer.Contact, Customer.Contact, ContactLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('CUSTOMERSALESPERSON', TempGPCustomer."Salesperson Code", Customer."Salesperson Code", SalesPersonLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('CUSTOMERSHIPMETHOD', TempGPCustomer."Shipment Method Code", Customer."Shipment Method Code", ShipmentMethodLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('CUSTOMERPMTTERMS', TempGPCustomer."Payment Terms Code", Customer."Payment Terms Code", PaymentTermsLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('CUSTOMERTERRITORY', TempGPCustomer."Territory Code", Customer."Territory Code", TerritoryLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('CUSTOMERTAXAREA', TempGPCustomer."Tax Area Code", Customer."Tax Area Code", TaxAreaLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('CUSTOMERTAXLIABLE', TempGPCustomer."Tax Liable", Customer."Tax Liable", TaxLiableLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('CUSTOMERBALANCE', TempGPCustomer.Balance, Customer.Balance, BalanceLbl, BalanceFailureShouldBeWarning);

                ValidateCustomerShipToAddresses(Customer);
            until TempGPCustomer.Next() = 0;

        LogValidationProgress(ValidationStepCustomerLbl);
    end;

    local procedure ValidateCustomerShipToAddresses(var Customer: Record Customer)
    var
        GPCustomerAddress: Record "GP Customer Address";
        ShipToAddress: Record "Ship-to Address";
        TempShipToAddress: Record "Ship-to Address" temporary;
        EntityType: Text[50];
        ContextCode: Text[250];
    begin
        EntityType := CustomerAddressEntityCaptionLbl;

        // GP
        GPCustomerAddress.SetRange(CUSTNMBR, Customer."No.");
        if GPCustomerAddress.FindSet() then
            repeat
                Clear(TempShipToAddress);

                TempShipToAddress."Customer No." := Customer."No.";
                TempShipToAddress.Code := CopyStr(GPCustomerAddress.ADRSCODE, 1, 10);
                TempShipToAddress.Name := Customer.Name;
                TempShipToAddress.Address := GPCustomerAddress.ADDRESS1;
                TempShipToAddress."Address 2" := CopyStr(GPCustomerAddress.ADDRESS2, 1, 50);
                TempShipToAddress.City := CopyStr(GPCustomerAddress.CITY, 1, 30);
                TempShipToAddress.Contact := GPCustomerAddress.CNTCPRSN;
                TempShipToAddress."Phone No." := GPCustomerAddress.PHONE1;
                TempShipToAddress."Shipment Method Code" := CopyStr(GPCustomerAddress.SHIPMTHD, 1, 10);
                TempShipToAddress."Fax No." := GPCustomerAddress.FAX;
                TempShipToAddress."Post Code" := GPCustomerAddress.ZIP;
                TempShipToAddress.County := GPCustomerAddress.STATE;
                TempShipToAddress."Tax Area Code" := GPCustomerAddress.TAXSCHID;

                if (CopyStr(TempShipToAddress."Phone No.", 1, 14) = '00000000000000') then
                    TempShipToAddress."Phone No." := '';

                if (CopyStr(TempShipToAddress."Fax No.", 1, 14) = '00000000000000') then
                    TempShipToAddress."Fax No." := '';

                TempShipToAddress.Insert();
            until GPCustomerAddress.Next() = 0;

        // Validate - Customer Ship-to Addresses
        if TempShipToAddress.FindSet() then
            repeat
                ContextCode := TempShipToAddress."Customer No." + '-' + TempShipToAddress.Code;
                MigrationValidationMgmt.SetContext(ValidatorCodeLbl, EntityType, ContextCode);

                if not MigrationValidationMgmt.ValidateRecordExists('SHIPADDREXISTS', ShipToAddress.Get(TempShipToAddress."Customer No.", TempShipToAddress.Code), StrSubstNo(MissingEntityTok, EntityType)) then
                    continue;

                MigrationValidationMgmt.ValidateAreEqual('SHIPADDRNAME', TempShipToAddress.Name, ShipToAddress.Name, NameLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('SHIPADDRADDR', TempShipToAddress.Address, ShipToAddress.Address, AddressLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('SHIPADDRADDR2', TempShipToAddress."Address 2", ShipToAddress."Address 2", Address2Lbl, true);
                MigrationValidationMgmt.ValidateAreEqual('SHIPADDRCITY', TempShipToAddress.City, ShipToAddress.City, CityLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('SHIPADDRPOSTCODE', TempShipToAddress."Post Code", ShipToAddress."Post Code", PostCodeLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('SHIPADDRPHN', TempShipToAddress."Phone No.", ShipToAddress."Phone No.", PhoneLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('SHIPADDRFAX', TempShipToAddress."Fax No.", ShipToAddress."Fax No.", FaxLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('SHIPADDRCONTACT', TempShipToAddress.Contact, ShipToAddress.Contact, ContactLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('SHIPADDRSHIPMETHOD', TempShipToAddress."Shipment Method Code", ShipToAddress."Shipment Method Code", ShipmentMethodLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('SHIPADDRCOUNTY', TempShipToAddress.County, ShipToAddress.County, CountyLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('SHIPADDRTAXAREA', TempShipToAddress."Tax Area Code", ShipToAddress."Tax Area Code", TaxAreaLbl, true);
            until TempShipToAddress.Next() = 0;
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
        TempGPItem: Record Item temporary;
        TempItemLedgerEntry: Record "Item Ledger Entry" temporary;
        GPPopulateCombinedTables: Codeunit "GP Populate Combined Tables";
        ItemCostMgt: Codeunit ItemCostManagement;
        IsDiscontinued: Boolean;
        IsInactive: Boolean;
        IsInventoryOrDiscontinued: Boolean;
        QuantityFailureShouldBeWarning: Boolean;
        ShouldInclude: Boolean;
        ClassName: Code[20];
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

        // GP
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

                        if not TempGPItem.Get(ItemNo) then begin
                            TempGPItem."No." := ItemNo;
                            TempGPItem.Description := GPItem.Description;
                            TempGPItem."Description 2" := GPItem.ShortName;
                            TempGPItem."Search Description" := GPItem.SearchDescription;
                            TempGPItem."Inventory Posting Group" := ClassName;
                            TempGPItem."Base Unit of Measure" := GPItem.BaseUnitOfMeasure;
                            TempGPItem."Purch. Unit of Measure" := GPItem.PurchUnitOfMeasure;
                            TempGPItem."Unit List Price" := GPItem.UnitListPrice;
                            TempGPItem."Net Weight" := GPItem.ShipWeight;
                            TempGPItem."Item Tracking Code" := GPItem.ItemTrackingCode;

                            if (GPItem.ItemType in [0, 2]) then
                                TempGPItem.Type := TempGPItem.Type::Inventory
                            else
                                if not Kits.Contains(ItemNo) then
                                    TempGPItem.Type := TempGPItem.Type::Service
                                else
                                    TempGPItem.Type := TempGPItem.Type::"Non-Inventory";

                            if TempGPItem.Type = TempGPItem.Type::Service then
                                TempGPItem."Costing Method" := TempGPItem."Costing Method"::FIFO
                            else
                                case GPItem.CostingMethod of
                                    '0':
                                        TempGPItem."Costing Method" := TempGPItem."Costing Method"::FIFO;
                                    '1':
                                        TempGPItem."Costing Method" := TempGPItem."Costing Method"::LIFO;
                                    '2':
                                        TempGPItem."Costing Method" := TempGPItem."Costing Method"::Specific;
                                    '3':
                                        TempGPItem."Costing Method" := TempGPItem."Costing Method"::Average;
                                    '4':
                                        TempGPItem."Costing Method" := TempGPItem."Costing Method"::Standard;
                                end;

                            TempGPItem."Unit Cost" := GPItem.CurrentCost;
                            TempGPItem."Standard Cost" := GPItem.StandardCost;
                            TempGPItem.Insert();
                            ItemCostMgt.UpdateUnitCost(TempGPItem, '', '', 0, 0, false, false, true, TempGPItem.FieldNo(TempGPItem."Standard Cost"));

                            if Quantity <> 0 then begin
                                TempItemLedgerEntry."Entry No." := TempItemLedgerEntry.Count() + 1;
                                TempItemLedgerEntry."Item No." := ItemNo;
                                TempItemLedgerEntry.Quantity := Quantity;
                                TempItemLedgerEntry.Insert();
                            end;
                        end;
                    end;
                until GPIV00101.Next() = 0;
        end;

        // Validate - Items
        if TempGPItem.FindSet() then
            repeat
                MigrationValidationMgmt.SetContext(ValidatorCodeLbl, EntityType, TempGPItem."No.");

                if not MigrationValidationMgmt.ValidateRecordExists('ITEMEXISTS', Item.Get(TempGPItem."No."), StrSubstNo(MissingEntityTok, EntityType)) then
                    continue;

                TempGPItem.CalcFields(Inventory);
                Item.CalcFields(Inventory);

                MigrationValidationMgmt.ValidateAreEqual('ITEMTYPE', TempGPItem.Type, Item.Type, TypeLbl);
                MigrationValidationMgmt.ValidateAreEqual('ITEMDESC', TempGPItem.Description, Item.Description, DescriptionLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('ITEMDESC2', TempGPItem."Description 2", Item."Description 2", Description2Lbl, true);
                MigrationValidationMgmt.ValidateAreEqual('ITEMSEARCHDESC', TempGPItem."Search Description", Item."Search Description", SearchDescription2Lbl, true);
                MigrationValidationMgmt.ValidateAreEqual('ITEMPOSTINGGROUP', TempGPItem."Inventory Posting Group", Item."Inventory Posting Group", ItemPostingGroupLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('ITEMUNITLISTPRICE', TempGPItem."Unit List Price", Item."Unit List Price", UnitListPriceLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('ITEMUNITCOST', TempGPItem."Unit Cost", Item."Unit Cost", UnitCostLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('ITEMSTANDARDCOST', TempGPItem."Standard Cost", Item."Standard Cost", StandardCostLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('ITEMCOSTMETHOD', TempGPItem."Costing Method", Item."Costing Method", CostingMethodLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('ITEMBASEUOFM', TempGPItem."Base Unit of Measure", Item."Base Unit of Measure", BaseUofMLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('ITEMPURCHUOFM', TempGPItem."Purch. Unit of Measure", Item."Purch. Unit of Measure", PurchUofMLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('ITEMTRACKINGCODE', TempGPItem."Item Tracking Code", Item."Item Tracking Code", ItemTrackingCodeLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('ITEMINVENTORY', TempGPItem.Inventory, Item.Inventory, QuantityLbl, QuantityFailureShouldBeWarning);
            until TempGPItem.Next() = 0;

        LogValidationProgress(ValidationStepItemLbl);
    end;

    local procedure RunPurchaseOrderMigrationValidation(var GPCompanyAdditionalSettings: Record "GP Company Additional Settings")
    var
        GPPOP10100: Record "GP POP10100";
        PurchaseHeader: Record "Purchase Header";
        TempPurchaseHeader: Record "Purchase Header" temporary;
        PurchaseLine: Record "Purchase Line";
        TempPurchaseLine: Record "Purchase Line" temporary;
        Vendor: Record Vendor;
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
                    PONumber := CopyStr(GPPOP10100.PONUMBER.TrimEnd(), 1, MaxStrLen(TempPurchaseHeader."No."));
                    if Vendor.Get(GPPOP10100.VENDORID) then
                        if not TempPurchaseHeader.Get("Purchase Document Type"::Order, PONumber) then begin
                            TempPurchaseHeader."Document Type" := "Purchase Document Type"::Order;
                            TempPurchaseHeader."No." := PONumber;
                            TempPurchaseHeader."Buy-from Vendor No." := CopyStr(GPPOP10100.VENDORID.TrimEnd(), 1, MaxStrLen(TempPurchaseHeader."Buy-from Vendor No."));
                            TempPurchaseHeader."Pay-to Vendor No." := CopyStr(GPPOP10100.VENDORID.TrimEnd(), 1, MaxStrLen(TempPurchaseHeader."Pay-to Vendor No."));
                            TempPurchaseHeader."Document Date" := GPPOP10100.DOCDATE;
                            TempPurchaseHeader.Insert();

                            if not PopulatePOLineBuffer(TempPurchaseHeader."No.", TempPurchaseLine) then
                                TempPurchaseHeader.Delete();
                        end;
                until GPPOP10100.Next() = 0;
        end;

        // Validate - Purchase Orders
        PurchaseHeader.SetLoadFields("Document Type", "No.", "Buy-from Vendor No.", "Pay-to Vendor No.", "Document Date");
        if TempPurchaseHeader.FindSet() then
            repeat
                MigrationValidationMgmt.SetContext(ValidatorCodeLbl, EntityType, TempPurchaseHeader."No.");

                if not MigrationValidationMgmt.ValidateRecordExists('POEXISTS', PurchaseHeader.Get("Purchase Document Type"::Order, TempPurchaseHeader."No."), StrSubstNo(MissingEntityTok, EntityType)) then
                    continue;

                MigrationValidationMgmt.ValidateAreEqual('POBUYFROMVEND', TempPurchaseHeader."Buy-from Vendor No.", PurchaseHeader."Buy-from Vendor No.", PurchaseOrderBuyFromVendorNoLbl);
                MigrationValidationMgmt.ValidateAreEqual('POPAYTOVEND', TempPurchaseHeader."Pay-to Vendor No.", PurchaseHeader."Pay-to Vendor No.", PurchaseOrderPayToVendorNoLbl);
                MigrationValidationMgmt.ValidateAreEqual('PODOCDATE', TempPurchaseHeader."Document Date", PurchaseHeader."Document Date", DocumentDateLbl);

                TempPurchaseLine.SetRange("Document No.", TempPurchaseHeader."No.");
                if TempPurchaseLine.FindSet() then
                    repeat
                        MigrationValidationMgmt.SetContext(ValidatorCodeLbl, EntityType, TempPurchaseHeader."No.");

                        PurchaseLine.SetRange("Document Type", "Purchase Document Type"::Order);
                        PurchaseLine.SetRange("Document No.", TempPurchaseHeader."No.");
                        PurchaseLine.SetRange("No.", TempPurchaseLine."No.");
                        if not MigrationValidationMgmt.ValidateRecordExists('POLINEEXISTS', PurchaseLine.FindFirst(), StrSubstNo(MissingEntityTok, LineEntityType)) then
                            continue;

                        MigrationValidationMgmt.ValidateAreEqual('POLINEQTY', TempPurchaseLine.Quantity, PurchaseLine.Quantity, QuantityLbl, true);
                        MigrationValidationMgmt.ValidateAreEqual('POLINEQTYRECV', TempPurchaseLine."Quantity Received", PurchaseLine."Quantity Received", QuantityRecLbl, true);
                    until TempPurchaseLine.Next() = 0;
            until TempPurchaseHeader.Next() = 0;

        LogValidationProgress(ValidationStepPurchaseOrderLbl);
    end;

    local procedure PopulatePOLineBuffer(PONumber: Code[20]; var TempPurchaseLine: Record "Purchase Line"): Boolean
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
                                    InsertPOLine(PONumber, GPPOP10110, LineQuantityRemaining, LineQtyReceivedByUnitCost, LineQtyInvoicedByUnitCost, HasLines, TempPurchaseLine)
                                else
                                    LineQuantityRemaining := LineQuantityRemaining - LineQtyReceivedByUnitCost;

                                LastLocation := GPPOPReceiptApplyLineUnitCost.TRXLOCTN;
                                LastLineUnitCost := GPPOPReceiptApplyLineUnitCost.PCHRPTCT;
                            end;
                        until GPPOPReceiptApplyLineUnitCost.Next() = 0;

                    if LineQuantityRemaining > 0 then
                        InsertPOLine(PONumber, GPPOP10110, LineQuantityRemaining, 0, 0, HasLines, TempPurchaseLine);
                end;
            end;
        until GPPOP10110.Next() = 0;

        exit(HasLines);
    end;

    local procedure InsertPOLine(PONumber: Code[20]; var GPPOP10110: Record "GP POP10110"; var LineQuantityRemaining: Decimal; QuantityReceived: Decimal; QuantityInvoiced: Decimal; var HasLines: Boolean; var TempPurchaseLine: Record "Purchase Line")
    var
        ItemNo: Code[20];
        AdjustedQuantity: Decimal;
        AdjustedQuantityReceived: Decimal;
        QuantityOverReceipt: Decimal;
        LineCount: Integer;
    begin
        TempPurchaseLine.Reset();
        LineCount := TempPurchaseLine.Count();
        ItemNo := CopyStr(GPPOP10110.ITEMNMBR.TrimEnd(), 1, MaxStrLen(ItemNo));

        AdjustedQuantityReceived := SubtractAndZeroIfNegative(QuantityReceived, QuantityInvoiced);
        if AdjustedQuantityReceived > 0 then
            AdjustedQuantity := SubtractAndZeroIfNegative(QuantityReceived, QuantityInvoiced)
        else
            AdjustedQuantity := SubtractAndZeroIfNegative(LineQuantityRemaining, QuantityInvoiced);

        QuantityOverReceipt := SubtractAndZeroIfNegative(AdjustedQuantityReceived, AdjustedQuantity);

        if QuantityOverReceipt > 0 then
            AdjustedQuantity := AdjustedQuantityReceived;

        if AdjustedQuantity > 0 then begin
            TempPurchaseLine.SetRange("Document Type", "Purchase Document Type"::Order);
            TempPurchaseLine.SetRange("Document No.", PONumber);
            TempPurchaseLine.SetRange("No.", ItemNo);
            if TempPurchaseLine.FindFirst() then begin
                TempPurchaseLine.Quantity := TempPurchaseLine.Quantity + AdjustedQuantity;
                TempPurchaseLine."Quantity Received" := TempPurchaseLine."Quantity Received" + AdjustedQuantityReceived;
                TempPurchaseLine.Modify();
            end else begin
                LineCount := LineCount + 1;
                TempPurchaseLine."Document Type" := "Purchase Document Type"::Order;
                TempPurchaseLine."Document No." := PONumber;
                TempPurchaseLine."Line No." := LineCount * 10000;
                TempPurchaseLine."No." := ItemNo;
                TempPurchaseLine.Quantity := AdjustedQuantity;
                TempPurchaseLine."Quantity Received" := AdjustedQuantityReceived;
                TempPurchaseLine.Insert();
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
        OrderAddress: Record "Order Address";
        RemitAddress: Record "Remit Address";
        TempGPVendor: Record Vendor temporary;
        TempOrderAddress: Record "Order Address" temporary;
        TempRemitAddress: Record "Remit Address" temporary;
        TempDetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry" temporary;
        GPPopulateCombinedTables: Codeunit "GP Populate Combined Tables";
        HelperFunctions: Codeunit "Helper Functions";
        PaymentTermsFormula: DateFormula;
        BalanceFailureShouldBeWarning: Boolean;
        IsActive: Boolean;
        ShouldInclude: Boolean;
        ShipMethod: Code[10];
        ClassName: Code[20];
        VendorNo: Code[20];
        Balance: Decimal;
        City: Text[30];
        State: Text[30];
        Address1: Text[50];
        Address2: Text[50];
        ContactName: Text[50];
        EntityType: Text[50];
        VendorName: Text[50];
        VendorName2: Text[50];
        ContextCode: Text[250];
    begin
        if CompanyValidationProgress.Get(CompanyNameTxt, ValidatorCodeLbl, ValidationStepVendorLbl) then
            exit;

        EntityType := VendorEntityCaptionLbl;
        BalanceFailureShouldBeWarning := (TotalUnpostedVendorBatchCount > 0);
        Evaluate(PaymentTermsFormula, '');

        // GP
        if GPCompanyAdditionalSettings.GetPayablesModuleEnabled() then begin
            GPPM00200.SetFilter(VENDORID, '<>%1', '');
            if GPPM00200.FindSet() then
                repeat
                    VendorNo := CopyStr(GPPM00200.VENDORID.TrimEnd(), 1, MaxStrLen(VendorNo));
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

                        if not TempGPVendor.Get(VendorNo) then begin
                            VendorName := CopyStr(GPVendor.VENDNAME.TrimEnd(), 1, MaxStrLen(VendorName));
                            VendorName2 := CopyStr(GPVendor.VNDCHKNM.TrimEnd(), 1, MaxStrLen(VendorName2));
                            ContactName := CopyStr(GPVendor.VNDCNTCT, 1, MaxStrLen(ContactName));
                            Address1 := CopyStr(GPVendor.ADDRESS1, 1, MaxStrLen(Address1));
                            Address2 := CopyStr(GPVendor.ADDRESS2, 1, MaxStrLen(Address2));
                            City := CopyStr(GPVendor.CITY, 1, MaxStrLen(City));
                            State := CopyStr(GPVendor.STATE, 1, MaxStrLen(State));
                            ShipMethod := CopyStr(GPVendor.SHIPMTHD.Trim(), 1, MaxStrLen(ShipMethod));
                            GPVendor.PYMTRMID := CopyStr(GPVendor.PYMTRMID.Trim(), 1, MaxStrLen(GPVendor.PYMTRMID));

                            TempGPVendor."No." := VendorNo;
                            TempGPVendor.Name := VendorName;
                            TempGPVendor."Vendor Posting Group" := ClassName;
                            TempGPVendor."Preferred Bank Account Code" := GetPreferredGPVendorBankCode(VendorNo);
                            TempGPVendor.Address := Address1;
                            TempGPVendor."Address 2" := Address2;
                            TempGPVendor.City := City;
                            TempGPVendor.Contact := ContactName;

                            TempGPVendor."Name 2" := '';
                            if VendorName2 <> '' then
                                if not HelperFunctions.StringEqualsCaseInsensitive(VendorName2, VendorName) then
                                    TempGPVendor."Name 2" := VendorName2;

                            GPVendor.PHNUMBR1 := HelperFunctions.CleanGPPhoneOrFaxNumber(GPVendor.PHNUMBR1);
                            GPVendor.FAXNUMBR := HelperFunctions.CleanGPPhoneOrFaxNumber(GPVendor.FAXNUMBR);

                            TempGPVendor."Phone No." := '';
                            if GPVendor.PHNUMBR1 <> '' then
                                if not HelperFunctions.ContainsAlphaChars(GPVendor.PHNUMBR1) then
                                    TempGPVendor."Phone No." := GPVendor.PHNUMBR1;

                            TempGPVendor."Fax No." := '';
                            if GPVendor.FAXNUMBR <> '' then
                                if not HelperFunctions.ContainsAlphaChars(GPVendor.FAXNUMBR) then
                                    TempGPVendor."Fax No." := GPVendor.FAXNUMBR;

                            TempGPVendor."Shipment Method Code" := '';
                            if ShipMethod <> '' then begin
                                if not TempShipmentMethod.Get(ShipMethod) then begin
                                    TempShipmentMethod.Validate(Code, ShipMethod);
                                    TempShipmentMethod.Insert(true);
                                end;
                                TempGPVendor."Shipment Method Code" := ShipMethod;
                            end;

                            TempGPVendor."Payment Terms Code" := '';
                            if GPVendor.PYMTRMID <> '' then begin
                                if GPPaymentTerms.Get(GPVendor.PYMTRMID) then
                                    if GPPaymentTerms.PYMTRMID_New <> '' then
                                        GPVendor.PYMTRMID := GPPaymentTerms.PYMTRMID_New;

                                if not TempPaymentTerms.Get(GPVendor.PYMTRMID) then begin
                                    TempPaymentTerms.Validate(Code, GPVendor.PYMTRMID);
                                    TempPaymentTerms.Validate("Due Date Calculation", PaymentTermsFormula);
                                    TempPaymentTerms.Insert(true);
                                end;
                                TempGPVendor."Payment Terms Code" := TempPaymentTerms.Code;
                            end;

                            TempGPVendor."Tax Area Code" := '';
                            TempGPVendor."Tax Liable" := false;
                            if GPVendor.TAXSCHID <> '' then begin
                                if not TempTaxArea.Get(GPVendor.TAXSCHID) then begin
                                    TempTaxArea.Validate(Code, GPVendor.TAXSCHID);
                                    TempTaxArea.Insert(true);
                                end;
                                TempGPVendor."Tax Area Code" := GPVendor.TAXSCHID;
                                TempGPVendor."Tax Liable" := true;
                            end;

                            TempGPVendor.Insert();

                            if Balance <> 0 then begin
                                TempDetailedVendorLedgEntry."Entry No." := TempDetailedVendorLedgEntry.Count() + 1;
                                TempDetailedVendorLedgEntry."Vendor No." := VendorNo;
                                TempDetailedVendorLedgEntry.Amount := Balance;
                                TempDetailedVendorLedgEntry.Insert();
                            end;

                            SimulateMigrateVendorAddresses(GPVendor, TempOrderAddress, TempRemitAddress);
                        end;
                    end;
                until GPPM00200.Next() = 0;
        end;

        // Validate - Vendor
        if TempGPVendor.FindSet() then
            repeat
                MigrationValidationMgmt.SetContext(ValidatorCodeLbl, EntityType, TempGPVendor."No.");

                if not MigrationValidationMgmt.ValidateRecordExists('VENDOREXISTS', Vendor.Get(TempGPVendor."No."), StrSubstNo(MissingEntityTok, EntityType)) then
                    continue;

                TempGPVendor.CalcFields(Balance);
                Vendor.CalcFields(Balance);

                MigrationValidationMgmt.ValidateAreEqual('VENDORNAME', TempGPVendor.Name, Vendor.Name, NameLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('VENDORNAME2', TempGPVendor."Name 2", Vendor."Name 2", Name2Lbl, true);
                MigrationValidationMgmt.ValidateAreEqual('VENDORPOSTINGGROUP', TempGPVendor."Vendor Posting Group", Vendor."Vendor Posting Group", VendorPostingGroupLbl);
                MigrationValidationMgmt.ValidateAreEqual('VENDORPREFBANKACCT', TempGPVendor."Preferred Bank Account Code", Vendor."Preferred Bank Account Code", PreferredBankAccountLbl);
                MigrationValidationMgmt.ValidateAreEqual('VENDORADDR', TempGPVendor.Address, Vendor.Address, AddressLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('VENDORADDR2', TempGPVendor."Address 2", Vendor."Address 2", Address2Lbl, true);
                MigrationValidationMgmt.ValidateAreEqual('VENDORCITY', TempGPVendor.City, Vendor.City, CityLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('VENDORPHN', TempGPVendor."Phone No.", Vendor."Phone No.", PhoneLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('VENDORFAX', TempGPVendor."Fax No.", Vendor."Fax No.", FaxLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('VENDORCONTACT', TempGPVendor.Contact, Vendor.Contact, ContactLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('VENDORSHIPMETHOD', TempGPVendor."Shipment Method Code", Vendor."Shipment Method Code", ShipmentMethodLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('VENDORPMTTERMS', TempGPVendor."Payment Terms Code", Vendor."Payment Terms Code", PaymentTermsLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('VENDORTERRITORY', TempGPVendor."Territory Code", Vendor."Territory Code", TerritoryLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('VENDORTAXAREA', TempGPVendor."Tax Area Code", Vendor."Tax Area Code", TaxAreaLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('VENDORTAXLIABLE', TempGPVendor."Tax Liable", Vendor."Tax Liable", TaxLiableLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('VENDORBALANCE', TempGPVendor.Balance, Vendor.Balance, BalanceLbl, BalanceFailureShouldBeWarning);
            until TempGPVendor.Next() = 0;

        // Validate - Vendor Order Addresses
        EntityType := VendorOrderAddressEntityCaptionLbl;
        if TempOrderAddress.FindSet() then
            repeat
                ContextCode := TempOrderAddress."Vendor No." + '-' + TempOrderAddress.Code;
                MigrationValidationMgmt.SetContext(ValidatorCodeLbl, EntityType, ContextCode);

                if not MigrationValidationMgmt.ValidateRecordExists('ORDERADDREXISTS', OrderAddress.Get(TempOrderAddress."Vendor No.", TempOrderAddress.Code), StrSubstNo(MissingEntityTok, EntityType)) then
                    continue;

                MigrationValidationMgmt.ValidateAreEqual('ORDERADDRNAME', TempOrderAddress.Name, OrderAddress.Name, NameLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('ORDERADDRADDR', TempOrderAddress.Address, OrderAddress.Address, AddressLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('ORDERADDRADDR2', TempOrderAddress."Address 2", OrderAddress."Address 2", Address2Lbl, true);
                MigrationValidationMgmt.ValidateAreEqual('ORDERADDRCITY', TempOrderAddress.City, OrderAddress.City, CityLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('ORDERADDRPOSTCODE', TempOrderAddress."Post Code", OrderAddress."Post Code", PostCodeLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('ORDERADDRPHN', TempOrderAddress."Phone No.", OrderAddress."Phone No.", PhoneLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('ORDERADDRFAX', TempOrderAddress."Fax No.", OrderAddress."Fax No.", FaxLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('ORDERADDRCOUNTY', TempOrderAddress.County, OrderAddress.County, CountyLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('ORDERADDRCONTACT', TempOrderAddress.Contact, OrderAddress.Contact, ContactLbl, true);
            until TempOrderAddress.Next() = 0;

        // Validate - Vendor Remit Addresses
        EntityType := VendorRemitAddressEntityCaptionLbl;
        if TempRemitAddress.FindSet() then
            repeat
                ContextCode := TempRemitAddress."Vendor No." + '-' + TempRemitAddress.Code;
                MigrationValidationMgmt.SetContext(ValidatorCodeLbl, EntityType, ContextCode);

                if not MigrationValidationMgmt.ValidateRecordExists('REMITADDREXISTS', RemitAddress.Get(TempRemitAddress.Code, TempRemitAddress."Vendor No."), StrSubstNo(MissingEntityTok, EntityType)) then
                    continue;

                MigrationValidationMgmt.ValidateAreEqual('REMITADDRNAME', TempRemitAddress.Name, RemitAddress.Name, NameLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('REMITADDRADDR', TempRemitAddress.Address, RemitAddress.Address, AddressLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('REMITADDRADDR2', TempRemitAddress."Address 2", RemitAddress."Address 2", Address2Lbl, true);
                MigrationValidationMgmt.ValidateAreEqual('REMITADDRCITY', TempRemitAddress.City, RemitAddress.City, CityLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('REMITADDRPOSTCODE', TempRemitAddress."Post Code", RemitAddress."Post Code", PostCodeLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('REMITADDRPHN', TempRemitAddress."Phone No.", RemitAddress."Phone No.", PhoneLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('REMITADDRFAX', TempRemitAddress."Fax No.", RemitAddress."Fax No.", FaxLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('REMITADDRCOUNTY', TempRemitAddress.County, RemitAddress.County, CountyLbl, true);
                MigrationValidationMgmt.ValidateAreEqual('REMITADDRCONTACT', TempRemitAddress.Contact, RemitAddress.Contact, ContactLbl, true);
            until TempRemitAddress.Next() = 0;

        LogValidationProgress(ValidationStepVendorLbl);
    end;

    local procedure SimulateMigrateVendorAddresses(var GPVendor: Record "GP Vendor"; var TempOrderAddress: Record "Order Address"; var TempRemitAddress: Record "Remit Address")
    var
        GPPM00200: Record "GP PM00200";
        GPVendorAddress: Record "GP Vendor Address";
        Vendor: Record Vendor;
        AddressCode: Code[10];
        AssignedPrimaryAddressCode: Code[10];
        AssignedRemitToAddressCode: Code[10];
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

                if AddressCode = AssignedRemitToAddressCode then
                    CreateOrUpdateRemitAddress(Vendor, GPVendorAddress, AddressCode, TempRemitAddress);

                if (AddressCode = AssignedPrimaryAddressCode) or (AddressCode <> AssignedRemitToAddressCode) then
                    CreateOrUpdateOrderAddress(Vendor, GPVendorAddress, AddressCode, TempOrderAddress);

            until GPVendorAddress.Next() = 0;
    end;

    local procedure CreateOrUpdateOrderAddress(Vendor: Record Vendor; GPVendorAddress: Record "GP Vendor Address"; AddressCode: Code[10]; var TempOrderAddress: Record "Order Address")
    var
        HelperFunctions: Codeunit "Helper Functions";
    begin
        if not TempOrderAddress.Get(Vendor."No.", AddressCode) then begin
            TempOrderAddress."Vendor No." := Vendor."No.";
            TempOrderAddress.Code := AddressCode;
            TempOrderAddress.Insert();
        end;

        TempOrderAddress.Name := Vendor.Name;
        TempOrderAddress.Address := GPVendorAddress.ADDRESS1;
        TempOrderAddress."Address 2" := CopyStr(GPVendorAddress.ADDRESS2, 1, MaxStrLen(TempOrderAddress."Address 2"));
        TempOrderAddress.City := CopyStr(GPVendorAddress.CITY, 1, MaxStrLen(TempOrderAddress.City));
        TempOrderAddress.Contact := GPVendorAddress.VNDCNTCT;
        TempOrderAddress."Phone No." := HelperFunctions.CleanGPPhoneOrFaxNumber(GPVendorAddress.PHNUMBR1);
        TempOrderAddress."Fax No." := HelperFunctions.CleanGPPhoneOrFaxNumber(GPVendorAddress.FAXNUMBR);
        TempOrderAddress."Post Code" := GPVendorAddress.ZIPCODE;
        TempOrderAddress.County := GPVendorAddress.STATE;
        TempOrderAddress.Modify();
    end;

    local procedure CreateOrUpdateRemitAddress(Vendor: Record Vendor; GPVendorAddress: Record "GP Vendor Address"; AddressCode: Code[10]; var TempRemitAddress: Record "Remit Address")
    var
        HelperFunctions: Codeunit "Helper Functions";
    begin
        if not TempRemitAddress.Get(AddressCode, Vendor."No.") then begin
            TempRemitAddress."Vendor No." := Vendor."No.";
            TempRemitAddress.Code := AddressCode;
            TempRemitAddress.Insert();
        end;

        TempRemitAddress.Name := Vendor.Name;
        TempRemitAddress.Address := GPVendorAddress.ADDRESS1;
        TempRemitAddress."Address 2" := CopyStr(GPVendorAddress.ADDRESS2, 1, MaxStrLen(TempRemitAddress."Address 2"));
        TempRemitAddress.City := CopyStr(GPVendorAddress.CITY, 1, MaxStrLen(TempRemitAddress.City));
        TempRemitAddress.Contact := GPVendorAddress.VNDCNTCT;
        TempRemitAddress."Phone No." := HelperFunctions.CleanGPPhoneOrFaxNumber(GPVendorAddress.PHNUMBR1);
        TempRemitAddress."Fax No." := HelperFunctions.CleanGPPhoneOrFaxNumber(GPVendorAddress.FAXNUMBR);
        TempRemitAddress."Post Code" := GPVendorAddress.ZIPCODE;
        TempRemitAddress.County := GPVendorAddress.STATE;
        TempRemitAddress.Modify();
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

    var
        TempPaymentTerms: Record "Payment Terms" temporary;
        TempSalespersonPurchaser: Record "Salesperson/Purchaser" temporary;
        TempShipmentMethod: Record "Shipment Method" temporary;
        TempTaxArea: Record "Tax Area" temporary;
        TempTerritory: Record Territory temporary;
        DefaultCurrency: Record Currency;
        CompanyValidationProgress: Record "Company Validation Progress";
        MigrationValidationMgmt: Codeunit "Migration Validation Mgmt.";
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
        StandardCostLbl: Label 'Standard Cost';
        StatisticalAccountEntityCaptionLbl: Label 'Statistical Account', MaxLength = 50;
        TaxAreaLbl: Label 'Tax Area';
        TaxLiableLbl: Label 'Tax Liable';
        TerritoryLbl: Label 'Territory';
        TransitNoLbl: Label 'Transit No.';
        TypeLbl: Label 'Type';
        UnitCostLbl: Label 'Unit Cost';
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
}