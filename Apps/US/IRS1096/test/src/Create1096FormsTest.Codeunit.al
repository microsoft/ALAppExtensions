codeunit 144041 "Create 1096 Forms Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryRandom: Codeunit "Library - Random";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryERM: Codeunit "Library - ERM";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        Assert: Codeunit Assert;
        DivCodeTok: Label 'DIV', Locked = true;
        MiscCodeTok: Label 'DIV', Locked = true;
        Div01CodeTok: Label 'DIV-01', Locked = true;
        IsInitialized: Boolean;
        FormsCreatedMsg: Label 'IRS 1096 forms have been created';
        NoFormsHaveBeenCreatedMsg: Label 'No IRS 1096 forms have been created';
        NoEntriesToCreateFormsMsg: Label 'No entries have been found by filters specified.';

    trigger OnRun()
    begin
        // [FEATURE] [1096]
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [HandlerFunctions('MessageHandler')]
    procedure CreateSingleFormCodeNoHyphen()
    var
        DtldVendLedgEntry: Record "Detailed Vendor Ledg. Entry";
        IRS1096Header: Record "IRS 1096 Form Header";
        IRS1096Line: Record "IRS 1096 Form Line";
        IRS1096FormMgt: Codeunit "IRS 1096 Form Mgt.";
        VendNo: Code[20];
        IRSCode: Code[10];
        PostingDate: Date;
    begin
        // [SCENARIO 461401] Stan can create a IRS 1096 form for the IRS code without a hyphen

        Initialize();
        VendNo := LibraryPurchase.CreateVendorNo();
        // [GIVEN] IRS code "DIV"
        IRSCode := InitializeDIVCode();
        PostingDate := CalcDate('<1Y>', WorkDate());
        // [GIVEN] Invoice applied to payment with "Vendor No." = "X", "Posting Date" = 01.01.2023 "IRS Code" = "DIV" and Amount = 100
        MockVendorLedgerEntry(DtldVendLedgEntry, VendNo, PostingDate, IRSCode, LibraryRandom.RandDec(100, 2));
        LibraryVariableStorage.Enqueue(FormsCreatedMsg);

        // [WHEN] Stan runs the "Create Forms" batch job for period from 01.01.2023 to 01.01.2023
        IRS1096FormMgt.CreateForms(PostingDate, PostingDate, false);

        // [THEN] One IRS 1096 form has been created
        IRS1096Header.SetRange("Starting Date", PostingDate);
        IRS1096Header.SetRange("Ending Date", PostingDate);
        IRS1096Header.SetRange("IRS Code", IRSCode);
        Assert.RecordCount(IRS1096Header, 1);
        IRS1096Header.FindFirst();
        // [THEN] IRS 1096 form has one line with the following details: "Vendor No." = "X", "IRS Code" = "DIV" and "Calculated Amount" = 100
        IRS1096Line.SetRange("Form No.", IRS1096Header."No.");
        Assert.RecordCount(IRS1096Line, 1);
        IRS1096Line.FindFirst();
        IRS1096Line.TestField("Vendor No.", VendNo);
        IRS1096Line.TestField("IRS Code", IRSCode);
        IRS1096Line.TestField("Calculated Amount", DtldVendLedgEntry.Amount);

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [HandlerFunctions('MessageHandler')]
    procedure IRSCodeNotIncludedInto1096FormIfTotalPositiveAmountLessThanMinimumReportable()
    var
        DtldVendLedgEntry: Record "Detailed Vendor Ledg. Entry";
        IRS1096Header: Record "IRS 1096 Form Header";
        IRS1096FormMgt: Codeunit "IRS 1096 Form Mgt.";
        VendNo: Code[20];
        IRSCode: Code[10];
        PostingDate: Date;
        MinimumReportableAmount: Decimal;
    begin
        // [FEAUTURE] [Minimum Reportable Amount]
        // [SCENARIO 461543] The positive total amount of the IRS code does not include in the IRS 1096 form if it is less than minimum reportable amount
        Initialize();
        MinimumReportableAmount := LibraryRandom.RandDec(100, 2);
        // [GIVEN] IRS code "DIV-01" with "Minimum Reportable Amount" = 100
        IRSCode := InitializeDIV01Code(MinimumReportableAmount);
        VendNo := LibraryPurchase.CreateVendorNo();
        PostingDate := CalcDate('<1Y>', WorkDate());
        // [GIVEN] Invoice applied to payment with "Vendor No." = "X", "Posting Date" = 01.01.2023 "IRS Code" = "DIV-01" and Amount = 50
        MockVendorLedgerEntry(DtldVendLedgEntry, VendNo, PostingDate, IRSCode, MinimumReportableAmount / 2);
        LibraryVariableStorage.Enqueue(NoFormsHaveBeenCreatedMsg);

        // [WHEN] Stan runs the "Create Forms" batch job for period from 01.01.2023 to 01.01.2023
        IRS1096FormMgt.CreateForms(PostingDate, PostingDate, false);

        // [THEN] No forms have been created
        Assert.IsTrue(IRS1096Header.IsEmpty(), '');

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [HandlerFunctions('MessageHandler')]
    procedure IRSCodeIncludesInto1096FormIfTotalPositiveAmountMoreThanMinimumReportable()
    var
        DtldVendLedgEntry: Record "Detailed Vendor Ledg. Entry";
        IRS1096Header: Record "IRS 1096 Form Header";
        IRS1096Line: Record "IRS 1096 Form Line";
        IRS1096FormMgt: Codeunit "IRS 1096 Form Mgt.";
        VendNo: Code[20];
        IRSCode: Code[10];
        PostingDate: Date;
        MinimumReportableAmount: Decimal;
        TotalAmount: Decimal;
    begin
        // [FEAUTURE] [Minimum Reportable Amount]
        // [SCENARIO 461543] The positive total amount of the IRS code includes in the IRS 1096 form if it is more than minimum reportable amount
        Initialize();
        MinimumReportableAmount := LibraryRandom.RandDec(100, 2);
        // [GIVEN] IRS code "DIV-01" with "Minimum Reportable Amount" = 100
        IRSCode := InitializeDIV01Code(MinimumReportableAmount);
        VendNo := LibraryPurchase.CreateVendorNo();
        PostingDate := CalcDate('<1Y>', WorkDate());
        // [GIVEN] Invoice applied to payment with "Vendor No." = "X", "Posting Date" = 01.01.2023 "IRS Code" = "DIV-01" and Amount = 75
        MockVendorLedgerEntry(DtldVendLedgEntry, VendNo, PostingDate, IRSCode, MinimumReportableAmount / 2);
        TotalAmount += DtldVendLedgEntry.Amount;
        // [GIVEN] Invoice applied to payment with "Vendor No." = "X", "Posting Date" = 01.01.2023 "IRS Code" = "DIV-01" and Amount = 26
        MockVendorLedgerEntry(DtldVendLedgEntry, VendNo, PostingDate, IRSCode, MinimumReportableAmount - DtldVendLedgEntry.Amount + 1);
        TotalAmount += DtldVendLedgEntry.Amount;
        LibraryVariableStorage.Enqueue(FormsCreatedMsg);

        // [WHEN] Stan runs the "Create Forms" batch job for period from 01.01.2023 to 01.01.2023
        IRS1096FormMgt.CreateForms(PostingDate, PostingDate, false);

        // [THEN] IRS 1096 form has not been created
        IRS1096Header.SetRange("Starting Date", PostingDate);
        IRS1096Header.SetRange("Ending Date", PostingDate);
        IRS1096Header.SetRange("IRS Code", DivCodeTok);
        Assert.RecordCount(IRS1096Header, 1);
        IRS1096Header.FindFirst();

        // [THEN] IRS 1096 form has one line with the following details: "Vendor No." = "X", "IRS Code" = "DIV-01" and "Calculated Amount" = 100
        IRS1096Line.SetRange("Form No.", IRS1096Header."No.");
        Assert.RecordCount(IRS1096Line, 1);
        IRS1096Line.FindFirst();
        IRS1096Line.TestField("Vendor No.", VendNo);
        IRS1096Line.TestField("IRS Code", IRSCode);
        IRS1096Line.TestField("Calculated Amount", TotalAmount);

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [HandlerFunctions('MessageHandler')]
    procedure IRSCodeIncludesInto1096FormIfTotalPositiveAmountEqualsMinimumReportable()
    var
        DtldVendLedgEntry: Record "Detailed Vendor Ledg. Entry";
        IRS1096Header: Record "IRS 1096 Form Header";
        IRS1096Line: Record "IRS 1096 Form Line";
        IRS1096FormMgt: Codeunit "IRS 1096 Form Mgt.";
        VendNo: Code[20];
        IRSCode: Code[10];
        PostingDate: Date;
        MinimumReportableAmount: Decimal;
        TotalAmount: Decimal;
    begin
        // [FEAUTURE] [Minimum Reportable Amount]
        // [SCENARIO 461543] The positive total amount of the IRS code includes in the IRS 1096 form if it equals minimum reportable amount
        Initialize();
        MinimumReportableAmount := LibraryRandom.RandDec(100, 2);
        // [GIVEN] IRS code "DIV-01" with "Minimum Reportable Amount" = 100
        IRSCode := InitializeDIV01Code(MinimumReportableAmount);
        VendNo := LibraryPurchase.CreateVendorNo();
        PostingDate := CalcDate('<1Y>', WorkDate());
        // [GIVEN] Invoice applied to payment with "Vendor No." = "X", "Posting Date" = 01.01.2023 "IRS Code" = "DIV-01" and Amount = 75
        MockVendorLedgerEntry(DtldVendLedgEntry, VendNo, PostingDate, IRSCode, MinimumReportableAmount / 2);
        TotalAmount += DtldVendLedgEntry.Amount;
        // [GIVEN] Invoice applied to payment with "Vendor No." = "X", "Posting Date" = 01.01.2023 "IRS Code" = "DIV-01" and Amount = 25
        MockVendorLedgerEntry(DtldVendLedgEntry, VendNo, PostingDate, IRSCode, MinimumReportableAmount - DtldVendLedgEntry.Amount);
        TotalAmount += DtldVendLedgEntry.Amount;
        LibraryVariableStorage.Enqueue(FormsCreatedMsg);

        // [WHEN] Stan runs the "Create Forms" batch job for period from 01.01.2023 to 01.01.2023
        IRS1096FormMgt.CreateForms(PostingDate, PostingDate, false);

        // [THEN] IRS 1096 form has not been created
        IRS1096Header.SetRange("Starting Date", PostingDate);
        IRS1096Header.SetRange("Ending Date", PostingDate);
        IRS1096Header.SetRange("IRS Code", DivCodeTok);
        Assert.RecordCount(IRS1096Header, 1);
        IRS1096Header.FindFirst();

        // [THEN] IRS 1096 form has one line with the following details: "Vendor No." = "X", "IRS Code" = "DIV-01" and "Calculated Amount" = 100
        IRS1096Line.SetRange("Form No.", IRS1096Header."No.");
        Assert.RecordCount(IRS1096Line, 1);
        IRS1096Line.FindFirst();
        IRS1096Line.TestField("Vendor No.", VendNo);
        IRS1096Line.TestField("IRS Code", IRSCode);
        IRS1096Line.TestField("Calculated Amount", TotalAmount);

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [HandlerFunctions('MessageHandler')]
    procedure IRSCodeNotIncludedInto1096FormIfZeroAmountAndMinimumReportableAmountIsNegative()
    var
        DtldVendLedgEntry: Record "Detailed Vendor Ledg. Entry";
        IRS1096Header: Record "IRS 1096 Form Header";
        IRS1096FormMgt: Codeunit "IRS 1096 Form Mgt.";
        VendNo: Code[20];
        IRSCode: Code[10];
        PostingDate: Date;
        MinimumReportableAmount: Decimal;
    begin
        // [FEAUTURE] [Minimum Reportable Amount]
        // [SCENARIO 461543] The zero total amount of the IRS code does not include in the IRS 1096 form if minimum reportable amount of this cose is negative
        Initialize();
        MinimumReportableAmount := -LibraryRandom.RandDec(100, 2);
        // [GIVEN] IRS code "DIV-01" with "Minimum Reportable Amount" = -100
        IRSCode := InitializeDIV01Code(MinimumReportableAmount);
        VendNo := LibraryPurchase.CreateVendorNo();
        PostingDate := CalcDate('<1Y>', WorkDate());
        // [GIVEN] Invoice applied to payment with "Vendor No." = "X", "Posting Date" = 01.01.2023 "IRS Code" = "DIV-01" and Amount = -100
        MockVendorLedgerEntry(DtldVendLedgEntry, VendNo, PostingDate, IRSCode, MinimumReportableAmount);
        // [GIVEN] Invoice applied to payment with "Vendor No." = "X", "Posting Date" = 01.01.2023 "IRS Code" = "DIV-01" and Amount = 100
        MockVendorLedgerEntry(DtldVendLedgEntry, VendNo, PostingDate, IRSCode, -MinimumReportableAmount);
        LibraryVariableStorage.Enqueue(NoFormsHaveBeenCreatedMsg);

        // [WHEN] Stan runs the "Create Forms" batch job for period from 01.01.2023 to 01.01.2023
        IRS1096FormMgt.CreateForms(PostingDate, PostingDate, false);

        // [THEN] No forms have been created
        Assert.IsTrue(IRS1096Header.IsEmpty(), '');

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [HandlerFunctions('MessageHandler')]
    procedure IRSCodeNotIncludedInto1096FormIfZeroAmountAndMinimumReportableAmountIsZero()
    var
        DtldVendLedgEntry: Record "Detailed Vendor Ledg. Entry";
        IRS1096Header: Record "IRS 1096 Form Header";
        IRS1096FormMgt: Codeunit "IRS 1096 Form Mgt.";
        VendNo: Code[20];
        IRSCode: Code[10];
        PostingDate: Date;
    begin
        // [FEAUTURE] [Minimum Reportable Amount]
        // [SCENARIO 461543] The zero total amount of the IRS code does not include in the IRS 1096 form if minimum reportable amount is zero
        Initialize();
        // [GIVEN] IRS code "DIV-01" with "Minimum Reportable Amount" = 0
        IRSCode := InitializeDIV01Code(0);
        VendNo := LibraryPurchase.CreateVendorNo();
        PostingDate := CalcDate('<1Y>', WorkDate());
        // [GIVEN] Invoice applied to payment with "Vendor No." = "X", "Posting Date" = 01.01.2023 "IRS Code" = "DIV-01" and Amount = -100
        MockVendorLedgerEntry(DtldVendLedgEntry, VendNo, PostingDate, IRSCode, LibraryRandom.RandDec(100, 2));
        // [GIVEN] Invoice applied to payment with "Vendor No." = "X", "Posting Date" = 01.01.2023 "IRS Code" = "DIV-01" and Amount = 100
        MockVendorLedgerEntry(DtldVendLedgEntry, VendNo, PostingDate, IRSCode, -DtldVendLedgEntry.Amount);
        LibraryVariableStorage.Enqueue(NoFormsHaveBeenCreatedMsg);

        // [WHEN] Stan runs the "Create Forms" batch job for period from 01.01.2023 to 01.01.2023
        IRS1096FormMgt.CreateForms(PostingDate, PostingDate, false);

        // [THEN] No forms have been created
        Assert.IsTrue(IRS1096Header.IsEmpty(), '');

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [HandlerFunctions('MessageHandler')]
    procedure IRSCodeIncludesInto1096FormIfNegativePositiveAmountMoreThanNegativeMinimumReportable()
    var
        DtldVendLedgEntry: Record "Detailed Vendor Ledg. Entry";
        IRS1096Header: Record "IRS 1096 Form Header";
        IRS1096Line: Record "IRS 1096 Form Line";
        IRS1096FormMgt: Codeunit "IRS 1096 Form Mgt.";
        VendNo: Code[20];
        IRSCode: Code[10];
        PostingDate: Date;
        MinimumReportableAmount: Decimal;
    begin
        // [FEAUTURE] [Minimum Reportable Amount]
        // [SCENARIO 461543] The negative total amount of the IRS code includes in the IRS 1096 form if it is more than negative minimum reportable amount
        Initialize();
        MinimumReportableAmount := -LibraryRandom.RandDec(100, 2);
        // [GIVEN] IRS code "DIV-01" with "Minimum Reportable Amount" = -100
        IRSCode := InitializeDIV01Code(MinimumReportableAmount);
        VendNo := LibraryPurchase.CreateVendorNo();
        PostingDate := CalcDate('<1Y>', WorkDate());
        // [GIVEN] Invoice applied to payment with "Vendor No." = "X", "Posting Date" = 01.01.2023 "IRS Code" = "DIV-01" and Amount = -50
        MockVendorLedgerEntry(DtldVendLedgEntry, VendNo, PostingDate, IRSCode, MinimumReportableAmount / 2);
        LibraryVariableStorage.Enqueue(FormsCreatedMsg);

        // [WHEN] Stan runs the "Create Forms" batch job for period from 01.01.2023 to 01.01.2023
        IRS1096FormMgt.CreateForms(PostingDate, PostingDate, false);

        // [THEN] IRS 1096 form has not been created
        IRS1096Header.SetRange("Starting Date", PostingDate);
        IRS1096Header.SetRange("Ending Date", PostingDate);
        IRS1096Header.SetRange("IRS Code", DivCodeTok);
        Assert.RecordCount(IRS1096Header, 1);
        IRS1096Header.FindFirst();

        // [THEN] IRS 1096 form has one line with the following details: "Vendor No." = "X", "IRS Code" = "DIV-01" and "Calculated Amount" = 100
        IRS1096Line.SetRange("Form No.", IRS1096Header."No.");
        Assert.RecordCount(IRS1096Line, 1);
        IRS1096Line.FindFirst();
        IRS1096Line.TestField("Vendor No.", VendNo);
        IRS1096Line.TestField("IRS Code", IRSCode);
        IRS1096Line.TestField("Calculated Amount", DtldVendLedgEntry.Amount);

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [HandlerFunctions('MessageHandler')]
    procedure IRSCodeIncludesInto1096FormIfNegativePositiveAmountLessThanNegativeMinimumReportable()
    var
        DtldVendLedgEntry: Record "Detailed Vendor Ledg. Entry";
        IRS1096Header: Record "IRS 1096 Form Header";
        IRS1096Line: Record "IRS 1096 Form Line";
        IRS1096FormMgt: Codeunit "IRS 1096 Form Mgt.";
        VendNo: Code[20];
        IRSCode: Code[10];
        PostingDate: Date;
        MinimumReportableAmount: Decimal;
    begin
        // [FEAUTURE] [Minimum Reportable Amount]
        // [SCENARIO 461543] The negative total amount of the IRS code includes in the IRS 1096 form if it is less than negative minimum reportable amount
        Initialize();
        // [GIVEN] IRS code "DIV-01" with "Minimum Reportable Amount" = -100
        MinimumReportableAmount := LibraryRandom.RandDec(100, 2);
        IRSCode := InitializeDIV01Code(MinimumReportableAmount);
        VendNo := LibraryPurchase.CreateVendorNo();
        PostingDate := CalcDate('<1Y>', WorkDate());
        // [GIVEN] Invoice applied to payment with "Vendor No." = "X", "Posting Date" = 01.01.2023 "IRS Code" = "DIV-01" and Amount = -200
        MockVendorLedgerEntry(DtldVendLedgEntry, VendNo, PostingDate, IRSCode, MinimumReportableAmount * 2);
        LibraryVariableStorage.Enqueue(FormsCreatedMsg);

        // [WHEN] Stan runs the "Create Forms" batch job for period from 01.01.2023 to 01.01.2023
        IRS1096FormMgt.CreateForms(PostingDate, PostingDate, false);

        // [THEN] IRS 1096 form has not been created
        IRS1096Header.SetRange("Starting Date", PostingDate);
        IRS1096Header.SetRange("Ending Date", PostingDate);
        IRS1096Header.SetRange("IRS Code", DivCodeTok);
        Assert.RecordCount(IRS1096Header, 1);
        IRS1096Header.FindFirst();

        // [THEN] IRS 1096 form has one line with the following details: "Vendor No." = "X", "IRS Code" = "DIV-01" and "Calculated Amount" = 100
        IRS1096Line.SetRange("Form No.", IRS1096Header."No.");
        Assert.RecordCount(IRS1096Line, 1);
        IRS1096Line.FindFirst();
        IRS1096Line.TestField("Vendor No.", VendNo);
        IRS1096Line.TestField("IRS Code", IRSCode);
        IRS1096Line.TestField("Calculated Amount", DtldVendLedgEntry.Amount);

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [HandlerFunctions('MessageHandler')]
    procedure BlankDocTypeNotConsideredFor1096Form()
    var
        DtldVendLedgEntry: Record "Detailed Vendor Ledg. Entry";
        IRS1096Header: Record "IRS 1096 Form Header";
        IRS1096FormMgt: Codeunit "IRS 1096 Form Mgt.";
        VendNo: Code[20];
        IRSCode: Code[10];
        PostingDate: Date;
    begin
        // [SCENARIO 461543] A document with blank document type is not considered for 1096 form

        Initialize();
        IRSCode := InitializeDIVCode();
        PostingDate := CalcDate('<1Y>', WorkDate());
        VendNo := LibraryPurchase.CreateVendorNo();
        // [GIVEN] A document with blank doc. type applied to payment with "Vendor No." = "X", "Posting Date" = 01.01.2023 "IRS Code" = "DIV" and Amount = 100
        MockBlankDocTypeVendorLedgerEntry(DtldVendLedgEntry, VendNo, PostingDate, IRSCode, LibraryRandom.RandDec(100, 2));
        LibraryVariableStorage.Enqueue(NoEntriesToCreateFormsMsg);

        // [WHEN] Stan runs the "Create Forms" batch job for period from 01.01.2023 to 01.01.2023
        IRS1096FormMgt.CreateForms(PostingDate, PostingDate, false);

        // [THEN] No forms have been created
        Assert.IsTrue(IRS1096Header.IsEmpty(), '');

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [HandlerFunctions('MessageHandler')]
    procedure Only1096FormsWithLinesCreated()
    var
        DtldVendLedgEntry: Record "Detailed Vendor Ledg. Entry";
        IRS1096Header: Record "IRS 1096 Form Header";
        IRS1096FormMgt: Codeunit "IRS 1096 Form Mgt.";
        VendNo: Code[20];
        DivIRSCode: Code[10];
        MiscIRSCode: Code[10];
        PostingDate: Date;
        MinimumReportableAmount: Decimal;
    begin
        // [SCENARIO 461543] Only 1096 forms with lines created

        Initialize();
        // [GIVEN] IRS code "MISC" without "Minimum Reportable Amount"
        MiscIRSCode := InitializeMISCCode();
        MinimumReportableAmount := LibraryRandom.RandDec(100, 2);
        // [GIVEN] IRS code "DIV" with "Minimum Reportable Amount" = 100
        DivIRSCode := InitializeDIV01Code(MinimumReportableAmount);
        PostingDate := CalcDate('<1Y>', WorkDate());
        VendNo := LibraryPurchase.CreateVendorNo();
        // [GIVEN] Invoice applied to payment with "Vendor No." = "X", "Posting Date" = 01.01.2023 "IRS Code" = "MISC" and Amount = 50
        MockVendorLedgerEntry(DtldVendLedgEntry, VendNo, PostingDate, MiscIRSCode, LibraryRandom.RandDec(100, 2));
        // [GIVEN] Invoice applied to payment with "Vendor No." = "X", "Posting Date" = 01.01.2023 "IRS Code" = "DIV" and Amount = 100
        MockVendorLedgerEntry(DtldVendLedgEntry, VendNo, PostingDate, DivIRSCode, MinimumReportableAmount / 2);
        LibraryVariableStorage.Enqueue(FormsCreatedMsg);

        // [WHEN] Stan runs the "Create Forms" batch job for period from 01.01.2023 to 01.01.2023
        IRS1096FormMgt.CreateForms(PostingDate, PostingDate, false);

        // [THEN] Only one MISC form has been created with the MISC code
        Assert.RecordCount(IRS1096Header, 1);
        IRS1096Header.FindFirst();
        IRS1096Header.TestField("IRS Code", MiscIRSCode);

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    procedure CompanyInformationIRSFields()
    var
        CompanyInformation: Record "Company Information";
        Employee: Record Employee;
        CompanyInformationPage: TestPage "Company Information";
        EINNumber: Code[10];
    begin
        // [FEATURE] [UT]
        // [SCENARIO 453564] "EIN Number" and "IRS Contact No." are editable on Company Information page
        EINNumber := LibraryUtility.GenerateRandomNumericText(10);
        Employee.Init();
        Employee."No." := LibraryUtility.GenerateGUID();
        Employee.Insert();
        CompanyInformationPage.OpenEdit();
        CompanyInformationPage."EIN Number".SetValue(EINNumber);
        CompanyInformationPage."IRS Contact No.".SetValue(Employee."No.");
        CompanyInformationPage.Close();
        CompanyInformation.Get();
        CompanyInformation.TestField("EIN Number", EINNumber);
        CompanyInformation.TestField("IRS Contact No.", Employee."No.");
    end;

    [Test]
    [HandlerFunctions('IRS1096RequestPageHandler')]
    procedure ReportIRS1096RequestPageInitialization()
    var
        CompanyInformation: Record "Company Information";
        Employee: Record Employee;
        EINNumber: Code[10];
    begin
        // [FEATURE] [UT]
        // [SCENARIO 453564] 'IRS 1096 Form' report opens request page initialized with "EIN Number" and "IRS Contact No." from Company Information
        Initialize();

        // [GIVEN] "EIN Number" and "IRS Contact No."
        EINNumber := LibraryUtility.GenerateRandomNumericText(10);
        Employee.Init();
        Employee."No." := LibraryUtility.GenerateGUID();
        Employee."First Name" := LibraryUtility.GenerateGUID();
        Employee."Last Name" := LibraryUtility.GenerateGUID();
        Employee.Insert();
        CompanyInformation."EIN Number" := EINNumber;
        CompanyInformation."IRS Contact No." := Employee."No.";

        // [WHEN] Run 'IRS 1096 Form' report
        Report.Run(Report::"IRS 1096 Form");

        // [THEN] The report's request page is initialized with values from "EIN Number" and "IRS Contact No."
        Assert.AreEqual(EINNumber, LibraryVariableStorage.DequeueText(), '');
        Assert.AreEqual(Employee.FullName(), LibraryVariableStorage.DequeueText(), '');

        LibraryVariableStorage.AssertEmpty();
    end;

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(CODEUNIT::"Create 1096 Forms Test");
        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(CODEUNIT::"Create 1096 Forms Test");
        SetupIRS1096Feature();
        IsInitialized := true;
        LibraryTestInitialize.OnAfterTestSuiteInitialize(CODEUNIT::"Create 1096 Forms Test");
    end;

    local procedure SetupIRS1096Feature()
    var
        PurchPayablesSetup: Record "Purchases & Payables Setup";
    begin
        PurchPayablesSetup.Get();
        PurchPayablesSetup.Validate("IRS 1096 Form No. Series", LibraryERM.CreateNoSeriesCode());
        PurchPayablesSetup.Modify(true);
    end;

    local procedure MockVendorLedgerEntry(var InvDtldVendLedgEntry: Record "Detailed Vendor Ledg. Entry"; VendNo: Code[20]; PostingDate: Date; IRSCode: Code[10]; Amount: Decimal)
    var
        DocType: Enum "Gen. Journal Document Type";
    begin
        MockCustomVendorLedgerEntry(InvDtldVendLedgEntry, DocType::Invoice, VendNo, PostingDate, IRSCode, Amount);
    end;

    local procedure MockBlankDocTypeVendorLedgerEntry(var InvDtldVendLedgEntry: Record "Detailed Vendor Ledg. Entry"; VendNo: Code[20]; PostingDate: Date; IRSCode: Code[10]; Amount: Decimal)
    var
        DocType: Enum "Gen. Journal Document Type";
    begin
        MockCustomVendorLedgerEntry(InvDtldVendLedgEntry, DocType::" ", VendNo, PostingDate, IRSCode, Amount);
    end;

    local procedure MockCustomVendorLedgerEntry(var InvDtldVendLedgEntry: Record "Detailed Vendor Ledg. Entry"; DocType: Enum "Gen. Journal Document Type"; VendNo: Code[20]; PostingDate: Date; IRSCode: Code[10]; Amount: Decimal)
    var
        VendLedgEntry: Record "Vendor Ledger Entry";
        InvVendLedgEntry: Record "Vendor Ledger Entry";
        DtldVendLedgEntry: Record "Detailed Vendor Ledg. Entry";
    begin
        VendLedgEntry."Entry No." := LibraryUtility.GetNewRecNo(VendLedgEntry, VendLedgEntry.FieldNo("Entry No."));
        VendLedgEntry."Document Type" := VendLedgEntry."Document Type"::Payment;
        VendLedgEntry."Vendor No." := VendNo;
        VendLedgEntry."Posting Date" := PostingDate;
        VendLedgEntry.Insert();
        InvVendLedgEntry := VendLedgEntry;
        InvVendLedgEntry."Document Type" := DocType;
        InvVendLedgEntry."Entry No." := LibraryUtility.GetNewRecNo(VendLedgEntry, VendLedgEntry.FieldNo("Entry No."));
        InvVendLedgEntry."IRS 1099 Amount" := Amount;
        InvVendLedgEntry."IRS 1099 Code" := IRSCode;
        InvVendLedgEntry.Insert();

        DtldVendLedgEntry."Entry No." := LibraryUtility.GetNewRecNo(DtldVendLedgEntry, DtldVendLedgEntry.FieldNo("Entry No."));
        DtldVendLedgEntry."Vendor Ledger Entry No." := VendLedgEntry."Entry No.";
        DtldVendLedgEntry."Entry Type" := DtldVendLedgEntry."Entry Type"::Application;
        DtldVendLedgEntry."Transaction No." := LibraryRandom.RandInt(100);
        DtldVendLedgEntry."Application No." := LibraryRandom.RandInt(100);
        DtldVendLedgEntry."Ledger Entry Amount" := true;
        DtldVendLedgEntry.Insert();

        InvDtldVendLedgEntry := DtldVendLedgEntry;
        InvDtldVendLedgEntry."Entry No." := LibraryUtility.GetNewRecNo(InvDtldVendLedgEntry, InvDtldVendLedgEntry.FieldNo("Entry No."));
        InvDtldVendLedgEntry."Vendor Ledger Entry No." := InvVendLedgEntry."Entry No.";
        InvDtldVendLedgEntry.Amount := Amount;
        InvDtldVendLedgEntry."Ledger Entry Amount" := true;
        InvDtldVendLedgEntry."Amount (LCY)" := Amount;
        InvDtldVendLedgEntry.Insert();
    end;

    local procedure InitializeDIVCode(): Code[10]
    begin
        InitializeCode(DivCodeTok);
        exit(DivCodeTok);
    end;

    local procedure InitializeMISCCode(): Code[10]
    begin
        InitializeCode(DivCodeTok);
        exit(MiscCodeTok);
    end;

    local procedure InitializeCode(IRSCode: Code[10])
    var
        IRS1099FormBox: Record "IRS 1099 Form-Box";
    begin
        IRS1099FormBox.SetRange(Code, IRSCode);
        IRS1099FormBox.DeleteAll(true);
        IRS1099FormBox.Code := IRSCode;
        IRS1099FormBox.Insert();
    end;

    local procedure InitializeDIV01Code(MiminumReportableAmount: Decimal): Code[10]
    var
        IRS1099FormBox: Record "IRS 1099 Form-Box";
    begin
        IRS1099FormBox.SetRange(Code, Div01CodeTok);
        IRS1099FormBox.DeleteAll(true);
        IRS1099FormBox.Code := Div01CodeTok;
        IRS1099FormBox."Minimum Reportable" := MiminumReportableAmount;
        IRS1099FormBox.Insert();
        exit(IRS1099FormBox.Code);
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text)
    begin
        Assert.ExpectedMessage(LibraryVariableStorage.DequeueText(), Message);
    end;

    [RequestPageHandler]
    procedure IRS1096RequestPageHandler(var IRS1096Form: TestRequestPage "IRS 1096 Form")
    begin
        LibraryVariableStorage.Enqueue(IRS1096Form.IdentificationNumber);
        LibraryVariableStorage.Enqueue(IRS1096Form.ContactName);
        IRS1096Form.Cancel().Invoke();
    end;
}