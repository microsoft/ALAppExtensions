Codeunit 4037 "Helper Functions"
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
                    tabledata "Accounting Period" = rimd;

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

#if not CLEAN21
    [Obsolete('Method is not supported, it was using files', '21.0')]
    procedure GetEntities(EntityName: Text; var JArray: JsonArray): Boolean
    begin
        exit(false);
    end;

    [Obsolete('Method is not supported, it was using files', '21.0')]
    procedure GetEntitiesAsJToken(EntityName: Text; var JToken: JsonToken): Boolean
    begin
        exit(false);
    end;

    [Obsolete('Method is not supported, it was using files', '21.0')]
    procedure GetObjectCount(EntityName: Text; var ObjectCount: Integer)
    begin
    end;
#endif

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

    procedure CleanupGenJournalBatches()
    var
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        GenJournalBatch.Reset();
        GenJournalBatch.SetRange("Journal Template Name", GeneralTemplateNameTxt);
        GenJournalBatch.SetFilter(Name, PostingGroupCodeTxt + '*');
        if GenJournalBatch.FindSet() then
            repeat
                GenJournalBatch.Delete(true);
            until GenJournalBatch.Next() = 0;

        if ValidateCountry('GB') then begin
            GenJournalBatch.Reset();
            GenJournalBatch.SetFilter(Name, '= CASH');
            GenJournalBatch.SetFilter("No. Series", '= GJNL-PMT');
            if GenJournalBatch.FindFirst() then begin
                GenJournalBatch."No. Series" := '';
                GenJournalBatch.Modify(true);
                Commit();
            end;
        end;
    end;

    procedure CleanupVatPostingSetup()
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        if ValidateCountry('GB') then
            if VATPostingSetup.FindSet(true, false) then begin
                repeat
                    VATPostingSetup."Sales VAT Account" := '';
                    VATPostingSetup."Purchase VAT Account" := '';
                    VATPostingSetup."Reverse Chrg. VAT Acc." := '';
                    VATPostingSetup.Modify(TRUE);
                until VATPostingSetup.Next() = 0;
                Commit();
            end;
    end;

    local procedure ValidateCountry(CountryCode: Code[10]): Boolean
    var
        ApplicationSystemConstants: Codeunit "Application System Constants";
    begin
        if StrPos(ApplicationSystemConstants.ApplicationVersion(), CountryCode) = 1 then
            exit(true);

        exit(false);
    end;

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

    local procedure CalculateDueDateFormula(GPPaymentTerms: Record "GP Payment Terms"; Use_Discount_Calc: Boolean; Discount_Calc: Text[32]): Text[50]
    var
        working_number: integer;
        extra_month: integer;
        extra_year: integer;
        working_string: Text[20];
        working_discount_calc: Text[50];
        final_string: Text[50];
    begin
        // BC Only supports GPPaymentTerms.CalculateDateFrom = Transaction Date
        // Set date formula to a string '<1M>'
        working_number := GPPaymentTerms.CalculateDateFromDays;  // Always add this many days to the due date.

        if Use_Discount_Calc and (Discount_Calc <> '') then
            // Need to get the date formula text minus the brackets...
            working_discount_calc := copystr(copystr(Discount_Calc, 2, (strlen(Discount_Calc) - 2)), 1, 50)
        else
            // In case use discount is true, but the passed-in formula string is empty
            Use_Discount_Calc := false;

        // Add base days + discount days
        if GPPaymentTerms.DUETYPE = GPPaymentTerms.DUETYPE::"Net Days" then
            if GPPaymentTerms.DUEDTDS > 0 then begin
                working_number := working_number + GPPaymentTerms.DUEDTDS;
                working_string := '<' + format(working_number) + 'D>';
            END;

        // Get the first day of the current month, then add appropriate days.
        // Need to remove one day since setting the date should fall on that number chosen, whereas the formula will add to the first of the month,
        // giving you one extra day we need to remove.
        if GPPaymentTerms.DUETYPE = GPPaymentTerms.DUETYPE::Date then
            if GPPaymentTerms.DUEDTDS > 0 then
                working_string := '<D' + format(GPPaymentTerms.DUEDTDS) + '>';

        // Go to the end of the current month, then add appropriate days
        if GPPaymentTerms.DUETYPE = GPPaymentTerms.DUETYPE::EOM then begin
            if GPPaymentTerms.DUEDTDS > 0 then
                working_number := working_number + GPPaymentTerms.DUEDTDS;
            if working_number > 0 then
                working_string := '<CM+' + format(working_number) + 'D>'
            ELSE
                working_string := '<CM>';
        end;

        // Just add the number of initial days to the current date
        if GPPaymentTerms.DUETYPE = GPPaymentTerms.DUETYPE::None then
            working_string := '<' + format(working_number) + 'D>';

        // Set the day of the next month
        // Need to remove one day, see the comments above for DUETYPE::Date
        if GPPaymentTerms.DUETYPE = GPPaymentTerms.DUETYPE::"Next Month" then begin
            if GPPaymentTerms.DUEDTDS > 0 then
                working_number := GPPaymentTerms.DUEDTDS;
            // First day of current month, + 1 month + the number of days
            working_string := '<-CM+1M+' + format(working_number - 1) + 'D>';
        end;

        if GPPaymentTerms.DUETYPE = GPPaymentTerms.DUETYPE::Months then begin
            if GPPaymentTerms.DUEDTDS > 0 then
                extra_month := GPPaymentTerms.DUEDTDS;
            // Add the extra months, then the extra days
            working_string := '<' + format(extra_month) + 'M+' + format(working_number) + 'D>';
        end;

        if GPPaymentTerms.DUETYPE = GPPaymentTerms.DUETYPE::"Month/Day" then
            working_string := '<M' + format(GPPaymentTerms.DueMonth) + '+D' + format(GPPaymentTerms.DUEDTDS) + '>';

        if GPPaymentTerms.DUETYPE = GPPaymentTerms.DUETYPE::Annual then begin
            if GPPaymentTerms.DUEDTDS > 0 then
                extra_year := GPPaymentTerms.DUEDTDS;
            // Add the extra months, then the extra days
            working_string := '<' + format(extra_year) + 'Y+' + format(working_number) + 'D>'
        end;

        if Use_Discount_Calc then begin
            final_string := copystr('<' + working_discount_calc, 1, 50);
            if (copystr(working_string, 2, 1) = '-') or (copystr(working_string, 2, 1) = '+') then
                final_string := final_string + copystr(working_string, 2)
            else
                if working_string <> '' then
                    final_string += '+' + copystr(working_string, 2)
                else
                    final_string += '>';
            exit(final_string);
        end else
            exit(working_string);
        // Back in the calling proc, EVALUATE(variable,forumlastring) will set the variable to the correct formula
    end;

    local procedure CalculateDiscountDateFormula(GPPaymentTerms: Record "GP Payment Terms"): Text[50]
    var
        working_number: integer;
        extra_month: integer;
        extra_year: integer;
        working_string: Text[20];
    begin
        // Set date formula to a string '<1M>'
        working_number := GPPaymentTerms.CalculateDateFromDays;  // Always add this many days to the due date.

        // Add base days + discount days
        if GPPaymentTerms.DISCTYPE = GPPaymentTerms.DISCTYPE::Days then
            if GPPaymentTerms.DISCDTDS > 0 then begin
                working_number := working_number + GPPaymentTerms.DISCDTDS;
                working_string := '<' + format(working_number) + 'D>';
            END;

        // Get the first day of the current month, then add appropriate days.
        // Need to remove one day since setting the date should fall on that number chosen, whereas the formula will add to the first of the month,
        // giving you one extra day we need to remove.
        if GPPaymentTerms.DISCTYPE = GPPaymentTerms.DISCTYPE::Date then
            if GPPaymentTerms.DISCDTDS > 0 then
                working_string := '<D' + format(GPPaymentTerms.DISCDTDS) + '>';

        // Go to the end of the current month, then add appropriate days
        if GPPaymentTerms.DISCTYPE = GPPaymentTerms.DISCTYPE::EOM then begin
            if GPPaymentTerms.DISCDTDS > 0 then
                working_number := working_number + GPPaymentTerms.DISCDTDS;
            if working_number > 0 then
                working_string := '<CM+' + format(working_number) + 'D>'
            else
                working_string := '<CM>';
        end;

        // Just add the number of initial days to the current date
        if GPPaymentTerms.DISCTYPE = GPPaymentTerms.DISCTYPE::None then
            working_string := '<+' + format(working_number) + 'D>';

        // Set the day of the next month
        // Need to remove one day, see the comments above for DISCTYPE::Date
        if GPPaymentTerms.DISCTYPE = GPPaymentTerms.DISCTYPE::"Next Month" then begin
            if GPPaymentTerms.DISCDTDS > 0 then
                working_number := GPPaymentTerms.DISCDTDS;
            // First day of current month, + 1 month + the number of days
            working_string := '<-CM+1M+' + format(working_number - 1) + 'D>;'
        end;

        if GPPaymentTerms.DISCTYPE = GPPaymentTerms.DISCTYPE::Months then begin
            if GPPaymentTerms.DISCDTDS > 0 then
                extra_month := GPPaymentTerms.DISCDTDS;
            // Add the extra months, then the extra days
            working_string := '<' + format(extra_month) + 'M+' + format(working_number) + 'D>;'
        end;

        if GPPaymentTerms.DISCTYPE = GPPaymentTerms.DISCTYPE::"Month/Day" then
            working_string := '<M' + format(GPPaymentTerms.DiscountMonth) + '+D' + format(GPPaymentTerms.DISCDTDS) + '>';

        if GPPaymentTerms.DISCTYPE = GPPaymentTerms.DISCTYPE::Annual then begin
            if GPPaymentTerms.DISCDTDS > 0 then
                extra_year := GPPaymentTerms.DISCDTDS;
            // Add the extra months, then the extra days
            working_string := '<' + format(extra_year) + 'Y+' + format(working_number) + 'D>;'
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
        PaymentTerm: Text[22];
        PaymentTerm_New: Text[10];
    begin
        if not GPPaymentTerms.FindSet() then
            exit;

        repeat
            PaymentTerm := DELCHR(GPPaymentTerms.PYMTRMID, '>', ' ');
            PaymentTerm_New := DELCHR(GPPaymentTerms.PYMTRMID_New, '>', ' ');
            // if the "old" and "new" payment terms are the same, skip
            if PaymentTerm <> PaymentTerm_New THEN begin
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

#if not CLEAN21
    [Obsolete('Method is not supported, it was using files', '21.0')]
    procedure GetDimensionInfo()
    begin
    end;
#endif

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


    procedure Cleanup();
    var
        GPGLTransactions: Record "GP GLTransactions";
        GPAccount: Record "GP Account";
        GPCustomer: Record "GP Customer";
        GPCustomerAddress: Record "GP Customer Address";
        GPCustomerTransactions: Record "GP Customer Transactions";
        GPItem: Record "GP Item";
        GPItemLocation: Record "GP Item Location";
        GPVendor: Record "GP Vendor";
        GPVendorAddress: Record "GP Vendor Address";
        GPVendorTransactions: Record "GP Vendor Transactions";
        GPCodes: Record "GP Codes";
        GPPostingAccounts: Record "GP Posting Accounts";
        GPSegments: Record "GP Segments";
        GPFiscalPeriods: Record "GP Fiscal Periods";
        GPPaymentTerms: Record "GP Payment Terms";
        GPBankMSTR: Record "GP Bank MSTR";
        GPCheckbookMSTR: Record "GP Checkbook MSTR";
        GPCheckbookTransactions: Record "GP Checkbook Transactions";
        GPSY40100: Record "GP SY40100";
        GPSY40101: Record "GP SY40101";
        GPSY06000: Record "GP SY06000";
        GPMC40200: Record "GP MC40200";
        GPPM00100: Record "GP PM00100";
        GPPM00200: Record "GP PM00200";
        GPRM00101: Record "GP RM00101";
        GPRM00201: Record "GP RM00201";
        GPIV00101: Record "GP IV00101";
        GPIV40400: Record "GP IV40400";
    begin
        GPAccount.DeleteAll();
        GPGLTransactions.DeleteAll();

        GPCustomer.DeleteAll();
        GPCustomerAddress.DeleteAll();
        GPCustomerTransactions.DeleteAll();

        GPItem.DeleteAll();
        GPItemLocation.DeleteAll();

        GPVendor.DeleteAll();
        GPVendorAddress.DeleteAll();
        GPVendorTransactions.DeleteAll();

        GPCodes.DeleteAll();
        GPPostingAccounts.DeleteAll();
        GPSegments.DeleteAll();
        GPFiscalPeriods.DeleteAll();
        GPPaymentTerms.DeleteAll();

        GPBankMSTR.DeleteAll();
        GPCheckbookMSTR.DeleteAll();
        GPCheckbookTransactions.DeleteAll();

        GPSY40100.DeleteAll();
        GPSY40101.DeleteAll();

        GPSY06000.DeleteAll();
        GPMC40200.DeleteAll();

        GPPM00100.DeleteAll();
        GPPM00200.DeleteAll();

        GPRM00101.DeleteAll();
        GPRM00201.DeleteAll();

        GPIV00101.DeleteAll();
        GPIV40400.DeleteAll();

        Session.LogMessage('00007GH', 'Cleaned up staging tables.', Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', GetTelemetryCategory());
    end;

    procedure CleanupBeforeSynchronization();
    var
        GLAccount: Record "G/L Account";
        GLEntry: Record "G/L Entry";
        Customer: Record Customer;
        CustLedgerEntry: Record "Cust. Ledger Entry";
        Dimension: Record Dimension;
        DimensionValue: Record "Dimension Value";
        DimensionSetEntry: Record "Dimension Set Entry";
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        Vendor: Record Vendor;
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
        DataMigrationStatus: Record "Data Migration Status";
        Item: Record Item;
        ItemLedgerEntry: Record "Item Ledger Entry";
        AvgCostAdjmtEntryPoint: Record "Avg. Cost Adjmt. Entry Point";
        ValueEntry: Record "Value Entry";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        PaymentTerms: Record "Payment Terms";
        PaymentTermTranslation: Record "Payment Term Translation";
        DataMigrationEntity: Record "Data Migration Entity";
        ItemTrackingCode: Record "Item Tracking Code";
        GenJournalLine: Record "Gen. Journal Line";
        GLItemLedgerRelation: Record "G/L - Item Ledger Relation";
        GLRegister: Record "G/L Register";
        Location: Record Location;
        TrackingSpecification: Record "Tracking Specification";
        ReservationEntry: Record "Reservation Entry";
        ItemJournalLine: Record "Item Journal Line";
        PostValueEntryToGL: Record "Post Value Entry to G/L";
        BankAccount: Record "Bank Account";
        BankAccountPostingGroup: Record "Bank Account Posting Group";
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        OverReceiptCode: Record "Over-Receipt Code";
        AccountingPeriod: Record "Accounting Period";
    begin
        GPConfiguration.DeleteAll();
        GLEntry.DeleteAll(true);
        GLRegister.DeleteAll(true);
        CustLedgerEntry.DeleteAll(true);
        DetailedCustLedgEntry.DeleteAll(true);
        Customer.DeleteAll(true);
        PurchaseLine.ModifyAll("Qty. Rcd. Not Invoiced", 0);
        PurchaseLine.DeleteAll(true);
        PurchaseHeader.DeleteAll(true);
        VendorLedgerEntry.DeleteAll(true);
        DetailedVendorLedgEntry.DeleteAll(true);
        Vendor.DeleteAll(true);
        ItemLedgerEntry.DeleteAll(true);
        AvgCostAdjmtEntryPoint.DeleteAll(true);
        ValueEntry.DeleteAll(true);
        PostValueEntryToGL.DeleteAll(true);
        TrackingSpecification.DeleteAll(true);
        ReservationEntry.DeleteAll(true);
        ItemJournalLine.DeleteAll(true);
        Item.DeleteAll(true);
        ItemUnitOfMeasure.DeleteAll(true);
        GLItemLedgerRelation.DeleteAll(true);
        ResetGLDimensionSetup();
        DimensionSetEntry.DeleteAll(true);
        DimensionValue.DeleteAll(true);
        Dimension.DeleteAll(true);
        PaymentTerms.DeleteAll(true);
        PaymentTermTranslation.DeleteAll(true);
        DataMigrationEntity.DeleteAll();
        Location.DeleteAll(true);
        ItemTrackingCode.DeleteAll(true);
        BankAccountLedgerEntry.DeleteAll(true);
        BankAccount.DeleteAll(true);

        if OverReceiptCode.Get('GP') then
            OverReceiptCode.Delete(true);

        BankAccountPostingGroup.Reset();
        BankAccountPostingGroup.SetFilter(Code, PostingGroupCodeTxt + '*');
        if not BankAccountPostingGroup.IsEmpty() then
            BankAccountPostingGroup.DeleteAll();

        BankAccReconciliationLine.DeleteAll(true);
        BankAccReconciliation.DeleteAll(true);

        DataMigrationStatus.Reset();
        DataMigrationStatus.SetRange("Migration Type", GetMigrationTypeTxt());
        if not DataMigrationStatus.IsEmpty() then
            DataMigrationStatus.DeleteAll();

        CleanupGenJournalBatches();
        CleanupVatPostingSetup();
        GenJournalLine.DeleteAll(true);
        GLAccount.DeleteAll(true);

        AccountingPeriod.DeleteAll();

        Commit();
        Session.LogMessage('00007GI', 'Cleaned up before Synchronization.', Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', GetTelemetryCategory());
        SetPreMigrationCleanupCompleted();
    end;

    procedure SetTransactionProcessedFlag();
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

    procedure SetAccountValidationError();
    begin
        GPConfiguration.GetSingleInstance();
        GPConfiguration."Account Validation Error" := true;
        GPConfiguration.Modify();
    end;

    procedure ClearAccountValidationError();
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
    begin
        if not GPCompanyAdditionalSettings.GetPayablesModuleEnabled() then
            exit(0);

        exit(GPVendor.Count());
    end;

    procedure RemoveEmptyGLTransactions();
    var
        GPGLTransactions: Record "GP GLTransactions";
    begin
        GPGLTransactions.Reset();
        GPGLTransactions.SetRange(PERDBLNC, 0);
        GPGLTransactions.DeleteAll();
    end;

    procedure PostGLTransactions();
    var
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalBatch: Record "Gen. Journal Batch";
        JournalBatchName: Text;
        DurationAsInt: BigInteger;
        StartTime: DateTime;
        FinishedTelemetryTxt: Label 'Posting GL transactions finished; Duration: %1', Comment = '%1 - The time taken', Locked = true;
        SkipPosting: Boolean;
    begin
        StartTime := CurrentDateTime();
        Session.LogMessage('00007GJ', 'Posting GL transactions started.', Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', GetTelemetryCategory());

        OnSkipPostingGLAccounts(SkipPosting);
        if SkipPosting then
            exit;

        OnSkipPostingAccountBatches(SkipPosting);
        if not SkipPosting then begin
            // Post the Account batches
            GenJournalBatch.Reset();
            GenJournalBatch.SetRange("Journal Template Name", GeneralTemplateNameTxt);
            GenJournalBatch.SetFilter(Name, PostingGroupCodeTxt + '*');
            if GenJournalBatch.FindSet() then
                repeat
                    JournalBatchName := GenJournalBatch.Name;
                    GenJournalLine.Reset();
                    GenJournalLine.SetRange("Journal Template Name", GeneralTemplateNameTxt);
                    GenJournalLine.SetRange("Journal Batch Name", JournalBatchName);
                    if not GenJournalLine.IsEmpty() then
                        PostGLBatch(CopyStr(JournalBatchName, 1, 10));
                until GenJournalBatch.Next() = 0;
        end;

        OnSkipPostingCustomerBatches(SkipPosting);
        if not SkipPosting then begin
            // Post the Customer Batch, if created...
            JournalBatchName := CustomerBatchNameTxt;
            GenJournalLine.Reset();
            GenJournalLine.SetRange("Journal Template Name", GeneralTemplateNameTxt);
            GenJournalLine.SetRange("Journal Batch Name", JournalBatchName);
            if not GenJournalLine.IsEmpty() then
                PostGLBatch(CopyStr(JournalBatchName, 1, 10));
        end;

        OnSkipPostingVendorBatches(SkipPosting);
        if not SkipPosting then begin
            // Post the Vendor Batch, if created...
            JournalBatchName := VendorBatchNameTxt;
            GenJournalLine.Reset();
            GenJournalLine.SetRange("Journal Template Name", GeneralTemplateNameTxt);
            GenJournalLine.SetRange("Journal Batch Name", JournalBatchName);
            if not GenJournalLine.IsEmpty() then
                PostGLBatch(CopyStr(JournalBatchName, 1, 10));
        end;

        OnSkipPostingBankBatches(SkipPosting);
        if not SkipPosting then begin
            // Post the Bank Batch, if created...
            JournalBatchName := BankBatchNameTxt;
            GenJournalLine.Reset();
            GenJournalLine.SetRange("Journal Template Name", GeneralTemplateNameTxt);
            GenJournalLine.SetRange("Journal Batch Name", JournalBatchName);
            if not GenJournalLine.IsEmpty() then
                PostGLBatch(CopyStr(JournalBatchName, 1, 10));
        end;

        // Remove posted batches
        RemoveBatches();
        DurationAsInt := CurrentDateTime() - StartTime;
        Session.LogMessage('00007GK', StrSubstNo(FinishedTelemetryTxt, DurationAsInt), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', GetTelemetryCategory());
    end;

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

    procedure RemoveBatches();
    var
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalBatch: Record "Gen. Journal Batch";
        JournalBatchName: Text;
    begin
        // GL Batches
        GenJournalBatch.Reset();
        GenJournalBatch.SetRange("Journal Template Name", GeneralTemplateNameTxt);
        if GenJournalBatch.FindSet() then
            repeat
                if strpos(GenJournalBatch.Name, PostingGroupCodeTxt) = 1 then begin
                    GenJournalLine.Reset();
                    GenJournalLine.SetRange("Journal Template Name", GeneralTemplateNameTxt);
                    GenJournalLine.SetRange("Journal Batch Name", GenJournalBatch.Name);
                    GenJournalLine.SetRange("Account Type", GenJournalLine."Account Type"::"G/L Account");
                    GenJournalLine.SetRange("Account No.", '');
                    If GenJournalLine.Count() = 1 then begin
                        GenJournalLine.DeleteAll();
                        GenJournalBatch.Delete();
                    end else
                        GenJournalBatch.Delete();
                end;
            until GenJournalBatch.Next() = 0;


        // Customer Batch
        JournalBatchName := CustomerBatchNameTxt;
        GenJournalLine.Reset();
        GenJournalLine.SetRange("Journal Template Name", GeneralTemplateNameTxt);
        GenJournalLine.SetRange("Journal Batch Name", JournalBatchName);
        GenJournalLine.SetRange("Account Type", GenJournalLine."Account Type"::Customer);
        GenJournalLine.SetRange("Account No.", '');
        If GenJournalLine.Count() = 1 then begin
            GenJournalLine.DeleteAll();
            if GenJournalBatch.Get(GeneralTemplateNameTxt, JournalBatchName) then
                GenJournalBatch.Delete();
        end;

        // Vendor Batch
        JournalBatchName := VendorBatchNameTxt;
        GenJournalLine.Reset();
        GenJournalLine.SetRange("Journal Template Name", GeneralTemplateNameTxt);
        GenJournalLine.SetRange("Journal Batch Name", JournalBatchName);
        GenJournalLine.SetRange("Account Type", GenJournalLine."Account Type"::Vendor);
        GenJournalLine.SetRange("Account No.", '');
        If GenJournalLine.Count() = 1 then begin
            GenJournalLine.DeleteAll();
            if GenJournalBatch.Get(GeneralTemplateNameTxt, JournalBatchName) then
                GenJournalBatch.Delete();
        end;

        // Bank Batch
        JournalBatchName := BankBatchNameTxt;
        GenJournalLine.Reset();
        GenJournalLine.SetRange("Journal Template Name", GeneralTemplateNameTxt);
        GenJournalLine.SetRange("Journal Batch Name", JournalBatchName);
        GenJournalLine.SetRange("Account Type", GenJournalLine."Account Type"::"Bank Account");
        If GenJournalLine.Count() = 1 then begin
            GenJournalLine.DeleteAll();
            if GenJournalBatch.Get(GeneralTemplateNameTxt, JournalBatchName) then
                GenJournalBatch.Delete();
        end;
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

    local procedure ResetGLDimensionSetup()
    var
        GLSetup: Record "General Ledger Setup";
    begin
        GLSetup.Get();
        GLSetup."Global Dimension 1 Code" := '';
        GLSetup."Global Dimension 2 Code" := '';
        GLSetup."Shortcut Dimension 1 Code" := '';
        GLSetup."Shortcut Dimension 2 Code" := '';
        GLSetup."Shortcut Dimension 3 Code" := '';
        GLSetup."Shortcut Dimension 4 Code" := '';
        GLSetup."Shortcut Dimension 5 Code" := '';
        GLSetup."Shortcut Dimension 6 Code" := '';
        GLSetup."Shortcut Dimension 7 Code" := '';
        GLSetup."Shortcut Dimension 8 Code" := '';
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
        DimCode: Code[20];
    begin
        if GPSegments.FindSet() then begin
            repeat
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
        DueDateCalculation: DateFormula;
        DiscountDateCalculation: DateFormula;
        SeedValue: integer;
        PaymentTerm: Text[10];
        DueDateCalculationText: Text[50];
        DiscountDateCalculationText: Text[50];
    begin
        SeedValue := 0;
        if GPPaymentTerms.FindSet() then begin
            repeat
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
    begin
        if GPItemLocation.FindSet() then
            repeat
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

    local procedure SetPreMigrationCleanupCompleted()
    begin
        GPConfiguration.GetSingleInstance();
        GPConfiguration."PreMigration Cleanup Completed" := true;
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

    procedure PreMigrationCleanupCompleted(): Boolean
    begin
        GPConfiguration.GetSingleInstance();
        exit(GPConfiguration."PreMigration Cleanup Completed");
    end;

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

        if not FiscalPeriodsCreated() then
            CreateFiscalPeriods();

        if GPCompanyAdditionalSettings.GetBankModuleEnabled() and not CheckBooksCreated() then
            CreateCheckbooks();

        if GPCompanyAdditionalSettings.GetMigrateOpenPOs() and not OpenPurchaseOrdersCreated() then
            CreateOpenPOs();

        if GPCompanyAdditionalSettings.GetPayablesModuleEnabled() and not VendorEFTBankAccountsCreated() then
            CreateVendorEFTBankAccounts();

        if GPCompanyAdditionalSettings.GetMigrateVendorClasses() and not VendorClassesCreated() then
            CreateVendorClasses();

        if GPCompanyAdditionalSettings.GetMigrateCustomerClasses() and not CustomerClassesCreated() then
            CreateCustomerClasses();

        exit(GPConfiguration.IsAllPostMigrationDataCreated());
    end;

    procedure CheckMigrationStatus()
    begin
        GPConfiguration.GetSingleInstance();
        if not GPConfiguration."PreMigration Cleanup Completed" then begin
            CreateDataMigrationErrorRecord('PreMigration cleanup not completed.');
            exit;
        end;

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

    procedure GetGPAccountNumberByIndex(GPAccountIndex: Integer): Code[20]
    var
        GPAccount: Record "GP Account";
    begin
        if (GPAccountIndex > 0) then
            if GPAccount.Get(GPAccountIndex) then
                exit(CopyStr(GPAccount.AcctNum, 1, 20));

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
}