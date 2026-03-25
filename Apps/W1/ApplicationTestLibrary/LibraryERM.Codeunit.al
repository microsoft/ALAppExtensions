/// <summary>
/// Provides utility functions for Enterprise Resource Management (ERM) test scenarios, including general ledger, journal processing, and financial posting operations.
/// </summary>
codeunit 131300 "Library - ERM"
{

    Permissions = TableData Currency = rimd,
                  TableData "Cust. Ledger Entry" = rimd,
                  TableData "Vendor Ledger Entry" = rimd,
                  TableData "Gen. Journal Template" = rimd,
                  TableData "VAT Posting Setup" = rimd;

    trigger OnRun()
    begin
    end;

    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryERMUnapply: Codeunit "Library - ERM Unapply";
        LibraryRandom: Codeunit "Library - Random";
        LibraryJournals: Codeunit "Library - Journals";
        SearchPostingType: Option All,Sales,Purchase;

    procedure ApplicationAmountRounding(ApplicationAmount: Decimal; CurrencyCode: Code[10]): Decimal
    var
        Currency: Record Currency;
    begin
        // Round Application Entry Amount.
        Currency.Initialize(CurrencyCode);

        // Case of Appln. Rounding Precision is equals to zero, use Amount Rounding Precision.
        if Currency."Appln. Rounding Precision" = 0 then
            Currency."Appln. Rounding Precision" := Currency."Amount Rounding Precision";

        exit(Round(ApplicationAmount, Currency."Appln. Rounding Precision", Currency.InvoiceRoundingDirection()));
    end;

    procedure ApplyCustomerLedgerEntries(ApplyingDocumentType: Enum "Gen. Journal Document Type"; DocumentType: Enum "Gen. Journal Document Type"; ApplyingDocumentNo: Code[20]; DocumentNo: Code[20])
    var
        ApplyingCustLedgerEntry: Record "Cust. Ledger Entry";
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        FindCustomerLedgerEntry(ApplyingCustLedgerEntry, ApplyingDocumentType, ApplyingDocumentNo);
        ApplyingCustLedgerEntry.CalcFields("Remaining Amount");
        SetApplyCustomerEntry(ApplyingCustLedgerEntry, ApplyingCustLedgerEntry."Remaining Amount");
        FindCustomerLedgerEntry(CustLedgerEntry, DocumentType, DocumentNo);
        CustLedgerEntry.CalcFields("Remaining Amount");
        CustLedgerEntry.Validate("Amount to Apply", CustLedgerEntry."Remaining Amount");
        CustLedgerEntry.Modify(true);
        SetAppliestoIdCustomer(CustLedgerEntry);
        PostCustLedgerApplication(ApplyingCustLedgerEntry);
    end;

    procedure ApplyVendorLedgerEntries(ApplyingDocumentType: Enum "Gen. Journal Document Type"; DocumentType: Enum "Gen. Journal Document Type"; ApplyingDocumentNo: Code[20]; DocumentNo: Code[20])
    var
        ApplyingVendorLedgerEntry: Record "Vendor Ledger Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        FindVendorLedgerEntry(ApplyingVendorLedgerEntry, ApplyingDocumentType, ApplyingDocumentNo);
        ApplyingVendorLedgerEntry.CalcFields("Remaining Amount");
        SetApplyVendorEntry(ApplyingVendorLedgerEntry, ApplyingVendorLedgerEntry."Remaining Amount");
        FindVendorLedgerEntry(VendorLedgerEntry, DocumentType, DocumentNo);
        VendorLedgerEntry.CalcFields("Remaining Amount");
        VendorLedgerEntry.Validate("Amount to Apply");
        VendorLedgerEntry.Modify(true);
        SetAppliestoIdVendor(VendorLedgerEntry);
        PostVendLedgerApplication(ApplyingVendorLedgerEntry);
    end;

    procedure ClearAdjustPmtDiscInVATSetup()
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        VATPostingSetup.SetRange("Adjust for Payment Discount", true);
        if VATPostingSetup.FindSet() then
            repeat
                VATPostingSetup.Validate("Adjust for Payment Discount", false);
                VATPostingSetup.Modify(true);
            until VATPostingSetup.Next() = 0;
    end;

    procedure CheckPreview(PaymentJournal: TestPage "Payment Journal"): Text
    var
        CheckPreviewPage: TestPage "Check Preview";
    begin
        CheckPreviewPage.Trap();
        PaymentJournal.PreviewCheck.Invoke();
        exit(CheckPreviewPage.AmountText.Value);
    end;

    procedure ClearGenJournalLines(GenJournalBatch: Record "Gen. Journal Batch")
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        GenJournalLine.SetRange("Journal Template Name", GenJournalBatch."Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", GenJournalBatch.Name);
        GenJournalLine.DeleteAll(true);
    end;

    procedure ConvertCurrency(Amount: Decimal; FromCur: Code[10]; ToCur: Code[10]; ConversionDate: Date) NewAmount: Decimal
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        CurrencyExchangeRate2: Record "Currency Exchange Rate";
    begin
        // Converts an Amount from one currency to another.
        // A blank currency code means LCY.
        NewAmount := Amount;

        // Convert to LCY.
        if FromCur <> '' then begin
            FindExchRate(CurrencyExchangeRate, FromCur, ConversionDate);
            NewAmount := NewAmount * CurrencyExchangeRate."Relational Exch. Rate Amount" / CurrencyExchangeRate."Exchange Rate Amount";
        end;

        // Convert into new currency.
        if ToCur <> '' then begin
            FindExchRate(CurrencyExchangeRate2, ToCur, ConversionDate);
            NewAmount := NewAmount * CurrencyExchangeRate2."Exchange Rate Amount" / CurrencyExchangeRate2."Relational Exch. Rate Amount";
        end;
    end;

    procedure CreateAnalysisColumn(var AnalysisColumn: Record "Analysis Column"; AnalysisArea: Enum "Analysis Area Type"; AnalysisColumnTemplate: Code[10])
    var
        RecRef: RecordRef;
    begin
        AnalysisColumn.Init();
        AnalysisColumn.Validate("Analysis Area", AnalysisArea);
        AnalysisColumn.Validate("Analysis Column Template", AnalysisColumnTemplate);
        RecRef.GetTable(AnalysisColumn);
        AnalysisColumn.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, AnalysisColumn.FieldNo("Line No.")));
        AnalysisColumn.Insert(true);
    end;

    procedure CreateAnalysisView(var AnalysisView: Record "Analysis View")
    begin
        AnalysisView.Init();
        AnalysisView.Validate(
          Code,
          CopyStr(
            LibraryUtility.GenerateRandomCode(AnalysisView.FieldNo(Code), DATABASE::"Analysis View"),
            1,
            LibraryUtility.GetFieldLength(DATABASE::"Analysis View", AnalysisView.FieldNo(Code))));

        // Validating Name as Code because value is not important.
        AnalysisView.Validate(Name, AnalysisView.Code);
        AnalysisView.Insert(true);
    end;

    procedure CreateAndPostTwoGenJourLinesWithSameBalAccAndDocNo(var GenJournalLine: Record "Gen. Journal Line"; BalAccType: Enum "Gen. Journal Account Type"; BalAccNo: Code[20]; Amount: Decimal): Code[20]
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        DocNo: Code[20];
    begin
        CreateGenJournalTemplate(GenJournalTemplate);
        CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        CreateGeneralJnlLineWithBalAcc(
          GenJournalLine, GenJournalTemplate.Name, GenJournalBatch.Name, GenJournalLine."Document Type"::Invoice,
          GenJournalLine."Account Type"::"G/L Account", CreateGLAccountNo(), BalAccType, BalAccNo, Amount);
        DocNo := GenJournalLine."Document No.";
        CreateGeneralJnlLineWithBalAcc(
          GenJournalLine, GenJournalTemplate.Name, GenJournalBatch.Name, GenJournalLine."Document Type"::Payment,
          GenJournalLine."Account Type"::"G/L Account", CreateGLAccountNo(), BalAccType, BalAccNo, -Amount);
        GenJournalLine.Validate("Document No.", DocNo);
        GenJournalLine.Modify(true);
        PostGeneralJnlLine(GenJournalLine);

        exit(DocNo);
    end;

    procedure CreateAccScheduleName(var AccScheduleName: Record "Acc. Schedule Name")
    var
        FinancialReport: Record "Financial Report";
        NewAccSchedName: Code[10];
    begin
        NewAccSchedName := CopyStr(LibraryUtility.GenerateRandomCode(AccScheduleName.FieldNo(Name), DATABASE::"Acc. Schedule Name"),
            1, LibraryUtility.GetFieldLength(DATABASE::"Acc. Schedule Name", AccScheduleName.FieldNo(Name)));
        AccScheduleName.Init();
        AccScheduleName.Validate(Name, NewAccSchedName);
        AccScheduleName.Insert(true);
        FinancialReport.Init();
        FinancialReport.Name := NewAccSchedName;
        FinancialReport."Financial Report Row Group" := NewAccSchedName;
        FinancialReport.Insert(true);
    end;

    procedure CreateAccScheduleLine(var AccScheduleLine: Record "Acc. Schedule Line"; ScheduleName: Code[10])
    var
        RecRef: RecordRef;
    begin
        AccScheduleLine.Init();
        AccScheduleLine.Validate("Schedule Name", ScheduleName);
        RecRef.GetTable(AccScheduleLine);
        AccScheduleLine.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, AccScheduleLine.FieldNo("Line No.")));
        AccScheduleLine.Insert(true);
    end;

    procedure CreateAccountMapping(var TextToAccMapping: Record "Text-to-Account Mapping"; MappingText: Text[250])
    var
        RecRef: RecordRef;
    begin
        TextToAccMapping.Init();
        RecRef.GetTable(TextToAccMapping);
        TextToAccMapping.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, TextToAccMapping.FieldNo("Line No.")));
        TextToAccMapping.Validate("Mapping Text", MappingText);
        TextToAccMapping.Insert(true);
    end;

    procedure CreateAccountMappingCustomer(var TextToAccMapping: Record "Text-to-Account Mapping"; MappingText: Text[250]; SourceNo: Code[20])
    begin
        CreateAccountMapping(TextToAccMapping, MappingText);
        TextToAccMapping.Validate("Bal. Source Type", TextToAccMapping."Bal. Source Type"::Customer);
        TextToAccMapping.Validate("Bal. Source No.", SourceNo);
        TextToAccMapping.Modify(true);
    end;

    procedure CreateAccountMappingGLAccount(var TextToAccMapping: Record "Text-to-Account Mapping"; MappingText: Text[250]; CreditNo: Code[20]; DebitNo: Code[20])
    begin
        CreateAccountMapping(TextToAccMapping, MappingText);
        TextToAccMapping.Validate("Bal. Source Type", TextToAccMapping."Bal. Source Type"::"G/L Account");
        TextToAccMapping.Validate("Debit Acc. No.", DebitNo);
        TextToAccMapping.Validate("Credit Acc. No.", CreditNo);
        TextToAccMapping.Modify(true);
    end;

    procedure CreateAccountMappingVendor(var TextToAccMapping: Record "Text-to-Account Mapping"; MappingText: Text[250]; SourceNo: Code[20])
    begin
        CreateAccountMapping(TextToAccMapping, MappingText);
        TextToAccMapping.Validate("Bal. Source Type", TextToAccMapping."Bal. Source Type"::Vendor);
        TextToAccMapping.Validate("Bal. Source No.", SourceNo);
        TextToAccMapping.Modify(true);
    end;

    procedure CreateBankAccount(var BankAccount: Record "Bank Account")
    var
        BankAccountPostingGroup: Record "Bank Account Posting Group";
        BankContUpdate: Codeunit "BankCont-Update";
    begin
        FindBankAccountPostingGroup(BankAccountPostingGroup);
        BankAccount.Init();
        BankAccount.Validate("No.", LibraryUtility.GenerateRandomCode(BankAccount.FieldNo("No."), DATABASE::"Bank Account"));
        BankAccount.Validate(Name, BankAccount."No.");  // Validating No. as Name because value is not important.
        BankAccount.Insert(true);
        BankAccount.Validate("Bank Acc. Posting Group", BankAccountPostingGroup.Code);
        BankAccount.Modify(true);
        BankContUpdate.OnModify(BankAccount);
    end;

    procedure CreateBankAccount(var BankAccount: Record "Bank Account"; GLAccount: Record "G/L Account")
    var
        BankAccountPostingGroup: Record "Bank Account Posting Group";
        BankContUpdate: Codeunit "BankCont-Update";
    begin
        CreateBankAccountPostingGroup(BankAccountPostingGroup, GLAccount);
        Clear(BankAccount);
        BankAccount.Validate("No.", LibraryUtility.GenerateRandomCode(BankAccount.FieldNo("No."), DATABASE::"Bank Account"));
        BankAccount.Validate(Name, BankAccount."No.");  // Validating No. as Name because value is not important.
        BankAccount.Insert(true);
        BankAccount.Validate("Bank Acc. Posting Group", BankAccountPostingGroup.Code);
        BankAccount.IBAN := LibraryUtility.GenerateRandomCode(BankAccount.FieldNo(IBAN), DATABASE::"Bank Account"); // Bypass CheckIBAN fired in OnValidate Trigger.        
        BankAccount.Modify(true);
        BankContUpdate.OnModify(BankAccount);
    end;

    procedure CreateBankAccountNo(): Code[20]
    var
        BankAccount: Record "Bank Account";
    begin
        CreateBankAccount(BankAccount);
        exit(BankAccount."No.");
    end;

    procedure CreateBankAccountNoWithNewPostingGroup(GLAccount: Record "G/L Account"): Code[20]
    var
        BankAccount: Record "Bank Account";
    begin
        CreateBankAccount(BankAccount, GLAccount);
        exit(BankAccount."No.");
    end;

    procedure CreateBankAccReconciliation(var BankAccReconciliation: Record "Bank Acc. Reconciliation"; BankAccountNo: Code[20]; StatementType: Enum "Bank Acc. Rec. Stmt. Type")
    begin
        BankAccReconciliation.Init();
        BankAccReconciliation.Validate("Statement Type", StatementType);
        BankAccReconciliation.Validate("Bank Account No.", BankAccountNo);
        BankAccReconciliation.Insert(true);
        BankAccReconciliation.TestField("Statement No.");
    end;

    procedure CreateBankAccReconciliationLn(var BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"; BankAccReconciliation: Record "Bank Acc. Reconciliation")
    var
        RecRef: RecordRef;
    begin
        BankAccReconciliationLine.Init();
        BankAccReconciliationLine.Validate("Bank Account No.", BankAccReconciliation."Bank Account No.");
        BankAccReconciliationLine.Validate("Statement No.", BankAccReconciliation."Statement No.");
        BankAccReconciliationLine.Validate("Statement Type", BankAccReconciliation."Statement Type");
        RecRef.GetTable(BankAccReconciliationLine);
        BankAccReconciliationLine.Validate(
          "Statement Line No.", LibraryUtility.GetNewLineNo(RecRef, BankAccReconciliationLine.FieldNo("Statement Line No.")));
        BankAccReconciliationLine."Transaction Date" := BankAccReconciliation."Statement Date";
        BankAccReconciliationLine.Insert(true);
    end;

    procedure CreateBankAccountPostingGroup(var BankAccountPostingGroup: Record "Bank Account Posting Group")
    begin
        BankAccountPostingGroup.Init();
        BankAccountPostingGroup.Validate(
          Code,
          CopyStr(LibraryUtility.GenerateRandomCode(BankAccountPostingGroup.FieldNo(Code), DATABASE::"Bank Account Posting Group"),
            1, LibraryUtility.GetFieldLength(DATABASE::"Bank Account Posting Group", BankAccountPostingGroup.FieldNo(Code))));
        BankAccountPostingGroup.Insert(true);
    end;

    procedure CreateBankAccountPostingGroup(var BankAccountPostingGroup: Record "Bank Account Posting Group"; GLAccount: Record "G/L Account")
    begin
        Clear(BankAccountPostingGroup);
        BankAccountPostingGroup.Validate(
          Code,
          CopyStr(LibraryUtility.GenerateRandomCode(BankAccountPostingGroup.FieldNo(Code), DATABASE::"Bank Account Posting Group"),
            1, LibraryUtility.GetFieldLength(DATABASE::"Bank Account Posting Group", BankAccountPostingGroup.FieldNo(Code))));
        BankAccountPostingGroup.Validate("G/L Account No.", GLAccount."No.");
        BankAccountPostingGroup.Insert(true);
    end;

    procedure CreateBusinessUnit(var BusinessUnit: Record "Business Unit")
    begin
        BusinessUnit.Init();
        BusinessUnit.Validate(Code, LibraryUtility.GenerateRandomCode(BusinessUnit.FieldNo(Code), DATABASE::"Business Unit"));
        BusinessUnit.Insert(true);
    end;

    procedure CreateChangeLogField(var ChangeLogSetupField: Record "Change Log Setup (Field)"; TableNo: Integer; FieldNo: Integer)
    begin
        ChangeLogSetupField.Init();
        ChangeLogSetupField.Validate("Table No.", TableNo);
        ChangeLogSetupField.Validate("Field No.", FieldNo);
        ChangeLogSetupField.Insert(true);
    end;

    procedure CreateChangeLogTable(var ChangeLogSetupTable: Record "Change Log Setup (Table)"; TableNo: Integer)
    begin
        ChangeLogSetupTable.Init();
        ChangeLogSetupTable.Validate("Table No.", TableNo);
        ChangeLogSetupTable.Insert(true);
    end;

    procedure CreateColumnLayout(var ColumnLayout: Record "Column Layout"; ColumnLayoutName: Code[10])
    var
        RecRef: RecordRef;
    begin
        ColumnLayout.Init();
        ColumnLayout.Validate("Column Layout Name", ColumnLayoutName);
        RecRef.GetTable(ColumnLayout);
        ColumnLayout.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, ColumnLayout.FieldNo("Line No.")));
        ColumnLayout.Insert(true);
    end;

    procedure CreateColumnLayoutName(var ColumnLayoutName: Record "Column Layout Name")
    begin
        ColumnLayoutName.Init();
        ColumnLayoutName.Validate(
          Name,
          CopyStr(LibraryUtility.GenerateRandomCode(ColumnLayoutName.FieldNo(Name), DATABASE::"Column Layout Name"),
            1, LibraryUtility.GetFieldLength(DATABASE::"Column Layout Name", ColumnLayoutName.FieldNo(Name))));
        ColumnLayoutName.Insert(true);
    end;

    procedure CreateCountryRegion(var CountryRegion: Record "Country/Region")
    begin
        CountryRegion.Init();
        CountryRegion.Validate(
          Code,
          CopyStr(LibraryUtility.GenerateRandomCode(CountryRegion.FieldNo(Code), DATABASE::"Country/Region"),
            1, LibraryUtility.GetFieldLength(DATABASE::"Country/Region", CountryRegion.FieldNo(Code))));
        CountryRegion.Insert(true);
    end;

    procedure CreateCountryRegion(): Code[10]
    var
        CountryRegion: Record "Country/Region";
    begin
        CreateCountryRegion(CountryRegion);
        exit(CountryRegion.Code);
    end;

    procedure CreateCountryRegionTranslation(CountryRegionCode: Code[10]; var CountryRegionTranslation: Record "Country/Region Translation")
    var
        LanguageCode: Code[10];
        NameTranslation: Text[50];
    begin
        LanguageCode := GetAnyLanguageDifferentFromCurrent();
        NameTranslation := CopyStr(LibraryRandom.RandText(MaxStrLen(NameTranslation)), 1, MaxStrLen(NameTranslation));
        CreateCountryRegionTranslation(CountryRegionCode, LanguageCode, NameTranslation, CountryRegionTranslation);
    end;

    procedure CreateCountryRegionTranslation(CountryRegionCode: Code[10]; LanguageCode: Code[10]; NameTranslation: Text[50]; var CountryRegionTranslation: Record "Country/Region Translation")
    begin
        CountryRegionTranslation.Init();
        CountryRegionTranslation.Validate("Country/Region Code", CountryRegionCode);
        CountryRegionTranslation.Validate("Language Code", LanguageCode);
        CountryRegionTranslation.Validate(Name, NameTranslation);
        CountryRegionTranslation.Insert(true);
    end;

    procedure CreateTerritory(var Territory: Record Territory)
    begin
        Territory.Init();
        Territory.Validate(
          Code,
          CopyStr(LibraryUtility.GenerateRandomCode(Territory.FieldNo(Code), DATABASE::Territory),
            1, LibraryUtility.GetFieldLength(DATABASE::Territory, Territory.FieldNo(Code))));
        Territory.Insert(true);
    end;

    procedure CreateCurrency(var Currency: Record Currency)
    begin
        Currency.Init();
        Currency.Validate(Code, LibraryUtility.GenerateRandomCode(Currency.FieldNo(Code), DATABASE::Currency));
        Currency.Insert(true);
    end;

    procedure CreateCurrencyWithRandomExchRates(): Code[10]
    var
        CurrencyCode: Code[10];
    begin
        CurrencyCode := CreateCurrencyWithGLAccountSetup();
        CreateRandomExchangeRate(CurrencyCode);
        exit(CurrencyCode);
    end;

    procedure CreateCurrencyWithRounding(): Code[10]
    var
        Currency: Record Currency;
        Decimals: Integer;
    begin
        Decimals := LibraryRandom.RandInt(5);
        Currency.Get(
            CreateCurrencyWithExchangeRate(
            WorkDate(), LibraryRandom.RandDec(100, Decimals), LibraryRandom.RandDec(100, Decimals)));
        Currency.Validate("Amount Rounding Precision", LibraryRandom.RandPrecision());
        Currency.Modify(true);
        exit(Currency.Code);
    end;

    procedure CreateCurrencyWithExchangeRate(StartingDate: Date; ExchangeRateAmount: Decimal; AdjustmentExchangeRateAmount: Decimal) CurrencyCode: Code[10]
    begin
        CurrencyCode := CreateCurrencyWithGLAccountSetup();
        CreateExchangeRate(CurrencyCode, StartingDate, ExchangeRateAmount, AdjustmentExchangeRateAmount);
        exit(CurrencyCode);
    end;

    procedure CreateCurrencyWithGLAccountSetup(): Code[10]
    var
        Currency: Record Currency;
    begin
        CreateCurrency(Currency);
        Currency.Validate("Residual Gains Account", CreateGLAccountNo());
        Currency.Validate("Residual Losses Account", Currency."Residual Gains Account");
        Currency.Validate("Realized G/L Gains Account", CreateGLAccountNo());
        Currency.Validate("Realized G/L Losses Account", Currency."Realized G/L Gains Account");
        Currency.Validate("Realized Gains Acc.", CreateGLAccountNo());
        Currency.Validate("Realized Losses Acc.", Currency."Realized Gains Acc.");
        Currency.Validate("Unrealized Gains Acc.", CreateGLAccountNo());
        Currency.Validate("Unrealized Losses Acc.", Currency."Unrealized Gains Acc.");
        Currency.Validate("Conv. LCY Rndg. Debit Acc.", CreateGLAccountNo());
        Currency.Validate("Conv. LCY Rndg. Credit Acc.", CreateGLAccountNo());
        Currency.Modify(true);
        exit(Currency.Code);
    end;

    procedure CreateCurrencyForReminderLevel(var CurrencyForReminderLevel: Record "Currency for Reminder Level"; ReminderTermsCode: Code[10]; CurrencyCode: Code[10])
    var
        RecRef: RecordRef;
    begin
        CurrencyForReminderLevel.Init();
        CurrencyForReminderLevel.Validate("Reminder Terms Code", ReminderTermsCode);
        RecRef.GetTable(CurrencyForReminderLevel);
        CurrencyForReminderLevel.Validate("No.", LibraryUtility.GetNewLineNo(RecRef, CurrencyForReminderLevel.FieldNo("No.")));
        CurrencyForReminderLevel.Validate("Currency Code", CurrencyCode);
        CurrencyForReminderLevel.Insert(true);
    end;

    procedure CreateCustomerDiscountGroup(var CustomerDiscountGroup: Record "Customer Discount Group")
    begin
        CustomerDiscountGroup.Init();
        CustomerDiscountGroup.Validate(
          Code, LibraryUtility.GenerateRandomCode(CustomerDiscountGroup.FieldNo(Code), DATABASE::"Customer Discount Group"));
        CustomerDiscountGroup.Validate(Description, CustomerDiscountGroup.Code);  // Validating Code as Description because value is not important.
        CustomerDiscountGroup.Insert(true);
    end;

    procedure CreateItemDiscountGroup(var ItemDiscountGroup: Record "Item Discount Group")
    begin
        ItemDiscountGroup.Init();
        ItemDiscountGroup.Validate(
          Code, LibraryUtility.GenerateRandomCode(ItemDiscountGroup.FieldNo(Code), DATABASE::"Item Discount Group"));
        ItemDiscountGroup.Validate(Description, ItemDiscountGroup.Code);  // Validating Code as Description because value is not important.
        ItemDiscountGroup.Insert(true);
    end;

    procedure CreateDeferralTemplate(var DeferralTemplate: Record "Deferral Template"; CalcMethod: Enum "Deferral Calculation Method"; StartDate: Enum "Deferral Calculation Start Date"; NumOfPeriods: Integer)
    begin
        DeferralTemplate.Init();
        DeferralTemplate."Deferral Code" :=
          LibraryUtility.GenerateRandomCode(DeferralTemplate.FieldNo("Deferral Code"), DATABASE::"Deferral Template");
        DeferralTemplate."Deferral Account" := CreateGLAccountNo();
        DeferralTemplate."Calc. Method" := CalcMethod;
        DeferralTemplate."Start Date" := StartDate;
        DeferralTemplate."No. of Periods" := NumOfPeriods;
        DeferralTemplate."Period Description" := DeferralTemplate."Deferral Code";
        DeferralTemplate.Insert(true);
    end;

    procedure CreateDeferralTemplateCode(CalcMethod: Enum "Deferral Calculation Method"; StartDate: Enum "Deferral Calculation Start Date"; NumOfPeriods: Integer): Code[10]
    var
        DeferralTemplate: Record "Deferral Template";
    begin
        CreateDeferralTemplate(DeferralTemplate, CalcMethod, StartDate, NumOfPeriods);
        exit(DeferralTemplate."Deferral Code");
    end;

    procedure CreateFinanceChargeMemoHeader(var FinanceChargeMemoHeader: Record "Finance Charge Memo Header"; CustomerNo: Code[20])
    begin
        FinanceChargeMemoHeader.Init();
        FinanceChargeMemoHeader.Insert(true);
        FinanceChargeMemoHeader.Validate("Customer No.", CustomerNo);
        FinanceChargeMemoHeader.Modify(true);
    end;

    procedure CreateFinanceChargeMemoLine(var FinanceChargeMemoLine: Record "Finance Charge Memo Line"; FinanceChargeMemoHeaderNo: Code[20]; Type: Option)
    var
        RecRef: RecordRef;
    begin
        FinanceChargeMemoLine.Init();
        FinanceChargeMemoLine.Validate("Finance Charge Memo No.", FinanceChargeMemoHeaderNo);
        RecRef.GetTable(FinanceChargeMemoLine);
        FinanceChargeMemoLine.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, FinanceChargeMemoLine.FieldNo("Line No.")));
        FinanceChargeMemoLine.Insert(true);
        FinanceChargeMemoLine.Validate(Type, Type);
        FinanceChargeMemoLine.Modify(true);
    end;

    procedure CreateFinanceChargeTerms(var FinanceChargeTerms: Record "Finance Charge Terms")
    begin
        FinanceChargeTerms.Init();
        FinanceChargeTerms.Validate(
          Code,
          CopyStr(LibraryUtility.GenerateRandomCode(FinanceChargeTerms.FieldNo(Code), DATABASE::"Finance Charge Terms"),
            1,
            LibraryUtility.GetFieldLength(DATABASE::"Finance Charge Terms", FinanceChargeTerms.FieldNo(Code))));
        FinanceChargeTerms.Insert(true);
    end;

    procedure CreateFinanceChargeText(var FinanceChargeText: Record "Finance Charge Text"; FinChargeTermsCode: Code[10]; Position: Option; Text: Text[100])
    var
        RecRef: RecordRef;
    begin
        FinanceChargeText.Init();
        FinanceChargeText.Validate("Fin. Charge Terms Code", FinChargeTermsCode);
        FinanceChargeText.Validate(Position, Position);
        RecRef.GetTable(FinanceChargeText);
        FinanceChargeText.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, FinanceChargeText.FieldNo("Line No.")));
        FinanceChargeText.Insert(true);
        FinanceChargeText.Validate(Text, Text);
        FinanceChargeText.Modify(true);
    end;

    procedure CreateExchRate(var CurrencyExchangeRate: Record "Currency Exchange Rate"; CurrencyCode: Code[10]; StartingDate: Date)
    begin
        CurrencyExchangeRate.Init();
        CurrencyExchangeRate.Validate("Currency Code", CurrencyCode);
        CurrencyExchangeRate.Validate("Starting Date", StartingDate);
        CurrencyExchangeRate.Insert(true);
    end;

    procedure CreateExchangeRate(CurrencyCode: Code[10]; StartingDate: Date; ExchangeRateAmount: Decimal; AdjustmentExchangeRateAmount: Decimal)
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
    begin
        CurrencyExchangeRate.Init();
        CurrencyExchangeRate.Validate("Currency Code", CurrencyCode);
        CurrencyExchangeRate.Validate("Starting Date", StartingDate);
        CurrencyExchangeRate.Insert(true);

        CurrencyExchangeRate.Validate("Exchange Rate Amount", ExchangeRateAmount);
        CurrencyExchangeRate.Validate("Adjustment Exch. Rate Amount", AdjustmentExchangeRateAmount);
        CurrencyExchangeRate.Validate("Relational Exch. Rate Amount", 1);
        CurrencyExchangeRate.Validate("Relational Adjmt Exch Rate Amt", 1);
        CurrencyExchangeRate.Modify(true);
    end;

    procedure CreateGenBusPostingGroup(var GenBusinessPostingGroup: Record "Gen. Business Posting Group")
    begin
        GenBusinessPostingGroup.Init();
        GenBusinessPostingGroup.Validate(
          Code,
          CopyStr(LibraryUtility.GenerateRandomCode(GenBusinessPostingGroup.FieldNo(Code), DATABASE::"Gen. Business Posting Group"),
            1, LibraryUtility.GetFieldLength(DATABASE::"Gen. Business Posting Group", GenBusinessPostingGroup.FieldNo(Code))));

        // Validating Code as Name because value is not important.
        GenBusinessPostingGroup.Validate(Description, GenBusinessPostingGroup.Code);
        GenBusinessPostingGroup.Insert(true);
    end;

    procedure CreateGeneralPostingSetup(var GeneralPostingSetup: Record "General Posting Setup"; GenBusPostingGroup: Code[20]; GenProdPostingGroup: Code[20])
    begin
        GeneralPostingSetup.Init();
        GeneralPostingSetup.Validate("Gen. Bus. Posting Group", GenBusPostingGroup);
        GeneralPostingSetup.Validate("Gen. Prod. Posting Group", GenProdPostingGroup);
        GeneralPostingSetup.Insert(true);
    end;

    procedure CreateGeneralPostingSetupInvt(var GeneralPostingSetup: Record "General Posting Setup")
    var
        GenBusinessPostingGroup: Record "Gen. Business Posting Group";
        GenProductPostingGroup: Record "Gen. Product Posting Group";
    begin
        CreateGenBusPostingGroup(GenBusinessPostingGroup);
        CreateGenProdPostingGroup(GenProductPostingGroup);
        CreateGeneralPostingSetup(GeneralPostingSetup, GenBusinessPostingGroup.Code, GenProductPostingGroup.Code);
        GeneralPostingSetup.Validate("Sales Account", CreateGLAccountNo());
        GeneralPostingSetup.Validate("Purch. Account", CreateGLAccountNo());
        GeneralPostingSetup.Validate("COGS Account", CreateGLAccountNo());
        GeneralPostingSetup.Validate("Inventory Adjmt. Account", CreateGLAccountNo());
        GeneralPostingSetup.Modify(true);
    end;

    procedure CreateGenProdPostingGroup(var GenProductPostingGroup: Record "Gen. Product Posting Group")
    begin
        GenProductPostingGroup.Init();
        GenProductPostingGroup.Validate(
          Code,
          CopyStr(LibraryUtility.GenerateRandomCode(GenProductPostingGroup.FieldNo(Code), DATABASE::"Gen. Product Posting Group"),
            1, LibraryUtility.GetFieldLength(DATABASE::"Gen. Product Posting Group", GenProductPostingGroup.FieldNo(Code))));

        // Validating Code as Name because value is not important.
        GenProductPostingGroup.Validate(Description, GenProductPostingGroup.Code);
        GenProductPostingGroup.Insert(true);
    end;

    procedure CreateInsurance(var Insurance: Record Insurance)
    begin
        Insurance.Init();
        Insurance.Insert(true);
        Insurance.Validate(Description, Insurance."No.");  // Validating No as Description because value is not important.
        Insurance.Modify(true);
    end;

    procedure CreateRandomExchangeRate(CurrencyCode: Code[10])
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
    begin
        CurrencyExchangeRate.Init();
        CurrencyExchangeRate.Validate("Currency Code", CurrencyCode);
        CurrencyExchangeRate.Validate("Starting Date", FindEarliestDateForExhRate());
        CurrencyExchangeRate.Insert(true);

        // Using RANDOM Exchange Rate Amount and Adjustment Exchange Rate, between 100 and 400 (Standard Value).
        CurrencyExchangeRate.Validate("Exchange Rate Amount", 100 * LibraryRandom.RandInt(4));
        CurrencyExchangeRate.Validate("Adjustment Exch. Rate Amount", CurrencyExchangeRate."Exchange Rate Amount");

        // Relational Exch. Rate Amount and Relational Adjmt Exch Rate Amt always greater than Exchange Rate Amount.
        CurrencyExchangeRate.Validate("Relational Exch. Rate Amount", 2 * CurrencyExchangeRate."Exchange Rate Amount");
        CurrencyExchangeRate.Validate("Relational Adjmt Exch Rate Amt", CurrencyExchangeRate."Relational Exch. Rate Amount");
        CurrencyExchangeRate.Modify(true);
    end;

    procedure CreateGeneralJnlLine(var GenJournalLine: Record "Gen. Journal Line"; JournalTemplateName: Code[10]; JournalBatchName: Code[10]; DocumentType: Enum "Gen. Journal Document Type"; AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20]; Amount: Decimal)
    var
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        GenJournalBatch.Get(JournalTemplateName, JournalBatchName);
        CreateGeneralJnlLineWithBalAcc(
            GenJournalLine, JournalTemplateName, JournalBatchName, DocumentType, AccountType, AccountNo,
            GenJournalBatch."Bal. Account Type", GenJournalBatch."Bal. Account No.", Amount);
    end;

    procedure CreateGeneralJnlLineWithBalAcc(var GenJournalLine: Record "Gen. Journal Line"; JournalTemplateName: Code[10]; JournalBatchName: Code[10]; DocumentType: Enum "Gen. Journal Document Type"; AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20]; BalAccountType: Enum "Gen. Journal Account Type"; BalAccountNo: Code[20]; Amount: Decimal)
    begin
        LibraryJournals.CreateGenJournalLine(GenJournalLine, JournalTemplateName, JournalBatchName, DocumentType, AccountType, AccountNo,
          BalAccountType, BalAccountNo, Amount);
    end;

    procedure CreateGeneralJnlLine2(var GenJournalLine: Record "Gen. Journal Line"; JournalTemplateName: Code[10]; JournalBatchName: Code[10]; DocumentType: Enum "Gen. Journal Document Type"; AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20]; Amount: Decimal)
    var
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        // This function should replace the identical one above, but it requires a lot of changes to existing tests so I'm keeping both for now and will refactor when time permits
        GenJournalBatch.Get(JournalTemplateName, JournalBatchName);
        CreateGeneralJnlLine2WithBalAcc(GenJournalLine, JournalTemplateName, JournalBatchName, DocumentType, AccountType, AccountNo,
          GenJournalBatch."Bal. Account Type", GenJournalBatch."Bal. Account No.", Amount);
    end;

    procedure CreateGeneralJnlLine2WithBalAcc(var GenJournalLine: Record "Gen. Journal Line"; JournalTemplateName: Code[10]; JournalBatchName: Code[10]; DocumentType: Enum "Gen. Journal Document Type"; AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20]; BalAccountType: Enum "Gen. Journal Account Type"; BalAccountNo: Code[20]; Amount: Decimal)
    begin
        // This function should replace the identical one above, but it requires a lot of changes to existing tests so I'm keeping both for now and will refactor when time permits
        LibraryJournals.CreateGenJournalLine2(GenJournalLine, JournalTemplateName, JournalBatchName, DocumentType, AccountType, AccountNo,
          BalAccountType, BalAccountNo, Amount);
    end;

    procedure CreateFAJournalLine(var FAJournalLine: Record "FA Journal Line"; JournalTemplateName: Code[10]; JournalBatchName: Code[10]; DocumentType: Enum "Gen. Journal Document Type"; FAPostingType: Enum "Gen. Journal Line FA Posting Type"; FANo: Code[20]; Amount: Decimal)
    var
        FAJournalBatch: Record "FA Journal Batch";
        NoSeries: Record "No. Series";
        NoSeriesCodeunit: Codeunit "No. Series";
        RecRef: RecordRef;
    begin
        // Find a balanced template/batch pair.
        FAJournalBatch.Get(JournalTemplateName, JournalBatchName);

        // Create a General Journal Entry.
        FAJournalLine.Init();
        FAJournalLine.Validate("Journal Template Name", JournalTemplateName);
        FAJournalLine.Validate("Journal Batch Name", JournalBatchName);
        RecRef.GetTable(FAJournalLine);
        FAJournalLine.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, FAJournalLine.FieldNo("Line No.")));
        FAJournalLine.Insert(true);
        FAJournalLine.Validate("Posting Date", WorkDate());  // Defaults to work date.
        FAJournalLine.Validate("Document Type", DocumentType);
        FAJournalLine.Validate("FA No.", FANo);
        FAJournalLine.Validate("FA Posting Type", FAPostingType);
        FAJournalLine.Validate("FA Posting Date", WorkDate());
        FAJournalLine.Validate(Amount, Amount);
        if NoSeries.Get(FAJournalBatch."No. Series") then
            FAJournalLine.Validate(
              "Document No.", NoSeriesCodeunit.PeekNextNo(FAJournalBatch."No. Series"));  // Unused but required field for posting.
        FAJournalLine.Validate("External Document No.", FAJournalLine."Document No.");  // Unused but required for vendor posting.
        FAJournalLine.Modify(true);
    end;

    procedure CreateGLAccount(var GLAccount: Record "G/L Account")
    begin
        GLAccount.Init();
        // Prefix a number to fix errors for local build.
        GLAccount.Validate(
          "No.",
          PadStr(
            '1' + LibraryUtility.GenerateRandomCode(GLAccount.FieldNo("No."), DATABASE::"G/L Account"), MaxStrLen(GLAccount."No."), '0'));
        GLAccount.Validate(Name, GLAccount."No.");  // Enter No. as Name because value is not important.
        GLAccount.Insert(true);
    end;

    procedure CreateGLAccountNo(): Code[20]
    var
        GLAccount: Record "G/L Account";
    begin
        CreateGLAccount(GLAccount);
        exit(GLAccount."No.");
    end;

    procedure CreateGLAccountNoWithDirectPosting(): Code[20]
    var
        GLAccount: Record "G/L Account";
    begin
        CreateGLAccount(GLAccount);
        GLAccount.Validate("Direct Posting", true);
        GLAccount.Modify();
        exit(GLAccount."No.");
    end;

    procedure CreateGLAccountWithSalesSetup(): Code[20]
    var
        GLAccount: Record "G/L Account";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        FindVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        exit(CreateGLAccountWithVATPostingSetup(VATPostingSetup, GLAccount."Gen. Posting Type"::Sale));
    end;

    procedure CreateGLAccountWithPurchSetup(): Code[20]
    var
        GLAccount: Record "G/L Account";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        FindVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        exit(CreateGLAccountWithVATPostingSetup(VATPostingSetup, GLAccount."Gen. Posting Type"::Purchase));
    end;

    procedure CreateGLAccountWithVATPostingSetup(var VATPostingSetup: Record "VAT Posting Setup"; GenPostingType: Enum "General Posting Type"): Code[20]
    var
        GLAccount: Record "G/L Account";
        GeneralPostingSetup: Record "General Posting Setup";
    begin
        FindGeneralPostingSetup(GeneralPostingSetup);
        CreateGLAccount(GLAccount);
        GLAccount.Validate("Account Type", GLAccount."Account Type"::Posting);
        UpdateGLAccountWithPostingSetup(GLAccount, GenPostingType, GeneralPostingSetup, VATPostingSetup);
        exit(GLAccount."No.");
    end;

    procedure CreateGLAccountCategory(var GLAccountCategory: Record "G/L Account Category")
    begin
        GLAccountCategory.Init();
        GLAccountCategory."Entry No." := 0;
        GLAccountCategory."System Generated" := false;
        GLAccountCategory.Validate("Account Category", LibraryRandom.RandIntInRange(1, 7));
        GLAccountCategory.Validate("Additional Report Definition", LibraryRandom.RandIntInRange(1, 7));
        GLAccountCategory.Validate(Description, LibraryUtility.GenerateRandomText(MaxStrLen(GLAccountCategory.Description)));
        GLAccountCategory.Insert();
    end;

    procedure CreateGLBudgetEntry(var GLBudgetEntry2: Record "G/L Budget Entry"; BudgetDate: Date; GLAccountNo: Code[20]; BudgetName: Code[10])
    var
        GLBudgetEntry: Record "G/L Budget Entry";
    begin
        if GLBudgetEntry.FindLast() then;
        GLBudgetEntry2.Init();
        GLBudgetEntry2.Validate("Entry No.", GLBudgetEntry."Entry No." + 1);
        GLBudgetEntry2.Validate("Budget Name", BudgetName);
        GLBudgetEntry2.Validate("G/L Account No.", GLAccountNo);
        GLBudgetEntry2.Validate(Date, BudgetDate);
        GLBudgetEntry2.Insert(true);
    end;

    procedure CreateGLBudgetName(var GLBudgetName: Record "G/L Budget Name")
    begin
        GLBudgetName.Init();
        GLBudgetName.Validate(Name, LibraryUtility.GenerateRandomCode(GLBudgetName.FieldNo(Name), DATABASE::"G/L Budget Name"));
        GLBudgetName.Validate(Description, GLBudgetName.Name);
        GLBudgetName.Insert(true);
    end;

    procedure CreateGenJnlAllocation(var GenJnlAllocation: Record "Gen. Jnl. Allocation"; JournalTemplateName: Code[10]; JournalBatchName: Code[10]; LineNo: Integer)
    var
        RecRef: RecordRef;
    begin
        GenJnlAllocation.Init();
        GenJnlAllocation.Validate("Journal Template Name", JournalTemplateName);
        GenJnlAllocation.Validate("Journal Batch Name", JournalBatchName);
        GenJnlAllocation.Validate("Journal Line No.", LineNo);
        RecRef.GetTable(GenJnlAllocation);
        GenJnlAllocation.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, GenJnlAllocation.FieldNo("Line No.")));
        GenJnlAllocation.Insert(true);
    end;

    procedure CreateGenJournalBatch(var GenJournalBatch: Record "Gen. Journal Batch"; JournalTemplateName: Code[10])
    begin
        // creates a new Gen. Journal Batch named with the next available number (if it does not yet exist), OR
        // returns the Gen. Journal batch named with the next available number
        // calling ConvertNumericToText to avoid auto-removal of the batch during posting by COD13
        GenJournalBatch.Init();
        GenJournalBatch.Validate("Journal Template Name", JournalTemplateName);
        GenJournalBatch.Validate(
          Name,
          LibraryUtility.ConvertNumericToText(
            CopyStr(
              LibraryUtility.GenerateRandomCode(GenJournalBatch.FieldNo(Name), DATABASE::"Gen. Journal Batch"),
              1,
              LibraryUtility.GetFieldLength(DATABASE::"Gen. Journal Batch", GenJournalBatch.FieldNo(Name)))));
        GenJournalBatch.Validate(Description, GenJournalBatch.Name);  // Validating Name as Description because value is not important.
        if GenJournalBatch.Insert(true) then;
    end;

    procedure CreateGenJournalTemplate(var GenJournalTemplate: Record "Gen. Journal Template")
    begin
        GenJournalTemplate.Init();
        GenJournalTemplate.Validate(
          Name,
          CopyStr(
            LibraryUtility.GenerateRandomCode(GenJournalTemplate.FieldNo(Name), DATABASE::"Gen. Journal Template"),
            1,
            LibraryUtility.GetFieldLength(DATABASE::"Gen. Journal Template", GenJournalTemplate.FieldNo(Name))));
        GenJournalTemplate.Validate(Description, GenJournalTemplate.Name);
        // Validating Name as Description because value is not important.
        GenJournalTemplate.Insert(true);

        if not GenJournalTemplate."Force Doc. Balance" then begin
            GenJournalTemplate.Validate("Force Doc. Balance", true);  // This field is FALSE by default in ES. Setting this to TRUE to match ES with W1.
            GenJournalTemplate.Modify(true);
        end;
    end;

    procedure CreateICGLAccount(var ICGLAccount: Record "IC G/L Account")
    begin
        ICGLAccount.Init();
        ICGLAccount.Validate(
          "No.",
          CopyStr(
            LibraryUtility.GenerateRandomCode(ICGLAccount.FieldNo("No."), DATABASE::"IC G/L Account"), 1,
            LibraryUtility.GetFieldLength(DATABASE::"IC G/L Account", ICGLAccount.FieldNo("No."))));
        ICGLAccount.Validate(Name, ICGLAccount."No.");  // Validating No. as Name because value is not important.
        ICGLAccount.Insert(true);
    end;

    procedure CreateDimension(var Dimension: Record Dimension)
    begin
        Dimension.Init();
        Dimension.Validate(
          "Code",
          CopyStr(
            LibraryUtility.GenerateRandomCode(Dimension.FieldNo("Code"), DATABASE::Dimension), 1,
            LibraryUtility.GetFieldLength(DATABASE::Dimension, Dimension.FieldNo("Code"))));
        Dimension.Validate(Name, Dimension."Code");  // Validating Code as Name because value is not important.
        Dimension.Insert(true);
    end;

    procedure CreateDimensionValue(var DimensionValue: Record "Dimension Value")
    var
        Dimension: Record Dimension;
    begin
        CreateDimension(Dimension);
        CreateDimensionValue(DimensionValue, Dimension.Code);
    end;

    procedure CreateDimensionValue(var DimensionValue: Record "Dimension Value"; DimensionCode: Code[20])
    begin
        DimensionValue.Init();
        DimensionValue.Validate(
          "Code",
          CopyStr(
            LibraryUtility.GenerateRandomCode(DimensionValue.FieldNo("Code"), DATABASE::"Dimension Value"), 1,
            LibraryUtility.GetFieldLength(DATABASE::"Dimension Value", DimensionValue.FieldNo("Code"))));
        DimensionValue.Validate("Dimension Code", DimensionCode);
        DimensionValue.Validate(Name, DimensionValue."Code");  // Validating Code as Name because value is not important.
        DimensionValue.Insert(true);
    end;

    procedure CreateICDimension(var ICDimension: Record "IC Dimension")
    begin
        ICDimension.Init();
        ICDimension.Validate(
          "Code",
          CopyStr(
            LibraryUtility.GenerateRandomCode(ICDimension.FieldNo("Code"), DATABASE::"IC Dimension"), 1,
            LibraryUtility.GetFieldLength(DATABASE::"IC Dimension", ICDimension.FieldNo("Code"))));
        ICDimension.Validate(Name, ICDimension."Code");  // Validating Code as Name because value is not important.
        ICDimension.Insert(true);
    end;

    procedure CreateICDimensionValue(var ICDimensionValue: Record "IC Dimension Value")
    var
        ICDimension: Record "IC Dimension";
    begin
        CreateICDimension(ICDimension);
        CreateICDimensionValue(ICDimensionValue, ICDimension.Code);
    end;

    procedure CreateICDimensionValue(var ICDimensionValue: Record "IC Dimension Value"; DimensionCode: Code[20])
    begin
        ICDimensionValue.Init();
        ICDimensionValue.Validate(
          "Code",
          CopyStr(
            LibraryUtility.GenerateRandomCode(ICDimensionValue.FieldNo("Code"), DATABASE::"IC Dimension Value"), 1,
            LibraryUtility.GetFieldLength(DATABASE::"IC Dimension Value", ICDimensionValue.FieldNo("Code"))));
        ICDimensionValue.Validate("Dimension Code", DimensionCode);
        ICDimensionValue.Validate(Name, ICDimensionValue."Code");  // Validating Code as Name because value is not important.
        ICDimensionValue.Insert(true);
    end;

    procedure CreateICPartner(var ICPartner: Record "IC Partner")
    begin
        ICPartner.Init();
        ICPartner.Validate(
          Code,
          CopyStr(
            LibraryUtility.GenerateRandomCode(ICPartner.FieldNo(Code), DATABASE::"IC Partner"), 1,
            LibraryUtility.GetFieldLength(DATABASE::"IC Partner", ICPartner.FieldNo(Code))));
        ICPartner.Validate(Name, ICPartner.Code);  // Validating Name as Code because value is not important.
        ICPartner."Payables Account" := CreateGLAccountNo();
        ICPartner."Receivables Account" := CreateGLAccountNo();
        ICPartner.Insert(true);
    end;

    procedure CreateICPartnerNo(): Code[20]
    var
        ICPartner: Record "IC Partner";
    begin
        CreateICPartner(ICPartner);
        exit(ICPartner.Code);
    end;

    procedure CreateInvDiscForCustomer(var CustInvoiceDisc: Record "Cust. Invoice Disc."; "Code": Code[20]; CurrencyCode: Code[10]; MinimumAmount: Decimal)
    begin
        CustInvoiceDisc.Init();
        CustInvoiceDisc.Validate(Code, Code);
        CustInvoiceDisc.Validate("Currency Code", CurrencyCode);
        CustInvoiceDisc.Validate("Minimum Amount", MinimumAmount);
        CustInvoiceDisc.Insert(true);
    end;

    procedure CreateInvDiscForVendor(var VendorInvoiceDisc: Record "Vendor Invoice Disc."; "Code": Code[20]; CurrencyCode: Code[10]; MinimumAmount: Decimal)
    begin
        VendorInvoiceDisc.Init();
        VendorInvoiceDisc.Validate(Code, Code);
        VendorInvoiceDisc.Validate("Currency Code", CurrencyCode);
        VendorInvoiceDisc.Validate("Minimum Amount", MinimumAmount);
        VendorInvoiceDisc.Insert(true);
    end;

    procedure CreateItemAnalysisView(var ItemAnalysisView: Record "Item Analysis View"; AnalysisArea: Enum "Analysis Area Type")
    begin
        ItemAnalysisView.Init();
        ItemAnalysisView.Validate("Analysis Area", AnalysisArea);
        ItemAnalysisView.Validate(Code, LibraryUtility.GenerateRandomCode(ItemAnalysisView.FieldNo(Code), DATABASE::"Item Analysis View"));
        // Validating Name as Code because value is not important.
        ItemAnalysisView.Validate(Name, ItemAnalysisView.Code);
        ItemAnalysisView.Insert(true);
    end;

    procedure GetAnyLanguageDifferentFromCurrent(): Code[10]
    var
        Language: Record Language;
    begin
        Language.SetFilter("Windows Language ID", '<>%1', GlobalLanguage());
        Language.SetFilter(Code, 'CSY|DAN|DEU|ESP|FRA|FRC|ENU|ITA|NOR|SVE');
        Language.FindFirst();
        Language.Next(LibraryRandom.RandIntInRange(1, Language.Count()));
        exit(Language.Code);
    end;

    procedure CreateLineDiscForCustomer(var SalesLineDiscount: Record "Sales Line Discount"; Type: Enum "Sales Line Discount Type"; "Code": Code[20]; SalesType: Option; SalesCode: Code[20]; StartingDate: Date; CurrencyCode: Code[10]; VariantCode: Code[10]; UnitOfMeasureCode: Code[10]; MinimumQuantity: Decimal)
    begin
        SalesLineDiscount.Init();
        SalesLineDiscount.Validate(Type, Type);
        SalesLineDiscount.Validate(Code, Code);
        SalesLineDiscount.Validate("Sales Type", SalesType);
        SalesLineDiscount.Validate("Sales Code", SalesCode);
        SalesLineDiscount.Validate("Starting Date", StartingDate);
        SalesLineDiscount.Validate("Currency Code", CurrencyCode);
        if Type = SalesLineDiscount.Type::Item then begin
            SalesLineDiscount.Validate("Variant Code", VariantCode);
            SalesLineDiscount.Validate("Unit of Measure Code", UnitOfMeasureCode);
        end;
        SalesLineDiscount.Validate("Minimum Quantity", MinimumQuantity);
        SalesLineDiscount.Insert(true);
    end;

    procedure CreateLineDiscForVendor(var PurchaseLineDiscount: Record "Purchase Line Discount"; ItemNo: Code[20]; VendorNo: Code[20]; StartingDate: Date; CurrencyCode: Code[10]; VariantCode: Code[10]; UnitofMeasureCode: Code[10]; MinimumQuantity: Decimal)
    begin
        PurchaseLineDiscount.Init();
        PurchaseLineDiscount.Validate("Item No.", ItemNo);
        PurchaseLineDiscount.Validate("Vendor No.", VendorNo);
        PurchaseLineDiscount.Validate("Starting Date", StartingDate);
        PurchaseLineDiscount.Validate("Currency Code", CurrencyCode);
        PurchaseLineDiscount.Validate("Variant Code", VariantCode);
        PurchaseLineDiscount.Validate("Unit of Measure Code", UnitofMeasureCode);
        PurchaseLineDiscount.Validate("Minimum Quantity", MinimumQuantity);
        PurchaseLineDiscount.Insert(true);
    end;

    procedure CreateNoSeriesCode(): Code[20]
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        // Create Number Series and Number Series Line and return the No. Series Code.
        LibraryUtility.CreateNoSeries(NoSeries, true, true, false);
        LibraryUtility.CreateNoSeriesLine(NoSeriesLine, NoSeries.Code, '', '');
        exit(NoSeries.Code);
    end;

    procedure CreateNoSeriesCode(Prefix: Code[3]): Code[20]
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        // Create Number Series and Number Series Line and return the No. Series Code.
        NoSeries.Code := Prefix;
        LibraryUtility.CreateNoSeries(NoSeries, true, true, false);
        LibraryUtility.CreateNoSeriesLine(NoSeriesLine, NoSeries.Code, '', '');
        exit(NoSeries.Code);
    end;

    procedure CreatePaymentMethod(var PaymentMethod: Record "Payment Method")
    begin
        PaymentMethod.Init();
        PaymentMethod.Validate(
          Code,
          CopyStr(
            LibraryUtility.GenerateRandomCode(PaymentMethod.FieldNo(Code), DATABASE::"Payment Method"), 1,
            LibraryUtility.GetFieldLength(DATABASE::"Payment Method", PaymentMethod.FieldNo(Code))));
        PaymentMethod.Validate(Description, LibraryUtility.GenerateGUID());
        PaymentMethod.Insert(true);
    end;

    procedure CreatePaymentMethodWithBalAccount(var PaymentMethod: Record "Payment Method")
    begin
        CreatePaymentMethod(PaymentMethod);
        PaymentMethod.Validate("Bal. Account Type", PaymentMethod."Bal. Account Type"::"G/L Account");
        PaymentMethod.Validate("Bal. Account No.", CreateGLAccountNo());
        PaymentMethod.Modify(true);
    end;

    [Scope('OnPrem')]
    procedure CreatePaymentMethodTranslation(PaymentMethodCode: Code[10]): Code[10]
    var
        PaymentMethodTranslation: Record "Payment Method Translation";
    begin
        PaymentMethodTranslation.Init();
        PaymentMethodTranslation.Validate("Payment Method Code", PaymentMethodCode);
        PaymentMethodTranslation.Validate("Language Code", GetAnyLanguageDifferentFromCurrent());
        PaymentMethodTranslation.Validate(Description, LibraryUtility.GenerateGUID());
        PaymentMethodTranslation.Insert(true);
        exit(PaymentMethodTranslation."Language Code");
    end;

    procedure CreatePaymentTerms(var PaymentTerms: Record "Payment Terms")
    begin
        PaymentTerms.Init();
        PaymentTerms.Validate(
          Code,
          CopyStr(
            LibraryUtility.GenerateRandomCode(PaymentTerms.FieldNo(Code), DATABASE::"Payment Terms"),
            1,
            LibraryUtility.GetFieldLength(DATABASE::"Payment Terms", PaymentTerms.FieldNo(Code))));
        PaymentTerms.Insert(true);

        OnAfterCreatePaymentTerms(PaymentTerms);
    end;

    procedure CreatePaymentTermsDiscount(var PaymentTerms: Record "Payment Terms"; CalcPmtDiscOnCrMemos: Boolean)
    begin
        CreatePaymentTerms(PaymentTerms);
        PaymentTerms.Validate("Calc. Pmt. Disc. on Cr. Memos", CalcPmtDiscOnCrMemos);
        Evaluate(PaymentTerms."Due Date Calculation", '<' + Format(LibraryRandom.RandInt(5)) + 'M>');
        Evaluate(PaymentTerms."Discount Date Calculation", '<' + Format(LibraryRandom.RandInt(10)) + 'D>');
        PaymentTerms.Validate("Due Date Calculation", PaymentTerms."Due Date Calculation");
        PaymentTerms.Validate("Discount Date Calculation", PaymentTerms."Discount Date Calculation");
        PaymentTerms.Validate("Discount %", LibraryRandom.RandInt(10));
        PaymentTerms.Modify(true);
    end;

    procedure CreatePostCode(var PostCode: Record "Post Code")
    var
        CountryRegion: Record "Country/Region";
    begin
        PostCode.Init();
        PostCode.Validate(
          Code,
          CopyStr(
            LibraryUtility.GenerateRandomCode(PostCode.FieldNo(Code), DATABASE::"Post Code"),
            1,
            LibraryUtility.GetFieldLength(DATABASE::"Post Code", PostCode.FieldNo(Code))));
        PostCode.Validate(
          City,
          CopyStr(
            LibraryUtility.GenerateRandomCode(PostCode.FieldNo(City), DATABASE::"Post Code"),
            1,
            LibraryUtility.GetFieldLength(DATABASE::"Post Code", PostCode.FieldNo(City))));
        CountryRegion.Next(LibraryRandom.RandInt(CountryRegion.Count()));
        PostCode.Validate("Country/Region Code", CountryRegion.Code);
        PostCode.Insert(true);

        OnAfterCreatePostCode(PostCode);
    end;

    local procedure CreatePrepaymentVATPostingSetup(var VATPostingSetup: Record "VAT Posting Setup"; VATCalcType: Enum "Tax Calculation Type"; GenPostingType: Enum "General Posting Type"; SetupGLAccount: Record "G/L Account"; VATAccountNo: Code[20])
    var
        VATBusinessPostingGroup: Record "VAT Business Posting Group";
        VATProductPostingGroup: Record "VAT Product Posting Group";
        Handled: Boolean;
    begin
        OnBeforeCreatePrepaymentVATPostingSetup(VATPostingSetup, VATCalcType, GenPostingType, SetupGLAccount, VATAccountNo, Handled);
        if Handled then
            exit;

        if (SetupGLAccount."VAT Bus. Posting Group" <> '') and (SetupGLAccount."VAT Prod. Posting Group" <> '') then
            if VATPostingSetup.Get(SetupGLAccount."VAT Bus. Posting Group", SetupGLAccount."VAT Prod. Posting Group") then
                exit;

        VATPostingSetup.Init();
        if SetupGLAccount."VAT Bus. Posting Group" <> '' then
            VATPostingSetup."VAT Bus. Posting Group" := SetupGLAccount."VAT Bus. Posting Group"
        else begin
            CreateVATBusinessPostingGroup(VATBusinessPostingGroup);
            VATPostingSetup."VAT Bus. Posting Group" := VATBusinessPostingGroup.Code;
        end;
        CreateVATProductPostingGroup(VATProductPostingGroup);
        VATPostingSetup."VAT Prod. Posting Group" := VATProductPostingGroup.Code;
        VATPostingSetup."VAT Identifier" := VATPostingSetup."VAT Prod. Posting Group";
        VATPostingSetup."VAT Calculation Type" := VATCalcType;
        if VATPostingSetup."VAT Calculation Type" <> VATPostingSetup."VAT Calculation Type"::"Full VAT" then begin
            VATPostingSetup."VAT %" := LibraryRandom.RandIntInRange(5, 25);
            VATAccountNo := CreateGLAccountNo();
        end;
        if GenPostingType = GenPostingType::Purchase then
            VATPostingSetup."Purchase VAT Account" := VATAccountNo
        else
            VATPostingSetup."Sales VAT Account" := VATAccountNo;
        VATPostingSetup.Insert();

        OnAfterCreatePrepaymentVATPostingSetup(VATPostingSetup, VATCalcType, GenPostingType, SetupGLAccount, VATAccountNo);
    end;

    local procedure CreatePrepaymentGenPostingSetup(var GenPostingSetup: Record "General Posting Setup"; var PrepmtGLAccount: Record "G/L Account"; GenPostingType: Enum "General Posting Type"; SetupGLAccount: Record "G/L Account")
    var
        GenBusPostingGroup: Record "Gen. Business Posting Group";
        GenProdPostingGroup: Record "Gen. Product Posting Group";
    begin
        if (SetupGLAccount."Gen. Bus. Posting Group" <> '') and (SetupGLAccount."Gen. Prod. Posting Group" <> '') then
            if GenPostingSetup.Get(SetupGLAccount."Gen. Bus. Posting Group", SetupGLAccount."Gen. Prod. Posting Group") then
                exit;

        GenPostingSetup.Init();
        if SetupGLAccount."Gen. Bus. Posting Group" <> '' then
            GenPostingSetup."Gen. Bus. Posting Group" := SetupGLAccount."Gen. Bus. Posting Group"
        else begin
            CreateGenBusPostingGroup(GenBusPostingGroup);
            GenPostingSetup."Gen. Bus. Posting Group" := GenBusPostingGroup.Code;
        end;
        CreateGenProdPostingGroup(GenProdPostingGroup);
        GenPostingSetup."Gen. Prod. Posting Group" := GenProdPostingGroup.Code;
        CreateGLAccount(PrepmtGLAccount);
        case GenPostingType of
            GenPostingType::Purchase:
                begin
                    GenPostingSetup."Direct Cost Applied Account" := CreateGLAccountNo();
                    GenPostingSetup."Purch. Account" := CreateGLAccountNo();
                    GenPostingSetup."Purch. Prepayments Account" := PrepmtGLAccount."No.";
                    GenPostingSetup."Purch. Line Disc. Account" := CreateGLAccountNo();
                end;
            GenPostingType::Sale:
                begin
                    GenPostingSetup."COGS Account" := CreateGLAccountNo();
                    GenPostingSetup."Sales Account" := CreateGLAccountNo();
                    GenPostingSetup."Sales Prepayments Account" := PrepmtGLAccount."No.";
                    GenPostingSetup."Sales Line Disc. Account" := CreateGLAccountNo();
                end;
        end;
        GenPostingSetup.Insert();
    end;

    procedure CreatePrepaymentVATSetup(var LineGLAccount: Record "G/L Account"; var PrepmtGLAccount: Record "G/L Account"; GenPostingType: Enum "General Posting Type"; VATCalcType: Enum "Tax Calculation Type"; PrepmtVATCalcType: Enum "Tax Calculation Type")
    var
        GenPostingSetup: Record "General Posting Setup";
        PassedGLAccount: Record "G/L Account";
        Handled: Boolean;
    begin
        PassedGLAccount := LineGLAccount;
        CreatePrepaymentGenPostingSetup(GenPostingSetup, PrepmtGLAccount, GenPostingType, PassedGLAccount);
        SetPostingGroupsOnPrepmtGLAccount(PrepmtGLAccount, GenPostingSetup, GenPostingType, PrepmtVATCalcType, PassedGLAccount);

        CreateGLAccount(LineGLAccount);

        OnBeforeSetPostingGroupsOnPrepmtGLAccount(LineGLAccount, PrepmtGLAccount, GenPostingType, VATCalcType.AsInteger(), PrepmtVATCalcType.AsInteger(), Handled);

        if Handled then
            exit;

        if (PrepmtVATCalcType = VATCalcType) and (VATCalcType <> VATCalcType::"Full VAT") then
            SetPostingGroupsOnPrepmtGLAccount(LineGLAccount, GenPostingSetup, GenPostingType, VATCalcType, PrepmtGLAccount)
        else begin
            PassedGLAccount."Gen. Bus. Posting Group" := PrepmtGLAccount."Gen. Bus. Posting Group";
            PassedGLAccount."VAT Bus. Posting Group" := PrepmtGLAccount."VAT Bus. Posting Group";
            SetPostingGroupsOnPrepmtGLAccount(LineGLAccount, GenPostingSetup, GenPostingType, VATCalcType, PassedGLAccount);
        end;

        OnAfterSetPostingGroupsOnPrepmtGLAccount(LineGLAccount, PrepmtGLAccount, GenPostingType, VATCalcType.AsInteger(), PrepmtVATCalcType.AsInteger());
    end;

    procedure CreateReasonCode(var ReasonCode: Record "Reason Code")
    begin
        ReasonCode.Init();
        ReasonCode.Validate(
          Code,
          CopyStr(
            LibraryUtility.GenerateRandomCode(ReasonCode.FieldNo(Code), DATABASE::"Reason Code"),
            1, LibraryUtility.GetFieldLength(DATABASE::"Reason Code", ReasonCode.FieldNo(Code))));
        ReasonCode.Validate(Description, ReasonCode.Code);  // Validating Description as Code because value is not important.
        ReasonCode.Insert(true);
    end;

    procedure CreateReminderHeader(var ReminderHeader: Record "Reminder Header")
    begin
        ReminderHeader.Init();
        ReminderHeader.Insert(true);
    end;

    procedure CreateReminderLevel(var ReminderLevel: Record "Reminder Level"; ReminderTermsCode: Code[10])
    begin
        ReminderLevel.Init();
        ReminderLevel.Validate("Reminder Terms Code", ReminderTermsCode);
        ReminderLevel.NewRecord();
        ReminderLevel.Insert(true);
    end;

    procedure CreateReminderLine(var ReminderLine: Record "Reminder Line"; ReminderNo: Code[20]; Type: Enum "Reminder Source Type")
    var
        RecRef: RecordRef;
    begin
        ReminderLine.Init();
        ReminderLine.Validate("Reminder No.", ReminderNo);
        RecRef.GetTable(ReminderLine);
        ReminderLine.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, ReminderLine.FieldNo("Line No.")));
        ReminderLine.Insert(true);
        ReminderLine.Validate(Type, Type);
        ReminderLine.Modify(true);
    end;

    procedure CreateReminderTerms(var ReminderTerms: Record "Reminder Terms")
    begin
        ReminderTerms.Init();
        ReminderTerms.Validate(Code, LibraryUtility.GenerateRandomCode(ReminderTerms.FieldNo(Code), DATABASE::"Reminder Terms"));
        ReminderTerms.Validate(Description, ReminderTerms.Code);
        ReminderTerms.Insert(true);
    end;

    procedure CreateReminderText(var ReminderText: Record "Reminder Text"; ReminderTermsCode: Code[10]; ReminderLevel: Integer; Position: Enum "Reminder Text Position"; Text: Text[100])
    var
        RecRef: RecordRef;
    begin
        ReminderText.Init();
        ReminderText.Validate("Reminder Terms Code", ReminderTermsCode);
        ReminderText.Validate("Reminder Level", ReminderLevel);
        ReminderText.Validate(Position, Position);
        RecRef.GetTable(ReminderText);
        ReminderText.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, ReminderText.FieldNo("Line No.")));
        ReminderText.Insert(true);
        ReminderText.Validate(Text, Text);
        ReminderText.Modify(true);
    end;

    procedure CreateRecurringTemplateName(var GenJournalTemplate: Record "Gen. Journal Template")
    begin
        GenJournalTemplate.Init();
        GenJournalTemplate.Validate(
          Name,
          CopyStr(LibraryUtility.GenerateRandomCode(GenJournalTemplate.FieldNo(Name), DATABASE::"Gen. Journal Template"),
            1, LibraryUtility.GetFieldLength(DATABASE::"Gen. Journal Template", GenJournalTemplate.FieldNo(Name))));
        GenJournalTemplate.Insert(true);
        GenJournalTemplate.Validate("Posting No. Series", LibraryUtility.GetGlobalNoSeriesCode());
        GenJournalTemplate.Validate(Recurring, true);
        GenJournalTemplate.Modify(true);
    end;

    procedure CreateRecurringBatchName(var GenJournalBatch: Record "Gen. Journal Batch"; JournalTemplateName: Code[10])
    var
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        // Create New General Journal Batch with a random Name of String length less than 10.
        GenJournalTemplate.Get(JournalTemplateName);
        GenJournalBatch.Init();
        GenJournalBatch.Validate("Journal Template Name", GenJournalTemplate.Name);
        GenJournalBatch.Validate(
          Name,
          CopyStr(LibraryUtility.GenerateRandomCode(GenJournalBatch.FieldNo(Name), DATABASE::"Gen. Journal Batch"),
            1, LibraryUtility.GetFieldLength(DATABASE::"Gen. Journal Batch", GenJournalBatch.FieldNo(Name))));
        GenJournalBatch.Insert(true);
        GenJournalBatch.Validate("Posting No. Series", GenJournalTemplate."Posting No. Series");
        GenJournalBatch.Modify(true);
    end;

    procedure CreateReturnReasonCode(var ReturnReason: Record "Return Reason")
    begin
        ReturnReason.Init();
        ReturnReason.Validate(
          Code,
          CopyStr(
            LibraryUtility.GenerateRandomCode(ReturnReason.FieldNo(Code), DATABASE::"Return Reason"),
            1, LibraryUtility.GetFieldLength(DATABASE::"Return Reason", ReturnReason.FieldNo(Code))));
        ReturnReason.Validate(Description, ReturnReason.Code);  // Validating Description as Code because value is not important.
        ReturnReason.Insert(true);
    end;

    procedure CreateSourceCode(var SourceCode: Record "Source Code")
    begin
        SourceCode.Init();
        SourceCode.Validate(
          Code,
          CopyStr(LibraryUtility.GenerateRandomCode(SourceCode.FieldNo(Code), DATABASE::"Source Code"),
            1, LibraryUtility.GetFieldLength(DATABASE::"Source Code", SourceCode.FieldNo(Code))));
        SourceCode.Insert(true);
    end;

    procedure CreateRelatedVATPostingSetup(GLAccount: Record "G/L Account"): Code[20]
    var
        VATPostingSetup: Record "VAT Posting Setup";
        VATProductPostingGroup: Record "VAT Product Posting Group";
    begin
        VATPostingSetup.Get(GLAccount."VAT Bus. Posting Group", GLAccount."VAT Prod. Posting Group");
        CreateVATProductPostingGroup(VATProductPostingGroup);
        VATPostingSetup."VAT Prod. Posting Group" := VATProductPostingGroup.Code;
        VATPostingSetup."Sales VAT Account" := CreateGLAccountNo();
        VATPostingSetup."Purchase VAT Account" := CreateGLAccountNo();
        VATPostingSetup.Insert();
        exit(VATPostingSetup."VAT Prod. Posting Group");
    end;

    procedure CreateVATBusinessPostingGroup(var VATBusinessPostingGroup: Record "VAT Business Posting Group")
    begin
        VATBusinessPostingGroup.Init();
        VATBusinessPostingGroup.Validate(
          Code,
          CopyStr(LibraryUtility.GenerateRandomCode(VATBusinessPostingGroup.FieldNo(Code), DATABASE::"VAT Business Posting Group"),
            1, LibraryUtility.GetFieldLength(DATABASE::"VAT Business Posting Group", VATBusinessPostingGroup.FieldNo(Code))));

        // Validating Code as Name because value is not important.
        VATBusinessPostingGroup.Validate(Description, VATBusinessPostingGroup.Code);
        VATBusinessPostingGroup.Insert(true);
    end;

    procedure CreateRandomVATIdentifierAndGetCode(): Text
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        exit(LibraryUtility.GenerateRandomCode(VATPostingSetup.FieldNo("VAT Identifier"), DATABASE::"VAT Posting Setup"));
    end;

    procedure CreateVATPostingSetup(var VATPostingSetup: Record "VAT Posting Setup"; VATBusPostingGroup: Code[20]; VATProdPostingGroup: Code[20])
    var
        Handled: Boolean;
    begin
        OnBeforeCreateVATPostingSetup(VATPostingSetup, Handled);
        if Handled then
            exit;

        VATPostingSetup.Init();
        VATPostingSetup.Validate("VAT Bus. Posting Group", VATBusPostingGroup);
        VATPostingSetup.Validate("VAT Prod. Posting Group", VATProdPostingGroup);
        VATPostingSetup.Insert(true);

        OnAfterCreateVATPostingSetup(VATPostingSetup);
    end;

    procedure CreateVATPostingSetupWithAccounts(var VATPostingSetup: Record "VAT Posting Setup"; VATCalculationType: Enum "Tax Calculation Type"; VATRate: Decimal)
    var
        VATBusinessPostingGroup: Record "VAT Business Posting Group";
        VATProductPostingGroup: Record "VAT Product Posting Group";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCreateVATPostingSetupWithAccounts(VATPostingSetup, VATCalculationType, VATRate, IsHandled);
        if IsHandled then
            exit;

        VATPostingSetup.Init();
        CreateVATBusinessPostingGroup(VATBusinessPostingGroup);
        CreateVATProductPostingGroup(VATProductPostingGroup);
        VATPostingSetup.Validate("VAT Bus. Posting Group", VATBusinessPostingGroup.Code);
        VATPostingSetup.Validate("VAT Prod. Posting Group", VATProductPostingGroup.Code);
        VATPostingSetup.Validate("VAT Calculation Type", VATCalculationType);
        VATPostingSetup.Validate("VAT %", VATRate);
        VATPostingSetup.Validate("VAT Identifier",
          LibraryUtility.GenerateRandomCode(VATPostingSetup.FieldNo("VAT Identifier"), DATABASE::"VAT Posting Setup"));
        VATPostingSetup.Validate("Sales VAT Account", CreateGLAccountNo());
        VATPostingSetup.Validate("Purchase VAT Account", CreateGLAccountNo());
        VATPostingSetup.Validate("Tax Category", 'S');
        VATPostingSetup.Insert(true);
    end;

    procedure CreateVATProductPostingGroup(var VATProductPostingGroup: Record "VAT Product Posting Group")
    var
        IsHandled: Boolean;
    begin
        OnBeforeCreateVATProductPostingGroup(VATProductPostingGroup, IsHandled);
        if IsHandled then
            exit;

        VATProductPostingGroup.Init();
        VATProductPostingGroup.Validate(
          Code,
          CopyStr(LibraryUtility.GenerateRandomCode(VATProductPostingGroup.FieldNo(Code), DATABASE::"VAT Product Posting Group"),
            1, LibraryUtility.GetFieldLength(DATABASE::"VAT Product Posting Group", VATProductPostingGroup.FieldNo(Code))));

        // Validating Code as Name because value is not important.
        VATProductPostingGroup.Validate(Description, VATProductPostingGroup.Code);
        VATProductPostingGroup.Insert(true);

        OnAfterCreateVATProductPostingGroup(VATProductPostingGroup);
    end;

    procedure CreateVATRegistrationNoFormat(var VATRegistrationNoFormat: Record "VAT Registration No. Format"; CountryRegionCode: Code[10])
    var
        RecRef: RecordRef;
    begin
        VATRegistrationNoFormat.Init();
        VATRegistrationNoFormat.Validate("Country/Region Code", CountryRegionCode);
        RecRef.GetTable(VATRegistrationNoFormat);
        VATRegistrationNoFormat.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, VATRegistrationNoFormat.FieldNo("Line No.")));
        VATRegistrationNoFormat.Insert(true);
    end;

    procedure CreateVATClause(var VATClause: Record "VAT Clause")
    begin
        VATClause.Init();
        VATClause.Validate(Code,
          CopyStr(LibraryUtility.GenerateRandomCode(VATClause.FieldNo(Code), DATABASE::"VAT Clause"),
            1, LibraryUtility.GetFieldLength(DATABASE::"VAT Clause", VATClause.FieldNo(Code))));
        VATClause.Validate(Description, LibraryUtility.GenerateGUID());
        VATClause.Validate("Description 2", LibraryUtility.GenerateGUID());
        VATClause.Insert(true);
    end;

    procedure GenerateVATRegistrationNo(CountryRegionCode: Code[10]) VATRegNo: Text[20]
    var
        VATRegistrationNoFormat: Record "VAT Registration No. Format";
        FormatType: Text[1];
        i: Integer;
        RandomCharacter: Char;
    begin
        // Generate VAT Registration No. as per VAT Registration No. format.
        VATRegistrationNoFormat.SetRange("Country/Region Code", CountryRegionCode);
        if VATRegistrationNoFormat.FindFirst() then
            for i := 1 to StrLen(VATRegistrationNoFormat.Format) do begin
                FormatType := CopyStr(VATRegistrationNoFormat.Format, i, 1);
                case FormatType of
                    'A' .. 'Z', '0' .. '9', '.', '-':
                        VATRegNo := InsStr(VATRegNo, FormatType, i);
                    '#':
                        VATRegNo := InsStr(VATRegNo, Format(LibraryRandom.RandInt(9)), i);
                    '@':
                        begin
                            RandomCharacter := LibraryRandom.RandInt(25) + 65;  // For the generation of random character.
                            VATRegNo := InsStr(VATRegNo, Format(RandomCharacter), i);  // Used as constant as VAT Registration validation is not important.
                        end;
                    ' ':
                        VATRegNo := VATRegNo + ' '
                    else
                        VATRegNo := InsStr(VATRegNo, Format(LibraryRandom.RandInt(9)), i);
                end;
            end
        else
            VATRegNo :=
              CopyStr(LibraryUtility.GenerateRandomCode(VATRegistrationNoFormat.FieldNo(Format), DATABASE::"VAT Registration No. Format"),
                1, LibraryUtility.GetFieldLength(DATABASE::"VAT Registration No. Format", VATRegistrationNoFormat.FieldNo(Format)));
    end;

    procedure CreateStandardGeneralJournal(var StandardGeneralJournal: Record "Standard General Journal"; JournalTemplateName: Code[10])
    begin
        StandardGeneralJournal.Init();
        StandardGeneralJournal.Validate("Journal Template Name", JournalTemplateName);
        StandardGeneralJournal.Validate(
          Code,
          CopyStr(
            LibraryUtility.GenerateRandomCode(StandardGeneralJournal.FieldNo(Code), DATABASE::"Standard General Journal"),
            1,
            LibraryUtility.GetFieldLength(DATABASE::"Standard General Journal", StandardGeneralJournal.FieldNo(Code))));

        // Validating Code as Description because value is not important.
        StandardGeneralJournal.Validate(Description, StandardGeneralJournal.Code);
        StandardGeneralJournal.Insert(true);
    end;

    procedure CreateStandardItemJournal(var StandardItemJournal: Record "Standard Item Journal"; JournalTemplateName: Code[10])
    begin
        StandardItemJournal.Init();
        StandardItemJournal.Validate("Journal Template Name", JournalTemplateName);
        StandardItemJournal.Validate(
          Code,
          CopyStr(
            LibraryUtility.GenerateRandomCode(StandardItemJournal.FieldNo(Code), DATABASE::"Standard Item Journal"),
            1,
            LibraryUtility.GetFieldLength(DATABASE::"Standard Item Journal", StandardItemJournal.FieldNo(Code))));

        // Validating Code as Description because value is not important.
        StandardItemJournal.Validate(Description, StandardItemJournal.Code);
        StandardItemJournal.Insert(true);
    end;

    procedure CreateVATStatementLine(var VATStatementLine: Record "VAT Statement Line"; StatementTemplateName: Code[10]; StatementName: Code[10])
    var
        RecRef: RecordRef;
    begin
        VATStatementLine.Init();
        VATStatementLine.Validate("Statement Template Name", StatementTemplateName);
        VATStatementLine.Validate("Statement Name", StatementName);
        RecRef.GetTable(VATStatementLine);
        VATStatementLine.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, VATStatementLine.FieldNo("Line No.")));
        VATStatementLine.Insert(true);
    end;

    procedure CreateVATStatementName(var VATStatementName: Record "VAT Statement Name"; StatementTemplateName: Code[10])
    begin
        VATStatementName.Init();
        VATStatementName.Validate("Statement Template Name", StatementTemplateName);
        VATStatementName.Validate(
          Name,
          CopyStr(
            LibraryUtility.GenerateRandomCode(VATStatementName.FieldNo(Name), DATABASE::"VAT Statement Name"), 1,
            LibraryUtility.GetFieldLength(DATABASE::"VAT Statement Name", VATStatementName.FieldNo(Name))));
        VATStatementName.Validate(Description, VATStatementName.Name);  // Validating Name as Description because value is not important.
        VATStatementName.Insert(true);
    end;

    procedure CreateVATStatementTemplate(var VATStatementTemplate: Record "VAT Statement Template")
    begin
        VATStatementTemplate.Init();
        VATStatementTemplate.Validate(
          Name,
          CopyStr(
            LibraryUtility.GenerateRandomCode(VATStatementTemplate.FieldNo(Name), DATABASE::"VAT Statement Template"), 1,
            LibraryUtility.GetFieldLength(DATABASE::"VAT Statement Template", VATStatementTemplate.FieldNo(Name))));
        VATStatementTemplate.Validate(Description, VATStatementTemplate.Name);  // Validating Name as Description because value is not important.
        VATStatementTemplate.Insert(true);
    end;

    procedure CreateVATStatementNameWithTemplate(var VATStatementName: Record "VAT Statement Name")
    var
        VATStatementTemplate: Record "VAT Statement Template";
    begin
        CreateVATStatementTemplate(VATStatementTemplate);
        CreateVATStatementName(VATStatementName, VATStatementTemplate.Name);
    end;

    procedure CreateTaxArea(var TaxArea: Record "Tax Area")
    begin
        TaxArea.Init();
        TaxArea.Validate(
          Code,
          CopyStr(
            LibraryUtility.GenerateRandomCode(TaxArea.FieldNo(Code), DATABASE::"Tax Area"),
            1,
            LibraryUtility.GetFieldLength(DATABASE::"Tax Area", TaxArea.FieldNo(Code))));
        TaxArea.Validate(Description, TaxArea.Code);  // Validating Code as Description because value is not important.
        TaxArea.Insert(true);
    end;

    procedure CreateTaxAreaLine(var TaxAreaLine: Record "Tax Area Line"; TaxAreaCode: Code[20]; TaxJurisdictionCode: Code[10])
    begin
        TaxAreaLine.Init();
        TaxAreaLine.Validate("Tax Area", TaxAreaCode);
        TaxAreaLine.Validate("Tax Jurisdiction Code", TaxJurisdictionCode);
        TaxAreaLine.Insert(true);
    end;

    procedure CreateTaxGroup(var TaxGroup: Record "Tax Group")
    begin
        TaxGroup.Init();
        TaxGroup.Validate(
          Code,
          CopyStr(
            LibraryUtility.GenerateRandomCode(TaxGroup.FieldNo(Code), DATABASE::"Tax Group"),
            1,
            LibraryUtility.GetFieldLength(DATABASE::"Tax Group", TaxGroup.FieldNo(Code))));
        TaxGroup.Validate(Description, TaxGroup.Code);  // Validating Code as Description because value is not important.
        TaxGroup.Insert(true);
    end;

    procedure CreateTaxJurisdiction(var TaxJurisdiction: Record "Tax Jurisdiction")
    begin
        TaxJurisdiction.Init();
        TaxJurisdiction.Validate(
          Code,
          CopyStr(
            LibraryUtility.GenerateRandomCode(TaxJurisdiction.FieldNo(Code), DATABASE::"Tax Jurisdiction"),
            1,
            LibraryUtility.GetFieldLength(DATABASE::"Tax Jurisdiction", TaxJurisdiction.FieldNo(Code))));
        TaxJurisdiction.Validate(Description, TaxJurisdiction.Code);  // Validating Code as Description because value is not important.
        TaxJurisdiction.Insert(true);
    end;

    procedure CreateTaxDetail(var TaxDetail: Record "Tax Detail"; TaxJurisdictionCode: Code[10]; TaxGroupCode: Code[20]; TaxType: Option; EffectiveDate: Date)
    begin
        TaxDetail.Init();
        TaxDetail.Validate("Tax Jurisdiction Code", TaxJurisdictionCode);
        TaxDetail.Validate("Tax Group Code", TaxGroupCode);
        TaxDetail.Validate("Tax Type", TaxType);
        TaxDetail.Validate("Effective Date", EffectiveDate);
        TaxDetail.Insert(true);
    end;

    procedure CreateCountryRegionWithIntrastatCode(): Code[10]
    var
        CountryRegion: Record "Country/Region";
    begin
        CreateCountryRegion(CountryRegion);
        CountryRegion.Validate(Name, LibraryUtility.GenerateGUID());
        CountryRegion.Validate("Intrastat Code", LibraryUtility.GenerateGUID());
        CountryRegion.Modify(true);
        exit(CountryRegion.Code);
    end;

    procedure CreateItemBudgetName(var ItemBudgetName: Record "Item Budget Name"; AnalysisArea: Enum "Analysis Area Type")
    begin
        ItemBudgetName.Init();
        ItemBudgetName.Validate("Analysis Area", AnalysisArea);
        ItemBudgetName.Validate(Name, LibraryUtility.GenerateGUID());
        ItemBudgetName.Insert(true);
    end;

    procedure DisableClosingUnreleasedOrdersMsg()
    var
        InstructionMgt: Codeunit "Instruction Mgt.";
    begin
        InstructionMgt.DisableMessageForCurrentUser(InstructionMgt.ClosingUnreleasedOrdersCode());
    end;

    procedure DisableMyNotifications(UserId: Code[50]; NotificationId: Guid)
    var
        MyNotifications: Record "My Notifications";
    begin
        if not MyNotifications.Get(UserId, NotificationId) then begin
            MyNotifications.Init();
            MyNotifications."User Id" := UserId;
            MyNotifications."Notification Id" := NotificationId;
            MyNotifications.Enabled := false;
            MyNotifications.Insert();
        end else begin
            MyNotifications.Enabled := false;
            MyNotifications.Modify();
        end;
    end;

    procedure FindRecurringTemplateName(var GenJournalTemplate: Record "Gen. Journal Template")
    begin
        GenJournalTemplate.SetRange(Type, GenJournalTemplate.Type::General);
        GenJournalTemplate.SetRange(Recurring, true);
        if not GenJournalTemplate.FindFirst() then
            CreateRecurringTemplateName(GenJournalTemplate);
    end;

    procedure FindBankAccount(var BankAccount: Record "Bank Account")
    begin
        BankAccount.SetFilter("Bank Acc. Posting Group", '<>%1', '');
        BankAccount.SetRange("Currency Code", '');
        BankAccount.SetRange(Blocked, false);
        if not BankAccount.FindFirst() then
            CreateBankAccount(BankAccount);
    end;

    procedure FindBankAccountPostingGroup(var BankAccountPostingGroup: Record "Bank Account Posting Group")
    begin
        if not BankAccountPostingGroup.FindFirst() then
            CreateBankAccountPostingGroup(BankAccountPostingGroup);
    end;

    procedure FindCountryRegion(var CountryRegion: Record "Country/Region")
    begin
        if not CountryRegion.FindFirst() then
            CreateCountryRegion(CountryRegion);
    end;

    procedure FindCurrency(var Currency: Record Currency)
    begin
        if not Currency.FindFirst() then
            CreateCurrency(Currency);
    end;

    procedure FindCustomerLedgerEntry(var CustLedgerEntry: Record "Cust. Ledger Entry"; DocumentType: Enum "Gen. Journal Document Type"; DocumentNo: Code[20])
    begin
        // Finds the matching Customer Ledger Entry from a General Journal Line.
        CustLedgerEntry.SetRange("Document Type", DocumentType);
        CustLedgerEntry.SetRange("Document No.", DocumentNo);
        CustLedgerEntry.FindFirst();
    end;

    procedure MinDate(Date1: Date; Date2: Date): Date
    begin
        if Date1 < Date2 then
            exit(Date1);
        exit(Date2);
    end;

    procedure MaxDate(Date1: Date; Date2: Date): Date
    begin
        if Date1 > Date2 then
            exit(Date1);
        exit(Date2);
    end;

    procedure FindEarliestDateForExhRate() Date: Date
    var
        GLEntry: Record "G/L Entry";
    begin
        Date := MinDate(WorkDate(), Today);
        GLEntry.SetCurrentKey("Posting Date");
        if GLEntry.FindFirst() then
            Date := MinDate(Date, NormalDate(GLEntry."Posting Date"));
        exit(Date);
    end;

    procedure FindExchRate(var CurrencyExchangeRate: Record "Currency Exchange Rate"; Currency: Code[10]; ConversionDate: Date)
    begin
        // Returns the Exchange Rate for a specified Currency at a specified Date. If multiple Exchange Rates exists it picks the latest.
        CurrencyExchangeRate.SetRange("Currency Code", Currency);
        CurrencyExchangeRate.SetRange("Starting Date", 0D, ConversionDate);
        CurrencyExchangeRate.FindLast();
    end;

    procedure FindGLAccount(var GLAccount: Record "G/L Account"): Code[20]
    begin
        // Filter G/L Account so that errors are not generated due to mandatory fields.
        SetGLAccountDirectPostingFilter(GLAccount);
        SetGLAccountNotBlankGroupsFilter(GLAccount);
        GLAccount.FindFirst();
        exit(GLAccount."No.");
    end;

    procedure FindGLAccountDataSet(var GLAccount: Record "G/L Account")
    begin
        SetGLAccountDirectPostingFilter(GLAccount);
        SetGLAccountNotBlankGroupsFilter(GLAccount);
        GLAccount.FindSet();
    end;

    procedure FindDirectPostingGLAccount(var GLAccount: Record "G/L Account"): Code[20]
    begin
        SetGLAccountDirectPostingFilter(GLAccount);
        GLAccount.FindFirst();
        exit(GLAccount."No.");
    end;

    procedure FindGenBusinessPostingGroup(var GenBusinessPostingGroup: Record "Gen. Business Posting Group")
    begin
        if not GenBusinessPostingGroup.FindFirst() then
            CreateGenBusPostingGroup(GenBusinessPostingGroup);
    end;

    procedure FindGenJournalBatch(var GenJournalBatch: Record "Gen. Journal Batch"; JournalTemplateName: Code[10])
    begin
        GenJournalBatch.SetRange("Journal Template Name", JournalTemplateName);
        if not GenJournalBatch.FindFirst() then
            CreateGenJournalBatch(GenJournalBatch, JournalTemplateName);
    end;

    procedure FindGenJournalTemplate(var GenJournalTemplate: Record "Gen. Journal Template")
    begin
        GenJournalTemplate.SetRange(Recurring, false);
        if not GenJournalTemplate.FindFirst() then begin
            CreateGenJournalTemplate(GenJournalTemplate);
            if GenJournalTemplate.GetRangeMin(Type) = GenJournalTemplate.GetRangeMax(Type) then begin
                GenJournalTemplate.Validate(Type, GenJournalTemplate.GetRangeMin(Type));
                GenJournalTemplate.Modify(true);
            end;
        end;
    end;

    procedure FindGenJournalTemplateWithGenName(var GenJournalTemplate: Record "Gen. Journal Template")
    begin
        GenJournalTemplate.SetRange(Recurring, false);
        GenJournalTemplate.SetRange(Name, 'GENERAL');
        if not GenJournalTemplate.FindFirst() then begin
            CreateGenJournalTemplate(GenJournalTemplate);
            if GenJournalTemplate.GetRangeMin(Type) = GenJournalTemplate.GetRangeMax(Type) then begin
                GenJournalTemplate.Validate(Type, GenJournalTemplate.GetRangeMin(Type));
                GenJournalTemplate.Modify(true);
            end;
        end;
    end;

    procedure FindGenProductPostingGroup(var GenProductPostingGroup: Record "Gen. Product Posting Group")
    begin
        if not GenProductPostingGroup.FindFirst() then
            CreateGenProdPostingGroup(GenProductPostingGroup);
    end;

    procedure FindGeneralPostingSetup(var GeneralPostingSetup: Record "General Posting Setup"): Boolean
    begin
        GeneralPostingSetup.SetFilter("Gen. Bus. Posting Group", '<>%1', '');
        GeneralPostingSetup.SetFilter("Gen. Prod. Posting Group", '<>%1', '');
        GeneralPostingSetup.FindFirst();
        exit(true);
    end;

    procedure FindGeneralPostingSetupInvtBase(var GeneralPostingSetup: Record "General Posting Setup")
    begin
        GeneralPostingSetup.SetFilter("Gen. Bus. Posting Group", '<>%1', '');
        GeneralPostingSetup.SetFilter("Gen. Prod. Posting Group", '<>%1', '');
        GeneralPostingSetup.SetFilter("COGS Account", '<>%1', '');
        GeneralPostingSetup.SetFilter("Inventory Adjmt. Account", '<>%1', '');
        if SearchPostingType <> SearchPostingType::Purchase then
            GeneralPostingSetup.SetFilter("Sales Account", '<>%1', '');
        if SearchPostingType <> SearchPostingType::Sales then
            GeneralPostingSetup.SetFilter("Purch. Account", '<>%1', '');
        if not GeneralPostingSetup.FindFirst() then begin
            GeneralPostingSetup.SetRange("Purch. Account");
            GeneralPostingSetup.SetRange("Inventory Adjmt. Account");
            if GeneralPostingSetup.FindFirst() then begin
                GeneralPostingSetup.Validate("Purch. Account", CreateGLAccountNo());
                GeneralPostingSetup.Validate("Inventory Adjmt. Account", CreateGLAccountNo());
                GeneralPostingSetup.Modify(true);
            end else
                CreateGeneralPostingSetupInvt(GeneralPostingSetup);
        end;
    end;

    procedure FindGeneralPostingSetupInvtFull(var GeneralPostingSetup: Record "General Posting Setup")
    begin
        GeneralPostingSetup.SetFilter("Gen. Bus. Posting Group", '<>%1', '');
        GeneralPostingSetup.SetFilter("Gen. Prod. Posting Group", '<>%1', '');
        if SearchPostingType <> SearchPostingType::Purchase then begin
            GeneralPostingSetup.SetFilter("Sales Account", '<>%1', '');
            GeneralPostingSetup.SetFilter("Sales Credit Memo Account", '<>%1', '');
            GeneralPostingSetup.SetFilter("Sales Prepayments Account", '<>%1', '');
        end;
        if SearchPostingType <> SearchPostingType::Sales then begin
            GeneralPostingSetup.SetFilter("Purch. Account", '<>%1', '');
            GeneralPostingSetup.SetFilter("Purch. Credit Memo Account", '<>%1', '');
            GeneralPostingSetup.SetFilter("Purch. Prepayments Account", '<>%1', '');
        end;
        GeneralPostingSetup.SetFilter("COGS Account", '<>%1', '');
        GeneralPostingSetup.SetFilter("COGS Account (Interim)", '<>''''');
        GeneralPostingSetup.SetFilter("Inventory Adjmt. Account", '<>%1', '');
        GeneralPostingSetup.SetFilter("Direct Cost Applied Account", '<>%1', '');
        GeneralPostingSetup.SetFilter("Overhead Applied Account", '<>%1', '');
        GeneralPostingSetup.SetFilter("Purchase Variance Account", '<>%1', '');
        if not GeneralPostingSetup.FindFirst() then begin
            GeneralPostingSetup.SetRange("Sales Prepayments Account");
            GeneralPostingSetup.SetRange("Purch. Prepayments Account");
            if GeneralPostingSetup.FindFirst() then begin
                SetGeneralPostingSetupPrepAccounts(GeneralPostingSetup);
                GeneralPostingSetup.Modify(true);
            end else begin
                GeneralPostingSetup.SetRange("COGS Account (Interim)");
                GeneralPostingSetup.SetRange("Direct Cost Applied Account");
                GeneralPostingSetup.SetRange("Overhead Applied Account");
                GeneralPostingSetup.SetRange("Purchase Variance Account");
                if GeneralPostingSetup.FindFirst() then begin
                    SetGeneralPostingSetupInvtAccounts(GeneralPostingSetup);
                    SetGeneralPostingSetupMfgAccounts(GeneralPostingSetup);
                    SetGeneralPostingSetupPrepAccounts(GeneralPostingSetup);
                    GeneralPostingSetup.Modify(true);
                end else begin
                    GeneralPostingSetup.SetRange("Purch. Account");
                    GeneralPostingSetup.SetRange("Purch. Credit Memo Account");
                    if GeneralPostingSetup.FindFirst() then begin
                        SetGeneralPostingSetupInvtAccounts(GeneralPostingSetup);
                        SetGeneralPostingSetupMfgAccounts(GeneralPostingSetup);
                        SetGeneralPostingSetupPrepAccounts(GeneralPostingSetup);
                        SetGeneralPostingSetupPurchAccounts(GeneralPostingSetup);
                        GeneralPostingSetup.Modify(true);
                    end else
                        FindGeneralPostingSetupInvtBase(GeneralPostingSetup);
                end;
            end;
        end;
    end;

    procedure FindGeneralPostingSetupInvtToGL(var GeneralPostingSetup: Record "General Posting Setup")
    begin
        GeneralPostingSetup.SetRange("Gen. Bus. Posting Group", '');
        GeneralPostingSetup.SetFilter("Gen. Prod. Posting Group", '<>%1', '');
        GeneralPostingSetup.SetFilter("COGS Account", '<>%1', '');
        GeneralPostingSetup.SetFilter("COGS Account (Interim)", '<>%1', '');
        GeneralPostingSetup.SetFilter("Inventory Adjmt. Account", '<>%1', '');
        GeneralPostingSetup.SetFilter("Direct Cost Applied Account", '<>%1', '');
        GeneralPostingSetup.SetFilter("Overhead Applied Account", '<>%1', '');
        GeneralPostingSetup.SetFilter("Purchase Variance Account", '<>%1', '');
        GeneralPostingSetup.SetFilter("Invt. Accrual Acc. (Interim)", '<>%1', '');
        if not GeneralPostingSetup.FindFirst() then begin
            GeneralPostingSetup.SetRange("COGS Account (Interim)");
            GeneralPostingSetup.SetRange("Direct Cost Applied Account");
            GeneralPostingSetup.SetRange("Overhead Applied Account");
            GeneralPostingSetup.SetRange("Purchase Variance Account");
            GeneralPostingSetup.SetRange("Invt. Accrual Acc. (Interim)");
            if GeneralPostingSetup.FindFirst() then begin
                SetGeneralPostingSetupInvtAccounts(GeneralPostingSetup);
                SetGeneralPostingSetupMfgAccounts(GeneralPostingSetup);
                GeneralPostingSetup.Modify(true);
            end else
                FindGeneralPostingSetupInvtBase(GeneralPostingSetup);
        end;
    end;

    procedure FindGenPostingSetupWithDefVAT(var GeneralPostingSetup: Record "General Posting Setup")
    var
        VATPostingSetup: Record "VAT Posting Setup";
        GenBusPostingGroup: Record "Gen. Business Posting Group";
        GenProdPostingGroup: Record "Gen. Product Posting Group";
    begin
        FindGeneralPostingSetupInvtFull(GeneralPostingSetup);
        FindVATPostingSetupInvt(VATPostingSetup);
        GenBusPostingGroup.Get(GeneralPostingSetup."Gen. Bus. Posting Group");
        GenBusPostingGroup.Validate("Def. VAT Bus. Posting Group", VATPostingSetup."VAT Bus. Posting Group");
        GenBusPostingGroup.Modify();
        GenProdPostingGroup.Get(GeneralPostingSetup."Gen. Prod. Posting Group");
        GenProdPostingGroup.Validate("Def. VAT Prod. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
        GenProdPostingGroup.Modify();
    end;

    procedure FindPaymentMethod(var PaymentMethod: Record "Payment Method")
    begin
        PaymentMethod.SetRange("Bal. Account No.", '');
        if not PaymentMethod.FindFirst() then
            CreatePaymentMethod(PaymentMethod);
    end;

    procedure FindPaymentTerms(var PaymentTerms: Record "Payment Terms")
    begin
        if not PaymentTerms.FindFirst() then
            CreatePaymentTerms(PaymentTerms);
    end;

    procedure FindPaymentTermsCode(): Code[10]
    var
        PaymentTerms: Record "Payment Terms";
        DateFormular_0D: DateFormula;
    begin
        Evaluate(DateFormular_0D, '<0D>');

        if PaymentTerms.FieldActive("Due Date Calculation") then // Field is disabled on IT build
            PaymentTerms.SetRange("Due Date Calculation", DateFormular_0D);
        if not PaymentTerms.FindFirst() then
            CreatePaymentTerms(PaymentTerms);
        exit(PaymentTerms.Code);
    end;

    procedure FindPostCode(var PostCode: Record "Post Code")
    begin
        if not PostCode.FindFirst() then
            CreatePostCode(PostCode);
    end;

    procedure FindGeneralJournalSourceCode(): Code[10]
    var
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        GenJournalTemplate.SetRange(Type, GenJournalTemplate.Type::General);
        GenJournalTemplate.SetRange(Recurring, false);
        GenJournalTemplate.SetFilter("Source Code", '<>%1', '');
        GenJournalTemplate.FindFirst();
        exit(GenJournalTemplate."Source Code");
    end;

    procedure FindVATBusinessPostingGroup(var VATBusinessPostingGroup: Record "VAT Business Posting Group")
    begin
        if not VATBusinessPostingGroup.FindFirst() then
            CreateVATBusinessPostingGroup(VATBusinessPostingGroup);
    end;

    procedure FindVATProductPostingGroup(var VATProductPostingGroup: Record "VAT Product Posting Group")
    begin
        if not VATProductPostingGroup.FindFirst() then
            CreateVATProductPostingGroup(VATProductPostingGroup);
    end;

    procedure FindVATPostingSetup(var VATPostingSetup: Record "VAT Posting Setup"; VATCalculationType: Enum "Tax Calculation Type")
    begin
        VATPostingSetup.SetFilter("VAT Bus. Posting Group", '<>%1', '');
        VATPostingSetup.SetFilter("VAT Prod. Posting Group", '<>%1', '');
        VATPostingSetup.SetFilter("Sales VAT Account", '<>%1', '');
        VATPostingSetup.SetFilter("Purchase VAT Account", '<>%1', '');
        VATPostingSetup.SetRange("VAT Calculation Type", VATCalculationType);
        VATPostingSetup.SetFilter("VAT %", '>%1', 0);
        if not VATPostingSetup.FindFirst() then
            CreateVATPostingSetupWithAccounts(VATPostingSetup, VATCalculationType, LibraryRandom.RandDecInDecimalRange(10, 25, 0));
    end;

    procedure FindVATPostingSetupInvt(var VATPostingSetup: Record "VAT Posting Setup")
    begin
        VATPostingSetup.SetFilter("VAT Prod. Posting Group", '<>%1', '');
        VATPostingSetup.SetFilter("VAT %", '<>%1', 0);
        VATPostingSetup.SetRange("VAT Calculation Type", VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        if SearchPostingType <> SearchPostingType::Purchase then
            VATPostingSetup.SetFilter("Sales VAT Account", '<>%1', '');
        if SearchPostingType <> SearchPostingType::Sales then
            VATPostingSetup.SetFilter("Purchase VAT Account", '<>%1', '');
        if not VATPostingSetup.FindFirst() then
            CreateVATPostingSetupWithAccounts(VATPostingSetup,
              VATPostingSetup."VAT Calculation Type"::"Normal VAT", LibraryRandom.RandDecInDecimalRange(10, 25, 0));
    end;

    procedure FindZeroVATPostingSetup(var VATPostingSetup: Record "VAT Posting Setup"; VATCalculationType: Enum "Tax Calculation Type")
    begin
        VATPostingSetup.SetFilter("VAT Bus. Posting Group", '<>%1', '');
        VATPostingSetup.SetFilter("VAT Prod. Posting Group", '<>%1', '');
        VATPostingSetup.SetRange("VAT Calculation Type", VATCalculationType);
        VATPostingSetup.SetRange("VAT %", 0);
        if not VATPostingSetup.FindFirst() then
            CreateVATPostingSetupWithAccounts(VATPostingSetup, VATCalculationType, 0);
    end;

    procedure FindUnrealVATPostingSetup(var VATPostingSetup: Record "VAT Posting Setup"; UnrealizedVATType: Option)
    begin
        VATPostingSetup.SetFilter("VAT Bus. Posting Group", '<>%1', '');
        VATPostingSetup.SetFilter("VAT Prod. Posting Group", '<>%1', '');
        VATPostingSetup.SetRange("VAT Calculation Type", VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        VATPostingSetup.SetRange("Unrealized VAT Type", UnrealizedVATType);
        VATPostingSetup.SetFilter("VAT %", '>%1', 0);
        if not VATPostingSetup.FindFirst() then begin
            VATPostingSetup.SetRange("Unrealized VAT Type");
            VATPostingSetup.FindFirst();
            VATPostingSetup."Unrealized VAT Type" := UnrealizedVATType;
            if VATPostingSetup."Sales VAT Unreal. Account" = '' then
                VATPostingSetup.Validate("Sales VAT Unreal. Account", CreateGLAccountNo());
            if VATPostingSetup."Purch. VAT Unreal. Account" = '' then
                VATPostingSetup.Validate("Purch. VAT Unreal. Account", CreateGLAccountNo());
            VATPostingSetup.Modify(true);
        end;
    end;

    procedure FindVendorLedgerEntry(var VendorLedgerEntry: Record "Vendor Ledger Entry"; DocumentType: Enum "Gen. Journal Document Type"; DocumentNo: Code[20])
    begin
        // Finds the matching Vendor Ledger Entry from a General Journal Line.
        VendorLedgerEntry.SetRange("Document Type", DocumentType);
        VendorLedgerEntry.SetRange("Document No.", DocumentNo);
        VendorLedgerEntry.FindFirst();
    end;

    procedure FindEmployeeLedgerEntry(var EmployeeLedgerEntry: Record "Employee Ledger Entry"; DocumentType: Enum "Gen. Journal Document Type"; DocumentNo: Code[20])
    begin
        // Finds the matching Vendor Ledger Entry from a General Journal Line.
        EmployeeLedgerEntry.SetRange("Document Type", DocumentType);
        EmployeeLedgerEntry.SetRange("Document No.", DocumentNo);
        EmployeeLedgerEntry.FindFirst();
    end;

    procedure FindDeferralLine(var DeferralLine: Record "Deferral Line"; DeferralDocType: Enum "Deferral Document Type"; GenJnlBatchName: Code[10]; GenJnlTemplateName: Code[10]; DocType: Integer; DocNo: Code[20]; LineNo: Integer)
    begin
        DeferralLine.SetRange("Deferral Doc. Type", DeferralDocType);
        DeferralLine.SetRange("Gen. Jnl. Batch Name", GenJnlBatchName);
        DeferralLine.SetRange("Gen. Jnl. Template Name", GenJnlTemplateName);
        DeferralLine.SetRange("Document Type", DocType);
        DeferralLine.SetRange("Document No.", DocNo);
        DeferralLine.SetRange("Line No.", LineNo);
        DeferralLine.FindFirst();
    end;

    procedure GetAddReportingCurrency(): Code[10]
    begin
        GeneralLedgerSetup.Get();
        exit(GeneralLedgerSetup."Additional Reporting Currency");
    end;

    procedure GetAllowPostingFrom(): Date
    begin
        GeneralLedgerSetup.Get();
        exit(GeneralLedgerSetup."Allow Posting From");
    end;

    procedure GetAllowPostingTo(): Date
    begin
        GeneralLedgerSetup.Get();
        exit(GeneralLedgerSetup."Allow Posting To");
    end;

    procedure GetAmountRoundingPrecision(): Decimal
    begin
        GeneralLedgerSetup.Get();
        exit(GeneralLedgerSetup."Amount Rounding Precision");
    end;

    procedure GetCurrencyAmountRoundingPrecision(CurrencyCode: Code[10]): Decimal
    var
        Currency: Record Currency;
    begin
        Currency.Initialize(CurrencyCode);
        exit(Currency."Amount Rounding Precision");
    end;

    procedure GetCurrencyCode("Code": Code[10]): Code[10]
    begin
        GeneralLedgerSetup.Get();
        exit(GeneralLedgerSetup.GetCurrencyCode(Code));
    end;

    procedure GetDiscountPaymentTerm(var PaymentTerms: Record "Payment Terms")
    begin
        PaymentTerms.SetFilter("Due Date Calculation", '<>''''');
        PaymentTerms.SetFilter("Discount Date Calculation", '<>''''');
        PaymentTerms.SetFilter("Discount %", '>%1', 0);
        if not PaymentTerms.FindFirst() then
            CreatePaymentTermsDiscount(PaymentTerms, false);
    end;

    procedure GetGlobalDimensionCode(DimNo: Integer): Code[20]
    begin
        GeneralLedgerSetup.Get();
        case DimNo of
            1:
                exit(GeneralLedgerSetup."Global Dimension 1 Code");
            2:
                exit(GeneralLedgerSetup."Global Dimension 2 Code");
        end;
    end;

    procedure GetInvoiceRoundingPrecisionLCY(): Decimal
    begin
        GeneralLedgerSetup.Get();
        exit(GeneralLedgerSetup."Inv. Rounding Precision (LCY)");
    end;

    procedure GetLCYCode(): Code[10]
    begin
        GeneralLedgerSetup.Get();
        exit(GeneralLedgerSetup."LCY Code");
    end;

    procedure GetPaymentTermsDiscountPct(PaymentTerms: Record "Payment Terms"): Decimal
    begin
        exit(PaymentTerms."Discount %");
    end;

    procedure GetShortcutDimensionCode(DimNo: Integer): Code[20]
    begin
        GeneralLedgerSetup.Get();
        case DimNo of
            1:
                exit(GeneralLedgerSetup."Shortcut Dimension 1 Code");
            2:
                exit(GeneralLedgerSetup."Shortcut Dimension 2 Code");
            3:
                exit(GeneralLedgerSetup."Shortcut Dimension 3 Code");
            4:
                exit(GeneralLedgerSetup."Shortcut Dimension 4 Code");
            5:
                exit(GeneralLedgerSetup."Shortcut Dimension 5 Code");
            6:
                exit(GeneralLedgerSetup."Shortcut Dimension 6 Code");
            7:
                exit(GeneralLedgerSetup."Shortcut Dimension 7 Code");
            8:
                exit(GeneralLedgerSetup."Shortcut Dimension 8 Code");
        end;
    end;

    procedure GetUnitAmountRoundingPrecision(): Decimal
    begin
        GeneralLedgerSetup.Get();
        exit(GeneralLedgerSetup."Unit-Amount Rounding Precision");
    end;

    procedure GetCombinedPostedDeferralLines(var TempPostedDeferralLine: Record "Posted Deferral Line" temporary; DocNo: Code[20])
    var
        PostedDeferralLine: Record "Posted Deferral Line";
    begin
        PostedDeferralLine.SetRange("Document No.", DocNo);
        PostedDeferralLine.FindSet();
        repeat
            TempPostedDeferralLine.SetRange("Document No.", DocNo);
            TempPostedDeferralLine.SetRange("Posting Date", PostedDeferralLine."Posting Date");
            if not TempPostedDeferralLine.FindFirst() then begin
                TempPostedDeferralLine.Init();
                TempPostedDeferralLine."Document No." := DocNo;
                TempPostedDeferralLine."Posting Date" := PostedDeferralLine."Posting Date";
                TempPostedDeferralLine.Insert();
            end;
            TempPostedDeferralLine.Amount += PostedDeferralLine.Amount;
            TempPostedDeferralLine.Modify();
        until PostedDeferralLine.Next() = 0;
        TempPostedDeferralLine.SetRange("Document No.");
        TempPostedDeferralLine.SetRange("Posting Date");
    end;

    procedure GetCountryIntrastatCode(CountryRegionCode: Code[10]): Code[10]
    var
        CountryRegion: Record "Country/Region";
    begin
        CountryRegion.Get(CountryRegionCode);
        exit(CountryRegion."Intrastat Code");
    end;

    procedure InvoiceAmountRounding(InvoiceAmont: Decimal; CurrencyCode: Code[10]): Decimal
    var
        Currency: Record Currency;
    begin
        // Round Invoice Amount.
        Currency.Initialize(CurrencyCode);
        exit(Round(InvoiceAmont, Currency."Invoice Rounding Precision", Currency.InvoiceRoundingDirection()));
    end;

    procedure IssueFinanceChargeMemo(FinanceChargeMemoHeader: Record "Finance Charge Memo Header")
    var
        IssueFinanceChargeMemos: Report "Issue Finance Charge Memos";
    begin
        FinanceChargeMemoHeader.SetRange("No.", FinanceChargeMemoHeader."No.");
        Clear(IssueFinanceChargeMemos);
        IssueFinanceChargeMemos.SetTableView(FinanceChargeMemoHeader);
        IssueFinanceChargeMemos.UseRequestPage(false);
        IssueFinanceChargeMemos.Run();
    end;

    procedure PostCustLedgerApplication(CustLedgerEntry: Record "Cust. Ledger Entry")
    begin
        // Post Application Entries.
        CODEUNIT.Run(CODEUNIT::"CustEntry-Apply Posted Entries", CustLedgerEntry);
    end;

    procedure PostGeneralJnlLine(GenJournalLine: Record "Gen. Journal Line")
    begin
        CODEUNIT.Run(CODEUNIT::"Gen. Jnl.-Post Batch", GenJournalLine);
    end;

    procedure PostFAJournalLine(FAJournalLine: Record "FA Journal Line")
    begin
        CODEUNIT.Run(CODEUNIT::"FA Jnl.-Post Batch", FAJournalLine);
    end;

    procedure PostVendLedgerApplication(VendorLedgerEntry: Record "Vendor Ledger Entry")
    begin
        // Post Application Entries.
        CODEUNIT.Run(CODEUNIT::"VendEntry-Apply Posted Entries", VendorLedgerEntry);
    end;

    procedure PostEmplLedgerApplication(EmployeeLedgerEntry: Record "Employee Ledger Entry")
    begin
        // Post Application Entries.
        CODEUNIT.Run(CODEUNIT::"EmplEntry-Apply Posted Entries", EmployeeLedgerEntry);
    end;

    procedure PostBankAccReconciliation(BankAccReconciliation: Record "Bank Acc. Reconciliation")
    begin
        CODEUNIT.Run(CODEUNIT::"Bank Acc. Reconciliation Post", BankAccReconciliation);
    end;

    procedure ReverseTransaction(TransactionNo: Integer)
    var
        ReversalEntry: Record "Reversal Entry";
    begin
        ReversalEntry.SetHideDialog(true);
        ReversalEntry.ReverseTransaction(TransactionNo);
    end;

    procedure RunAddnlReportingCurrency(CurrencyCode: Code[10]; DocumentNo: Code[20]; NewRetainedEarningsGLAccNo: Code[20])
    var
        AdjustAddReportingCurrency: Report "Adjust Add. Reporting Currency";
    begin
        // Run Additional Currency Reporting Report for ACY.
        AdjustAddReportingCurrency.SetAddCurr(CurrencyCode);
        AdjustAddReportingCurrency.InitializeRequest(DocumentNo, NewRetainedEarningsGLAccNo);
        AdjustAddReportingCurrency.UseRequestPage(false);
        AdjustAddReportingCurrency.Run();
    end;

    // New Exch. rate adjustment for v.20
    procedure RunExchRateAdjustmentForDocNo(CurrencyCode: Code[10]; DocumentNo: Code[20])
    begin
        RunExchRateAdjustment(CurrencyCode, 0D, WorkDate(), 'Test', WorkDate(), DocumentNo, false);
    end;

    procedure RunExchRateAdjustmentForDocNo(CurrencyCode: Code[10]; DocumentNo: Code[20]; EndDate: Date)
    begin
        RunExchRateAdjustment(CurrencyCode, 0D, EndDate, 'Test', EndDate, DocumentNo, false);
    end;

    procedure RunExchRateAdjustmentSimple(CurrencyCode: Code[10]; EndDate: Date; PostingDate: Date)
    begin
        RunExchRateAdjustment(
          CurrencyCode, 0D, EndDate, 'Test', PostingDate, LibraryUtility.GenerateGUID(), false);
    end;

    procedure RunExchRateAdjustment(CurrencyCode: Code[10]; StartDate: Date; EndDate: Date; PostingDescription: Text[50]; PostingDate: Date; PostingDocNo: Code[20]; AdjGLAcc: Boolean)
    var
        Currency: Record Currency;
        ExchRateAdjustment: Report "Exch. Rate Adjustment";
    begin
        Currency.SetRange(Code, CurrencyCode);
        ExchRateAdjustment.SetTableView(Currency);
        ExchRateAdjustment.InitializeRequest2(
            StartDate, EndDate, PostingDescription, PostingDate, PostingDocNo, true, AdjGLAcc);
        ExchRateAdjustment.UseRequestPage(false);
        ExchRateAdjustment.SetHideUI(true);
        ExchRateAdjustment.Run();
    end;

    procedure RunAdjustGenJournalBalance(var GenJournalLine: Record "Gen. Journal Line")
    begin
        CODEUNIT.Run(CODEUNIT::"Adjust Gen. Journal Balance", GenJournalLine);
    end;

    [Scope('OnPrem')]
    procedure RunReminderIssue(var ReminderIssue: Codeunit "Reminder-Issue")
    begin
        ReminderIssue.Run();
    end;

    [Scope('OnPrem')]
    procedure RunFinChrgMemoIssue(var FinChrgMemoIssue: Codeunit "FinChrgMemo-Issue")
    begin
        FinChrgMemoIssue.Run();
    end;

    procedure SelectLastGenJnBatch(var GenJournalBatch: Record "Gen. Journal Batch")
    var
        GLAccount: Record "G/L Account";
    begin
        GenJournalBatch.SetRange("Journal Template Name", SelectGenJnlTemplate());
        GenJournalBatch.SetRange("Bal. Account Type", GenJournalBatch."Bal. Account Type"::"G/L Account");
        CreateGLAccount(GLAccount);
        GenJournalBatch.FindLast();
        GenJournalBatch.Validate("Bal. Account No.", GLAccount."No.");
        GenJournalBatch.Modify(true);
    end;

    procedure SelectGenJnlBatch(var GenJournalBatch: Record "Gen. Journal Batch")
    begin
        LibraryJournals.SelectGenJournalBatch(GenJournalBatch, SelectGenJnlTemplate());
    end;

    procedure SelectGenJnlTemplate(): Code[10]
    var
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        exit(LibraryJournals.SelectGenJournalTemplate(GenJournalTemplate.Type::General, PAGE::"General Journal"));
    end;

    procedure SelectFAJournalBatch(var FAJournalBatch: Record "FA Journal Batch")
    begin
        // Select FA Journal Batch Name for FA Journal Line.
        FAJournalBatch.SetRange("Journal Template Name", SelectFAJournalTemplate());
        if FAJournalBatch.FindFirst() then
            exit;
        // Create New FA Journal Batch.
        FAJournalBatch.Init();
        FAJournalBatch.Validate("Journal Template Name", SelectFAJournalTemplate());
        FAJournalBatch.Validate(Name,
          CopyStr(LibraryUtility.GenerateRandomCode(FAJournalBatch.FieldNo(Name), DATABASE::"FA Journal Batch"),
            1, LibraryUtility.GetFieldLength(DATABASE::"FA Journal Batch", FAJournalBatch.FieldNo(Name))));
        FAJournalBatch.Insert(true);
        FAJournalBatch.Validate("No. Series", CreateNoSeriesCode());
        FAJournalBatch.Modify(true);
    end;

    procedure SelectFAJournalTemplate(): Code[10]
    var
        FAJournalTemplate: Record "FA Journal Template";
    begin
        // Select FA Journal Template Name for FA Journal Line.
        FAJournalTemplate.SetRange(Recurring, false);
        if not FAJournalTemplate.FindFirst() then begin
            FAJournalTemplate.Init();
            FAJournalTemplate.Validate(
              Name, CopyStr(LibraryUtility.GenerateRandomCode(FAJournalTemplate.FieldNo(Name), DATABASE::"FA Journal Template"),
                1, LibraryUtility.GetFieldLength(DATABASE::"FA Journal Template", FAJournalTemplate.FieldNo(Name))));
            FAJournalTemplate.Validate(Recurring, false);
            FAJournalTemplate.Insert(true);
        end;
        exit(FAJournalTemplate.Name);
    end;

    procedure SetBlockDeleteGLAccount(NewValue: Boolean) OldValue: Boolean
    begin
        GeneralLedgerSetup.SetLoadFields("Block Deletion of G/L Accounts");
        GeneralLedgerSetup.Get();
        OldValue := GeneralLedgerSetup."Block Deletion of G/L Accounts";
        GeneralLedgerSetup.Validate("Block Deletion of G/L Accounts", NewValue);
        GeneralLedgerSetup.Modify(true);
    end;

    procedure SetCurrencyGainLossAccounts(var Currency: Record Currency)
    begin
        Currency.Validate("Realized Losses Acc.", CreateGLAccountNo());
        Currency.Validate("Realized Gains Acc.", CreateGLAccountNo());
        Currency.Validate("Unrealized Losses Acc.", CreateGLAccountNo());
        Currency.Validate("Unrealized Gains Acc.", CreateGLAccountNo());
        Currency.Modify(true);
    end;

    procedure SetAddReportingCurrency(AdditionalReportingCurrency: Code[10])
    begin
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup."Additional Reporting Currency" := AdditionalReportingCurrency;
        GeneralLedgerSetup.Modify(true);
    end;

    procedure SetAllowDDExportWitoutIBANAndSWIFT(ExportWithoutIBANAndSWIFT: Boolean)
    begin
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup.Validate("SEPA Export w/o Bank Acc. Data", ExportWithoutIBANAndSWIFT);
        GeneralLedgerSetup.Modify(true);
    end;

    procedure SetAllowNonEuroExport(AllowNonEuroExport: Boolean)
    begin
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup.Validate("SEPA Non-Euro Export", AllowNonEuroExport);
        GeneralLedgerSetup.Modify(true);
    end;

    procedure SetAllowPostingFromTo(FromDate: Date; ToDate: Date)
    begin
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup."Allow Posting From" := FromDate;
        GeneralLedgerSetup."Allow Posting To" := ToDate;
        GeneralLedgerSetup.Modify(true);
    end;

    procedure SetAllowPostingTo(ToDate: Date)
    begin
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup."Allow Posting To" := ToDate;
        GeneralLedgerSetup.Modify(true);
    end;

    procedure SetAmountRoundingPrecision(AmountRoundingPrecision: Decimal)
    begin
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup."Amount Rounding Precision" := AmountRoundingPrecision;
        GeneralLedgerSetup.Modify(true);
    end;

    procedure SetApplnRoundingPrecision(ApplnRoundingPrecision: Decimal)
    begin
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup.Validate("Appln. Rounding Precision", ApplnRoundingPrecision);
        GeneralLedgerSetup.Modify(true);
    end;

    procedure SetBillToSellToVATCalc(BillToSellToVATCalc: Enum "G/L Setup VAT Calculation")
    begin
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup.Validate("Bill-to/Sell-to VAT Calc.", BillToSellToVATCalc);
        GeneralLedgerSetup.Modify(true);
    end;

    procedure SetGlobalDimensionCode(DimNo: Integer; DimCode: Code[20])
    begin
        GeneralLedgerSetup.Get();
        case DimNo of
            1:
                GeneralLedgerSetup.Validate("Global Dimension 1 Code", DimCode);
            2:
                GeneralLedgerSetup.Validate("Global Dimension 2 Code", DimCode);
        end;
        GeneralLedgerSetup.Modify(true);
    end;

    procedure SetAppliestoIdCustomer(var CustLedgerEntry: Record "Cust. Ledger Entry")
    begin
        // Set Applies-to ID.
        CustLedgerEntry.LockTable();
        CustLedgerEntry.FindFirst();
        repeat
            CustLedgerEntry.TestField(Open, true);
            CustLedgerEntry.Validate("Applies-to ID", UserId);
            if CustLedgerEntry."Amount to Apply" = 0 then begin
                CustLedgerEntry.CalcFields("Remaining Amount");
                CustLedgerEntry.Validate("Amount to Apply", CustLedgerEntry."Remaining Amount");
            end;
            CustLedgerEntry.Modify(true);
        until CustLedgerEntry.Next() = 0;
    end;

    procedure SetAppliestoIdVendor(var VendorLedgerEntry: Record "Vendor Ledger Entry")
    begin
        // Set Applies-to ID.
        VendorLedgerEntry.LockTable();
        VendorLedgerEntry.FindFirst();
        repeat
            VendorLedgerEntry.TestField(Open, true);
            VendorLedgerEntry.Validate("Applies-to ID", UserId);
            if VendorLedgerEntry."Amount to Apply" = 0 then begin
                VendorLedgerEntry.CalcFields("Remaining Amount");
                VendorLedgerEntry.Validate("Amount to Apply", VendorLedgerEntry."Remaining Amount");
            end;
            VendorLedgerEntry.Modify(true);
        until VendorLedgerEntry.Next() = 0;
    end;

    procedure SetAppliestoIdEmployee(var EmployeeLedgerEntry: Record "Employee Ledger Entry")
    begin
        // Set Applies-to ID.
        EmployeeLedgerEntry.LockTable();
        EmployeeLedgerEntry.FindFirst();
        repeat
            EmployeeLedgerEntry.TestField(Open, true);
            EmployeeLedgerEntry.Validate("Applies-to ID", UserId);
            if EmployeeLedgerEntry."Amount to Apply" = 0 then begin
                EmployeeLedgerEntry.CalcFields("Remaining Amount");
                EmployeeLedgerEntry.Validate("Amount to Apply", EmployeeLedgerEntry."Remaining Amount");
            end;
            EmployeeLedgerEntry.Modify(true);
        until EmployeeLedgerEntry.Next() = 0;
    end;

    procedure SetApplyCustomerEntry(var CustLedgerEntry: Record "Cust. Ledger Entry"; AmountToApply: Decimal)
    var
        CustLedgerEntry2: Record "Cust. Ledger Entry";
    begin
        // Clear any existing applying entries.
        CustLedgerEntry2.SetRange("Applying Entry", true);
        CustLedgerEntry2.SetFilter("Entry No.", '<>%1', CustLedgerEntry."Entry No.");
        if CustLedgerEntry2.FindSet() then
            repeat
                CustLedgerEntry2.Validate("Applying Entry", false);
                CustLedgerEntry2.Modify(true);
            until CustLedgerEntry2.Next() = 0;

        // Clear Applies-to IDs
        CustLedgerEntry2.Reset();
        CustLedgerEntry2.SetFilter("Applies-to ID", '<>%1', '');
        if CustLedgerEntry2.FindSet() then
            repeat
                CustLedgerEntry2.Validate("Applies-to ID", '');
                CustLedgerEntry2.Modify(true);
            until CustLedgerEntry2.Next() = 0;

        // Apply Payment Entry on Posted Invoice.
        CustLedgerEntry.Validate("Applying Entry", true);
        CustLedgerEntry.Validate("Applies-to ID", UserId);
        CustLedgerEntry.Validate("Amount to Apply", AmountToApply);
        CustLedgerEntry.Modify(true);
        CODEUNIT.Run(CODEUNIT::"Cust. Entry-Edit", CustLedgerEntry);
        Commit();
    end;

    procedure SetApplyVendorEntry(var VendorLedgerEntry: Record "Vendor Ledger Entry"; AmountToApply: Decimal)
    var
        VendorLedgerEntry2: Record "Vendor Ledger Entry";
    begin
        // Clear any existing applying entries.
        VendorLedgerEntry2.SetRange("Applying Entry", true);
        VendorLedgerEntry2.SetFilter("Entry No.", '<>%1', VendorLedgerEntry."Entry No.");
        if VendorLedgerEntry2.FindSet() then
            repeat
                VendorLedgerEntry2.Validate("Applying Entry", false);
                VendorLedgerEntry2.Modify(true);
            until VendorLedgerEntry2.Next() = 0;

        // Clear Applies-to IDs.
        VendorLedgerEntry2.Reset();
        VendorLedgerEntry2.SetFilter("Applies-to ID", '<>%1', '');
        if VendorLedgerEntry2.FindSet() then
            repeat
                VendorLedgerEntry2.Validate("Applies-to ID", '');
                VendorLedgerEntry2.Modify(true);
            until VendorLedgerEntry2.Next() = 0;

        // Apply Payment Entry on Posted Invoice.
        VendorLedgerEntry.Validate("Applying Entry", true);
        VendorLedgerEntry.Validate("Applies-to ID", UserId);
        VendorLedgerEntry.Validate("Amount to Apply", AmountToApply);
        VendorLedgerEntry.Modify(true);
        CODEUNIT.Run(CODEUNIT::"Vend. Entry-Edit", VendorLedgerEntry);
    end;

    procedure SetApplyEmployeeEntry(var EmployeeLedgerEntry: Record "Employee Ledger Entry"; AmountToApply: Decimal)
    var
        EmployeeLedgerEntry2: Record "Employee Ledger Entry";
    begin
        // Clear any existing applying entries.
        EmployeeLedgerEntry2.SetRange("Applying Entry", true);
        EmployeeLedgerEntry2.SetFilter("Entry No.", '<>%1', EmployeeLedgerEntry."Entry No.");
        if EmployeeLedgerEntry2.FindSet() then
            repeat
                EmployeeLedgerEntry2.Validate("Applying Entry", false);
                EmployeeLedgerEntry2.Modify(true);
            until EmployeeLedgerEntry2.Next() = 0;

        // Clear Applies-to IDs.
        EmployeeLedgerEntry2.Reset();
        EmployeeLedgerEntry2.SetFilter("Applies-to ID", '<>%1', '');
        if EmployeeLedgerEntry2.FindSet() then
            repeat
                EmployeeLedgerEntry2.Validate("Applies-to ID", '');
                EmployeeLedgerEntry2.Modify(true);
            until EmployeeLedgerEntry2.Next() = 0;

        // Apply Payment Entry on Posted Invoice.
        EmployeeLedgerEntry.Validate("Applying Entry", true);
        EmployeeLedgerEntry.Validate("Applies-to ID", UserId);
        EmployeeLedgerEntry.Validate("Amount to Apply", AmountToApply);
        EmployeeLedgerEntry.Modify(true);
        CODEUNIT.Run(CODEUNIT::"Empl. Entry-Edit", EmployeeLedgerEntry);
    end;

    procedure SetEnableDataCheck(EnableDataCheck: Boolean)
    begin
        GeneralLedgerSetup.Get();
        if GeneralLedgerSetup."Enable Data Check" <> EnableDataCheck then begin
            GeneralLedgerSetup."Enable Data Check" := EnableDataCheck;
            GeneralLedgerSetup.Modify();
        end;
    end;

    procedure SetGLAccountDirectPostingFilter(var GLAccount: Record "G/L Account")
    begin
        GLAccount.SetRange(Blocked, false);
        GLAccount.SetRange("Account Type", GLAccount."Account Type"::Posting);
        GLAccount.SetRange("Direct Posting", true);
    end;

    procedure SetGLAccountNotBlankGroupsFilter(var GLAccount: Record "G/L Account")
    begin
        GLAccount.SetFilter("Gen. Bus. Posting Group", '<>%1', '');
        GLAccount.SetFilter("Gen. Prod. Posting Group", '<>%1', '');
        GLAccount.SetFilter("VAT Prod. Posting Group", '<>%1', '');
    end;

    procedure SetGeneralPostingSetupInvtAccounts(var GeneralPostingSetup: Record "General Posting Setup")
    begin
        if GeneralPostingSetup."COGS Account" = '' then
            GeneralPostingSetup.Validate("COGS Account", CreateGLAccountNo());
        if GeneralPostingSetup."COGS Account (Interim)" = '' then
            GeneralPostingSetup.Validate("COGS Account (Interim)", CreateGLAccountNo());
        if GeneralPostingSetup."Inventory Adjmt. Account" = '' then
            GeneralPostingSetup.Validate("Inventory Adjmt. Account", CreateGLAccountNo());
        if GeneralPostingSetup."Invt. Accrual Acc. (Interim)" = '' then
            GeneralPostingSetup.Validate("Invt. Accrual Acc. (Interim)", CreateGLAccountNo());
    end;

    procedure SetGeneralPostingSetupMfgAccounts(var GeneralPostingSetup: Record "General Posting Setup")
    begin
        if GeneralPostingSetup."Direct Cost Applied Account" = '' then
            GeneralPostingSetup.Validate("Direct Cost Applied Account", CreateGLAccountNo());
        if GeneralPostingSetup."Overhead Applied Account" = '' then
            GeneralPostingSetup.Validate("Overhead Applied Account", CreateGLAccountNo());
        if GeneralPostingSetup."Purchase Variance Account" = '' then
            GeneralPostingSetup.Validate("Purchase Variance Account", CreateGLAccountNo());
    end;

    procedure SetGeneralPostingSetupPrepAccounts(var GeneralPostingSetup: Record "General Posting Setup")
    begin
        if GeneralPostingSetup."Sales Prepayments Account" = '' then
            GeneralPostingSetup.Validate("Sales Prepayments Account", CreateGLAccountNo());
        if GeneralPostingSetup."Purch. Prepayments Account" = '' then
            GeneralPostingSetup.Validate("Purch. Prepayments Account", CreateGLAccountNo());
    end;

    procedure SetGeneralPostingSetupPurchAccounts(var GeneralPostingSetup: Record "General Posting Setup")
    begin
        if GeneralPostingSetup."Purch. Account" = '' then
            GeneralPostingSetup.Validate("Purch. Account", CreateGLAccountNo());
        if GeneralPostingSetup."Purch. Line Disc. Account" = '' then
            GeneralPostingSetup.Validate("Purch. Line Disc. Account", CreateGLAccountNo());
        if GeneralPostingSetup."Purch. Inv. Disc. Account" = '' then
            GeneralPostingSetup.Validate("Purch. Inv. Disc. Account", CreateGLAccountNo());
        if GeneralPostingSetup."Purch. Credit Memo Account" = '' then
            GeneralPostingSetup.Validate("Purch. Credit Memo Account", CreateGLAccountNo());
    end;

    procedure SetGeneralPostingSetupPurchPmtDiscAccounts(var GeneralPostingSetup: Record "General Posting Setup")
    begin
        if GeneralPostingSetup."Purch. Pmt. Disc. Debit Acc." = '' then
            GeneralPostingSetup.Validate("Purch. Pmt. Disc. Debit Acc.", CreateGLAccountNo());
        if GeneralPostingSetup."Purch. Pmt. Disc. Credit Acc." = '' then
            GeneralPostingSetup.Validate("Purch. Pmt. Disc. Credit Acc.", CreateGLAccountNo());
        if GeneralPostingSetup."Purch. Pmt. Tol. Debit Acc." = '' then
            GeneralPostingSetup.Validate("Purch. Pmt. Tol. Debit Acc.", CreateGLAccountNo());
        if GeneralPostingSetup."Purch. Pmt. Tol. Credit Acc." = '' then
            GeneralPostingSetup.Validate("Purch. Pmt. Tol. Credit Acc.", CreateGLAccountNo());
    end;

    procedure SetGeneralPostingSetupSalesAccounts(var GeneralPostingSetup: Record "General Posting Setup")
    begin
        if GeneralPostingSetup."Sales Account" = '' then
            GeneralPostingSetup.Validate("Sales Account", CreateGLAccountNo());
        if GeneralPostingSetup."Sales Line Disc. Account" = '' then
            GeneralPostingSetup.Validate("Sales Line Disc. Account", CreateGLAccountNo());
        if GeneralPostingSetup."Sales Inv. Disc. Account" = '' then
            GeneralPostingSetup.Validate("Sales Inv. Disc. Account", CreateGLAccountNo());
        if GeneralPostingSetup."Sales Credit Memo Account" = '' then
            GeneralPostingSetup.Validate("Sales Credit Memo Account", CreateGLAccountNo());
    end;

    procedure SetGeneralPostingSetupSalesPmtDiscAccounts(var GeneralPostingSetup: Record "General Posting Setup")
    begin
        if GeneralPostingSetup."Sales Pmt. Disc. Debit Acc." = '' then
            GeneralPostingSetup.Validate("Sales Pmt. Disc. Debit Acc.", CreateGLAccountNo());
        if GeneralPostingSetup."Sales Pmt. Disc. Credit Acc." = '' then
            GeneralPostingSetup.Validate("Sales Pmt. Disc. Credit Acc.", CreateGLAccountNo());
        if GeneralPostingSetup."Sales Pmt. Tol. Debit Acc." = '' then
            GeneralPostingSetup.Validate("Sales Pmt. Tol. Debit Acc.", CreateGLAccountNo());
        if GeneralPostingSetup."Sales Pmt. Tol. Credit Acc." = '' then
            GeneralPostingSetup.Validate("Sales Pmt. Tol. Credit Acc.", CreateGLAccountNo());
    end;

    local procedure SetPostingGroupsOnPrepmtGLAccount(var GLAccount: Record "G/L Account"; GenPostingSetup: Record "General Posting Setup"; GenPostingType: Enum "General Posting Type"; VATCalcType: Enum "Tax Calculation Type"; SetupGLAccount: Record "G/L Account")
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        GLAccount."Gen. Posting Type" := GenPostingType;
        GLAccount."Gen. Bus. Posting Group" := GenPostingSetup."Gen. Bus. Posting Group";
        GLAccount."Gen. Prod. Posting Group" := GenPostingSetup."Gen. Prod. Posting Group";
        CreatePrepaymentVATPostingSetup(VATPostingSetup, VATCalcType, GenPostingType, SetupGLAccount, GLAccount."No.");
        GLAccount."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        GLAccount."VAT Prod. Posting Group" := VATPostingSetup."VAT Prod. Posting Group";
        GLAccount."Income/Balance" := GLAccount."Income/Balance"::"Balance Sheet";
        GLAccount."Direct Posting" := true;
        GLAccount.Modify();
    end;

    procedure SetInvRoundingPrecisionLCY(InvRoundingPrecisionLCY: Decimal)
    begin
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup.Validate("Inv. Rounding Precision (LCY)", InvRoundingPrecisionLCY);
        GeneralLedgerSetup.Modify(true);
    end;

    procedure SetMaxVATDifferenceAllowed(MaxVATDifferenceAllowed: Decimal)
    begin
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup.Validate("Max. VAT Difference Allowed", MaxVATDifferenceAllowed);
        GeneralLedgerSetup.Modify(true);
    end;

    procedure SetLCYCode(LCYCode: Code[10])
    begin
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup."LCY Code" := '';        // to avoid error on updating LCY Code
        GeneralLedgerSetup.Validate("LCY Code", LCYCode);
        GeneralLedgerSetup.Modify(true);
    end;

    procedure SetSearchGenPostingTypeAll()
    begin
        SearchPostingType := SearchPostingType::All;
    end;

    procedure SetSearchGenPostingTypePurch()
    begin
        SearchPostingType := SearchPostingType::Purchase;
    end;

    procedure SetSearchGenPostingTypeSales()
    begin
        SearchPostingType := SearchPostingType::Sales;
    end;

    procedure SetShortcutDimensionCode(DimNo: Integer; DimCode: Code[20])
    begin
        GeneralLedgerSetup.Get();
        case DimNo of
            1:
                GeneralLedgerSetup.Validate("Shortcut Dimension 1 Code", DimCode);
            2:
                GeneralLedgerSetup.Validate("Shortcut Dimension 2 Code", DimCode);
            3:
                GeneralLedgerSetup.Validate("Shortcut Dimension 3 Code", DimCode);
            4:
                GeneralLedgerSetup.Validate("Shortcut Dimension 4 Code", DimCode);
            5:
                GeneralLedgerSetup.Validate("Shortcut Dimension 5 Code", DimCode);
            6:
                GeneralLedgerSetup.Validate("Shortcut Dimension 6 Code", DimCode);
            7:
                GeneralLedgerSetup.Validate("Shortcut Dimension 7 Code", DimCode);
            8:
                GeneralLedgerSetup.Validate("Shortcut Dimension 8 Code", DimCode);
        end;
        GeneralLedgerSetup.Modify(true);
    end;

    procedure SetUnrealizedVAT(UnrealizedVAT: Boolean)
    begin
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup.Validate("Unrealized VAT", UnrealizedVAT);
        GeneralLedgerSetup.Modify(true);
    end;

    procedure SetVATRoundingType(Direction: Text[1])
    begin
        GeneralLedgerSetup.Get();
        case Direction of
            '<':
                GeneralLedgerSetup."VAT Rounding Type" := GeneralLedgerSetup."VAT Rounding Type"::Down;
            '>':
                GeneralLedgerSetup."VAT Rounding Type" := GeneralLedgerSetup."VAT Rounding Type"::Up;
            '=':
                GeneralLedgerSetup."VAT Rounding Type" := GeneralLedgerSetup."VAT Rounding Type"::Nearest;
        end;
        GeneralLedgerSetup.Modify(true);
    end;

    procedure SetWorkDate()
    var
        GLEntry: Record "G/L Entry";
        OK: Boolean;
    begin
        // Set workdate to date of last transaction or today
        GLEntry.SetCurrentKey("G/L Account No.", "Posting Date");
        OK := true;
        repeat
            GLEntry.SetFilter("G/L Account No.", '>%1', GLEntry."G/L Account No.");
            GLEntry.SetFilter("Posting Date", '>%1', GLEntry."Posting Date");
            if GLEntry.FindFirst() then begin
                GLEntry.SetRange("G/L Account No.", GLEntry."G/L Account No.");
                GLEntry.SetRange("Posting Date");
                GLEntry.FindLast();
            end else
                OK := false
        until not OK;

        if GLEntry."Posting Date" = 0D then
            WorkDate := Today
        else
            WorkDate := NormalDate(GLEntry."Posting Date");
    end;

    procedure SetupReportSelection(ReportUsage: Enum "Report Selection Usage"; ReportId: Integer)
    var
        ReportSelections: Record "Report Selections";
    begin
        ReportSelections.SetRange(Usage, ReportUsage);
        ReportSelections.DeleteAll();
        ReportSelections.Init();
        ReportSelections.Validate(Usage, ReportUsage);
        ReportSelections.Validate(Sequence, '1');
        ReportSelections.Validate("Report ID", ReportId);
        ReportSelections.Insert(true);
    end;

    procedure SuggestBankAccountReconciliation(var BankAccReconciliation: Record "Bank Acc. Reconciliation"; BankAccount: Record "Bank Account"; StatementType: Enum "Bank Acc. Rec. Stmt. Type"; IncludeChecks: Boolean)
    var
        SuggestBankAccReconLines: Report "Suggest Bank Acc. Recon. Lines";
    begin
        CreateBankAccReconciliation(BankAccReconciliation, BankAccount."No.", StatementType);

        SuggestBankAccReconLines.SetStmt(BankAccReconciliation);
        SuggestBankAccReconLines.SetTableView(BankAccount);
        SuggestBankAccReconLines.InitializeRequest(WorkDate(), WorkDate(), IncludeChecks);
        SuggestBankAccReconLines.UseRequestPage(false);

        SuggestBankAccReconLines.Run();
    end;

    procedure UnapplyCustomerLedgerEntry(CustLedgerEntry: Record "Cust. Ledger Entry")
    begin
        LibraryERMUnapply.UnapplyCustomerLedgerEntry(CustLedgerEntry);
    end;

    procedure UnapplyVendorLedgerEntry(VendorLedgerEntry: Record "Vendor Ledger Entry")
    begin
        LibraryERMUnapply.UnapplyVendorLedgerEntry(VendorLedgerEntry);
    end;

    procedure UnapplyEmployeeLedgerEntry(EmployeeLedgerEntry: Record "Employee Ledger Entry")
    begin
        LibraryERMUnapply.UnapplyEmployeeLedgerEntry(EmployeeLedgerEntry);
    end;

    procedure UpdateAnalysisView(var AnalysisView: Record "Analysis View")
    begin
        CODEUNIT.Run(CODEUNIT::"Update Analysis View", AnalysisView)
    end;

    procedure UpdateGenPostingSetupPrepmtAccounts(var GeneralPostingSetup: Record "General Posting Setup")
    begin
        GeneralPostingSetup.Validate("Sales Prepayments Account", CreateGLAccountWithSalesSetup());
        GeneralPostingSetup.Validate("Purch. Prepayments Account", CreateGLAccountWithPurchSetup());
        GeneralPostingSetup.Modify();
    end;

    procedure UpdateGLAccountWithPostingSetup(var GLAccount: Record "G/L Account"; GenPostingType: Enum "General Posting Type"; GeneralPostingSetup: Record "General Posting Setup"; VATPostingSetup: Record "VAT Posting Setup")
    begin
        GLAccount.Validate("Gen. Posting Type", GenPostingType);
        GLAccount.Validate("Gen. Bus. Posting Group", GeneralPostingSetup."Gen. Bus. Posting Group");
        GLAccount.Validate("Gen. Prod. Posting Group", GeneralPostingSetup."Gen. Prod. Posting Group");
        GLAccount.Validate("VAT Bus. Posting Group", VATPostingSetup."VAT Bus. Posting Group");
        GLAccount.Validate("VAT Prod. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
        GLAccount.Modify(true);
    end;

    procedure UpdateVATPostingSetup(var VATPostingSetup: Record "VAT Posting Setup"; VATPercent: Integer)
    begin
        FindVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        VATPostingSetup."VAT %" := VATPercent;
        VATPostingSetup.Modify(true);
    end;

    procedure UpdateCompanyAddress()
    var
        CompanyInformation: Record "Company Information";
        PostCode: Record "Post Code";
    begin
        if not CompanyInformation.Get() then
            CompanyInformation.Insert(true);

        CompanyInformation.Validate(Name, LibraryUtility.GenerateRandomText(MaxStrLen(CompanyInformation.Name)));
        CompanyInformation.Validate("Name 2", LibraryUtility.GenerateRandomText(MaxStrLen(CompanyInformation."Name 2")));
        CompanyInformation.Validate(Address, LibraryUtility.GenerateRandomText(MaxStrLen(CompanyInformation.Address)));
        CompanyInformation.Validate("Address 2", LibraryUtility.GenerateRandomText(MaxStrLen(CompanyInformation."Address 2")));
        CompanyInformation.Validate(Name, LibraryUtility.GenerateRandomText(MaxStrLen(CompanyInformation.Name)));
        FindPostCode(PostCode);

        CompanyInformation.Validate("Post Code", PostCode.Code);
        CompanyInformation.Modify(true);
    end;

    procedure UpdateSalesPrepmtAccountVATGroup(GenBusPostingGroupCode: Code[20]; GenProdPostingGroupCode: Code[20]; NewVATProdPostingGroupCode: Code[20])
    var
        GeneralPostingSetup: Record "General Posting Setup";
        GLAccount: Record "G/L Account";
    begin
        GeneralPostingSetup.Get(GenBusPostingGroupCode, GenProdPostingGroupCode);
        GLAccount.Get(GeneralPostingSetup."Sales Prepayments Account");
        GLAccount."VAT Prod. Posting Group" := NewVATProdPostingGroupCode;
        GLAccount.Modify();
    end;

    procedure UpdatePurchPrepmtAccountVATGroup(GenBusPostingGroupCode: Code[20]; GenProdPostingGroupCode: Code[20]; NewVATProdPostingGroupCode: Code[20])
    var
        GeneralPostingSetup: Record "General Posting Setup";
        GLAccount: Record "G/L Account";
    begin
        GeneralPostingSetup.Get(GenBusPostingGroupCode, GenProdPostingGroupCode);
        GLAccount.Get(GeneralPostingSetup."Purch. Prepayments Account");
        GLAccount."VAT Prod. Posting Group" := NewVATProdPostingGroupCode;
        GLAccount.Modify();
    end;

    procedure VATAmountRounding(VATAmount: Decimal; CurrencyCode: Code[10]): Decimal
    var
        Currency: Record Currency;
    begin
        // Round VAT Entry Amount.
        Currency.InitRoundingPrecision();
        if CurrencyCode <> '' then
            Currency.Get(CurrencyCode);

        exit(Round(VATAmount, Currency."Amount Rounding Precision", Currency.VATRoundingDirection()));
    end;

    procedure VerifyVendApplnWithZeroTransNo(DocumentNo: Code[20]; DocumentType: Enum "Gen. Journal Document Type"; AmountLCY: Decimal)
    var
        DtldVendLedgEntry: Record "Detailed Vendor Ledg. Entry";
    begin
        DtldVendLedgEntry.SetRange("Document Type", DocumentType);
        DtldVendLedgEntry.SetRange("Document No.", DocumentNo);
        DtldVendLedgEntry.SetRange("Entry Type", DtldVendLedgEntry."Entry Type"::Application);
        DtldVendLedgEntry.FindLast();
        DtldVendLedgEntry.TestField("Transaction No.", 0);
        DtldVendLedgEntry.TestField("Application No.");
        DtldVendLedgEntry.TestField("Amount (LCY)", AmountLCY);
    end;

    procedure VerifyCustApplnWithZeroTransNo(DocumentNo: Code[20]; DocumentType: Enum "Gen. Journal Document Type"; AmountLCY: Decimal)
    var
        DtldCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
    begin
        DtldCustLedgEntry.SetRange("Document Type", DocumentType);
        DtldCustLedgEntry.SetRange("Document No.", DocumentNo);
        DtldCustLedgEntry.SetRange("Entry Type", DtldCustLedgEntry."Entry Type"::Application);
        DtldCustLedgEntry.FindLast();
        DtldCustLedgEntry.TestField("Transaction No.", 0);
        DtldCustLedgEntry.TestField("Application No.");
        DtldCustLedgEntry.TestField("Amount (LCY)", AmountLCY);
    end;

    procedure UpdateAmountOnGenJournalLine(GenJournalBatch: Record "Gen. Journal Batch"; var GeneralJournal: TestPage "General Journal")
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        GeneralJournal.OK().Invoke();  // Need to close the Page to ensure changes are reflected on Record Variable.
        GenJournalLine.SetRange("Journal Template Name", GenJournalBatch."Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", GenJournalBatch.Name);
        GenJournalLine.FindFirst();
        GenJournalLine.Validate(Amount, LibraryRandom.RandDec(100, 2));  // Update Random Amount.
        GenJournalLine.Modify(true);
        GeneralJournal.OpenEdit();
        GeneralJournal.CurrentJnlBatchName.SetValue(GenJournalBatch.Name);
    end;

    procedure FillSalesHeaderExcludedFieldList(var FieldListToExclude: List of [Text])
    var
        SalesHeaderRef: Record "Sales Header";
    begin
        FieldListToExclude.Add(SalesHeaderRef.FieldName("Document Type"));
        FieldListToExclude.Add(SalesHeaderRef.FieldName("Quote No."));
        FieldListToExclude.Add(SalesHeaderRef.FieldName("No."));
        FieldListToExclude.Add(SalesHeaderRef.FieldName("Posting Date"));
        FieldListToExclude.Add(SalesHeaderRef.FieldName("VAT Reporting Date"));
        FieldListToExclude.Add(SalesHeaderRef.FieldName("Posting Description"));
        FieldListToExclude.Add(SalesHeaderRef.FieldName("No. Series"));
        FieldListToExclude.Add(SalesHeaderRef.FieldName("Prepayment No. Series"));
        FieldListToExclude.Add(SalesHeaderRef.FieldName("Prepmt. Cr. Memo No. Series"));
        FieldListToExclude.Add(SalesHeaderRef.FieldName("Shipping No. Series"));

        OnAfterFillSalesHeaderExcludedFieldList(FieldListToExclude);
    end;

    procedure GetDeletionBlockedAfterDate(): Date
    var
        DocumentsRetentionPeriod: Interface "Documents - Retention Period";
        DeletionBlockedAfterDate: Date;
    begin
        GeneralLedgerSetup.Get();
        DocumentsRetentionPeriod := GeneralLedgerSetup."Document Retention Period";
        DeletionBlockedAfterDate := DocumentsRetentionPeriod.GetDeletionBlockedAfterDate();
        if DeletionBlockedAfterDate = 0D then
            exit(WorkDate());
        exit(DeletionBlockedAfterDate);
    end;

    procedure UpdateDirectCostNonInventoryAppliedAccountInGeneralPostingSetup(var GeneralPostingSetup: Record "General Posting Setup")
    begin
        GeneralPostingSetup.Validate("Direct Cost Non-Inv. App. Acc.", CreateGLAccountNo());
        GeneralPostingSetup.Modify();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreatePaymentTerms(var PaymentTerms: Record "Payment Terms")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreatePostCode(var PostCode: Record "Post Code")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreatePrepaymentVATPostingSetup(var VATPostingSetup: Record "VAT Posting Setup"; VATCalcType: Enum "Tax Calculation Type"; GenPostingType: Enum "General Posting Type"; SetupGLAccount: Record "G/L Account"; VATAccountNo: Code[20]; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreatePrepaymentVATPostingSetup(var VATPostingSetup: Record "VAT Posting Setup"; VATCalcType: Enum "Tax Calculation Type"; GenPostingType: Enum "General Posting Type"; SetupGLAccount: Record "G/L Account"; VATAccountNo: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateVATPostingSetupWithAccounts(var VATPostingSetup: Record "VAT Posting Setup"; VATCalculationType: Enum "Tax Calculation Type"; VATRate: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSetPostingGroupsOnPrepmtGLAccount(var LineGLAccount: Record "G/L Account"; var PrepmtGLAccount: Record "G/L Account"; GenPostingType: Enum "General Posting Type"; VATCalcType: Option "Normal VAT","Reverse Charge VAT","Full VAT","Sales Tax"; PrepmtVATCalcType: Option; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetPostingGroupsOnPrepmtGLAccount(var LineGLAccount: Record "G/L Account"; var PrepmtGLAccount: Record "G/L Account"; GenPostingType: Enum "General Posting Type"; VATCalcType: Option "Normal VAT","Reverse Charge VAT","Full VAT","Sales Tax"; PrepmtVATCalcType: Option)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateVATPostingSetup(var VATPostingSetup: Record "VAT Posting Setup"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateVATPostingSetup(var VATPostingSetup: Record "VAT Posting Setup")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateVATProductPostingGroup(var VATProductPostingGroup: Record "VAT Product Posting Group"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateVATProductPostingGroup(var VATProductPostingGroup: Record "VAT Product Posting Group")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFillSalesHeaderExcludedFieldList(var FieldListToExclude: List of [Text])
    begin
    end;
}

