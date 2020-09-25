Codeunit 1937 "MigrationGP Helper Functions"
{
    var
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
        AnArrayExpectedErr: Label 'An array was expected.';
        PostingGroupCodeTxt: Label 'GP', Locked = true;
        DocNoOutofBalanceMsg: Label 'Document No. %1 is out of balance by %2. Transactions will not be created. Please check the amount in the import file.', Comment = '%1 = Balance Amount', Locked = true;
        CustomerBatchNameTxt: Label 'GPCUST', Locked = true;
        VendorBatchNameTxt: Label 'GPVEND', Locked = true;
        GlDocNoTxt: Label 'G00001', Locked = true;
        MigrationTypeTxt: Label 'Great Plains';
        ImportedEntityTxt: Label 'Imported %1 data file.', Locked = true;

    procedure GetEntities(EntityName: Text; var JArray: JsonArray): Boolean
    var
        JObject: JsonObject;
        JToken: JsonToken;
        FileName: Text;
    begin
        FileName := GetFileNameByEntityName(EntityName);
        if FileName <> '' then begin
            GetFileContent(FileName, JObject);
            JObject.Get(EntityName, JToken);
            if not JToken.IsArray() then
                LogInternalError(AnArrayExpectedErr, DataClassification::SystemMetadata, Verbosity::Error);
            JArray := JToken.AsArray();
            Session.LogMessage('00007GL', StrSubstNo(ImportedEntityTxt, EntityName), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', GetMigrationTypeTxt());
            exit(true);
        end;
        exit(false);
    end;

    procedure GetEntitiesAsJToken(EntityName: Text; var JToken: JsonToken): Boolean
    var
        JObject: JsonObject;
        FileName: Text;
    begin
        FileName := GetFileNameByEntityName(EntityName);
        if FileName <> '' then begin
            GetFileContent(FileName, JObject);
            JObject.Get(EntityName, JToken);
            Session.LogMessage('00007GM', StrSubstNo(ImportedEntityTxt, EntityName), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', GetMigrationTypeTxt());
            exit(true);
        end;
        exit(false);
    end;

    procedure GetObjectCount(EntityName: Text; var ObjectCount: Integer)
    var
        JObject: JsonObject;
        JToken: JsonToken;
        FileName: Text;
    begin
        ObjectCount := 0;
        FileName := GetFileNameByEntityName(EntityName);
        if FileName <> '' then begin
            GetFileContent(FileName, JObject);
            JObject.Get('MaxResults', JToken);
            if JToken.IsValue() then
                ObjectCount := JToken.AsValue().AsInteger();
        end;
    end;

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
        if NameValueBuffer.Find('-') then
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

    local procedure GetFileContent(FileName: Text; var JObject: JsonObject)
    var
        FileInStream: InStream;
        TempFile: File;
    begin
        TempFile.TextMode(true);
        TempFile.WriteMode(false);
        TempFile.Open(FileName);
        TempFile.CreateInStream(FileInStream);
        JObject.ReadFrom(FileInStream);
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
        MigrationGPAccountSetup: Record "MigrationGP Account Setup";
    begin
        if not MigrationGPAccountSetup.FindFirst() then
            exit('');

        case AccountToGet of
            'SalesAccount':
                exit(MigrationGPAccountSetup.SalesAccount);
            'SalesLineDiscAccount':
                exit(MigrationGPAccountSetup.SalesLineDiscAccount);
            'SalesInvDiscAccount':
                exit(MigrationGPAccountSetup.SalesInvDiscAccount);
            'SalesPmtDiscDebitAccount':
                exit(MigrationGPAccountSetup.SalesPmtDiscDebitAccount);
            'PurchAccount':
                exit(MigrationGPAccountSetup.PurchAccount);
            'PurchInvDiscAccount':
                exit(MigrationGPAccountSetup.PurchInvDiscAccount);
            'COGSAccount':
                exit(MigrationGPAccountSetup.COGSAccount);
            'InventoryAdjmtAccount':
                exit(MigrationGPAccountSetup.InventoryAdjmtAccount);
            'SalesCreditMemoAccount':
                exit(MigrationGPAccountSetup.SalesCreditMemoAccount);
            'PurchPmtDiscDebitAcc':
                exit(MigrationGPAccountSetup.PurchPmtDiscDebitAcc);
            'PurchPrepaymentsAccount':
                exit(MigrationGPAccountSetup.PurchPrepaymentsAccount);
            'PurchaseVarianceAccount':
                exit(MigrationGPAccountSetup.PurchaseVarianceAccount);
            'InventoryAccount':
                exit(MigrationGPAccountSetup.InventoryAccount);
            'ReceivablesAccount':
                exit(MigrationGPAccountSetup.ReceivablesAccount);
            'ServiceChargeAccount':
                exit(MigrationGPAccountSetup.ServiceChargeAccount);
            'PaymentDiscDebitAccount':
                exit(MigrationGPAccountSetup.PurchPmtDiscDebitAccount);
            'PayablesAccount':
                exit(MigrationGPAccountSetup.PayablesAccount);
            'PurchServiceChargeAccount':
                exit(MigrationGPAccountSetup.PurchServiceChargeAccount);
            'PurchPaymentDiscDebitAccount':
                exit(MigrationGPAccountSetup.PurchPmtDiscDebitAccount);
        end;
    end;

    procedure ConvertAccountCategory(MigrationGPAccount: Record "MigrationGP Account"): Option
    var
        AccountCategoryType: Option ,Assets,Liabilities,Equity,Income,"Cost of Goods Sold",Expense;
    begin
        case MigrationGPAccount.AccountCategory of
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

    procedure ConvertDebitCreditType(MigrationGPAccount: Record "MigrationGP Account"): Option
    var
        DebitCreditType: Option Both,Debit,Credit;
    begin
        if MigrationGPAccount.DebitCredit = 0 then
            exit(DebitCreditType::Debit);

        exit(DebitCreditType::Credit);
    end;

    procedure ConvertIncomeBalanceType(MigrationGPAccount: Record "MigrationGP Account"): Option
    var
        IncomeBalanceType: Option "Income Statement","Balance Sheet";
    begin
        if MigrationGPAccount.IncomeBalance then
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
        GenJournalBatch.SetFilter("Bal. Account Type", '= 0');
        GenJournalBatch.SetFilter("Bal. Account No.", '> 0');
        if GenJournalBatch.Find('-') then begin
            repeat
                GenJournalBatch."Bal. Account No." := '';
                GenJournalBatch.Modify(true);
            until GenJournalBatch.Next() = 0;
            Commit();
        end;

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

    procedure IsUsingNewAccountFormat(): Boolean
    var
        MigrationGPConfig: Record "MigrationGP Config";
    begin
        if MigrationGPConfig.Get() then
            if MigrationGPConfig."Chart of Account Option" = MigrationGPConfig."Chart of Account Option"::New then
                exit(true);

        exit(false);
    end;

    procedure AssignSubAccountCategory(MigrationGPAccount: Record "MigrationGP Account") AcctSubCategory: Integer
    var
        GLAccount: Record "G/L Account";
    begin
        case MigrationGPAccount.AccountCategory of
            1:
                AcctSubCategory := GetAcctSubCategoryEntryNo(GLAccount."Account Category"::Assets, CashTxt);
            2, 4, 6:
                AcctSubCategory := GetAcctSubCategoryEntryNo(GLAccount."Account Category"::Assets, CurrentAssetsTxt);
            3:
                AcctSubCategory := GetAcctSubCategoryEntryNo(GLAccount."Account Category"::Assets, ARTxt);
            5:
                AcctSubCategory := GetAcctSubCategoryEntryNo(GLAccount."Account Category"::Assets, InventoryTxt);
            7:
                AcctSubCategory := GetAcctSubCategoryEntryNo(GLAccount."Account Category"::Assets, PrepaidExpensesTxt);
            8, 11, 12:
                AcctSubCategory := GetAcctSubCategoryEntryNo(GLAccount."Account Category"::Assets, InventoryTxt);
            9:
                AcctSubCategory := GetAcctSubCategoryEntryNo(GLAccount."Account Category"::Assets, EquipementTxt);
            10:
                AcctSubCategory := GetAcctSubCategoryEntryNo(GLAccount."Account Category"::Assets, AccumDeprecTxt);
            13, 14, 15, 16, 17, 18, 19, 20, 21:
                AcctSubCategory := GetAcctSubCategoryEntryNo(GLAccount."Account Category"::Liabilities, CurrentLiabilitiesTxt);
            22:
                AcctSubCategory := GetAcctSubCategoryEntryNo(GLAccount."Account Category"::Liabilities, LongTermLiabilitiesTxt);
            23:
                AcctSubCategory := GetAcctSubCategoryEntryNo(GLAccount."Account Category"::Equity, CommonStockTxt);
            24, 25, 26, 28:
                AcctSubCategory := GetAcctCategoryEntryNo(GLAccount."Account Category"::Equity);
            27:
                AcctSubCategory := GetAcctSubCategoryEntryNo(GLAccount."Account Category"::Equity, RetEarningsTxt);
            29, 30:
                AcctSubCategory := GetAcctSubCategoryEntryNo(GLAccount."Account Category"::Equity, DistrToShareholdersTxt);
            31:
                AcctSubCategory := GetAcctCategoryEntryNo(GLAccount."Account Category"::Income);
            32:
                AcctSubCategory := GetAcctSubCategoryEntryNo(GLAccount."Account Category"::Income, IncomeSalesReturnsTxt);
            33:
                AcctSubCategory := GetAcctCategoryEntryNo(GLAccount."Account Category"::"Cost of Goods Sold");
            34, 35:
                AcctSubCategory := GetAcctCategoryEntryNo(GLAccount."Account Category"::Expense);
            36:
                AcctSubCategory := GetAcctSubCategoryEntryNo(GLAccount."Account Category"::Expense, PayrollExpenseTxt);
            37:
                AcctSubCategory := GetAcctSubCategoryEntryNo(GLAccount."Account Category"::Expense, BenefitsExpenseTxt);
            38:
                AcctSubCategory := GetAcctSubCategoryEntryNo(GLAccount."Account Category"::Expense, InterestExpenseTxt);
            39, 41:
                AcctSubCategory := GetAcctSubCategoryEntryNo(GLAccount."Account Category"::Expense, TaxExpenseTxt);
            40, 42, 43, 44, 45, 46, 47:
                AcctSubCategory := GetAcctSubCategoryEntryNo(GLAccount."Account Category"::Expense, OtherIncomeExpenseTxt);
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

    procedure SetCustomerTransType(var MigrationGPCustTrans: Record "MigrationGP CustomerTrans")
    begin
        case
            MigrationGPCustTrans.RMDTYPAL of
            1 .. 5:
                MigrationGPCustTrans.TransType := MigrationGPCustTrans.TransType::Invoice;
            9:
                MigrationGPCustTrans.TransType := MigrationGPCustTrans.TransType::Payment;
            7, 8:
                MigrationGPCustTrans.TransType := MigrationGPCustTrans.TransType::"Credit Memo";
        end;
    end;

    procedure SetVendorTransType(var MigrationGPVendTrans: Record "MigrationGP VendorTrans")
    begin
        case
            MigrationGPVendTrans.DOCTYPE of
            1 .. 3, 7:
                MigrationGPVendTrans.TransType := MigrationGPVendTrans.TransType::Invoice;
            6:
                MigrationGPVendTrans.TransType := MigrationGPVendTrans.TransType::Payment;
            4, 5:
                MigrationGPVendTrans.TransType := MigrationGPVendTrans.TransType::"Credit Memo";
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
            if InventorySetup."Default Costing Method" = CostingMethod::Specific then
                Error(MigrationNotSupportedErr);

        exit(true);
    end;

    procedure CreateDimensions()
    var
        MigrationGPSegments: Record "MigrationGP Segments";
        Dimension: Record Dimension;
    begin
        if not MigrationGPSegments.FindSet() then
            exit;

        repeat
            if not Dimension.Get(MigrationGPSegments.Id) then begin
                Dimension.Init();
                Dimension.Validate(Code, CheckDimensionName(MigrationGPSegments.Id));
                Dimension.Validate(Name, MigrationGPSegments.Name);
                Dimension.Validate("Code Caption", MigrationGPSegments.CodeCaption);
                Dimension.Validate("Filter Caption", MigrationGPSegments.FilterCaption);
                Dimension.Insert(true);
            end;
        until MigrationGPSegments.Next() = 0;

        CreateDimensionValues();
    end;

    procedure CreatePaymentTerms()
    var
        MigrationGPPaymentTerms: Record "MigrationGP Payment Terms";
        PaymentTerms: Record "Payment Terms";
        DueDateCalculation: DateFormula;
        DiscountDateCalculation: DateFormula;
        SeedValue: integer;
        PaymentTerm: Text[10];
        DueDateCalculationText: Text[50];
        DiscountDateCalculationText: Text[50];
    begin
        if not MigrationGPPaymentTerms.FindSet() then
            exit;

        SeedValue := 0;
        repeat
            if STRLEN(DELCHR(MigrationGPPaymentTerms.PYMTRMID, '>', ' ')) > 10 then begin
                PaymentTerm := GeneratePaymentTerm(SeedValue, MigrationGPPaymentTerms.PYMTRMID);
                PaymentTerms.Validate(Code, PaymentTerm);
                SeedValue := SeedValue + 1;
            end else
                PaymentTerm := COPYSTR(DELCHR(MigrationGPPaymentTerms.PYMTRMID, '>', ' '), 1, 10);

            if not PaymentTerms.Get(PaymentTerm) then begin
                PaymentTerms.Init();
                PaymentTerms.Validate(Code, PaymentTerm);
                PaymentTerms.Validate(Description, DELCHR(MigrationGPPaymentTerms.PYMTRMID, '>', ' '));
                PaymentTerms.Validate("Discount %", (MigrationGPPaymentTerms.DSCPCTAM / 100));

                DiscountDateCalculationText := CalculateDiscountDateFormula(MigrationGPPaymentTerms);
                EVALUATE(DiscountDateCalculation, DiscountDateCalculationText);
                PaymentTerms.Validate("Discount Date Calculation", DiscountDateCalculation);

                if MigrationGPPaymentTerms.CalculateDateFrom = MigrationGPPaymentTerms.CalculateDateFrom::"Transaction Date" then
                    DueDateCalculationText := CalculateDueDateFormula(MigrationGPPaymentTerms, false, '')
                else
                    DueDateCalculationText := CalculateDueDateFormula(MigrationGPPaymentTerms, true, copystr(DiscountDateCalculationText, 1, 32));

                EVALUATE(DueDateCalculation, DueDateCalculationText);
                PaymentTerms.Validate("Due Date Calculation", DueDateCalculation);

                PaymentTerms.Insert(true);

                MigrationGPPaymentTerms.PYMTRMID_New := PaymentTerm;
                MigrationGPPaymentTerms.Modify();
            end;
        until MigrationGPPaymentTerms.Next() = 0;
        SeedValue := 0;
        // At this point, update the historical tables with the "corrected" Payment Term ID
        UpdatePaymentTerms();
    end;

    procedure CreateItemTrackingCodes()
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
    end;

    local procedure CalculateDueDateFormula(MigrationGPPaymentTerms: Record "MigrationGP Payment Terms"; Use_Discount_Calc: Boolean; Discount_Calc: Text[32]): Text[50]
    var
        working_number: integer;
        extra_month: integer;
        extra_year: integer;
        working_string: Text[20];
        working_discount_calc: Text[50];
        final_string: Text[50];
    begin
        // BC Only supports MigrationGPPaymentTerms.CalculateDateFrom = Transaction Date
        // Set date formula to a string '<1M>'
        working_number := MigrationGPPaymentTerms.CalculateDateFromDays;  // Always add this many days to the due date.

        if Use_Discount_Calc and (Discount_Calc <> '') then
            // Need to get the date formula text minus the brackets...
            working_discount_calc := copystr(copystr(Discount_Calc, 2, (strlen(Discount_Calc) - 2)), 1, 50)
        else
            // In case use discount is true, but the passed-in formula string is empty
            Use_Discount_Calc := false;

        // Add base days + discount days
        if MigrationGPPaymentTerms.DUETYPE = MigrationGPPaymentTerms.DUETYPE::"Net Days" then
            if MigrationGPPaymentTerms.DUEDTDS > 0 then begin
                working_number := working_number + MigrationGPPaymentTerms.DUEDTDS;
                working_string := '<' + format(working_number) + 'D>';
            END;

        // Get the first day of the current month, then add appropriate days.
        // Need to remove one day since setting the date should fall on that number chosen, whereas the formula will add to the first of the month,
        // giving you one extra day we need to remove.
        if MigrationGPPaymentTerms.DUETYPE = MigrationGPPaymentTerms.DUETYPE::Date then
            if MigrationGPPaymentTerms.DUEDTDS > 0 then
                working_string := '<D' + format(MigrationGPPaymentTerms.DUEDTDS) + '>';

        // Go to the end of the current month, then add appropriate days
        if MigrationGPPaymentTerms.DUETYPE = MigrationGPPaymentTerms.DUETYPE::EOM then begin
            if MigrationGPPaymentTerms.DUEDTDS > 0 then
                working_number := working_number + MigrationGPPaymentTerms.DUEDTDS;
            if working_number > 0 then
                working_string := '<CM+' + format(working_number) + 'D>'
            ELSE
                working_string := '<CM>';
        end;

        // Just add the number of initial days to the current date
        if MigrationGPPaymentTerms.DUETYPE = MigrationGPPaymentTerms.DUETYPE::None then
            working_string := '<' + format(working_number) + 'D>';

        // Set the day of the next month
        // Need to remove one day, see the comments above for DUETYPE::Date
        if MigrationGPPaymentTerms.DUETYPE = MigrationGPPaymentTerms.DUETYPE::"Next Month" then begin
            if MigrationGPPaymentTerms.DUEDTDS > 0 then
                working_number := MigrationGPPaymentTerms.DUEDTDS;
            // First day of current month, + 1 month + the number of days
            working_string := '<-CM+1M+' + format(working_number - 1) + 'D>;'
        end;

        if MigrationGPPaymentTerms.DUETYPE = MigrationGPPaymentTerms.DUETYPE::Months then begin
            if MigrationGPPaymentTerms.DUEDTDS > 0 then
                extra_month := MigrationGPPaymentTerms.DUEDTDS;
            // Add the extra months, then the extra days
            working_string := '<' + format(extra_month) + 'M+' + format(working_number) + 'D>;'
        end;

        if MigrationGPPaymentTerms.DUETYPE = MigrationGPPaymentTerms.DUETYPE::"Month/Day" then
            working_string := '<M' + format(MigrationGPPaymentTerms.DueMonth) + '+D' + format(MigrationGPPaymentTerms.DUEDTDS) + '>';

        if MigrationGPPaymentTerms.DUETYPE = MigrationGPPaymentTerms.DUETYPE::Annual then begin
            if MigrationGPPaymentTerms.DUEDTDS > 0 then
                extra_year := MigrationGPPaymentTerms.DUEDTDS;
            // Add the extra months, then the extra days
            working_string := '<' + format(extra_year) + 'Y+' + format(working_number) + 'D>;'
        end;

        if Use_Discount_Calc then begin
            final_string := copystr('<' + working_discount_calc, 1, 50);
            if (copystr(working_string, 2) = '-') or (copystr(working_string, 2) = '+') then
                final_string := final_string + copystr(working_string, 3, (strlen(working_string) - 2))
            else
                final_string := final_string + '+' + copystr(working_string, 2, (strlen(working_string) - 1));
            exit(final_string);
        end else
            exit(working_string);
        // Back in the calling proc, EVALUATE(variable,forumlastring) will set the variable to the correct formula
    end;

    local procedure CalculateDiscountDateFormula(MigrationGPPaymentTerms: Record "MigrationGP Payment Terms"): Text[50]
    var
        working_number: integer;
        extra_month: integer;
        extra_year: integer;
        working_string: Text[20];
    begin
        // Set date formula to a string '<1M>'
        working_number := MigrationGPPaymentTerms.CalculateDateFromDays;  // Always add this many days to the due date.

        // Add base days + discount days
        if MigrationGPPaymentTerms.DISCTYPE = MigrationGPPaymentTerms.DISCTYPE::Days then
            if MigrationGPPaymentTerms.DISCDTDS > 0 then begin
                working_number := working_number + MigrationGPPaymentTerms.DISCDTDS;
                working_string := '<' + format(working_number) + 'D>';
            END;

        // Get the first day of the current month, then add appropriate days.
        // Need to remove one day since setting the date should fall on that number chosen, whereas the formula will add to the first of the month,
        // giving you one extra day we need to remove.
        if MigrationGPPaymentTerms.DISCTYPE = MigrationGPPaymentTerms.DISCTYPE::Date then
            if MigrationGPPaymentTerms.DISCDTDS > 0 then
                working_string := '<D' + format(MigrationGPPaymentTerms.DISCDTDS) + '>';

        // Go to the end of the current month, then add appropriate days
        if MigrationGPPaymentTerms.DISCTYPE = MigrationGPPaymentTerms.DISCTYPE::EOM then begin
            if MigrationGPPaymentTerms.DISCDTDS > 0 then
                working_number := working_number + MigrationGPPaymentTerms.DISCDTDS;
            if working_number > 0 then
                working_string := '<CM+' + format(working_number) + 'D>'
            else
                working_string := '<CM>';
        end;

        // Just add the number of initial days to the current date
        if MigrationGPPaymentTerms.DISCTYPE = MigrationGPPaymentTerms.DISCTYPE::None then
            working_string := '<+' + format(working_number) + 'D>';

        // Set the day of the next month
        // Need to remove one day, see the comments above for DISCTYPE::Date
        if MigrationGPPaymentTerms.DISCTYPE = MigrationGPPaymentTerms.DISCTYPE::"Next Month" then begin
            if MigrationGPPaymentTerms.DISCDTDS > 0 then
                working_number := MigrationGPPaymentTerms.DISCDTDS;
            // First day of current month, + 1 month + the number of days
            working_string := '<-CM+1M+' + format(working_number - 1) + 'D>;'
        end;

        if MigrationGPPaymentTerms.DISCTYPE = MigrationGPPaymentTerms.DISCTYPE::Months then begin
            if MigrationGPPaymentTerms.DISCDTDS > 0 then
                extra_month := MigrationGPPaymentTerms.DISCDTDS;
            // Add the extra months, then the extra days
            working_string := '<' + format(extra_month) + 'M+' + format(working_number) + 'D>;'
        end;

        if MigrationGPPaymentTerms.DISCTYPE = MigrationGPPaymentTerms.DISCTYPE::"Month/Day" then
            working_string := '<M' + format(MigrationGPPaymentTerms.DiscountMonth) + '+D' + format(MigrationGPPaymentTerms.DISCDTDS) + '>';

        if MigrationGPPaymentTerms.DISCTYPE = MigrationGPPaymentTerms.DISCTYPE::Annual then begin
            if MigrationGPPaymentTerms.DISCDTDS > 0 then
                extra_year := MigrationGPPaymentTerms.DISCDTDS;
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
        MigrationGPPaymentTerms: Record "MigrationGP Payment Terms";
        MigrationGPCustomer: Record "MigrationGP Customer"; //1932
        MigrationGPCustomerTrans: Record "MigrationGP CustomerTrans"; //1933
        MigrationGPVendor: Record "MigrationGP Vendor"; //1934
        MigrationGPVendorTrans: Record "MigrationGP VendorTrans"; //1935
        GPSOPTrxHist: Record "GP_SOPTrxHist"; //4100
        GPRMOpen: Record "GP_RMOpen"; //4114
        GPRMHist: Record "GP_RMHist"; //4115
        GPPOPReceiptHist: Record "GP_POPReceiptHist"; //4116
        GPPOPPOHist: Record "GP_POP_POHist"; //4123
        GPPMHist: Record "GP_PMHist"; //4126
        PaymentTerm: Text[22];
        PaymentTerm_New: Text[10];
    begin
        if not MigrationGPPaymentTerms.FindSet() then
            exit;

        repeat
            PaymentTerm := DELCHR(MigrationGPPaymentTerms.PYMTRMID, '>', ' ');
            PaymentTerm_New := DELCHR(MigrationGPPaymentTerms.PYMTRMID_New, '>', ' ');
            // if the "old" and "new" payment terms are the same, skip
            if PaymentTerm <> PaymentTerm_New THEN begin
                // update the payment terms in the tables that have this field
                WITH MigrationGPCustomer DO BEGIN
                    RESET();
                    SetFilter("PYMTRMID", PaymentTerm);
                    if FINDFIRST() then
                        MODIFYALL("PYMTRMID", PaymentTerm_New);
                END;

                WITH MigrationGPCustomerTrans DO BEGIN
                    RESET();
                    SetFilter("PYMTRMID", PaymentTerm);
                    if FINDFIRST() then
                        MODIFYALL("PYMTRMID", PaymentTerm_New);
                END;

                WITH MigrationGPVendor DO BEGIN
                    RESET();
                    SetFilter("PYMTRMID", PaymentTerm);
                    if FINDFIRST() then
                        MODIFYALL("PYMTRMID", PaymentTerm_New);
                END;

                WITH MigrationGPVendorTrans DO BEGIN
                    RESET();
                    SetFilter("PYMTRMID", PaymentTerm);
                    if FINDFIRST() then
                        MODIFYALL("PYMTRMID", PaymentTerm_New);
                END;

                WITH GPSOPTrxHist DO BEGIN
                    RESET();
                    SetFilter("PYMTRMID", PaymentTerm);
                    if FINDFIRST() then
                        MODIFYALL("PYMTRMID", PaymentTerm_New);
                END;

                WITH GPRMOpen DO BEGIN
                    RESET();
                    SetFilter("PYMTRMID", PaymentTerm);
                    if FINDFIRST() then
                        MODIFYALL("PYMTRMID", PaymentTerm_New);
                END;

                WITH GPRMHist DO BEGIN
                    RESET();
                    SetFilter("PYMTRMID", PaymentTerm);
                    if FINDFIRST() then
                        MODIFYALL("PYMTRMID", PaymentTerm_New);
                END;

                WITH GPPOPReceiptHist DO BEGIN
                    RESET();
                    SetFilter("PYMTRMID", PaymentTerm);
                    if FINDFIRST() then
                        MODIFYALL("PYMTRMID", PaymentTerm_New);
                END;

                WITH GPPOPPOHist DO BEGIN
                    RESET();
                    SetFilter("PYMTRMID", PaymentTerm);
                    if FINDFIRST() then
                        MODIFYALL("PYMTRMID", PaymentTerm_New);
                END;

                WITH GPPMHist DO BEGIN
                    RESET();
                    SetFilter("PYMTRMID", PaymentTerm);
                    if FINDFIRST() then
                        MODIFYALL("PYMTRMID", PaymentTerm_New);
                END;
            end;
        until MigrationGPPaymentTerms.Next() = 0;
    end;

    procedure GetMigrationTypeTxt(): Text[250]
    begin
        exit(CopyStr(MigrationTypeTxt, 1, 250));
    end;

    local procedure CheckDimensionName(Name: Text[50]): Text[50]
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
            exit(CopyStr(Name + 's', 1, 50));

        exit(Name);
    end;

    procedure CreateDimensionValues()
    var
        MigrationGPCodes: Record "MigrationGP Codes";
        DimensionValue: Record "Dimension Value";
    begin
        MigrationGPCodes.SetFilter(MigrationGPCodes.Name, '<> %1', '');
        if not MigrationGPCodes.FindSet() then
            exit;

        repeat
            if not DimensionValue.Get(CheckDimensionName(MigrationGPCodes.Id), MigrationGPCodes.Name) then begin
                DimensionValue.Init();
                DimensionValue.Validate("Dimension Code", CheckDimensionName(MigrationGPCodes.Id));
                DimensionValue.Validate(Code, MigrationGPCodes.Name);
                DimensionValue.Validate(Name, MigrationGPCodes.Description);
                DimensionValue.Insert(true);
            end;
        until MigrationGPCodes.Next() = 0;
    end;

    procedure GetDimensionInfo()
    var
        JArray: JsonArray;
    begin
        if GetEntities('Segment', JArray) then
            GetSegmentsFromJson(JArray);

        if GetEntities('CODE', JArray) then
            GetCodesFromJson(JArray);
    end;

    local procedure GetSegmentsFromJson(JArray: JsonArray)
    var
        MigrationGPSegment: Record "MigrationGP Segments";
        RecordVariant: Variant;
        ChildJToken: JsonToken;
        EntityId: Text[75];
        i: Integer;
    begin
        i := 0;

        while JArray.Get(i, ChildJToken) do begin
            EntityId := CopyStr(TrimStringQuotes(GetTextFromJToken(ChildJToken, 'SEGMENTCODE')), 1, MaxStrLen(MigrationGPSegment.Id));

            if not MigrationGPSegment.Get(EntityId) then begin
                MigrationGPSegment.Init();
                MigrationGPSegment.Validate(MigrationGPSegment.Id, EntityId);
                MigrationGPSegment.Insert(true);
            end;

            RecordVariant := MigrationGPSegment;
            UpdateSegmentFromJson(RecordVariant, ChildJToken);
            MigrationGPSegment := RecordVariant;
            MigrationGPSegment.Modify(false);

            i := i + 1;
        end;
    end;

    local procedure UpdateSegmentFromJson(var RecordVariant: Variant; JToken: JsonToken)
    var
        MigrationGPSegment: Record "MigrationGP Segments";
    begin
        UpdateFieldValue(RecordVariant, MigrationGPSegment.FieldNo(Name), JToken.AsObject(), 'SGMTNAME');
        UpdateFieldValue(RecordVariant, MigrationGPSegment.FieldNo(CodeCaption), JToken.AsObject(), 'SEGMENTCODECAPTION');
        UpdateFieldValue(RecordVariant, MigrationGPSegment.FieldNo(FilterCaption), JToken.AsObject(), 'SEGMENTFILTERCAPTION');
    end;

    local procedure GetCodesFromJson(JArray: JsonArray)
    var
        MigrationGPCode: Record "MigrationGP Codes";
        RecordVariant: Variant;
        ChildJToken: JsonToken;
        EntityId: Text[75];
        Name: Text[50];
        i: Integer;
    begin
        i := 0;

        while JArray.Get(i, ChildJToken) do begin
            EntityId := CopyStr(TrimStringQuotes(GetTextFromJToken(ChildJToken, 'SGMTNUMB')), 1, MaxStrLen(MigrationGPCode.Id));
            Name := CopyStr(TrimStringQuotes(GetTextFromJToken(ChildJToken, 'SGMTNAME')), 1, MaxStrLen(MigrationGPCode.Name));

            if not MigrationGPCode.Get(EntityId, Name) then begin
                MigrationGPCode.Init();
                MigrationGPCode.Validate(MigrationGPCode.Id, EntityId);
                MigrationGPCode.Validate(MigrationGPCode.Name, Name);
                MigrationGPCode.Insert(true);
            end;

            RecordVariant := MigrationGPCode;
            UpdateCodeFromJson(RecordVariant, ChildJToken);
            MigrationGPCode := RecordVariant;
            MigrationGPCode.Modify(false);

            i := i + 1;
        end;
    end;

    local procedure UpdateCodeFromJson(var RecordVariant: Variant; JToken: JsonToken)
    var
        MigrationGPCode: Record "MigrationGP Codes";
    begin
        UpdateFieldValue(RecordVariant, MigrationGPCode.FieldNo(Description), JToken.AsObject(), 'DSCRIPTN');
    end;

    procedure Cleanup();
    var
        MigrationGPGLTrans: Record "MigrationGP GLTrans";
        MigrationGPAccount: Record "MigrationGP Account";
        MigrationGPCustomer: Record "MigrationGP Customer";
        MigrationGPCustTrans: Record "MigrationGP CustomerTrans";
        MigrationGPItem: Record "MigrationGP Item";
        MigrationGPVendor: Record "MigrationGP Vendor";
        MigrationGPVendTrans: Record "MigrationGP VendorTrans";
        MigrationGPCode: Record "MigrationGP Codes";
        MigrationGPAccountSetup: Record "MigrationGP Account Setup";
        MigrationGPSegments: Record "MigrationGP Segments";
        MigrationGPFiscalPeriods: Record "MigrationGP Fiscal Periods";
        MigrationGPPaymentTerms: Record "MigrationGP Payment Terms";
        HelperFunctions: Codeunit "MigrationGP Helper Functions";
    begin
        MigrationGPAccount.DeleteAll();
        MigrationGPGLTrans.DeleteAll();

        MigrationGPCustomer.DeleteAll();
        MigrationGPCustTrans.DeleteAll();

        MigrationGPItem.DeleteAll();

        MigrationGPVendor.DeleteAll();
        MigrationGPVendTrans.DeleteAll();

        MigrationGPCode.DeleteAll();
        MigrationGPAccountSetup.DeleteAll();
        MigrationGPSegments.DeleteAll();
        MigrationGPFiscalPeriods.DeleteAll();
        MigrationGPPaymentTerms.DeleteAll();
        Session.LogMessage('00007GH', 'Cleaned up staging tables.', Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', HelperFunctions.GetMigrationTypeTxt());
    end;

    procedure CleanupBeforeSynchronization();
    var
        GLAccount: Record "G/L Account";
        GLEntry: Record "G/L Entry";
        Customer: Record Customer;
        CustLedgerEntry: Record "Cust. Ledger Entry";
        DetailedCustLedgerEntry: Record "Detailed Cust. Ledg. Entry";
        Vendor: Record Vendor;
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
        Item: Record Item;
        ItemLedgerEntry: Record "Item Ledger Entry";
        AvgCodeAdjmtEntryPoint: Record "Avg. Cost Adjmt. Entry Point";
        ValueEntry: Record "Value Entry";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        HelperFunctions: Codeunit "MigrationGP Helper Functions";
    begin
        GLAccount.DeleteAll(true);
        GLEntry.DeleteAll(true);
        Customer.DeleteAll(true);
        CustLedgerEntry.DeleteAll(true);
        DetailedCustLedgerEntry.DeleteAll(true);
        Vendor.DeleteAll(true);
        VendorLedgerEntry.DeleteAll(true);
        DetailedVendorLedgEntry.DeleteAll(true);
        Item.DeleteAll(true);
        ItemLedgerEntry.DeleteAll(true);
        AvgCodeAdjmtEntryPoint.DeleteAll(true);
        ValueEntry.DeleteAll(true);
        ItemUnitOfMeasure.DeleteAll(true);
        Session.LogMessage('00007GI', 'Cleaned up before Synchronization.', Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', HelperFunctions.GetMigrationTypeTxt());
    end;

    procedure SetTransactionProcessedFlag();
    var
        MigrationGPConfig: Record "MigrationGP Config";
    begin
        MigrationGPConfig.GetSingleInstance();
        MigrationGPConfig."GL Transactions Processed" := true;
        MigrationGPConfig.Modify();
    end;

    procedure HaveGLTrxsBeenProcessed(): Boolean;
    var
        MigrationGPConfig: Record "MigrationGP Config";
    begin
        MigrationGPConfig.GetSingleInstance();
        exit(MigrationGPConfig."GL Transactions Processed");
    end;

    procedure RemoveEmptyGLTransactions();
    var
        MigrationGPGLTrans: Record "MigrationGP GLTrans";
    begin
        MigrationGPGLTrans.Reset();
        MigrationGPGLTrans.SetRange(PERDBLNC, 0);
        MigrationGPGLTrans.DeleteAll();
    end;

    procedure PostGLTransactions();
    var
        GenJnlLine: Record "Gen. Journal Line";
        GenJnlBatch: Record "Gen. Journal Batch";
        HelperFunctions: Codeunit "MigrationGP Helper Functions";
        JournalBatchName: Text;
        DurationAsInt: BigInteger;
        StartTime: DateTime;
    begin
        StartTime := CurrentDateTime();
        Session.LogMessage('00007GJ', 'Posting GL transactions started.', Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', HelperFunctions.GetMigrationTypeTxt());
        if HelperFunctions.IsUsingNewAccountFormat() then begin
            GenJnlBatch.Reset();
            GenJnlBatch.SetRange("Journal Template Name", 'GENERAL');
            // Get all batches that start with the text of GP
            GenJnlBatch.SetFilter(Name, PostingGroupCodeTxt + '*');
            GenJnlBatch.FindFirst();
            repeat
                JournalBatchName := GenJnlBatch.Name;
                GenJnlLine.Reset();
                GenJnlLine.SetRange("Journal Template Name", 'GENERAL');
                GenJnlLine.SetRange("Journal Batch Name", JournalBatchName);
                if not GenJnlLine.IsEmpty() then
                    PostGLBatch(CopyStr(JournalBatchName, 1, 10));
            until GenJnlBatch.Next() = 0;
        end else begin
            // Original Chart of accounts uses a specific batch...
            JournalBatchName := PostingGroupCodeTxt;
            GenJnlLine.Reset();
            GenJnlLine.SetRange("Journal Template Name", 'GENERAL');
            GenJnlLine.SetRange("Journal Batch Name", JournalBatchName);
            if not GenJnlLine.IsEmpty() then
                PostGLBatch(CopyStr(JournalBatchName, 1, 10));
        end;

        // Post the Customer Batch, if created...
        JournalBatchName := CustomerBatchNameTxt;
        GenJnlLine.Reset();
        GenJnlLine.SetRange("Journal Template Name", 'GENERAL');
        GenJnlLine.SetRange("Journal Batch Name", JournalBatchName);
        if not GenJnlLine.IsEmpty() then
            PostGLBatch(CopyStr(JournalBatchName, 1, 10));

        // Post the Vendor Batch, if created...
        JournalBatchName := VendorBatchNameTxt;
        GenJnlLine.Reset();
        GenJnlLine.SetRange("Journal Template Name", 'GENERAL');
        GenJnlLine.SetRange("Journal Batch Name", JournalBatchName);
        if not GenJnlLine.IsEmpty() then
            PostGLBatch(CopyStr(JournalBatchName, 1, 10));

        // Remove posted batches
        RemoveBatches();
        DurationAsInt := CurrentDateTime() - StartTime;
        Session.LogMessage('00007GK', 'Posting GL transactions finished; duration %1 (DurationAsInt)', Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', HelperFunctions.GetMigrationTypeTxt());
    end;

    procedure PostGLBatch(JournalBatchName: Code[10])
    var
        GenJnlLine: Record "Gen. Journal Line";
        TotalBalance: Decimal;
    begin
        GenJnlLine.Reset();
        GenJnlLine.SetRange("Journal Template Name", 'GENERAL');
        GenJnlLine.SetRange("Journal Batch Name", JournalBatchName);
        // Do not care about balances for Customer and Vendor batches
        if (JournalBatchName <> CustomerBatchNameTxt) and (JournalBatchName <> VendorBatchNameTxt) then begin
            repeat
                TotalBalance := TotalBalance + GenJnlLine.Amount;
            until GenJnlLine.Next() = 0;
            if TotalBalance = 0 then
                if GenJnlLine.FindFirst() then
                    codeunit.Run(codeunit::"Gen. Jnl.-Post Batch", GenJnlLine)
                else begin
                    Message(StrSubstNo(DocNoOutofBalanceMsg, GlDocNoTxt, FORMAT(TotalBalance)));
                    if GenJnlLine.FindFirst() then
                        GenJnlLine.DeleteAll();
                end;
        end else
            if GenJnlLine.FindFirst() then
                codeunit.Run(codeunit::"Gen. Jnl.-Post Batch", GenJnlLine);

    end;

    procedure RemoveBatches();
    var
        GenJnlLine: Record "Gen. Journal Line";
        GenJnlBatch: Record "Gen. Journal Batch";
        HelperFunctions: Codeunit "MigrationGP Helper Functions";
        JournalBatchName: Text;
    begin
        // GL Batches
        if HelperFunctions.IsUsingNewAccountFormat() then begin
            // Finished posting the batches, now clean up
            GenJnlBatch.Reset();
            GenJnlBatch.SetRange("Journal Template Name", 'GENERAL');
            GenJnlBatch.FindFirst();
            repeat
                if strpos(GenJnlBatch.Name, PostingGroupCodeTxt) = 1 then begin
                    GenJnlLine.Reset();
                    GenJnlLine.SetRange("Journal Template Name", 'GENERAL');
                    GenJnlLine.SetRange("Journal Batch Name", GenJnlBatch.Name);
                    GenJnlLine.SetRange("Account Type", GenJnlLine."Account Type"::"G/L Account");
                    GenJnlLine.SetRange("Account No.", '');
                    if not GenJnlLine.IsEmpty() then
                        If GenJnlLine.Count() = 1 then begin
                            GenJnlLine.DeleteAll();
                            GenJnlBatch.Delete();
                        end
                        else
                            GenJnlBatch.Delete();
                end;
            until GenJnlBatch.Next() = 0;
        end else begin
            JournalBatchName := PostingGroupCodeTxt;
            GenJnlLine.Reset();
            GenJnlLine.SetRange("Journal Template Name", 'GENERAL');
            GenJnlLine.SetRange("Journal Batch Name", JournalBatchName);
            GenJnlLine.SetRange("Account Type", GenJnlLine."Account Type"::"G/L Account");
            GenJnlLine.SetRange("Account No.", '');
            if not GenJnlLine.IsEmpty() then
                If GenJnlLine.Count() = 1 then begin
                    GenJnlLine.DeleteAll();
                    if GenJnlBatch.Get('GENERAL', JournalBatchName) then
                        GenJnlBatch.Delete();
                end;
        end;

        // Customer Batch
        JournalBatchName := CustomerBatchNameTxt;
        GenJnlLine.Reset();
        GenJnlLine.SetRange("Journal Template Name", 'GENERAL');
        GenJnlLine.SetRange("Journal Batch Name", JournalBatchName);
        GenJnlLine.SetRange("Account Type", GenJnlLine."Account Type"::Customer);
        GenJnlLine.SetRange("Account No.", '');
        if not GenJnlLine.IsEmpty() then
            If GenJnlLine.Count() = 1 then begin
                GenJnlLine.DeleteAll();
                if GenJnlBatch.Get('GENERAL', JournalBatchName) then
                    GenJnlBatch.Delete();
            end;

        // Vendor Batch
        JournalBatchName := VendorBatchNameTxt;
        GenJnlLine.Reset();
        GenJnlLine.SetRange("Journal Template Name", 'GENERAL');
        GenJnlLine.SetRange("Journal Batch Name", JournalBatchName);
        GenJnlLine.SetRange("Account Type", GenJnlLine."Account Type"::Vendor);
        GenJnlLine.SetRange("Account No.", '');
        if not GenJnlLine.IsEmpty() then
            If GenJnlLine.Count() = 1 then begin
                GenJnlLine.DeleteAll();
                if GenJnlBatch.Get('GENERAL', JournalBatchName) then
                    GenJnlBatch.Delete();
            end;
    end;
}