namespace Microsoft.DataMigration.GP;

using System.Reflection;
using System.Utilities;
using System.Integration;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.Consolidation;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Location;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Inventory.Setup;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Journal;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.Period;
using Microsoft.Manufacturing.Setup;
using Microsoft.CRM.Setup;
using Microsoft.Purchases.Setup;
using Microsoft.Sales.Setup;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Receivables;
using Microsoft.Purchases.Vendor;
using Microsoft.Purchases.Payables;
using Microsoft.Foundation.PaymentTerms;
using Microsoft.Inventory.Tracking;
using Microsoft.Inventory.Costing;
using Microsoft.Bank.BankAccount;
using Microsoft.Bank.Ledger;
using Microsoft.Bank.Reconciliation;
using Microsoft.Purchases.Document;
using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.DataMigration;
using Microsoft.Utilities;
using Microsoft.Inventory.Posting;
using Microsoft.Finance.Analysis.StatisticalAccount;

codeunit 4037 "Helper Functions"
{
    Permissions = tabledata "Dimension Set Entry" = rimd,
                    tabledata "G/L Account" = rimd,
                    tabledata "G/L Entry" = rimd,
                    tabledata Customer = rimd,
                    tabledata "Cust. Ledger Entry" = rimd,
                    tabledata Dimension = rimd,
                    tabledata "Dimension Value" = rimd,
                    tabledata "Detailed Cust. Ledg. Entry" = rimd,
                    tabledata Vendor = rimd,
                    tabledata "Vendor Ledger Entry" = rimd,
                    tabledata "Detailed Vendor Ledg. Entry" = rimd,
                    tabledata "Data Migration Status" = rimd,
                    tabledata Item = rimd,
                    tabledata "Item Ledger Entry" = rimd,
                    tabledata "Avg. Cost Adjmt. Entry Point" = rimd,
                    tabledata "Value Entry" = rimd,
                    tabledata "Item Unit of Measure" = rimd,
                    tabledata "Payment Terms" = rimd,
                    tabledata "Payment Term Translation" = rimd,
                    tabledata "Data Migration Entity" = rimd,
                    tabledata "Item Tracking Code" = rimd,
                    tabledata "Gen. Journal Line" = rimd,
                    tabledata "G/L - Item Ledger Relation" = rimd,
                    tabledata "G/L Register" = rimd,
                    tabledata "Bank Account" = rimd,
                    tabledata "Bank Account Posting Group" = rimd,
                    tabledata "Bank Account Ledger Entry" = rimd,
                    tabledata "Bank Acc. Reconciliation" = rimd,
                    tabledata "Bank Acc. Reconciliation Line" = rimd,
                    tabledata "Purchase Header" = rimd,
                    tabledata "Purchase Line" = rimd,
                    tabledata "Over-Receipt Code" = rimd,
                    tabledata "Accounting Period" = rimd,
                    tabledata "Data Migration Error" = rimd,
                    tabledata "Statistical Acc. Journal Batch" = rimd,
                    tabledata "Statistical Acc. Journal Line" = rimd;

    var
        GPConfiguration: Record "GP Configuration";
        CurrentAssetsTxt: Label 'Current Assets';
        PeriodTxt: Label 'Period';
        ARTxt: Label 'Accounts Receivable';
        CashTxt: Label 'Cash';
        PrepaidExpensesTxt: Label 'Prepaid Expenses';
        InventoryTxt: Label 'Inventory';
        EquipementTxt: Label 'Equipment';
        AccumDeprecTxt: Label 'Accumulated Depreciation';
        CurrentLiabilitiesTxt: Label 'Current Liabilities';
        LongTermLiabilitiesTxt: Label 'Long Term Liabilities';
        CommonStockTxt: Label 'Common Stock';
        RetEarningsTxt: Label 'Retained Earnings';
        DistrToShareholdersTxt: Label 'Distributions to Shareholders';
        IncomeSalesReturnsTxt: Label 'Sales Returns & Allowances';
        InterestExpenseTxt: Label 'Interest Expense';
        PayrollExpenseTxt: Label 'Payroll Expense';
        BenefitsExpenseTxt: Label 'Benefits Expense';
        OtherIncomeExpenseTxt: Label 'Other Income & Expenses';
        TaxExpenseTxt: Label 'Tax Expense';
        TransactionExistsMsg: Label 'Transactions have already been entered. In order to use the wizard, you will need to create a new company to migrate your data.';
        SavedJrnlLinesFoundMsg: Label 'Saved journal lines are found. In order to use the wizard, you will need to delete the journal lines before you migrate your data.';
        MigrationNotSupportedErr: Label 'This migration does not support the "Specific" costing method. Verify your costing method in Inventory Setup.';
        PostingGroupCodeTxt: Label 'GP', Locked = true;
        DocNoOutofBalanceMsg: Label 'Document No. %1 is out of balance by %2. Transactions will not be created. Please check the amount in the import file.', Comment = '%1 = Balance Amount', Locked = true;
        CustomerBatchNameTxt: Label 'GPCUST', Locked = true;
        VendorBatchNameTxt: Label 'GPVEND', Locked = true;
        BankBatchNameTxt: Label 'GPBANK', Locked = true;
        GlDocNoTxt: Label 'G00001', Locked = true;
        MigrationTypeTxt: Label 'Great Plains';
        CloudMigrationTok: Label 'CloudMigration', Locked = true;
        GeneralTemplateNameTxt: Label 'GENERAL', Locked = true;
        NotAllJournalLinesPostedMsg: Label 'Not all journal lines were posted. Number of unposted lines - %1.', Comment = '%1 Number of unposted lines';
        MigrationLogAreaBatchPostingTxt: Label 'Batch Posting', Locked = true;

    procedure GetTextFromJToken(JToken: JsonToken; Path: Text): Text
    var
        SelectedJToken: JsonToken;
    begin
        if (JToken.SelectToken(Path, SelectedJToken)) then
            exit(Format(SelectedJToken));
    end;

    procedure WriteTextToField(var DestinationFieldRef: FieldRef; TextToWrite: Text)
    var
        TypeHelper: Codeunit "Type Helper";
        TempBlob: Codeunit "Temp Blob";
        RecordRef: RecordRef;
        OutStream: OutStream;
        MyVariant: Variant;
        BooleanVar: Boolean;
        DateTimeVar: DateTime;
        IntegerVar: Integer;
        DecimalVar: Decimal;
        DummyDateVar: Date;
    begin
        Clear(DummyDateVar);
        TextToWrite := TrimStringQuotes(TextToWrite);
        case Format(DestinationFieldRef.Type()) of
            'Text', 'Code':
                DestinationFieldRef.Value := CopyStr(TextToWrite, 1, DestinationFieldRef.Length());
            'Boolean':
                begin
                    Evaluate(BooleanVar, TextToWrite);
                    DestinationFieldRef.Value := BooleanVar;
                end;
            'DateTime':
                begin
                    Evaluate(DateTimeVar, TextToWrite);
                    DestinationFieldRef.Value := DateTimeVar;
                end;
            'Integer':
                begin
                    Evaluate(IntegerVar, TextToWrite);
                    DestinationFieldRef.Value := IntegerVar;
                end;
            'Decimal':
                begin
                    Evaluate(DecimalVar, TextToWrite);
                    DestinationFieldRef.Value := DecimalVar;
                end;
            'Date':
                begin
                    MyVariant := DummyDateVar;
                    TypeHelper.Evaluate(MyVariant, TextToWrite, 'yyyy-MM-dd', 'en-US');
                    DestinationFieldRef.Value := MyVariant;
                end;
            'BLOB':
                begin
                    TempBlob.CreateOutStream(OutSTream, TEXTENCODING::UTF8);
                    OutStream.Write(TextToWrite);
                    RecordRef := DestinationFieldRef.Record();
                    TempBlob.ToRecordRef(RecordRef, DestinationFieldRef.Number());
                end;
        end;
    end;

    procedure GetFileNameByEntityName(EntityName: Text): Text
    var
        NameValueBuffer: Record "Name/Value Buffer";
    begin
        NameValueBuffer.SetFilter(Value, '= %1', EntityName);
        if NameValueBuffer.FindFirst() then
            exit(NameValueBuffer.Name);

        exit('');
    end;

    procedure UpdateFieldValue(var RecordVariant: Variant; FieldNo: Integer; JObject: JsonObject; PropertyName: Text)
    var
        RRef: RecordRef;
        FRef: FieldRef;
        Value: Text;
        JToken: JsonToken;
    begin
        RRef.GetTable(RecordVariant);
        FRef := RRef.Field(FieldNo);

        if JObject.Get(PropertyName, JToken) then
            if JToken.WriteTo(Value) then
                WriteTextToField(FRef, TrimBackslash(Value));

        RRef.SetTable(RecordVariant);
    end;

    procedure UpdateFieldWithValue(var RecordVariant: Variant; FieldNo: Integer; Value: Text[30])
    var
        RRef: RecordRef;
        FRef: FieldRef;
    begin
        RRef.GetTable(RecordVariant);
        FRef := RRef.Field(FieldNo);
        WriteTextToField(FRef, Value);
        RRef.SetTable(RecordVariant);
    end;

    procedure TrimStringQuotes(Value: Text): Text
    var
        FirstChar: Integer;
        LastChar: Integer;
    begin
        FirstChar := StrPos(Value, '"'); // Finds the first occurrence
        if FirstChar = 1 then begin
            LastChar := Strlen(Value);
            if CopyStr(Value, LastChar, 1) = '"' then begin
                // Remove the first and last characters
                Value := DelStr(Value, LastChar, 1); // Should remove the last quote
                Value := DelStr(Value, FirstChar, 1); // Should remove the first quote
            end;
        end;
        exit(Value);
    end;

    procedure GetPostingAccountNumber(AccountToGet: Text): Code[20]
    var
        GPPostingAccounts: Record "GP Posting Accounts";
    begin
        if not GPPostingAccounts.FindFirst() then
            exit('');

        case AccountToGet of
            'SalesAccount':
                exit(GPPostingAccounts.SalesAccount);
            'SalesLineDiscAccount':
                exit(GPPostingAccounts.SalesLineDiscAccount);
            'SalesInvDiscAccount':
                exit(GPPostingAccounts.SalesInvDiscAccount);
            'SalesPmtDiscDebitAccount':
                exit(GPPostingAccounts.SalesPmtDiscDebitAccount);
            'PurchAccount':
                exit(GPPostingAccounts.PurchAccount);
            'PurchInvDiscAccount':
                exit(GPPostingAccounts.PurchInvDiscAccount);
            'COGSAccount':
                exit(GPPostingAccounts.COGSAccount);
            'InventoryAdjmtAccount':
                exit(GPPostingAccounts.InventoryAdjmtAccount);
            'SalesCreditMemoAccount':
                exit(GPPostingAccounts.SalesCreditMemoAccount);
            'PurchPmtDiscDebitAcc':
                exit(GPPostingAccounts.PurchPmtDiscDebitAcc);
            'PurchPrepaymentsAccount':
                exit(GPPostingAccounts.PurchPrepaymentsAccount);
            'PurchaseVarianceAccount':
                exit(GPPostingAccounts.PurchaseVarianceAccount);
            'InventoryAccount':
                exit(GPPostingAccounts.InventoryAccount);
            'ReceivablesAccount':
                exit(GPPostingAccounts.ReceivablesAccount);
            'ServiceChargeAccount':
                exit(GPPostingAccounts.ServiceChargeAccount);
            'PaymentDiscDebitAccount':
                exit(GPPostingAccounts.PurchPmtDiscDebitAccount);
            'PayablesAccount':
                exit(GPPostingAccounts.PayablesAccount);
            'PurchServiceChargeAccount':
                exit(GPPostingAccounts.PurchServiceChargeAccount);
            'PurchPaymentDiscDebitAccount':
                exit(GPPostingAccounts.PurchPmtDiscDebitAccount);
        end;
    end;

    procedure ConvertAccountCategory(GPAccount: Record "GP Account"): Option
    var
        AccountCategoryType: Option ,Assets,Liabilities,Equity,Income,"Cost of Goods Sold",Expense;
    begin
        case GPAccount.AccountCategory of
            1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12:
                exit(AccountCategoryType::Assets);
            13, 14, 15, 16, 17, 18, 19, 20, 21, 22:
                exit(AccountCategoryType::Liabilities);
            23, 24, 25, 26, 27, 28, 29, 30:
                exit(AccountCategoryType::Equity);
            31, 32:
                exit(AccountCategoryType::Income);
            33:
                exit(AccountCategoryType::"Cost of Goods Sold");
            34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47:
                exit(AccountCategoryType::Expense);
        end;
    end;

    procedure ConvertDebitCreditType(GPAccount: Record "GP Account"): Option
    var
        DebitCreditType: Option Both,Debit,Credit;
    begin
        if GPAccount.DebitCredit = 0 then
            exit(DebitCreditType::Debit);

        exit(DebitCreditType::Credit);
    end;

    procedure ConvertIncomeBalanceType(GPAccount: Record "GP Account"): Option
    var
        IncomeBalanceType: Option "Income Statement","Balance Sheet";
    begin
        if GPAccount.IncomeBalance then
            exit(IncomeBalanceType::"Income Statement");

        exit(IncomeBalanceType::"Balance Sheet");
    end;

    procedure CreateCountryIfNeeded(CountryCode: Code[10]; CountryName: Text[50])
    var
        CustomerDataMigrationFacade: Codeunit "Customer Data Migration Facade";
        AddressFormatToSet: Option "Post Code+City","City+Post Code","City+County+Post Code","Blank Line+Post Code+City";
        ContactAddressFormatToSet: Option First,"After Company Name",Last;
    begin
        CustomerDataMigrationFacade.CreateCountryIfNeeded(CountryCode, CountryName, AddressFormatToSet::"City+County+Post Code", ContactAddressFormatToSet::"After Company Name");
    end;

#if not CLEAN24
    [Obsolete('Data cleanup is no longer performed before migration.', '24.0')]
    procedure CleanupGenJournalBatches()
    begin
    end;

    [Obsolete('Data cleanup is no longer performed before migration.', '24.0')]
    procedure CleanupVatPostingSetup()
    begin
    end;
#endif

    local procedure GetAcctCategoryEntryNo(Category: Option): Integer
    var
        GLAccountCategory: Record "G/L Account Category";
        GLAccountCategoryMgt: Codeunit "G/L Account Category Mgt.";
    begin
        GLAccountCategory.Init();
        GLAccountCategoryMgt.GetAccountCategory(GLAccountCategory, Category);
        exit(GLAccountCategory."Entry No.");
    end;

    procedure AssignSubAccountCategory(GPAccount: Record "GP Account") AcctSubCategory: Integer
    var
        GLAccountCategory: Record "G/L Account Category";
    begin
        case GPAccount.AccountCategory of
            1:
                AcctSubCategory := GetAcctSubCategoryEntryNo(GLAccountCategory."Account Category"::Assets, CashTxt);
            2, 4, 6:
                AcctSubCategory := GetAcctSubCategoryEntryNo(GLAccountCategory."Account Category"::Assets, CurrentAssetsTxt);
            3:
                AcctSubCategory := GetAcctSubCategoryEntryNo(GLAccountCategory."Account Category"::Assets, ARTxt);
            5:
                AcctSubCategory := GetAcctSubCategoryEntryNo(GLAccountCategory."Account Category"::Assets, InventoryTxt);
            7:
                AcctSubCategory := GetAcctSubCategoryEntryNo(GLAccountCategory."Account Category"::Assets, PrepaidExpensesTxt);
            8, 11, 12:
                AcctSubCategory := GetAcctSubCategoryEntryNo(GLAccountCategory."Account Category"::Assets, InventoryTxt);
            9:
                AcctSubCategory := GetAcctSubCategoryEntryNo(GLAccountCategory."Account Category"::Assets, EquipementTxt);
            10:
                AcctSubCategory := GetAcctSubCategoryEntryNo(GLAccountCategory."Account Category"::Assets, AccumDeprecTxt);
            13, 14, 15, 16, 17, 18, 19, 20, 21:
                AcctSubCategory := GetAcctSubCategoryEntryNo(GLAccountCategory."Account Category"::Liabilities, CurrentLiabilitiesTxt);
            22:
                AcctSubCategory := GetAcctSubCategoryEntryNo(GLAccountCategory."Account Category"::Liabilities, LongTermLiabilitiesTxt);
            23:
                AcctSubCategory := GetAcctSubCategoryEntryNo(GLAccountCategory."Account Category"::Equity, CommonStockTxt);
            24, 25, 26, 28:
                AcctSubCategory := GetAcctCategoryEntryNo(GLAccountCategory."Account Category"::Equity);
            27:
                AcctSubCategory := GetAcctSubCategoryEntryNo(GLAccountCategory."Account Category"::Equity, RetEarningsTxt);
            29, 30:
                AcctSubCategory := GetAcctSubCategoryEntryNo(GLAccountCategory."Account Category"::Equity, DistrToShareholdersTxt);
            31:
                AcctSubCategory := GetAcctCategoryEntryNo(GLAccountCategory."Account Category"::Income);
            32:
                AcctSubCategory := GetAcctSubCategoryEntryNo(GLAccountCategory."Account Category"::Income, IncomeSalesReturnsTxt);
            33:
                AcctSubCategory := GetAcctCategoryEntryNo(GLAccountCategory."Account Category"::"Cost of Goods Sold");
            34, 35:
                AcctSubCategory := GetAcctCategoryEntryNo(GLAccountCategory."Account Category"::Expense);
            36:
                AcctSubCategory := GetAcctSubCategoryEntryNo(GLAccountCategory."Account Category"::Expense, PayrollExpenseTxt);
            37:
                AcctSubCategory := GetAcctSubCategoryEntryNo(GLAccountCategory."Account Category"::Expense, BenefitsExpenseTxt);
            38:
                AcctSubCategory := GetAcctSubCategoryEntryNo(GLAccountCategory."Account Category"::Expense, InterestExpenseTxt);
            39, 41:
                AcctSubCategory := GetAcctSubCategoryEntryNo(GLAccountCategory."Account Category"::Expense, TaxExpenseTxt);
            40, 42, 43, 44, 45, 46, 47:
                AcctSubCategory := GetAcctSubCategoryEntryNo(GLAccountCategory."Account Category"::Expense, OtherIncomeExpenseTxt);
            else
                AcctSubCategory := 0;
        end;
    end;

    local procedure GetAcctSubCategoryEntryNo(Category: Option; Description: Text): Integer
    var
        GLAccountCategory: Record "G/L Account Category";
        GLAccountCategoryMgt: Codeunit "G/L Account Category Mgt.";
    begin
        GLAccountCategory.Init();
        GLAccountCategoryMgt.GetAccountSubcategory(GLAccountCategory, Category, Description);
        exit(GLAccountCategory."Entry No.");
    end;

    procedure TrimBackslash(Value: Text): Text
    begin
        exit(DelChr(Value, '=', '\'));
    end;

    procedure SetCustomerTransType(var GPCustomerTransactions: Record "GP Customer Transactions")
    begin
        case
            GPCustomerTransactions.RMDTYPAL of
            1 .. 5:
                GPCustomerTransactions.TransType := GPCustomerTransactions.TransType::Invoice;
            9:
                GPCustomerTransactions.TransType := GPCustomerTransactions.TransType::Payment;
            7, 8:
                GPCustomerTransactions.TransType := GPCustomerTransactions.TransType::"Credit Memo";
        end;
    end;

    procedure SetVendorTransType(var GPVendorTransactions: Record "GP Vendor Transactions")
    begin
        case
            GPVendorTransactions.DOCTYPE of
            1 .. 3, 7:
                GPVendorTransactions.TransType := GPVendorTransactions.TransType::Invoice;
            6:
                GPVendorTransactions.TransType := GPVendorTransactions.TransType::Payment;
            4, 5:
                GPVendorTransactions.TransType := GPVendorTransactions.TransType::"Credit Memo";
        end;
    end;

    procedure ResetAdjustforPaymentInGLSetup(var Flag: Boolean);
    var
        GLSetup: Record "General Ledger Setup";
    begin
        GLSetup.Reset();
        if GLSetup.FindFirst() then
            if Flag then begin
                Flag := false;
                GLSetup."Adjust for Payment Disc." := false;
                GLSetup.Modify();
            end else
                if not GLSetup."Adjust for Payment Disc." then begin
                    Flag := true;
                    GLSetup."Adjust for Payment Disc." := true;
                    GLSetup.Modify();
                end;
    end;

    procedure RunPreMigrationChecks(): Boolean;
    var
        InventorySetup: Record "Inventory Setup";
        GLEntry: Record "G/L Entry";
        ItemLedgerEntry: Record "Item Ledger Entry";
        ItemJournalLine: Record "Item Journal Line";
        GenJournalLine: Record "Gen. Journal Line";
        CostingMethod: Option FIFO,LIFO,Specific,Average,Standard;
    begin
        GLEntry.Reset();
        ItemLedgerEntry.Reset();
        if GLEntry.Find('-') then
            repeat
                if (GLEntry."Source Code" <> 'BEGBAL') or not ItemLedgerEntry.IsEmpty() then
                    // Non Beginning balance Transaction exists in GL entry to Item Ledger Entry
                    Error(TransactionExistsMsg);
            until GLEntry.Next() = 0;

        ItemJournalLine.Reset();
        if not ItemJournalLine.IsEmpty() then
            // Saved Item Journal line exists.
            Error(SavedJrnlLinesFoundMsg);

        GenJournalLine.Reset();
        if not GenJournalLine.IsEmpty() then
            // Saved General Journal line exists.
            Error(SavedJrnlLinesFoundMsg);

        if InventorySetup.Get() then
            if InventorySetup."Default Costing Method".AsInteger() = CostingMethod::Specific then
                Error(MigrationNotSupportedErr);

        exit(true);
    end;

    procedure CreateDimensions()
    begin
        CreateDimensionsImp();
    end;

    procedure CreatePaymentTerms()
    begin
        CreatePaymentTermsImp();
    end;

    procedure CreateItemTrackingCodes()
    begin
        CreateItemTrackingCodesImp();
    end;

    procedure CreateLocations()
    begin
        CreateLocationsImp();
    end;

    procedure CreateCheckbooks()
    begin
        CreateCheckBooksImp();
    end;

    procedure CreateOpenPOs()
    begin
        CreateOpenPOsImp();
    end;

    procedure CreateFiscalPeriods()
    begin
        CreateFiscalPeriodsImp();
    end;

    procedure CreateVendorEFTBankAccounts()
    begin
        CreateVendorEFTBankAccountsImp();
    end;

    procedure CreateVendorClasses()
    begin
        CreateVendorClassesImp();
    end;

    procedure CreateCustomerClasses()
    begin
        CreateCustomerClassesImp();
    end;

    local procedure CreateKitItems()
    var
        GPItemMigrator: Codeunit "GP Item Migrator";
    begin
        GPItemMigrator.MigrateKitItems();
    end;

    procedure CreateSetupRecordsIfNeeded()
    var
        CompanyInformation: Record "Company Information";
        GLSetup: Record "General Ledger Setup";
        InventorySetup: Record "Inventory Setup";
        ManufacturingSetup: Record "Manufacturing Setup";
        MarketingSetup: Record "Marketing Setup";
        PurchasesPayableSetup: Record "Purchases & Payables Setup";
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        SourceCodeSetup: Record "Source Code Setup";
    begin
        if CompanyInformation.IsEmpty() then begin
            CompanyInformation.Init();
            CompanyInformation.Insert(true);
        end;

        if GLSetup.IsEmpty() then begin
            GLSetup.Init();
            GLSetup.Insert(true);
        end;

        if InventorySetup.IsEmpty() then begin
            InventorySetup.Init();
            InventorySetup.Insert(true);
        end;

        if ManufacturingSetup.IsEmpty() then begin
            ManufacturingSetup.Init();
            ManufacturingSetup.Insert(true);
        end;

        if MarketingSetup.IsEmpty() then begin
            MarketingSetup.Init();
            MarketingSetup.Insert(true);
        end;

        if PurchasesPayableSetup.IsEmpty() then begin
            PurchasesPayableSetup.Init();
            PurchasesPayableSetup.Insert(true);
        end;

        if SalesReceivablesSetup.IsEmpty() then begin
            SalesReceivablesSetup.Init();
            SalesReceivablesSetup.Insert(true);
        end;

        if SourceCodeSetup.IsEmpty() then begin
            SourceCodeSetup.Init();
            SourceCodeSetup.Insert(true);
        end;
    end;

    internal procedure CalculateDueDateFormula(GPPaymentTerms: Record "GP Payment Terms"; Use_Discount_Calc: Boolean; Discount_Calc: Text[32]): Text[50]
    var
        working_number: integer;
        extra_month: integer;
        extra_year: integer;
        working_string: Text[20];
        working_discount_calc: Text[50];
        final_string: Text[50];
        MonthAsInteger: Integer;
    begin
        // BC Only supports GPPaymentTerms.CalculateDateFrom = Transaction Date
        // Set date formula to a string '<1M>'
        working_number := GPPaymentTerms.CalculateDateFromDays;  // Always add this many days to the due date.
        if working_number < 0 then
            working_number := 0;

        if Use_Discount_Calc and (Discount_Calc <> '') then
            // Need to get the date formula text minus the brackets...
            working_discount_calc := CopyStr(CopyStr(Discount_Calc, 2, (StrLen(Discount_Calc) - 2)), 1, 50)
        else
            // In case use discount is true, but the passed-in formula string is empty
            Use_Discount_Calc := false;

        // Add base days + discount days
        if GPPaymentTerms.DUETYPE = GPPaymentTerms.DUETYPE::"Net Days" then
            if GPPaymentTerms.DUEDTDS > 0 then begin
                working_number := working_number + GPPaymentTerms.DUEDTDS;
                working_string := '<' + Format(working_number, 0, 9) + 'D>';
            end;

        // Get the first day of the current month, then add appropriate days.
        // Need to remove one day since setting the date should fall on that number chosen, whereas the formula will add to the first of the month,
        // giving you one extra day we need to remove.
        if GPPaymentTerms.DUETYPE = GPPaymentTerms.DUETYPE::Date then
            if GPPaymentTerms.DUEDTDS > 0 then
                working_string := '<D' + Format(GPPaymentTerms.DUEDTDS, 0, 9) + '>';

        // Go to the end of the current month, then add appropriate days
        if GPPaymentTerms.DUETYPE = GPPaymentTerms.DUETYPE::EOM then begin
            if GPPaymentTerms.DUEDTDS > 0 then
                working_number := working_number + GPPaymentTerms.DUEDTDS;
            if working_number > 0 then
                working_string := '<CM+' + Format(working_number, 0, 9) + 'D>'
            else
                working_string := '<CM>';
        end;

        // Just add the number of initial days to the current date
        if GPPaymentTerms.DUETYPE = GPPaymentTerms.DUETYPE::None then
            working_string := '<' + Format(working_number, 0, 9) + 'D>';

        // Set the day of the next month
        // Need to remove one day, see the comments above for DUETYPE::Date
        if GPPaymentTerms.DUETYPE = GPPaymentTerms.DUETYPE::"Next Month" then begin
            if GPPaymentTerms.DUEDTDS > 0 then
                working_number := GPPaymentTerms.DUEDTDS;

            if working_number < 1 then
                working_number := 1;

            // First day of current month, + 1 month + the number of days
            working_string := '<-CM+1M+' + Format(working_number - 1, 0, 9) + 'D>';
        end;

        if GPPaymentTerms.DUETYPE = GPPaymentTerms.DUETYPE::Months then begin
            if GPPaymentTerms.DUEDTDS > 0 then
                extra_month := GPPaymentTerms.DUEDTDS;
            // Add the extra months, then the extra days
            working_string := '<' + Format(extra_month, 0, 9) + 'M+' + Format(working_number, 0, 9) + 'D>';
        end;

        if GPPaymentTerms.DUETYPE = GPPaymentTerms.DUETYPE::"Month/Day" then begin
            MonthAsInteger := GPPaymentTerms.DueMonth;
            working_string := '<M' + Format(MonthAsInteger, 0, 9) + '+D' + Format(GPPaymentTerms.DUEDTDS, 0, 9) + '>';
        end;

        if GPPaymentTerms.DUETYPE = GPPaymentTerms.DUETYPE::Annual then begin
            if GPPaymentTerms.DUEDTDS > 0 then
                extra_year := GPPaymentTerms.DUEDTDS;
            // Add the extra months, then the extra days
            working_string := '<' + Format(extra_year, 0, 9) + 'Y+' + Format(working_number, 0, 9) + 'D>'
        end;

        if Use_Discount_Calc then begin
            final_string := CopyStr('<' + working_discount_calc, 1, 50);
            if (CopyStr(working_string, 2, 1) = '-') or (CopyStr(working_string, 2, 1) = '+') then
                final_string := final_string + CopyStr(working_string, 2)
            else
                if working_string <> '' then
                    final_string += '+' + CopyStr(working_string, 2)
                else
                    final_string += '>';
            exit(final_string);
        end else
            exit(working_string);
        // Back in the calling proc, EVALUATE(variable,forumlastring) will set the variable to the correct formula
    end;

    internal procedure CalculateDiscountDateFormula(GPPaymentTerms: Record "GP Payment Terms"): Text[50]
    var
        working_number: integer;
        extra_month: integer;
        extra_year: integer;
        working_string: Text[20];
    begin
        // Set date formula to a string '<1M>'
        working_number := GPPaymentTerms.CalculateDateFromDays;  // Always add this many days to the due date.
        if working_number < 0 then
            working_number := 0;

        // Add base days + discount days
        if GPPaymentTerms.DISCTYPE = GPPaymentTerms.DISCTYPE::Days then
            if GPPaymentTerms.DISCDTDS > 0 then begin
                working_number := working_number + GPPaymentTerms.DISCDTDS;
                working_string := '<' + Format(working_number, 0, 9) + 'D>';
            end;

        // Get the first day of the current month, then add appropriate days.
        // Need to remove one day since setting the date should fall on that number chosen, whereas the formula will add to the first of the month,
        // giving you one extra day we need to remove.
        if GPPaymentTerms.DISCTYPE = GPPaymentTerms.DISCTYPE::Date then
            if GPPaymentTerms.DISCDTDS > 0 then
                working_string := '<D' + Format(GPPaymentTerms.DISCDTDS, 0, 9) + '>';

        // Go to the end of the current month, then add appropriate days
        if GPPaymentTerms.DISCTYPE = GPPaymentTerms.DISCTYPE::EOM then begin
            if GPPaymentTerms.DISCDTDS > 0 then
                working_number := working_number + GPPaymentTerms.DISCDTDS;
            if working_number > 0 then
                working_string := '<CM+' + Format(working_number, 0, 9) + 'D>'
            else
                working_string := '<CM>';
        end;

        // Just add the number of initial days to the current date
        if GPPaymentTerms.DISCTYPE = GPPaymentTerms.DISCTYPE::None then
            working_string := '<+' + Format(working_number, 0, 9) + 'D>';

        // Set the day of the next month
        // Need to remove one day, see the comments above for DISCTYPE::Date
        if GPPaymentTerms.DISCTYPE = GPPaymentTerms.DISCTYPE::"Next Month" then begin
            if GPPaymentTerms.DISCDTDS > 0 then
                working_number := GPPaymentTerms.DISCDTDS;

            if working_number < 1 then
                working_number := 1;

            // First day of current month, + 1 month + the number of days
            working_string := '<-CM+1M+' + Format(working_number - 1, 0, 9) + 'D>;'
        end;

        if GPPaymentTerms.DISCTYPE = GPPaymentTerms.DISCTYPE::Months then begin
            if GPPaymentTerms.DISCDTDS > 0 then
                extra_month := GPPaymentTerms.DISCDTDS;
            // Add the extra months, then the extra days
            working_string := '<' + Format(extra_month, 0, 9) + 'M+' + Format(working_number, 0, 9) + 'D>;'
        end;

        if GPPaymentTerms.DISCTYPE = GPPaymentTerms.DISCTYPE::"Month/Day" then
            working_string := '<M' + Format(GPPaymentTerms.DiscountMonth, 0, 9) + '+D' + Format(GPPaymentTerms.DISCDTDS, 0, 9) + '>';

        if GPPaymentTerms.DISCTYPE = GPPaymentTerms.DISCTYPE::Annual then begin
            if GPPaymentTerms.DISCDTDS > 0 then
                extra_year := GPPaymentTerms.DISCDTDS;
            // Add the extra months, then the extra days
            working_string := '<' + Format(extra_year, 0, 9) + 'Y+' + Format(working_number, 0, 9) + 'D>;'
        end;

        exit(working_string);
        // Back in the calling proc, EVALUATE(variable,forumlastring) will set the variable to the correct formula
    end;

    local procedure GeneratePaymentTerm(SeedValue: Integer; GPPaymentTerm: Text[22]): Text[10]
    var
        seedlength: integer;
    begin
        seedlength := STRLEN(FORMAT(SeedValue));
        exit(COPYSTR((COPYSTR(GPPaymentTerm, 1, (10 - seedlength)) + FORMAT(SeedValue)), 1, 10));
    end;

    local procedure UpdatePaymentTerms()
    var
        GPPaymentTerms: Record "GP Payment Terms";
        GPCustomer: Record "GP Customer"; //1932
        GPCustomerTrans: Record "GP Customer Transactions"; //1933
        GPVendor: Record "GP Vendor"; //1934
        GPVendorTransactions: Record "GP Vendor Transactions"; //1935
        GPSOPTrxHist: Record "GPSOPTrxHist"; //4100
        GPRMOpen: Record "GPRMOpen"; //4114
        GPRMHist: Record "GPRMHist"; //4115
        GPPOPReceiptHist: Record "GPPOPReceiptHist"; //4116
        GPPOPPOHist: Record "GPPOPPOHist"; //4123
        GPPMHist: Record "GPPMHist"; //4126
        GPPOP10100: Record "GP POP10100";
        DataMigrationErrorLogging: Codeunit "Data Migration Error Logging";
        PaymentTerm: Text[22];
        PaymentTerm_New: Text[10];
    begin
        if not GPPaymentTerms.FindSet() then
            exit;

        repeat
            DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(GPPaymentTerms.RecordId));
            PaymentTerm := DELCHR(GPPaymentTerms.PYMTRMID, '>', ' ');
            PaymentTerm_New := DELCHR(GPPaymentTerms.PYMTRMID_New, '>', ' ');
            // if the "old" and "new" payment terms are the same, skip
            if PaymentTerm <> PaymentTerm_New then begin
                // update the payment terms in the tables that have this field
                Clear(GPCustomer);
                GPCustomer.SetRange(GPCustomer."PYMTRMID", PaymentTerm);
                if not GPCustomer.IsEmpty() then
                    GPCustomer.MODIFYALL(GPCustomer."PYMTRMID", PaymentTerm_New);


                Clear(GPCustomerTrans);
                GPCustomerTrans.SetRange(GPCustomerTrans."PYMTRMID", PaymentTerm);
                if not GPCustomerTrans.IsEmpty() then
                    GPCustomerTrans.MODIFYALL(GPCustomerTrans."PYMTRMID", PaymentTerm_New);


                Clear(GPVendor);
                GPVendor.SetRange(GPVendor."PYMTRMID", PaymentTerm);
                if not GPVendor.IsEmpty() then
                    GPVendor.MODIFYALL(GPVendor."PYMTRMID", PaymentTerm_New);


                Clear(GPVendorTransactions);
                GPVendorTransactions.SetRange(GPVendorTransactions."PYMTRMID", PaymentTerm);
                if not GPVendorTransactions.IsEmpty() then
                    GPVendorTransactions.MODIFYALL(GPVendorTransactions."PYMTRMID", PaymentTerm_New);


                Clear(GPSOPTrxHist);
                GPSOPTrxHist.SetRange(GPSOPTrxHist."PYMTRMID", PaymentTerm);
                if not GPSOPTrxHist.IsEmpty() then
                    GPSOPTrxHist.MODIFYALL(GPSOPTrxHist."PYMTRMID", PaymentTerm_New);


                Clear(GPRMOpen);
                GPRMOpen.SetRange(GPRMOpen."PYMTRMID", PaymentTerm);
                if not GPRMOpen.IsEmpty() then
                    GPRMOpen.MODIFYALL(GPRMOpen."PYMTRMID", PaymentTerm_New);


                Clear(GPRMHist);
                GPRMHist.SetRange(GPRMHist."PYMTRMID", PaymentTerm);
                if not GPRMHist.IsEmpty() then
                    GPRMHist.MODIFYALL(GPRMHist."PYMTRMID", PaymentTerm_New);


                Clear(GPPOPReceiptHist);
                GPPOPReceiptHist.SetRange(GPPOPReceiptHist."PYMTRMID", PaymentTerm);
                if not GPPOPReceiptHist.IsEmpty() then
                    GPPOPReceiptHist.MODIFYALL(GPPOPReceiptHist."PYMTRMID", PaymentTerm_New);


                Clear(GPPOPPOHist);
                GPPOPPOHist.SetRange(GPPOPPOHist."PYMTRMID", PaymentTerm);
                if not GPPOPPOHist.IsEmpty() then
                    GPPOPPOHist.MODIFYALL(GPPOPPOHist."PYMTRMID", PaymentTerm_New);


                Clear(GPPMHist);
                GPPMHist.SetRange(GPPMHist."PYMTRMID", PaymentTerm);
                if not GPPMHist.IsEmpty() then
                    GPPMHist.MODIFYALL(GPPMHist."PYMTRMID", PaymentTerm_New);

                Clear(GPPOP10100);
                GPPOP10100.SetRange(GPPOP10100.PYMTRMID, PaymentTerm);
                if not GPPOP10100.IsEmpty() then
                    GPPOP10100.ModifyAll(GPPOP10100.PYMTRMID, PaymentTerm_New);

            end;
        until GPPaymentTerms.Next() = 0;
    end;

    procedure GetMigrationTypeTxt(): Text[250]
    begin
        exit(CopyStr(MigrationTypeTxt, 1, 250));
    end;

    procedure GetTelemetryCategory(): Text
    begin
        exit(CloudMigrationTok);
    end;

    internal procedure CheckDimensionName(Name: Text[50]): Code[20]
    var
        GLAccount: Record "G/L Account";
        BusinessUnit: Record "Business Unit";
        Item: Record Item;
        Location: Record Location;
    begin
        if ((UpperCase(Name) = UpperCase(GLAccount.TableCaption())) or
            (UpperCase(Name) = UpperCase(BusinessUnit.TableCaption())) or
            (UpperCase(Name) = UpperCase(Item.TableCaption())) or
            (UpperCase(Name) = UpperCase(Location.TableCaption())) or
            (UpperCase(Name) = UpperCase(PeriodTxt))) then
            exit(CopyStr(Name + 's', 1, 20));

        exit(CopyStr(Name, 1, 20));
    end;

    procedure CreateDimensionValues()
    var
        GPCodes: Record "GP Codes";
        DimensionValue: Record "Dimension Value";
        DimCode: Code[20];
    begin
        GPCodes.SetFilter(GPCodes.Name, '<> %1', '');
        if GPCodes.FindSet() then
            repeat
                DimCode := CheckDimensionName(GPCodes.Id);
                if not DimensionValue.Get(DimCode, GPCodes.Name) then begin
                    DimensionValue.Init();
                    DimensionValue.Validate("Dimension Code", DimCode);
                    DimensionValue.Validate(Code, GPCodes.Name);
                    DimensionValue.Validate(Name, GPCodes.Description);
                    DimensionValue.Insert(true);
                end;
            until GPCodes.Next() = 0;
    end;

    procedure AnyCompaniesWithTooManySegments(var CompanyList: List of [Text])
    var
        GPCompanyMigrationSettings: Record "GP Company Migration Settings";
    begin
        GPCompanyMigrationSettings.SetFilter(Replicate, '=%1', true);
        GPCompanyMigrationSettings.SetFilter(NumberOfSegments, '>%1', 9);
        if GPCompanyMigrationSettings.FindSet() then
            repeat
                CompanyList.Add(GPCompanyMigrationSettings.Name);
            until GPCompanyMigrationSettings.Next() = 0;
    end;

#if not CLEAN24
    [Obsolete('Cleaning up tables before running the migration is no longer wanted.', '24.0')]
    procedure Cleanup();
    begin
    end;

    [Obsolete('Cleaning up tables before running the migration is no longer wanted.', '24.0')]
    procedure CleanupBeforeSynchronization();
    begin
    end;
#endif

    procedure SetTransactionProcessedFlag()
    begin
        GPConfiguration.GetSingleInstance();
        GPConfiguration."GL Transactions Processed" := true;
        GPConfiguration.Modify();
    end;

    procedure HaveGLTrxsBeenProcessed(): Boolean;
    begin
        GPConfiguration.GetSingleInstance();
        exit(GPConfiguration."GL Transactions Processed");
    end;

    procedure SetAccountValidationError()
    begin
        GPConfiguration.GetSingleInstance();
        GPConfiguration."Account Validation Error" := true;
        GPConfiguration.Modify();
    end;

    procedure ClearAccountValidationError()
    begin
        GPConfiguration.GetSingleInstance();
        GPConfiguration."Account Validation Error" := false;
        GPConfiguration.Modify();
    end;

    procedure GetAccountValidationError(): Boolean;
    begin
        GPConfiguration.GetSingleInstance();
        exit(GPConfiguration."Account Validation Error");
    end;

    procedure GetNumberOfAccounts(): Integer;
    var
        GPAccount: Record "GP Account";
    begin
        exit(GPAccount.Count());
    end;

    procedure GetNumberOfItems(): Integer;
    var
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        GPIV00101: Record "GP IV00101";
    begin
        if not GPCompanyAdditionalSettings.GetInventoryModuleEnabled() then
            exit(0);

        if not GPCompanyAdditionalSettings.GetMigrateKitItems() then
            GPIV00101.SetFilter(ITEMTYPE, '<>%1', GPIV00101.KitItemTypeId());

        if not GPCompanyAdditionalSettings.GetMigrateInactiveItems() then
            GPIV00101.SetRange(INACTIVE, false);

        if not GPCompanyAdditionalSettings.GetMigrateDiscontinuedItems() then
            GPIV00101.SetFilter(ITEMTYPE, '<>%1&<>%2', GPIV00101.DiscontinuedItemTypeId(), GPIV00101.KitItemTypeId());

        exit(GPIV00101.Count());
    end;

    procedure GetNumberOfCustomers(): Integer;
    var
        GPCustomer: Record "GP Customer";
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
    begin
        if not GPCompanyAdditionalSettings.GetReceivablesModuleEnabled() then
            exit(0);

        exit(GPCustomer.Count());
    end;

    procedure GetNumberOfVendors(): Integer;
    var
        GPVendor: Record "GP Vendor";
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        GPVendorMigrator: Codeunit "GP Vendor Migrator";
        IsTemporaryVendor: Boolean;
        HasOpenPurchaseOrders: Boolean;
        HasOpenTransactions: Boolean;
        VendorCount: Integer;
    begin
        if not GPCompanyAdditionalSettings.GetPayablesModuleEnabled() then
            exit(0);

        if GPVendor.FindSet() then
            repeat
                if GPVendorMigrator.ShouldMigrateVendor(GPVendor.VENDORID, IsTemporaryVendor, HasOpenPurchaseOrders, HasOpenTransactions) then
                    VendorCount := VendorCount + 1;

            until GPVendor.Next() = 0;

        exit(VendorCount);
    end;

    procedure RemoveEmptyGLTransactions()
    var
        GPGLTransactions: Record "GP GLTransactions";
    begin
        GPGLTransactions.Reset();
        GPGLTransactions.SetRange(PERDBLNC, 0);
        GPGLTransactions.DeleteAll();
    end;

    procedure RaiseNotificationForUnpostedJournals()
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
        UnpostedJournalLines: Notification;
        UnpostedLines: Integer;
    begin
        UnpostedJournalLines.Id := '99b0853c-3c62-420a-8d7e-497b4133ada2';
        UnpostedJournalLines.Recall();

        if not HybridCloudManagement.GetLastReplicationSummary(HybridReplicationSummary) then
            exit;

        if not (HybridReplicationSummary.Status = HybridReplicationSummary.Status::Completed) then
            exit;

        UnpostedLines := GetUnpostedLines(GeneralTemplateNameTxt, PostingGroupCodeTxt + '*');
        UnpostedLines += GetUnpostedLines(GeneralTemplateNameTxt, CustomerBatchNameTxt);
        UnpostedLines += GetUnpostedLines(GeneralTemplateNameTxt, VendorBatchNameTxt);
        UnpostedLines += GetUnpostedLines(GeneralTemplateNameTxt, BankBatchNameTxt);

        if (UnpostedLines = 0) then
            exit;

        UnpostedJournalLines.Message := StrSubstNo(NotAllJournalLinesPostedMsg, UnpostedLines);
        UnpostedJournalLines.Scope := NotificationScope::LocalScope;
        UnpostedJournalLines.Send();
    end;

    local procedure GetUnpostedLines(TemplateName: Text; BatchNameFilter: text): Integer
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        UnpostedLines: Integer;
    begin
        GenJournalBatch.SetRange("Journal Template Name", TemplateName);
        GenJournalBatch.SetFilter(Name, BatchNameFilter);
        if GenJournalBatch.FindSet() then
            repeat
                GenJournalLine.SetRange("Journal Template Name", GeneralTemplateNameTxt);
                GenJournalLine.SetRange("Journal Batch Name", BatchNameFilter);
                if not GenJournalLine.IsEmpty() then
                    UnpostedLines += GenJournalLine.Count();
            until GenJournalBatch.Next() = 0;

        exit(UnpostedLines);
    end;

    local procedure GetGLBatchCountWithUnpostedLinesForCompany(CompanyNameTxt: Text; TemplateName: Text; BatchNameFilter: text): Integer
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        UnpostedBatchCount: Integer;
    begin
        if not GenJournalBatch.ChangeCompany(CompanyNameTxt) then
            exit;

        if not GenJournalLine.ChangeCompany(CompanyNameTxt) then
            exit;

        GenJournalBatch.SetRange("Journal Template Name", TemplateName);
        GenJournalBatch.SetFilter(Name, BatchNameFilter);
        if GenJournalBatch.FindSet() then
            repeat
                GenJournalLine.SetRange("Journal Template Name", GenJournalBatch."Journal Template Name");
                GenJournalLine.SetRange("Journal Batch Name", GenJournalBatch.Name);
                if not GenJournalLine.IsEmpty() then
                    UnpostedBatchCount := UnpostedBatchCount + 1;
            until GenJournalBatch.Next() = 0;

        exit(UnpostedBatchCount);
    end;

    local procedure GetItemBatchCountWithUnpostedLinesForCompany(CompanyNameTxt: Text): Integer
    var
        ItemJournalBatch: Record "Item Journal Batch";
        ItemJournalLine: Record "Item Journal Line";
        UnpostedBatchCount: Integer;
    begin
        if not ItemJournalBatch.ChangeCompany(CompanyNameTxt) then
            exit;

        if not ItemJournalLine.ChangeCompany(CompanyNameTxt) then
            exit;

        ItemJournalBatch.SetFilter(Name, 'GPITM*');
        if ItemJournalBatch.FindSet() then
            repeat
                ItemJournalLine.SetRange("Journal Batch Name", ItemJournalBatch.Name);
                if not ItemJournalLine.IsEmpty() then
                    UnpostedBatchCount += UnpostedBatchCount + 1;
            until ItemJournalBatch.Next() = 0;

        exit(UnpostedBatchCount);
    end;

    local procedure GetStatisticalBatchCountWithUnpostedLinesForCompany(CompanyNameTxt: Text): Integer
    var
        StatisticalAccJournalBatch: Record "Statistical Acc. Journal Batch";
        StatisticalAccJournalLine: Record "Statistical Acc. Journal Line";
        UnpostedBatchCount: Integer;
    begin
        if not StatisticalAccJournalBatch.ChangeCompany(CompanyNameTxt) then
            exit;

        if not StatisticalAccJournalLine.ChangeCompany(CompanyNameTxt) then
            exit;

        StatisticalAccJournalBatch.SetFilter(Name, 'GP*');
        if StatisticalAccJournalBatch.FindSet() then
            repeat
                StatisticalAccJournalLine.SetRange("Journal Batch Name", StatisticalAccJournalBatch.Name);
                if not StatisticalAccJournalLine.IsEmpty() then
                    UnpostedBatchCount += UnpostedBatchCount + 1;
            until StatisticalAccJournalBatch.Next() = 0;

        exit(UnpostedBatchCount);
    end;

    internal procedure GetUnpostedBatchCountForCompany(CompanyNameTxt: Text; var TotalGLBatchCount: Integer; var TotalStatisticalBatchCount: Integer; var TotalItemBatchCount: Integer)
    var
        HybridCompanyStatus: Record "Hybrid Company Status";
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
    begin
        TotalGLBatchCount := 0;
        TotalStatisticalBatchCount := 0;
        TotalItemBatchCount := 0;

        if not HybridCompanyStatus.Get(CompanyNameTxt) then
            exit;

        if not (HybridCompanyStatus."Upgrade Status" = HybridCompanyStatus."Upgrade Status"::Completed) then
            exit;


        if not GPCompanyAdditionalSettings.Get(CompanyNameTxt) then
            exit;

        if not GPCompanyAdditionalSettings."Skip Posting Account Batches" then begin
            TotalGLBatchCount := GetGLBatchCountWithUnpostedLinesForCompany(CompanyNameTxt, GeneralTemplateNameTxt, PostingGroupCodeTxt + '*');
            TotalStatisticalBatchCount := GetStatisticalBatchCountWithUnpostedLinesForCompany(CompanyNameTxt);
        end;

        if not GPCompanyAdditionalSettings."Skip Posting Customer Batches" then
            TotalGLBatchCount += GetGLBatchCountWithUnpostedLinesForCompany(CompanyNameTxt, GeneralTemplateNameTxt, CustomerBatchNameTxt);

        if not GPCompanyAdditionalSettings."Skip Posting Vendor Batches" then
            TotalGLBatchCount += GetGLBatchCountWithUnpostedLinesForCompany(CompanyNameTxt, GeneralTemplateNameTxt, VendorBatchNameTxt);

        if not GPCompanyAdditionalSettings."Skip Posting Bank Batches" then
            TotalGLBatchCount += GetGLBatchCountWithUnpostedLinesForCompany(CompanyNameTxt, GeneralTemplateNameTxt, BankBatchNameTxt);

        if not GPCompanyAdditionalSettings."Skip Posting Item Batches" then
            TotalItemBatchCount := GetItemBatchCountWithUnpostedLinesForCompany(CompanyNameTxt);
    end;

    procedure PostGLTransactions()
    var
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalBatch: Record "Gen. Journal Batch";
        ItemJournalLine: Record "Item Journal Line";
        ItemJournalBatch: Record "Item Journal Batch";
        StatisticalAccJournalBatch: Record "Statistical Acc. Journal Batch";
        StatisticalAccJournalLine: Record "Statistical Acc. Journal Line";
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        JournalBatchName: Text;
        DurationAsInt: BigInteger;
        StartTime: DateTime;
        FinishedTelemetryTxt: Label 'Posting GL transactions finished; Duration: %1', Comment = '%1 - The time taken', Locked = true;
        SkipPosting: Boolean;
    begin
        StartTime := CurrentDateTime();
        Session.LogMessage('00007GJ', 'Posting GL transactions started.', Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', GetTelemetryCategory());

        SkipPosting := GPCompanyAdditionalSettings.GetSkipAllPosting();
        OnSkipPostingGLAccounts(SkipPosting);
        if SkipPosting then
            exit;

        // Item batches
        SkipPosting := GPCompanyAdditionalSettings.GetSkipPostingItemBatches();
        OnSkipPostingItemBatches(SkipPosting);
        if not SkipPosting then
            if ItemJournalBatch.FindSet() then
                repeat
                    ItemJournalLine.SetRange("Journal Template Name", ItemJournalBatch."Journal Template Name");
                    ItemJournalLine.SetRange("Journal Batch Name", ItemJournalBatch.Name);
                    ItemJournalLine.SetFilter("Item No.", '<>%1', '');
                    if not ItemJournalLine.IsEmpty() then
                        SafePostItemBatch(ItemJournalBatch);
                until ItemJournalBatch.Next() = 0;

        // Account batches
        SkipPosting := GPCompanyAdditionalSettings.GetSkipPostingAccountBatches();
        OnSkipPostingAccountBatches(SkipPosting);
        if not SkipPosting then begin
            // GL
            GenJournalBatch.Reset();
            GenJournalBatch.SetRange("Journal Template Name", GeneralTemplateNameTxt);
            GenJournalBatch.SetFilter(Name, PostingGroupCodeTxt + '*');
            if GenJournalBatch.FindSet() then
                repeat
                    if (GenJournalBatch.Name <> CustomerBatchNameTxt) and (GenJournalBatch.Name <> VendorBatchNameTxt) and (GenJournalBatch.Name <> BankBatchNameTxt) then begin
                        JournalBatchName := GenJournalBatch.Name;
                        GenJournalLine.Reset();
                        GenJournalLine.SetRange("Journal Template Name", GeneralTemplateNameTxt);
                        GenJournalLine.SetRange("Journal Batch Name", JournalBatchName);
                        if not GenJournalLine.IsEmpty() then
                            SafePostGLBatch(CopyStr(JournalBatchName, 1, 10));
                    end;
                until GenJournalBatch.Next() = 0;

            // Statistical
            StatisticalAccJournalBatch.SetFilter(Name, PostingGroupCodeTxt + '*');
            if StatisticalAccJournalBatch.FindSet() then
                repeat
                    StatisticalAccJournalLine.SetRange("Journal Batch Name", StatisticalAccJournalBatch.Name);
                    if not StatisticalAccJournalLine.IsEmpty() then
                        SafePostStatisticalAccBatch(StatisticalAccJournalBatch.Name);
                until StatisticalAccJournalBatch.Next() = 0;
        end;

        // Customer batches
        SkipPosting := GPCompanyAdditionalSettings.GetSkipPostingCustomerBatches();
        OnSkipPostingCustomerBatches(SkipPosting);
        if not SkipPosting then begin
            JournalBatchName := CustomerBatchNameTxt;
            GenJournalLine.Reset();
            GenJournalLine.SetRange("Journal Template Name", GeneralTemplateNameTxt);
            GenJournalLine.SetRange("Journal Batch Name", JournalBatchName);
            if not GenJournalLine.IsEmpty() then
                SafePostGLBatch(CopyStr(JournalBatchName, 1, 10));
        end;

        // Vendor batches
        SkipPosting := GPCompanyAdditionalSettings.GetSkipPostingVendorBatches();
        OnSkipPostingVendorBatches(SkipPosting);
        if not SkipPosting then begin
            JournalBatchName := VendorBatchNameTxt;
            GenJournalLine.Reset();
            GenJournalLine.SetRange("Journal Template Name", GeneralTemplateNameTxt);
            GenJournalLine.SetRange("Journal Batch Name", JournalBatchName);
            if not GenJournalLine.IsEmpty() then
                SafePostGLBatch(CopyStr(JournalBatchName, 1, 10));
        end;

        // Bank batches
        SkipPosting := GPCompanyAdditionalSettings.GetSkipPostingBankBatches();
        OnSkipPostingBankBatches(SkipPosting);
        if not SkipPosting then begin
            JournalBatchName := BankBatchNameTxt;
            GenJournalLine.Reset();
            GenJournalLine.SetRange("Journal Template Name", GeneralTemplateNameTxt);
            GenJournalLine.SetRange("Journal Batch Name", JournalBatchName);
            if not GenJournalLine.IsEmpty() then
                SafePostGLBatch(CopyStr(JournalBatchName, 1, 10));
        end;

        // Remove posted batches
        RemoveBatches();
        DurationAsInt := CurrentDateTime() - StartTime;
        Session.LogMessage('00007GK', StrSubstNo(FinishedTelemetryTxt, DurationAsInt), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', GetTelemetryCategory());
    end;

    [Obsolete('This procedure will be soon removed.', '25.0')]
    procedure PostGLBatch(JournalBatchName: Code[10])
    var
        GenJournalLine: Record "Gen. Journal Line";
        TotalBalance: Decimal;
    begin
        GenJournalLine.Reset();
        GenJournalLine.SetRange("Journal Template Name", GeneralTemplateNameTxt);
        GenJournalLine.SetRange("Journal Batch Name", JournalBatchName);
        // Do not care about balances for Customer, Vendor, and Bank batches
        if (JournalBatchName <> CustomerBatchNameTxt) and (JournalBatchName <> VendorBatchNameTxt) and (JournalBatchName <> BankBatchNameTxt) then begin
            repeat
                TotalBalance := TotalBalance + GenJournalLine.Amount;
            until GenJournalLine.Next() = 0;
            if TotalBalance = 0 then
                if GenJournalLine.FindFirst() then
                    codeunit.Run(codeunit::"Gen. Jnl.-Post Batch", GenJournalLine)
                else begin
                    Message(StrSubstNo(DocNoOutofBalanceMsg, GlDocNoTxt, FORMAT(TotalBalance)));
                    if GenJournalLine.FindFirst() then
                        GenJournalLine.DeleteAll();
                end;
        end else
            if GenJournalLine.FindFirst() then
                codeunit.Run(codeunit::"Gen. Jnl.-Post Batch", GenJournalLine);
    end;

    local procedure SafePostGLBatch(JournalBatchName: Code[10])
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        GenJournalLine.SetRange("Journal Template Name", GeneralTemplateNameTxt);
        GenJournalLine.SetRange("Journal Batch Name", JournalBatchName);
        if GenJournalLine.FindFirst() then begin
            // Commit is required to safely handle errors that may occur during posting.
            Commit();
            if not Codeunit.Run(Codeunit::"Gen. Jnl.-Post Batch", GenJournalLine) then
                LogWarningAndClearLastError(JournalBatchName);
        end;
    end;

    [Obsolete('This procedure will be soon removed.', '25.0')]
    procedure PostStatisticalAccBatch(JournalBatchName: Code[10])
    var
        StatisticalAccJournalLine: Record "Statistical Acc. Journal Line";
    begin
        StatisticalAccJournalLine.SetRange("Journal Batch Name", JournalBatchName);
        if StatisticalAccJournalLine.FindFirst() then
            Codeunit.Run(Codeunit::"Stat. Acc. Post. Batch", StatisticalAccJournalLine);
    end;

    local procedure SafePostStatisticalAccBatch(JournalBatchName: Code[10])
    var
        StatisticalAccJournalLine: Record "Statistical Acc. Journal Line";
    begin
        StatisticalAccJournalLine.SetRange("Journal Batch Name", JournalBatchName);
        if StatisticalAccJournalLine.FindFirst() then begin
            // Commit is required to safely handle errors that may occur during posting.
            Commit();
            if not Codeunit.Run(Codeunit::"Stat. Acc. Post. Batch", StatisticalAccJournalLine) then
                LogWarningAndClearLastError(JournalBatchName);
        end;
    end;

    local procedure SafePostItemBatch(ItemJournalBatch: Record "Item Journal Batch")
    var
        ItemJournalLine: Record "Item Journal Line";
    begin
        ItemJournalLine.SetRange("Journal Template Name", ItemJournalBatch."Journal Template Name");
        ItemJournalLine.SetRange("Journal Batch Name", ItemJournalBatch.Name);
        if ItemJournalLine.FindFirst() then begin
            // Commit is required to safely handle errors that may occur during posting.
            Commit();
            if not Codeunit.Run(Codeunit::"Item Jnl.-Post Batch", ItemJournalLine) then
                LogWarningAndClearLastError(ItemJournalBatch.Name);
        end;
    end;

    internal procedure LogWarningAndClearLastError(ContextValue: Text[50])
    var
        GPMigrationWarnings: Record "GP Migration Warnings";
        WarningText: Text[500];
    begin
        WarningText := CopyStr(GetLastErrorText(false), 1, MaxStrLen(WarningText));
        GPMigrationWarnings.InsertWarning(MigrationLogAreaBatchPostingTxt, ContextValue, WarningText);
        ClearLastError();
    end;

    local procedure GLBatchHasLines(TemplateName: Code[10]; BatchName: Code[10]; AccountType: Enum "Gen. Journal Account Type"): Boolean
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        GenJournalLine.SetRange("Journal Template Name", TemplateName);
        GenJournalLine.SetRange("Journal Batch Name", BatchName);
        GenJournalLine.SetRange("Account Type", AccountType);
        GenJournalLine.SetFilter("Account No.", '<>%1', '');
        exit(not GenJournalLine.IsEmpty());
    end;

    local procedure StatisticalBatchHasLines(BatchName: Code[10]): Boolean
    var
        StatisticalAccJournalLine: Record "Statistical Acc. Journal Line";
    begin
        StatisticalAccJournalLine.SetRange("Journal Batch Name", BatchName);
        StatisticalAccJournalLine.SetFilter("Statistical Account No.", '<>%1', '');
        exit(not StatisticalAccJournalLine.IsEmpty());
    end;

    procedure RemoveBatches();
    var
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalBatch: Record "Gen. Journal Batch";
        ItemJournalBatch: Record "Item Journal Batch";
        ItemJournalLine: Record "Item Journal Line";
        StatisticalAccJournalBatch: Record "Statistical Acc. Journal Batch";
        StatisticalAccJournalLine: Record "Statistical Acc. Journal Line";
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        JournalBatchName: Code[10];
        SkipPosting: Boolean;
    begin
        SkipPosting := GPCompanyAdditionalSettings.GetSkipAllPosting();
        OnSkipPostingGLAccounts(SkipPosting);
        if SkipPosting then
            exit;

        // Account batches
        SkipPosting := GPCompanyAdditionalSettings.GetSkipPostingAccountBatches();
        OnSkipPostingAccountBatches(SkipPosting);
        if not SkipPosting then begin
            // GL
            GenJournalBatch.Reset();
            GenJournalBatch.SetRange("Journal Template Name", GeneralTemplateNameTxt);
            if GenJournalBatch.FindSet() then
                repeat
                    if StrPos(GenJournalBatch.Name, PostingGroupCodeTxt) = 1 then
                        if (GenJournalBatch.Name <> CustomerBatchNameTxt) and (GenJournalBatch.Name <> VendorBatchNameTxt) and (GenJournalBatch.Name <> BankBatchNameTxt) then
                            if not GLBatchHasLines(GeneralTemplateNameTxt, GenJournalBatch.Name, GenJournalLine."Account Type"::"G/L Account") then begin
                                GenJournalLine.Reset();
                                GenJournalLine.SetRange("Journal Template Name", GeneralTemplateNameTxt);
                                GenJournalLine.SetRange("Journal Batch Name", GenJournalBatch.Name);
                                GenJournalLine.SetRange("Account Type", GenJournalLine."Account Type"::"G/L Account");
                                GenJournalLine.SetRange("Account No.", '');
                                if GenJournalLine.Count() <= 1 then begin
                                    GenJournalLine.DeleteAll();
                                    GenJournalBatch.Delete();
                                end
                            end;
                until GenJournalBatch.Next() = 0;

            // Statistical
            if StatisticalAccJournalBatch.FindSet() then
                repeat
                    if StrPos(StatisticalAccJournalBatch.Name, PostingGroupCodeTxt) = 1 then
                        if not StatisticalBatchHasLines(StatisticalAccJournalBatch.Name) then begin
                            StatisticalAccJournalLine.SetRange("Journal Batch Name", StatisticalAccJournalBatch.Name);
                            if StatisticalAccJournalLine.Count() <= 1 then begin
                                StatisticalAccJournalLine.DeleteAll();
                                StatisticalAccJournalBatch.Delete();
                            end;
                        end;
                until StatisticalAccJournalBatch.Next() = 0;
        end;

        // Customer batches
        SkipPosting := GPCompanyAdditionalSettings.GetSkipPostingCustomerBatches();
        OnSkipPostingCustomerBatches(SkipPosting);
        if not SkipPosting then begin
            JournalBatchName := CustomerBatchNameTxt;
            if not GLBatchHasLines(GeneralTemplateNameTxt, JournalBatchName, GenJournalLine."Account Type"::Customer) then begin
                GenJournalLine.Reset();
                GenJournalLine.SetRange("Journal Template Name", GeneralTemplateNameTxt);
                GenJournalLine.SetRange("Journal Batch Name", JournalBatchName);
                GenJournalLine.SetRange("Account Type", GenJournalLine."Account Type"::Customer);
                GenJournalLine.SetRange("Account No.", '');
                if GenJournalLine.Count() <= 1 then begin
                    GenJournalLine.DeleteAll();
                    if GenJournalBatch.Get(GeneralTemplateNameTxt, JournalBatchName) then
                        GenJournalBatch.Delete();
                end;
            end;
        end;

        // Vendor batches
        SkipPosting := GPCompanyAdditionalSettings.GetSkipPostingVendorBatches();
        OnSkipPostingVendorBatches(SkipPosting);
        if not SkipPosting then begin
            JournalBatchName := VendorBatchNameTxt;
            if not GLBatchHasLines(GeneralTemplateNameTxt, JournalBatchName, GenJournalLine."Account Type"::Vendor) then begin
                GenJournalLine.Reset();
                GenJournalLine.SetRange("Journal Template Name", GeneralTemplateNameTxt);
                GenJournalLine.SetRange("Journal Batch Name", JournalBatchName);
                GenJournalLine.SetRange("Account Type", GenJournalLine."Account Type"::Vendor);
                GenJournalLine.SetRange("Account No.", '');
                if GenJournalLine.Count() <= 1 then begin
                    GenJournalLine.DeleteAll();
                    if GenJournalBatch.Get(GeneralTemplateNameTxt, JournalBatchName) then
                        GenJournalBatch.Delete();
                end;
            end;
        end;

        // Bank batches
        SkipPosting := GPCompanyAdditionalSettings.GetSkipPostingBankBatches();
        OnSkipPostingBankBatches(SkipPosting);
        if not SkipPosting then begin
            JournalBatchName := BankBatchNameTxt;
            if not GLBatchHasLines(GeneralTemplateNameTxt, JournalBatchName, GenJournalLine."Account Type"::"Bank Account") then begin
                GenJournalLine.Reset();
                GenJournalLine.SetRange("Journal Template Name", GeneralTemplateNameTxt);
                GenJournalLine.SetRange("Journal Batch Name", JournalBatchName);
                GenJournalLine.SetRange("Account Type", GenJournalLine."Account Type"::"Bank Account");
                if GenJournalLine.Count() <= 1 then begin
                    GenJournalLine.DeleteAll();
                    if GenJournalBatch.Get(GeneralTemplateNameTxt, JournalBatchName) then
                        GenJournalBatch.Delete();
                end;
            end;
        end;

        // Item batches
        SkipPosting := GPCompanyAdditionalSettings.GetSkipPostingItemBatches();
        OnSkipPostingItemBatches(SkipPosting);
        if not SkipPosting then
            if ItemJournalBatch.FindSet() then
                repeat
                    ItemJournalLine.SetRange("Journal Template Name", ItemJournalBatch."Journal Template Name");
                    ItemJournalLine.SetRange("Journal Batch Name", ItemJournalBatch.Name);
                    ItemJournalLine.SetFilter("Item No.", '<>%1', '');
                    if ItemJournalLine.IsEmpty() then
                        ItemJournalBatch.Delete();
                until ItemJournalBatch.Next() = 0;
    end;

    procedure SetGlobalDimensions(GlobalDim1: Code[20]; GlobalDim2: Code[20])
    var
        GLSetup: Record "General Ledger Setup";
    begin
        if not GLSetup.IsEmpty() then
            GLSetup.Get();

        CheckPluralization(GlobalDim1);
        CheckPluralization(GlobalDim2);

        if GlobalDim1 <> '' then begin
            GLSetup."Global Dimension 1 Code" := GlobalDim1;
            GLSetup."Shortcut Dimension 1 Code" := GlobalDim1;
        end;

        if GlobalDim2 <> '' then begin
            GLSetup."Global Dimension 2 Code" := GlobalDim2;
            GLSetup."Shortcut Dimension 2 Code" := GlobalDim2;
        end;

        if (GlobalDim1 <> '') or (GlobalDim2 <> '') then
            GLSetup.Modify();

        SetShorcutDimenions();
    end;

    procedure UpdateGlobalDimensionNo()
    var
        DimensionValue: Record "Dimension Value";
    begin
        if DimensionValue.FindSet() then
            repeat
                DimensionValue."Global Dimension No." := GetGlobalDimensionNo(DimensionValue."Dimension Code");
                DimensionValue.Modify();
            until DimensionValue.Next() = 0;
    end;

    procedure SetProcessesRunning(IsRunning: Boolean)
    var
        GPCompanyMigrationSettings: Record "GP Company Migration Settings";
    begin
        GPCompanyMigrationSettings.SetRange(Replicate, true);
        GPCompanyMigrationSettings.SetRange(Name, CompanyName());
        if GPCompanyMigrationSettings.FindFirst() then begin
            GPCompanyMigrationSettings.ProcessesAreRunning := IsRunning;
            GPCompanyMigrationSettings.Modify();
        end;
    end;

    local procedure CheckPluralization(var GlobalDim: Code[20])
    var
        Dim: Code[21];
    begin
        if GlobalDim in ['G/L ACCOUNT', 'BUSINESS UNIT', 'ITEM', 'LOCATION', 'PERIOD'] then begin
            Dim := GlobalDim + 'S';
            GlobalDim := CopyStr(Dim, 1, 20);
        end;
    end;

    local procedure SetShorcutDimenions()
    var
        GLSetup: Record "General Ledger Setup";
        GPSegments: Record "GP Segments";
        Modified: Boolean;
        i: Integer;
    begin
        i := 1;
        Modified := false;
        GLSetup.Get();
        if GPSegments.FindSet() then
            repeat
                if (GPSegments.Id <> GLSetup."Global Dimension 1 Code") and (GPSegments.Id <> GLSetup."Global Dimension 2 Code") then begin
                    case i of
                        1:
                            GLSetup."Shortcut Dimension 3 Code" := GPSegments.Id;
                        2:
                            GLSetup."Shortcut Dimension 4 Code" := GPSegments.Id;
                        3:
                            GLSetup."Shortcut Dimension 5 Code" := GPSegments.Id;
                        4:
                            GLSetup."Shortcut Dimension 6 Code" := GPSegments.Id;
                        5:
                            GLSetup."Shortcut Dimension 7 Code" := GPSegments.Id;
                        6:
                            GLSetup."Shortcut Dimension 8 Code" := GPSegments.Id;
                    end;
                    Modified := true;
                    i := i + 1;
                end;
            until GPSegments.Next() = 0;

        if Modified then
            GLSetup.Modify();
    end;

    local procedure GetGlobalDimensionNo(DimensionCode: Code[20]): Integer
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();
        case DimensionCode of
            GeneralLedgerSetup."Global Dimension 1 Code":
                exit(1);
            GeneralLedgerSetup."Global Dimension 2 Code":
                exit(2);
            GeneralLedgerSetup."Shortcut Dimension 3 Code":
                exit(3);
            GeneralLedgerSetup."Shortcut Dimension 4 Code":
                exit(4);
            GeneralLedgerSetup."Shortcut Dimension 5 Code":
                exit(5);
            GeneralLedgerSetup."Shortcut Dimension 6 Code":
                exit(6);
            GeneralLedgerSetup."Shortcut Dimension 7 Code":
                exit(7);
            GeneralLedgerSetup."Shortcut Dimension 8 Code":
                exit(8);
            else
                exit(0);
        end;
    end;

    local procedure CreateDimensionsImp()
    var
        GPSegments: Record "GP Segments";
        Dimension: Record Dimension;
        DataMigrationErrorLogging: Codeunit "Data Migration Error Logging";
        DimCode: Code[20];
    begin
        if GPSegments.FindSet() then begin
            repeat
                DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(GPSegments.RecordId()));
                DimCode := CheckDimensionName(GPSegments.Id);
                if not Dimension.Get(DimCode) then begin
                    Dimension.Init();
                    Dimension.Validate(Code, DimCode);
                    Dimension.Validate(Name, GPSegments.Name);
                    Dimension.Validate("Code Caption", GPSegments.CodeCaption);
                    Dimension.Validate("Filter Caption", GPSegments.FilterCaption);
                    Dimension.Insert(true);
                end;
            until GPSegments.Next() = 0;

            CreateDimensionValues();
        end;

        Session.LogMessage('0000BBF', 'Created Dimensions', Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', GetTelemetryCategory());
        SetDimentionsCreated();
    end;

    local procedure CreatePaymentTermsImp()
    var
        GPPaymentTerms: Record "GP Payment Terms";
        PaymentTerms: Record "Payment Terms";
        GPMigrationWarnings: Record "GP Migration Warnings";
        DataMigrationErrorLogging: Codeunit "Data Migration Error Logging";
        DueDateCalculation: DateFormula;
        DiscountDateCalculation: DateFormula;
        SeedValue: integer;
        PaymentTerm: Text[10];
        DueDateCalculationText: Text[50];
        DiscountDateCalculationText: Text[50];
        LogMigrationArea: Text[50];
        IsPaymentTermHandled: Boolean;
    begin
        LogMigrationArea := 'Payment Terms';
        SeedValue := 0;
        if GPPaymentTerms.FindSet() then begin
            repeat
                DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(GPPaymentTerms.RecordId()));
                IsPaymentTermHandled := false;
                OnHandlePaymentTerm(GPPaymentTerms, IsPaymentTermHandled);
                if not IsPaymentTermHandled then begin
                    if StrLen(DelChr(GPPaymentTerms.PYMTRMID, '>', ' ')) > 10 then begin
                        PaymentTerm := GeneratePaymentTerm(SeedValue, GPPaymentTerms.PYMTRMID);
                        PaymentTerms.Validate(Code, PaymentTerm);
                        SeedValue := SeedValue + 1;
                    end else
                        PaymentTerm := CopyStr(DelChr(GPPaymentTerms.PYMTRMID, '>', ' '), 1, 10);

                    if not PaymentTerms.Get(PaymentTerm) then begin
                        PaymentTerms.Init();
                        PaymentTerms.Validate(Code, PaymentTerm);
                        PaymentTerms.Validate(Description, DelChr(GPPaymentTerms.PYMTRMID, '>', ' '));
                        PaymentTerms.Validate("Discount %", (GPPaymentTerms.DSCPCTAM / 100));

                        DiscountDateCalculationText := CalculateDiscountDateFormula(GPPaymentTerms);
                        Evaluate(DiscountDateCalculation, DiscountDateCalculationText);
                        PaymentTerms.Validate("Discount Date Calculation", DiscountDateCalculation);

                        if GPPaymentTerms.CalculateDateFrom = GPPaymentTerms.CalculateDateFrom::"Transaction Date" then
                            DueDateCalculationText := CalculateDueDateFormula(GPPaymentTerms, false, '')
                        else
                            DueDateCalculationText := CalculateDueDateFormula(GPPaymentTerms, true, copystr(DiscountDateCalculationText, 1, 32));

                        Evaluate(DueDateCalculation, DueDateCalculationText);
                        PaymentTerms.Validate("Due Date Calculation", DueDateCalculation);

                        PaymentTerms.Insert(true);

                        GPPaymentTerms.PYMTRMID_New := PaymentTerm;
                        GPPaymentTerms.Modify();
                    end;
                end else
                    GPMigrationWarnings.InsertWarning(LogMigrationArea, PaymentTerm, 'Payment Term ' + GPPaymentTerms.PYMTRMID + ' was handled.');
            until GPPaymentTerms.Next() = 0;

            SeedValue := 0;
            // At this point, update the historical tables with the "corrected" Payment Term ID
            UpdatePaymentTerms();
        end;

        Session.LogMessage('0000BBG', 'Created Payment Terms', Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', GetTelemetryCategory());
        SetPaymentTermsCreated();
    end;

    local procedure CreateLocationsImp()
    var
        GPItemLocation: Record "GP Item Location";
        Location: Record Location;
        DataMigrationErrorLogging: Codeunit "Data Migration Error Logging";
    begin
        if GPItemLocation.FindSet() then
            repeat
                DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(GPItemLocation.RecordId()));
                Location.Init();
                Location.Code := Text.CopyStr(GPItemLocation.LOCNCODE, 1, 10);
                Location.Name := GPItemLocation.LOCNDSCR;
                Location.Address := GPItemLocation.ADDRESS1;
                Location."Address 2" := Text.CopyStr(GPItemLocation.ADDRESS2, 1, 50);
                Location.City := Text.CopyStr(GPItemLocation.CITY, 1, 30);
                Location."Phone No." := GPItemLocation.PHONE1;
                Location."Phone No. 2" := GPItemLocation.PHONE2;
                Location."Fax No." := GPItemLocation.FAXNUMBR;
                Location."Post Code" := GPItemLocation.ZIPCODE;
                Location.Insert(true);
            until GPItemLocation.Next() = 0;

        Session.LogMessage('0000BK6', 'Created Locations', Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', GetTelemetryCategory());
        SetLocationsCreated();
    end;

    local procedure CreateItemTrackingCodesImp()
    var
        ItemTrackingCode: Record "Item Tracking Code";
    begin
        ItemTrackingCode.Init();
        ItemTrackingCode.Code := 'LOT';
        ItemTrackingCode.Description := 'LOT NUMBERS';
        ItemTrackingCode."Lot Specific Tracking" := true;
        ItemTrackingCode."Lot Purchase Inbound Tracking" := true;
        ItemTrackingCode."Lot Purchase Outbound Tracking" := true;
        ItemTrackingCode."Lot Sales Inbound Tracking" := true;
        ItemTrackingCode."Lot Sales Outbound Tracking" := true;
        ItemTrackingCode."Lot Pos. Adjmt. Inb. Tracking" := true;
        ItemTrackingCode."Lot Pos. Adjmt. Outb. Tracking" := true;
        ItemTrackingCode."Lot Neg. Adjmt. Inb. Tracking" := true;
        ItemTrackingCode."Lot Neg. Adjmt. Outb. Tracking" := true;
        ItemTrackingCode."Lot Transfer Tracking" := true;
        ItemTrackingCode."Lot Manuf. Inbound Tracking" := true;
        ItemTrackingCode."Lot Manuf. Outbound Tracking" := true;
        ItemTrackingCode."Lot Assembly Inbound Tracking" := true;
        ItemTrackingCode."Lot Assembly Outbound Tracking" := true;
        ItemTrackingCode.Insert(true);

        ItemTrackingCode.Init();
        ItemTrackingCode.Code := 'SERIAL';
        ItemTrackingCode.Description := 'SERIAL NUMBERS';
        ItemTrackingCode."SN Specific Tracking" := true;
        ItemTrackingCode."SN Purchase Inbound Tracking" := true;
        ItemTrackingCode."SN Purchase Outbound Tracking" := true;
        ItemTrackingCode."SN Sales Inbound Tracking" := true;
        ItemTrackingCode."SN Sales Outbound Tracking" := true;
        ItemTrackingCode."SN Pos. Adjmt. Inb. Tracking" := true;
        ItemTrackingCode."SN Pos. Adjmt. Outb. Tracking" := true;
        ItemTrackingCode."SN Neg. Adjmt. Inb. Tracking" := true;
        ItemTrackingCode."SN Neg. Adjmt. Outb. Tracking" := true;
        ItemTrackingCode."SN Transfer Tracking" := true;
        ItemTrackingCode."SN Manuf. Inbound Tracking" := true;
        ItemTrackingCode."SN Manuf. Outbound Tracking" := true;
        ItemTrackingCode."SN Assembly Inbound Tracking" := true;
        ItemTrackingCode."SN Assembly Outbound Tracking" := true;
        ItemTrackingCode.Insert(true);

        SetItemTrackingCodesCreated();
    end;

    local procedure CreateCheckBooksImp()
    var
        GPCheckbookMigrator: Codeunit "GP Checkbook Migrator";
    begin
        GPCheckbookMigrator.MoveCheckbookStagingData();
        Session.LogMessage('0000CAB', 'Created Checkbooks', Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', GetTelemetryCategory());
        SetCheckBooksCreated();
    end;

    local procedure CreateOpenPOsImp()
    var
        GPPOMigrator: Codeunit "GP PO Migrator";
    begin
        GPPOMigrator.MigratePOStagingData();
        Session.LogMessage('0000CQP', 'Created Open Purchase Orders', Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', GetTelemetryCategory());
        SetOpenPurchaseOrdersCreated();
    end;

    local procedure CreateFiscalPeriodsImp()
    var
        FiscalPeriods: Codeunit FiscalPeriods;
    begin
        FiscalPeriods.MoveStagingData();
        Session.LogMessage('0000HRB', 'Created Fiscal Periods', Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', GetTelemetryCategory());
        SetOpenFiscalPeriodsCreated();
    end;

    local procedure CreateVendorEFTBankAccountsImp()
    var
        GPVendorMigrator: CodeUnit "GP Vendor Migrator";
    begin
        GPVendorMigrator.MigrateVendorEFTBankAccounts();
        Session.LogMessage('0000HRC', 'Created EFT Bank Accounts', Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', GetTelemetryCategory());
        SetVendorEFTBankAccountsCreated();
    end;

    local procedure CreateVendorClassesImp()
    begin
        SetVendorClassesCreated();
    end;

    local procedure CreateCustomerClassesImp()
    begin
        SetCustomerClassesCreated();
    end;

    local procedure SetDimentionsCreated()
    begin
        GPConfiguration.GetSingleInstance();
        GPConfiguration."Dimensions Created" := true;
        GPConfiguration.Modify();
    end;

    local procedure SetPaymentTermsCreated()
    begin
        GPConfiguration.GetSingleInstance();
        GPConfiguration."Payment Terms Created" := true;
        GPConfiguration.Modify();
    end;

    local procedure SetItemTrackingCodesCreated()
    begin
        GPConfiguration.GetSingleInstance();
        GPConfiguration."Item Tracking Codes Created" := true;
        GPConfiguration.Modify();
    end;

    local procedure SetLocationsCreated()
    begin
        GPConfiguration.GetSingleInstance();
        GPConfiguration."Locations Created" := true;
        GPConfiguration.Modify();
    end;

    local procedure SetCheckBooksCreated()
    begin
        GPConfiguration.GetSingleInstance();
        GPConfiguration."CheckBooks Created" := true;
        GPConfiguration.Modify();
    end;

    local procedure SetOpenPurchaseOrdersCreated()
    begin
        GPConfiguration.GetSingleInstance();
        GPConfiguration."Open Purchase Orders Created" := true;
        GPConfiguration.Modify();
    end;

    local procedure SetOpenFiscalPeriodsCreated()
    begin
        GPConfiguration.GetSingleInstance();
        GPConfiguration."Fiscal Periods Created" := true;
        GPConfiguration.Modify();
    end;

    local procedure SetVendorEFTBankAccountsCreated()
    begin
        GPConfiguration.GetSingleInstance();
        GPConfiguration."Vendor EFT Bank Acc. Created" := true;
        GPConfiguration.Modify();
    end;

    local procedure SetVendorClassesCreated()
    begin
        GPConfiguration.GetSingleInstance();
        GPConfiguration."Vendor Classes Created" := true;
        GPConfiguration.Modify();
    end;

    local procedure SetCustomerClassesCreated()
    begin
        GPConfiguration.GetSingleInstance();
        GPConfiguration."Customer Classes Created" := true;
        GPConfiguration.Modify();
    end;

    local procedure DimensionsCreated(): Boolean
    begin
        GPConfiguration.GetSingleInstance();
        exit(GPConfiguration."Dimensions Created");
    end;

    local procedure PaymentTermsCreated(): Boolean
    begin
        GPConfiguration.GetSingleInstance();
        exit(GPConfiguration."Payment Terms Created");
    end;

    local procedure ItemTrackingCodesCreated(): Boolean
    begin
        GPConfiguration.GetSingleInstance();
        exit(GPConfiguration."Item Tracking Codes Created");
    end;

    procedure LocationsCreated(): Boolean
    begin
        GPConfiguration.GetSingleInstance();
        exit(GPConfiguration."Locations Created");
    end;

    local procedure CheckBooksCreated(): Boolean
    begin
        GPConfiguration.GetSingleInstance();
        exit(GPConfiguration."CheckBooks Created");
    end;

    local procedure OpenPurchaseOrdersCreated(): Boolean
    begin
        GPConfiguration.GetSingleInstance();
        exit(GPConfiguration."Open Purchase Orders Created");
    end;

    local procedure FiscalPeriodsCreated(): Boolean
    begin
        GPConfiguration.GetSingleInstance();
        exit(GPConfiguration."Fiscal Periods Created");
    end;

    local procedure VendorEFTBankAccountsCreated(): Boolean
    begin
        GPConfiguration.GetSingleInstance();
        exit(GPConfiguration."Vendor EFT Bank Acc. Created");
    end;

    local procedure VendorClassesCreated(): Boolean
    begin
        GPConfiguration.GetSingleInstance();
        exit(GPConfiguration."Vendor Classes Created");
    end;

    local procedure CustomerClassesCreated(): Boolean
    begin
        GPConfiguration.GetSingleInstance();
        exit(GPConfiguration."Customer Classes Created");
    end;

#if not CLEAN24
    [Obsolete('Cleaning up tables before running the migration is no longer wanted.', '24.0')]
    procedure PreMigrationCleanupCompleted(): Boolean
    begin
        GPConfiguration.GetSingleInstance();
#pragma warning disable AL0432        
        exit(GPConfiguration."PreMigration Cleanup Completed");
#pragma warning restore AL0432
    end;
#endif

    procedure GetLastError()
    begin
        GPConfiguration.GetSingleInstance();
        GPConfiguration."Last Error Message" := CopyStr(GetLastErrorText(), 1, 250);
        GPConfiguration.Modify();
    end;

    procedure CreatePreMigrationData(): Boolean
    var
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
    begin
        CreateDimensions();
        if not DimensionsCreated() then
            exit(false);

        CreatePaymentTerms();
        if not PaymentTermsCreated() then
            exit(false);

        if GPCompanyAdditionalSettings.GetInventoryModuleEnabled() then begin
            CreateItemTrackingCodes();
            if not ItemTrackingCodesCreated() then
                exit(false);

            CreateLocations();
            if not LocationsCreated() then
                exit(false);
        end;

        exit(true)
    end;

    procedure CreatePostMigrationData(): Boolean
    var
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
    begin
        // this procedure might run multiple times depending upon migration errors.

        if GPCompanyAdditionalSettings.GetGLModuleEnabled() then
            if not FiscalPeriodsCreated() then
                CreateFiscalPeriods();

        if GPCompanyAdditionalSettings.GetBankModuleEnabled() then
            if not CheckBooksCreated() then
                CreateCheckbooks();

        if GPCompanyAdditionalSettings.GetMigrateOpenPOs() then
            if not OpenPurchaseOrdersCreated() then
                CreateOpenPOs();

        if GPCompanyAdditionalSettings.GetPayablesModuleEnabled() then
            if not VendorEFTBankAccountsCreated() then
                CreateVendorEFTBankAccounts();

        if GPCompanyAdditionalSettings.GetMigrateVendorClasses() then
            if not VendorClassesCreated() then
                CreateVendorClasses();

        if GPCompanyAdditionalSettings.GetMigrateCustomerClasses() then
            if not CustomerClassesCreated() then
                CreateCustomerClasses();

        if GPCompanyAdditionalSettings.GetMigrateKitItems() then
            CreateKitItems();

        exit(GPConfiguration.IsAllPostMigrationDataCreated());
    end;

    procedure CheckMigrationStatus()
    begin
        GPConfiguration.GetSingleInstance();

        if not GPConfiguration."Dimensions Created" then
            CreateDataMigrationErrorRecord('Dimensions not created.');
        if not GPConfiguration."CheckBooks Created" then
            CreateDataMigrationErrorRecord('CheckBooks not created');
        if not GPConfiguration."Payment Terms Created" then
            CreateDataMigrationErrorRecord('Payment Terms not created');
        if not GPConfiguration."Item Tracking Codes Created" then
            CreateDataMigrationErrorRecord('Item Tracking Codes not created');
        if not GPConfiguration."Locations Created" then
            CreateDataMigrationErrorRecord('Locations not created.');
    end;

    local procedure CreateDataMigrationErrorRecord(ErrorMessage: Text[250])
    var
        DataMigrationError: Record "Data Migration Error";
    begin
        DataMigrationError.Init();
        DataMigrationError."Migration Type" := MigrationTypeTxt;
        DataMigrationError."Scheduled For Retry" := false;
        DataMigrationError."Error Message" := ErrorMessage;
        DataMigrationError.Insert();
    end;

    procedure CleanGPPhoneOrFaxNumber(InValue: Text[30]) OutValue: Text[21]
    begin
        OutValue := CopyStr(InValue, 1, 21);

        if (CopyStr(InValue, 1, 14) = '00000000000000') then
            OutValue := '';

        exit(OutValue);
    end;

    procedure ContainsAlphaChars(InValue: Text[30]): Boolean
    var
        NextChar: Char;
        I: Integer;
    begin
        for I := 1 to StrLen(InValue) do begin
            NextChar := InValue[I];
            if ((NextChar >= 65) and (NextChar <= 90)) or       // A-Z
                ((NextChar >= 97) and (NextChar <= 122)) then   // a-z
                exit(true);
        end;

        exit(false);
    end;

    procedure GetGPAccountNumberByIndex(GPAccountIndex: Integer): Code[20]
    var
        GPAccount: Record "GP Account";
    begin
        if (GPAccountIndex > 0) then
            if GPAccount.Get(GPAccountIndex) then
                exit(CopyStr(GPAccount.AcctNum.Trim(), 1, 20));

        exit('');
    end;

    procedure EnsureAccountHasGenProdPostingAccount(AccountNumber: Code[20])
    var
        GLAccount: Record "G/L Account";
    begin
        if GLAccount.Get(AccountNumber) then
            // Ensure the GLAccount has a Gen. Prod. Posting Group.
            if GLAccount."Gen. Prod. Posting Group" = '' then begin
                GLAccount."Gen. Prod. Posting Group" := PostingGroupCodeTxt;
                GLAccount.Modify(true);
            end;
    end;

    procedure CreateCurrencyIfNeeded(CurrencyCode: Code[10])
    var
        Currency: Record Currency;
        GPMC40200: Record "GP MC40200";
    begin
        if CurrencyCode = '' then
            exit;

        if not GPMC40200.Get(CurrencyCode) then
            exit;

        if Currency.Get(CurrencyCode) then
            exit;

        Currency.Validate("Symbol", GPMC40200.CRNCYSYM);
        Currency.Validate("Code", CurrencyCode);
        Currency.Validate("Description", CopyStr(GPMC40200.CRNCYDSC, 1, 30));
        Currency.Validate("Invoice Rounding Type", Currency."Invoice Rounding Type"::Nearest);
        Currency.Insert(true);
    end;

    procedure StringEqualsCaseInsensitive(Text1: Text; Text2: Text): Boolean
    begin
        exit(UpperCase(Text1) = UpperCase(Text2));
    end;

    internal procedure CheckAndLogErrors()
    var
        LastError: Text;
    begin
        LastError := GetLastErrorText(false);
        if LastError = '' then
            exit;

        LogError(LastError);
        Commit();
    end;

    local procedure LogError(LastErrorMessage: Text)
    var
        ExistingDataMigrationError: Record "Data Migration Error";
        DataMigrationError: Record "Data Migration Error";
        DataMigrationErrorLogging: Codeunit "Data Migration Error Logging";
    begin
        if LastErrorMessage = '' then
            exit;

        if ExistingDataMigrationError.FindLast() then;
        DataMigrationError.Id := ExistingDataMigrationError.Id + 1;
        DataMigrationError.Insert();
        DataMigrationError."Last Record Under Processing" := CopyStr(DataMigrationErrorLogging.GetLastRecordUnderProcessing(), 1, MaxStrLen(DataMigrationError."Last Record Under Processing"));
        DataMigrationError.SetLastRecordUnderProcessingLog(DataMigrationErrorLogging.GetFullListOfLastRecordsUnderProcessingAsText());

        DataMigrationError."Error Message" := CopyStr(LastErrorMessage, 1, MaxStrLen(DataMigrationError."Error Message"));
        DataMigrationError."Migration Type" := GetMigrationTypeTxt();

        DataMigrationError.SetFullExceptionMessage(GetLastErrorText());
        DataMigrationError.SetExceptionCallStack(GetLastErrorCallStack());

        DataMigrationErrorLogging.ClearLastRecordUnderProcessing();
    end;

    internal procedure ShouldMigrateItem(ItemNo: Text): Boolean
    var
        GPIV00101: Record "GP IV00101";
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
    begin
        if GPIV00101.Get(ItemNo) then begin
            if not GPCompanyAdditionalSettings.GetMigrateKitItems() then
                if GPIV00101.ITEMTYPE = 3 then
                    exit(false);

            if GPIV00101.INACTIVE then
                if not GPCompanyAdditionalSettings.GetMigrateInactiveItems() then
                    exit(false);

            if GPIV00101.IsDiscontinued() then
                if not GPCompanyAdditionalSettings.GetMigrateDiscontinuedItems() then
                    exit(false);
        end;

        exit(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSkipPostingGLAccounts(var SkipPosting: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSkipPostingAccountBatches(var SkipPosting: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSkipPostingCustomerBatches(var SkipPosting: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSkipPostingVendorBatches(var SkipPosting: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSkipPostingBankBatches(var SkipPosting: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSkipPostingItemBatches(var SkipPosting: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnHandlePaymentTerm(GPPaymentTerms: Record "GP Payment Terms"; var IsPaymentTermHandled: Boolean)
    begin
    end;
}