codeunit 139767 "UT Report Bank Deposit"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Bank Deposit] [Reports]
    end;

    var
        LibraryReportDataSet: Codeunit "Library - Report Dataset";
        LibraryUTUtility: Codeunit "Library UT Utility";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryRandom: Codeunit "Library - Random";
        LibraryERM: Codeunit "Library - ERM";
        LibrarySales: Codeunit "Library - Sales";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryUtility: Codeunit "Library - Utility";
        Initialized: Boolean;
        InitializeHandled: Boolean;
        PostedBankDepositLineAmountTxt: Label 'Posted_Bank_Deposit_Line_Amount';
        PostedBankDepositLineAccountTypeCapTxt: Label 'Posted_Bank_Deposit_Line__Account_Type_';
        PostedBankDepositLineAccountNoCapTxt: Label 'Posted_Bank_Deposit_Line__Account_No__';
        AmountCapTxt: Label 'Amount';
        GenJournalLineAccountTypeCapTxt: Label 'Gen__Journal_Line__Account_Type_';
        GenJournalLineDocumentTypeCapTxt: Label 'Gen__Journal_Line__Document_Type_';
        AmountDueCapTxt: Label 'AmountDue';
        DimensionCapTxt: Label 'Dim1Number';
        GenJournalLineAppliesToIDCapTxt: Label 'Gen__Journal_Line_Applies_to_ID';
        DimSetEntryDimensionCodeCapTxt: Label 'DimensionSetEntry__Dimension_Code_';
        DimSetEntryDimensionCodeTxt: Label 'DimensionSetEntry2__Dimension_Code_';
        DimSetEntryDimensionValueCodeTxt: Label 'DimensionSetEntry2__Dimension_Value_Code_';

    [Test]
    [HandlerFunctions('DepositRequestPageHandler')]
    procedure OnAfterGetRecordCustLedgerEntryDeposit()
    var
        PostedBankDepositLine: Record "Posted Bank Deposit Line";
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        // Purpose of the test is to validate Posted Deposit Line - OnAfterGetRecord of the Report ID: 10403, Deposit with Cust. Ledger Entry.
        // Setup.
        Initialize();
        CreatePostedBankDeposit(PostedBankDepositLine, PostedBankDepositLine."Account Type"::Customer, CreateCustomer());
        CreateCustomerLedgerEntry(CustLedgerEntry, PostedBankDepositLine."Document No.", PostedBankDepositLine."Account No.");
        UpdateEntryNoPostedBankDepositLine(PostedBankDepositLine, CustLedgerEntry."Entry No.");
        CreateDetailedCustomerLedgerEntry(CustLedgerEntry."Entry No.", PostedBankDepositLine."Account No.");

        // Enqueue values for use in DepositRequestPageHandler.
        LibraryVariableStorage.Enqueue(PostedBankDepositLine."Bank Deposit No.");
        LibraryVariableStorage.Enqueue(true);  // Print Application - TRUE.

        // Exercise.
        Commit();  // Commit required for explicit commit used in Codeunit ID: 10143, Deposit-Printed.
        REPORT.Run(Report::"Bank Deposit");

        // Verify: Verify the Account No and Sum Amount after running Deposit Report.
        LibraryReportDataSet.LoadDataSetFile();
        LibraryReportDataSet.AssertElementWithValueExists(PostedBankDepositLineAccountTypeCapTxt, Format(PostedBankDepositLine."Account Type"::Customer));
        LibraryReportDataSet.AssertElementWithValueExists(PostedBankDepositLineAccountNoCapTxt, PostedBankDepositLine."Account No.");
        LibraryReportDataSet.AssertElementWithValueExists(PostedBankDepositLineAmountTxt, PostedBankDepositLine.Amount);
    end;

    [Test]
    [HandlerFunctions('DepositRequestPageHandler')]
    procedure OnAfterGetRecordVendLedgerEntryDeposit()
    var
        PostedBankDepositLine: Record "Posted Bank Deposit Line";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        // Purpose of the test is to validate Posted Deposit Line - OnAfterGetRecord of the Report ID: 10403, Deposit with Vendor Ledger Entry.
        // Setup.
        Initialize();
        CreatePostedBankDeposit(PostedBankDepositLine, PostedBankDepositLine."Account Type"::Vendor, CreateVendor());
        CreateVendorLedgerEntry(VendorLedgerEntry, PostedBankDepositLine."Document No.", PostedBankDepositLine."Account No.");
        UpdateEntryNoPostedBankDepositLine(PostedBankDepositLine, VendorLedgerEntry."Entry No.");
        CreateDetailedVendorLedgerEntry(VendorLedgerEntry."Entry No.", PostedBankDepositLine."Account No.");

        // Enqueue values for use in DepositRequestPageHandler.
        LibraryVariableStorage.Enqueue(PostedBankDepositLine."Bank Deposit No.");
        LibraryVariableStorage.Enqueue(false);  // Print Application - FALSE.

        // Exercise.
        Commit();  // Commit required for explicit commit used in Codeunit ID: 10143, Deposit-Printed.
        REPORT.Run(Report::"Bank Deposit");

        // Verify: Verify the Account No and Sum Amount after running Deposit Report.
        LibraryReportDataSet.LoadDataSetFile();
        LibraryReportDataSet.AssertElementWithValueExists(PostedBankDepositLineAccountTypeCapTxt, Format(PostedBankDepositLine."Account Type"::Vendor));
        LibraryReportDataSet.AssertElementWithValueExists(PostedBankDepositLineAccountNoCapTxt, PostedBankDepositLine."Account No.");
        LibraryReportDataSet.AssertElementWithValueExists(PostedBankDepositLineAmountTxt, PostedBankDepositLine.Amount);
    end;

    [Test]
    [HandlerFunctions('DepositRequestPageHandler')]
    procedure OnAfterGetRecordBankAccountDeposit()
    var
        PostedBankDepositHeader: Record "Posted Bank Deposit Header";
        PostedBankDepositLine: Record "Posted Bank Deposit Line";
    begin
        // Purpose of the test is to validate Posted Deposit Line - OnAfterGetRecord of the Report ID: 10403, Deposit with Account Type Bank Account.
        // Setup.
        Initialize();
        CreatePostedBankDeposit(PostedBankDepositLine, PostedBankDepositLine."Account Type"::"Bank Account", CreateBankAccount());

        // Enqueue values for use in DepositRequestPageHandler.
        LibraryVariableStorage.Enqueue(PostedBankDepositHeader."No.");
        LibraryVariableStorage.Enqueue(true);  // Print Application - TRUE.

        // Exercise.
        Commit();  // Commit required for explicit commit used in Codeunit ID: 10143, Deposit-Printed.
        REPORT.Run(Report::"Bank Deposit");

        // Verify: Verify the Account No and Account Type after running Deposit Report.
        LibraryReportDataSet.LoadDataSetFile();
        LibraryReportDataSet.AssertElementWithValueExists(PostedBankDepositLineAccountTypeCapTxt, Format(PostedBankDepositLine."Account Type"::"Bank Account"));
        LibraryReportDataSet.AssertElementWithValueExists(PostedBankDepositLineAccountNoCapTxt, PostedBankDepositLine."Account No.");
    end;

    [Test]
    [HandlerFunctions('DepositRequestPageHandler')]
    procedure OnAfterGetRecordGLAccountDeposit()
    var
        PostedBankDepositLine: Record "Posted Bank Deposit Line";
    begin
        // Purpose of the test is to validate Posted Deposit Line - OnAfterGetRecord of the Report ID: 10403, Deposit with Account Type GL Account.
        // Setup.
        Initialize();
        CreatePostedBankDeposit(PostedBankDepositLine, PostedBankDepositLine."Account Type"::"G/L Account", CreateGLAccount());

        // Enqueue values for use in DepositRequestPageHandler.
        LibraryVariableStorage.Enqueue(PostedBankDepositLine."Bank Deposit No.");
        LibraryVariableStorage.Enqueue(true);  // Print Application - TRUE.

        // Exercise.
        Commit(); // Commit required for explicit commit used in Codeunit ID: 10143, Deposit-Printed.
        REPORT.Run(Report::"Bank Deposit");

        // Verify: Verify the Account No and Account Type after running Deposit Report.
        LibraryReportDataSet.LoadDataSetFile();
        LibraryReportDataSet.AssertElementWithValueExists(PostedBankDepositLineAccountTypeCapTxt, Format(PostedBankDepositLine."Account Type"::"G/L Account"));
        LibraryReportDataSet.AssertElementWithValueExists(PostedBankDepositLineAccountNoCapTxt, PostedBankDepositLine."Account No.");
    end;

    [Test]
    [HandlerFunctions('DepositTestReportRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnAfterGetRecordGenJournalLineBlankICDepositTestReport()
    var
        BankDepositHeader: Record "Bank Deposit Header";
        GenJournalLine: Record "Gen. Journal Line";
    begin
        // Purpose of the test is to validate Gen. Journal Line - OnAfterGetRecord of the Report ID: 10402, Deposit Test Report with Account Type IC Partner.
        // Setup.
        Initialize();
        CreateBankDepositHeader(BankDepositHeader);
        CreateGenJournalLine(GenJournalLine, BankDepositHeader, GenJournalLine."Account Type"::"IC Partner", '');  // Blank IC Partner Code.
        LibraryVariableStorage.Enqueue(BankDepositHeader."No.");  // Enqueue value for use in DepositTestReportRequestPageHandler.

        // Exercise.
        REPORT.Run(REPORT::"Bank Deposit Test Report");

        // Verify: Verify the Document Type, Account Type and Amount after running Deposit Test Report.
        LibraryReportDataSet.LoadDataSetFile();
        LibraryReportDataSet.AssertElementWithValueExists(GenJournalLineAccountTypeCapTxt, Format(GenJournalLine."Account Type"::"IC Partner"));
        LibraryReportDataSet.AssertElementWithValueExists(GenJournalLineDocumentTypeCapTxt, Format(GenJournalLine."Document Type"::Payment));
        LibraryReportDataSet.AssertElementWithValueExists(AmountCapTxt, BankDepositHeader."Total Deposit Amount");
    end;

    [Test]
    [HandlerFunctions('DepositTestReportRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnAfterGetRecordGenJournalLineTypeICDepositTestReport()
    var
        BankDepositHeader: Record "Bank Deposit Header";
        GenJournalLine: Record "Gen. Journal Line";
    begin
        // Purpose of the test is to validate Gen. Journal Line - OnAfterGetRecord of the Report ID: 10402, Deposit Test Report with Account Type IC Partner.
        // Setup.
        Initialize();
        CreateBankDepositHeader(BankDepositHeader);
        CreateGenJournalLine(GenJournalLine, BankDepositHeader, GenJournalLine."Account Type"::"IC Partner", CreateICPartner());
        LibraryVariableStorage.Enqueue(BankDepositHeader."No.");  // Enqueue value for use in DepositTestReportRequestPageHandler.

        // Exercise.
        REPORT.Run(REPORT::"Bank Deposit Test Report");

        // Verify: Verify the Document Type, Account Type and Amount after running Deposit Test Report.
        LibraryReportDataSet.LoadDataSetFile();
        LibraryReportDataSet.AssertElementWithValueExists(GenJournalLineAccountTypeCapTxt, Format(GenJournalLine."Account Type"::"IC Partner"));
        LibraryReportDataSet.AssertElementWithValueExists(GenJournalLineDocumentTypeCapTxt, Format(GenJournalLine."Document Type"::Payment));
        LibraryReportDataSet.AssertElementWithValueExists(AmountCapTxt, BankDepositHeader."Total Deposit Amount");
    end;

    [Test]
    [HandlerFunctions('DepositTestReportRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnAfterGetRecordVendLedgerEntryDepositTestReport()
    var
        BankDepositHeader: Record "Bank Deposit Header";
        GenJournalLine: Record "Gen. Journal Line";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        // Purpose of the test is to validate Vendor Ledger Entry - OnAfterGetRecord of the Report ID: 10402, Deposit Test Report with Account Type Vendor.
        // Setup.
        Initialize();
        CreateBankDepositHeader(BankDepositHeader);
        CreateGenJournalLine(GenJournalLine, BankDepositHeader, GenJournalLine."Account Type"::Vendor, CreateVendor());
        UpdateApplyToDocGenJournalLine(GenJournalLine);
        LibraryVariableStorage.Enqueue(BankDepositHeader."No.");  // Enqueue value for use in DepositTestReportRequestPageHandler.
        CreateVendorLedgerEntry(VendorLedgerEntry, GenJournalLine."Document No.", GenJournalLine."Account No.");
        UpdateApplyToDocVendorLedgerEntry(VendorLedgerEntry, GenJournalLine);
        CreateDetailedVendorLedgerEntry(VendorLedgerEntry."Entry No.", GenJournalLine."Account No.");

        // Exercise.
        REPORT.Run(REPORT::"Bank Deposit Test Report");

        // Verify: Verify the Document Type, Account Type, Amount and Amount Due after running Deposit Test Report.
        LibraryReportDataSet.LoadDataSetFile();
        VendorLedgerEntry.CalcFields("Remaining Amount");
        LibraryReportDataSet.AssertElementWithValueExists(GenJournalLineAccountTypeCapTxt, Format(GenJournalLine."Account Type"::Vendor));
        LibraryReportDataSet.AssertElementWithValueExists(GenJournalLineDocumentTypeCapTxt, Format(GenJournalLine."Document Type"::Payment));
        LibraryReportDataSet.AssertElementWithValueExists(AmountCapTxt, BankDepositHeader."Total Deposit Amount");
        LibraryReportDataSet.AssertElementWithValueExists(AmountDueCapTxt, VendorLedgerEntry."Remaining Amount");
    end;

    [Test]
    [HandlerFunctions('DepositTestReportRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnAfterGetRecordCustLedgerEntryDepositTestReport()
    var
        BankDepositHeader: Record "Bank Deposit Header";
        GenJournalLine: Record "Gen. Journal Line";
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        // Purpose of the test is to validate Cust. Ledger Entry - OnAfterGetRecord of the Report ID: 10402, Deposit Test Report with Account Type Customer.
        // Setup.
        Initialize();
        CreateBankDepositHeader(BankDepositHeader);
        CreateGenJournalLine(GenJournalLine, BankDepositHeader, GenJournalLine."Account Type"::Customer, CreateCustomer());
        UpdateApplyToDocGenJournalLine(GenJournalLine);
        LibraryVariableStorage.Enqueue(BankDepositHeader."No.");  // Enqueue value for use in DepositTestReportRequestPageHandler.
        CreateCustomerLedgerEntry(CustLedgerEntry, GenJournalLine."Document No.", GenJournalLine."Account No.");
        UpdateApplyToDocCustomerLedgerEntry(CustLedgerEntry, GenJournalLine);
        CreateDetailedCustomerLedgerEntry(CustLedgerEntry."Entry No.", GenJournalLine."Account No.");

        // Exercise.
        REPORT.Run(REPORT::"Bank Deposit Test Report");

        // Verify: Verify the Document Type, Account Type, Amount and Amount Due after running Deposit Test Report.
        LibraryReportDataSet.LoadDataSetFile();
        CustLedgerEntry.CalcFields("Remaining Amount");
        LibraryReportDataSet.AssertElementWithValueExists(GenJournalLineAccountTypeCapTxt, Format(GenJournalLine."Account Type"::Customer));
        LibraryReportDataSet.AssertElementWithValueExists(GenJournalLineDocumentTypeCapTxt, Format(GenJournalLine."Document Type"::Payment));
        LibraryReportDataSet.AssertElementWithValueExists(AmountCapTxt, BankDepositHeader."Total Deposit Amount");
        LibraryReportDataSet.AssertElementWithValueExists(AmountDueCapTxt, CustLedgerEntry."Remaining Amount");
    end;

    [Test]
    [HandlerFunctions('DepositTestReportRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnAfterGetRecordApplyCustLedgerDepositTestReport()
    var
        BankDepositHeader: Record "Bank Deposit Header";
        GenJournalLine: Record "Gen. Journal Line";
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        // Purpose of the test is to validate Cust. Ledger Entry - OnAfterGetRecord of the Report ID: 10402, Deposit Test Report with Applies To ID.
        // Setup.
        Initialize();
        CreateBankDepositHeader(BankDepositHeader);
        CreateGenJournalLine(GenJournalLine, BankDepositHeader, GenJournalLine."Account Type"::Customer, CreateCustomer());
        LibraryVariableStorage.Enqueue(BankDepositHeader."No.");  // Enqueue value for use in DepositTestReportRequestPageHandler.
        CreateCustomerLedgerEntry(CustLedgerEntry, GenJournalLine."Document No.", GenJournalLine."Account No.");
        CustLedgerEntry."Applies-to ID" := GenJournalLine."Applies-to ID";
        CustLedgerEntry.Modify();
        CreateDetailedCustomerLedgerEntry(CustLedgerEntry."Entry No.", GenJournalLine."Account No.");

        // Exercise.
        REPORT.Run(REPORT::"Bank Deposit Test Report");

        // Verify: Verify the Document Type, Account Type, Dimension and Applies To ID after running Deposit Test Report.
        LibraryReportDataSet.LoadDataSetFile();
        LibraryReportDataSet.AssertElementWithValueExists(DimensionCapTxt, 0);  // Blank Dimension.
        LibraryReportDataSet.AssertElementWithValueExists(GenJournalLineAccountTypeCapTxt, Format(GenJournalLine."Account Type"::Customer));
        LibraryReportDataSet.AssertElementWithValueExists(GenJournalLineDocumentTypeCapTxt, Format(GenJournalLine."Document Type"::Payment));
        LibraryReportDataSet.AssertElementWithValueExists(GenJournalLineAppliesToIDCapTxt, GenJournalLine."Applies-to ID");
    end;

    [Test]
    [HandlerFunctions('DepositTestReportRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnAfterGetRecordApplyVendLedgerDepositTestReport()
    var
        BankDepositHeader: Record "Bank Deposit Header";
        GenJournalLine: Record "Gen. Journal Line";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        // Purpose of the test is to validate Vendor Ledger Entry - OnAfterGetRecord of the Report ID: 10402, Deposit Test Report with Applies To ID.
        // Setup.
        Initialize();
        CreateBankDepositHeader(BankDepositHeader);
        CreateGenJournalLine(GenJournalLine, BankDepositHeader, GenJournalLine."Account Type"::Vendor, CreateVendor());
        LibraryVariableStorage.Enqueue(BankDepositHeader."No.");  // Enqueue value for use in DepositTestReportRequestPageHandler.
        CreateVendorLedgerEntry(VendorLedgerEntry, GenJournalLine."Document No.", GenJournalLine."Account No.");
        VendorLedgerEntry."Applies-to ID" := GenJournalLine."Applies-to ID";
        VendorLedgerEntry.Modify();
        CreateDetailedVendorLedgerEntry(VendorLedgerEntry."Entry No.", GenJournalLine."Account No.");

        // Exercise.
        REPORT.Run(REPORT::"Bank Deposit Test Report");

        // Verify: Verify the Document Type, Account Type, Dimension and Applies To ID after running Deposit Test Report.
        LibraryReportDataSet.LoadDataSetFile();
        LibraryReportDataSet.AssertElementWithValueExists(DimensionCapTxt, 0);  // Blank Dimension.
        LibraryReportDataSet.AssertElementWithValueExists(GenJournalLineAccountTypeCapTxt, Format(GenJournalLine."Account Type"::Vendor));
        LibraryReportDataSet.AssertElementWithValueExists(GenJournalLineDocumentTypeCapTxt, Format(GenJournalLine."Document Type"::Payment));
        LibraryReportDataSet.AssertElementWithValueExists(GenJournalLineAppliesToIDCapTxt, GenJournalLine."Applies-to ID");
    end;

    [Test]
    [HandlerFunctions('DepositTestReportRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnAfterGetRecordDimLoopTypeBankDepositTestReport()
    var
        BankDepositHeader: Record "Bank Deposit Header";
        GenJournalLine: Record "Gen. Journal Line";
        DimensionSetEntry: Record "Dimension Set Entry";
    begin
        // Purpose of the test is to validate DimensionLoop1 - OnAfterGetRecord of the Report ID: 10402, Deposit Test Report with Account Type Bank Account.
        // Setup.
        Initialize();
        CreateBankDepositHeader(BankDepositHeader);
        CreateGenJournalLine(GenJournalLine, BankDepositHeader, GenJournalLine."Account Type"::"Bank Account", CreateBankAccount());
        CreateDimension(DimensionSetEntry);
        UpdateDimensionOnBankDepositHeader(BankDepositHeader, DimensionSetEntry."Dimension Set ID");
        LibraryVariableStorage.Enqueue(BankDepositHeader."No.");  // Enqueue value for use in DepositTestReportRequestPageHandler.

        // Exercise.
        REPORT.Run(REPORT::"Bank Deposit Test Report");

        // Verify: Verify the Document Type, Account Type, Dimension Code and Applies To ID after running Deposit Test Report.
        LibraryReportDataSet.LoadDataSetFile();
        LibraryReportDataSet.AssertElementWithValueExists(DimensionCapTxt, 1);
        LibraryReportDataSet.AssertElementWithValueExists(DimSetEntryDimensionCodeCapTxt, DimensionSetEntry."Dimension Code");
        LibraryReportDataSet.AssertElementWithValueExists(GenJournalLineAccountTypeCapTxt, Format(GenJournalLine."Account Type"::"Bank Account"));
        LibraryReportDataSet.AssertElementWithValueExists(GenJournalLineDocumentTypeCapTxt, Format(GenJournalLine."Document Type"::Payment));
    end;

    [Test]
    [HandlerFunctions('DepositTestReportRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnAfterGetRecordDimLoopTypeGLDepositTestReport()
    var
        BankDepositHeader: Record "Bank Deposit Header";
        GenJournalLine: Record "Gen. Journal Line";
        DimensionSetEntry: Record "Dimension Set Entry";
    begin
        // Purpose of the test is to validate DimensionLoop1 - OnAfterGetRecord of the Report ID: 10402, Deposit Test Report with Account Type GL Account.
        // Setup.
        Initialize();
        CreateBankDepositHeader(BankDepositHeader);
        CreateGenJournalLine(GenJournalLine, BankDepositHeader, GenJournalLine."Account Type"::"G/L Account", CreateGLAccount());
        CreateDimension(DimensionSetEntry);
        UpdateDimensionOnBankDepositHeader(BankDepositHeader, DimensionSetEntry."Dimension Set ID");
        LibraryVariableStorage.Enqueue(BankDepositHeader."No.");  // Enqueue value for use in DepositTestReportRequestPageHandler.

        // Exercise.
        REPORT.Run(REPORT::"Bank Deposit Test Report");

        // Verify: Verify the Document Type, Account Type, Dimension Code and Applies To ID after running Deposit Test Report.
        LibraryReportDataSet.LoadDataSetFile();
        LibraryReportDataSet.AssertElementWithValueExists(DimensionCapTxt, 1);
        LibraryReportDataSet.AssertElementWithValueExists(DimSetEntryDimensionCodeCapTxt, DimensionSetEntry."Dimension Code");
        LibraryReportDataSet.AssertElementWithValueExists(GenJournalLineAccountTypeCapTxt, Format(GenJournalLine."Account Type"::"G/L Account"));
        LibraryReportDataSet.AssertElementWithValueExists(GenJournalLineDocumentTypeCapTxt, Format(GenJournalLine."Document Type"::Payment));
    end;

    [Test]
    [HandlerFunctions('DepositTestReportRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure DepositTestReportForEmployee()
    var
        Employee: Record Employee;
        BankDepositHeader: Record "Bank Deposit Header";
        GenJournalLine: Record "Gen. Journal Line";
    begin
        // [SCENARIO 256390] Print "Deposit Test Report" with Account Type is Employee and descrition the same as employee's Name
        Initialize();

        // [GIVEN] Deposit with line where Account Type is Employee "E" which has Name "N" and description "N"
        CreateBankDepositHeader(BankDepositHeader);
        CreateEmployee(Employee);
        CreateGenJournalLine(GenJournalLine, BankDepositHeader, GenJournalLine."Account Type"::Employee, Employee."No.");
        GenJournalLine.Validate(Description, CopyStr(Employee.FullName(), 1, MaxStrLen(GenJournalLine.Description)));
        GenJournalLine.Modify(true);
        LibraryVariableStorage.Enqueue(BankDepositHeader."No.");  // Enqueue value for use in DepositTestReportRequestPageHandler.

        // [WHEN] Run "Deposit Test Report"
        REPORT.Run(REPORT::"Bank Deposit Test Report");

        // [THEN] Employee "E" presents in the report with Name "N"
        // [THEN] Description "N" is not exported
        LibraryReportDataSet.LoadDataSetFile();
        VerifyDepositTestReportEmployee(GenJournalLine, Employee."No." + ' - ' + Employee.FullName());
        LibraryReportDataSet.AssertElementWithValueNotExist('Gen__Journal_Line_Description', Employee.FullName());
        LibraryReportDataSet.AssertElementWithValueNotExist('Gen__Journal_Line_Description', GenJournalLine.Description);
    end;

    [Test]
    [HandlerFunctions('DepositTestReportRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure DepositTestReportForEmployeeWithLineDescription()
    var
        Employee: Record Employee;
        BankDepositHeader: Record "Bank Deposit Header";
        GenJournalLine: Record "Gen. Journal Line";
    begin
        // [SCENARIO 256390] Print "Deposit Test Report" with Account Type is Employee and descrition different from employee's Name
        Initialize();

        // [GIVEN] Deposit with line where Account Type is Employee "E" which has Name "N" and description "D"
        CreateBankDepositHeader(BankDepositHeader);
        CreateEmployee(Employee);
        CreateGenJournalLine(GenJournalLine, BankDepositHeader, GenJournalLine."Account Type"::Employee, Employee."No.");
        GenJournalLine.Validate(Description, LibraryUTUtility.GetNewCode());
        GenJournalLine.Modify(true);
        LibraryVariableStorage.Enqueue(BankDepositHeader."No.");  // Enqueue value for use in DepositTestReportRequestPageHandler.

        // [WHEN] Run "Deposit Test Report"
        REPORT.Run(REPORT::"Bank Deposit Test Report");

        // [THEN] Employee "E" presents in the report with Name "N"
        // [THEN] Description "N" is not exported
        // [THEN] Description "D" is exported
        LibraryReportDataSet.LoadDataSetFile();
        VerifyDepositTestReportEmployee(GenJournalLine, Employee."No." + ' - ' + Employee.FullName());
        LibraryReportDataSet.AssertElementWithValueNotExist('Gen__Journal_Line_Description', Employee.FullName());
        LibraryReportDataSet.AssertElementWithValueExists('Gen__Journal_Line_Description', GenJournalLine.Description);
    end;

    [Test]
    [HandlerFunctions('DepositTestReportRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure DepositTestReportForRemovedEmployee()
    var
        Employee: Record Employee;
        BankDepositHeader: Record "Bank Deposit Header";
        GenJournalLine: Record "Gen. Journal Line";
    begin
        // [SCENARIO 256390] Print "Deposit Test Report" with Account Type is Employee and Employee is removed
        Initialize();

        // [GIVEN] Deposit with line where Account Type is Employee "E" which has Name "N"
        CreateBankDepositHeader(BankDepositHeader);
        CreateEmployee(Employee);
        CreateGenJournalLine(GenJournalLine, BankDepositHeader, GenJournalLine."Account Type"::Employee, Employee."No.");
        LibraryVariableStorage.Enqueue(BankDepositHeader."No.");  // Enqueue value for use in DepositTestReportRequestPageHandler.
        Employee.Delete();

        // [WHEN] Run "Deposit Test Report"
        REPORT.Run(REPORT::"Bank Deposit Test Report");

        // [THEN] Employee "E" presents in the report with Name marked as 'Invalid Employee'
        LibraryReportDataSet.LoadDataSetFile();
        VerifyDepositTestReportEmployee(GenJournalLine, Employee."No." + ' - ' + '<Invalid Employee>');
    end;

    [Test]
    [HandlerFunctions('DepositTestReportRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnAfterGetRecordDimLoopTypeGLDepositTestReport2()
    var
        BankDepositHeader: Record "Bank Deposit Header";
        GenJournalLine: Record "Gen. Journal Line";
        DimensionSetEntry: Record "Dimension Set Entry";
    begin
        // [SCENARIO 372135] Purpose of the test is to validate DimensionLoop1 - OnAfterGetRecord of the Report ID: 10402, Deposit Test Report with Account Type GL Account.
        Initialize();

        // [GIVEN] Deposit with General Journal line with Dimension "D" and Dimension Value "DV".
        CreateBankDepositHeader(BankDepositHeader);
        CreateGenJournalLine(GenJournalLine, BankDepositHeader, GenJournalLine."Account Type"::"G/L Account", CreateGLAccount());
        CreateDimension(DimensionSetEntry);
        UpdateDimendionOnDepositLine(GenJournalLine, DimensionSetEntry."Dimension Set ID");

        // [WHEN] Report "Deposit Test Report" is run.
        LibraryVariableStorage.Enqueue(BankDepositHeader."No.");
        REPORT.Run(REPORT::"Bank Deposit Test Report");

        // [THEN] Verify the Document Type, Account Type, Dimension Code and Applies To ID after running Deposit Test Report.
        LibraryReportDataSet.LoadDataSetFile();
        LibraryReportDataSet.AssertElementWithValueExists(DimSetEntryDimensionCodeTxt, DimensionSetEntry."Dimension Code");
        LibraryReportDataSet.AssertElementWithValueExists(DimSetEntryDimensionValueCodeTxt, DimensionSetEntry."Dimension Value Code");

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('DepositTestReportRequestPageHandler')]
    procedure ApplyingTwoDifferentJournalLinesWithSameDocumentNoToDifferentEntriesDisplayApplicationsInTestReport()
    var
        BankDepositHeader: Record "Bank Deposit Header";
        SalesHeader: Record "Sales Header";
        FirstInvoice: Record "Cust. Ledger Entry";
        SecondInvoice: Record "Cust. Ledger Entry";
        FirstJournalLine: Record "Gen. Journal Line";
        SecondJournalLine: Record "Gen. Journal Line";
    begin
        // [SCENARIO 543664] When running the Test report, applications of two lines with the same document number should be displayed.
        Initialize();
        // [GIVEN] A bank deposit with two lines, applied to two different sales invoices, of the same customer.
        CreateBankDepositHeader(BankDepositHeader);
        LibrarySales.CreateSalesInvoice(SalesHeader);
        LibrarySales.PostSalesDocument(SalesHeader, false, true);
        CreateGenJournalLine(FirstJournalLine, BankDepositHeader, FirstJournalLine."Account Type"::Customer, SalesHeader."Bill-to Customer No.");
        FirstInvoice.SetRange("Customer No.", SalesHeader."Bill-to Customer No.");
        FirstInvoice.FindLast();
        FirstInvoice."Applies-to ID" := BankDepositHeader."No.";
        FirstInvoice.CalcFields("Remaining Amount");
        FirstInvoice.Modify();
        FirstJournalLine."Document No." := BankDepositHeader."No.";
        FirstJournalLine.Amount := -FirstInvoice."Remaining Amount";
        FirstJournalLine.Modify();
        UpdateGenJournalLineAppliesToID(FirstJournalLine, BankDepositHeader."No.");
        LibrarySales.CreateSalesInvoiceForCustomerNo(SalesHeader, FirstInvoice."Customer No.");
        LibrarySales.PostSalesDocument(SalesHeader, false, true);
        CreateGenJournalLine(SecondJournalLine, BankDepositHeader, FirstJournalLine."Account Type"::Customer, SalesHeader."Bill-to Customer No.");
        SecondInvoice.SetRange("Customer No.", SalesHeader."Bill-to Customer No.");
        SecondInvoice.FindLast();
        SecondInvoice."Applies-to ID" := BankDepositHeader."No.";
        SecondInvoice.CalcFields("Remaining Amount");
        SecondInvoice.Modify();
        SecondJournalLine."Document No." := BankDepositHeader."No.";
        SecondJournalLine.Amount := -SecondInvoice."Remaining Amount";
        SecondJournalLine.Modify();
        UpdateGenJournalLineAppliesToID(SecondJournalLine, BankDepositHeader."No.");
        Commit();
        // [WHEN] Running the Test Report
        LibraryVariableStorage.Enqueue(BankDepositHeader."No.");
        Report.Run(Report::"Bank Deposit Test Report");
        // [THEN] Both applications should be shown
        LibraryReportDataSet.LoadDataSetFile();
        LibraryReportDataSet.AssertElementTagWithValueExists('Cust__Ledger_Entry__Document_No__', FirstInvoice."Document No.");
        LibraryReportDataSet.AssertElementTagWithValueExists('Cust__Ledger_Entry__Document_No__', SecondInvoice."Document No.");
        BankDepositHeader.Delete();
    end;

    [Test]
    [HandlerFunctions('DepositTestReportRequestPageHandler')]
    procedure ApplyingTwoDepositLinesToTwoOpenCustomerEntriesEachShowInTestReport()
    var
        BankDepositHeader: Record "Bank Deposit Header";
        Customer: Record Customer;
        CustomerLedgerEntries: array[4] of Record "Cust. Ledger Entry";
        FirstLine, SecondLine : Record "Gen. Journal Line";
    begin
        // [SCENARIO 543664] Applying two deposit lines to two open customer entries each should show the four lines on the Test Report
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        // [GIVEN] A bank deposit with two deposit lines
        CreateBankDepositHeader(BankDepositHeader);
        CreateGenJournalLine(FirstLine, BankDepositHeader, FirstLine."Account Type"::Customer, Customer."No.");
        UpdateApplyToDocGenJournalLine(FirstLine);
        CreateGenJournalLine(SecondLine, BankDepositHeader, SecondLine."Account Type"::Customer, Customer."No.");
        UpdateApplyToDocGenJournalLine(SecondLine);
        // [GIVEN] 4 open customer ledger entries
        CreateCustomerLedgerEntry(CustomerLedgerEntries[1], 'INV1', Customer."No.");
        CreateCustomerLedgerEntry(CustomerLedgerEntries[2], 'INV2', Customer."No.");
        CreateCustomerLedgerEntry(CustomerLedgerEntries[3], 'INV3', Customer."No.");
        CreateCustomerLedgerEntry(CustomerLedgerEntries[4], 'INV4', Customer."No.");
        // [GIVEN] Each deposit line applied to two of the customer ledger entries
        UpdateApplyToDocCustomerLedgerEntry(CustomerLedgerEntries[1], FirstLine);
        UpdateApplyToDocCustomerLedgerEntry(CustomerLedgerEntries[2], FirstLine);
        UpdateApplyToDocCustomerLedgerEntry(CustomerLedgerEntries[3], SecondLine);
        UpdateApplyToDocCustomerLedgerEntry(CustomerLedgerEntries[4], SecondLine);
        Commit();
        // [WHEN] Running the test report
        LibraryVariableStorage.Enqueue(BankDepositHeader."No.");
        Report.Run(Report::"Bank Deposit Test Report");
        LibraryReportDataSet.LoadDataSetFile();
        // [THEN] The 4 invoices should appear in the report
        LibraryReportDataSet.AssertElementWithValueExists('Cust__Ledger_Entry__Document_No__', 'INV1');
        LibraryReportDataSet.AssertElementWithValueExists('Cust__Ledger_Entry__Document_No__', 'INV2');
        LibraryReportDataSet.AssertElementWithValueExists('Cust__Ledger_Entry__Document_No__', 'INV3');
        LibraryReportDataSet.AssertElementWithValueExists('Cust__Ledger_Entry__Document_No__', 'INV4');
        BankDepositHeader.Delete();
    end;

    [Test]
    [HandlerFunctions('DepositTestReportRequestPageHandler')]
    procedure ApplyingTwoDepositLinesToTwoOpenVendorEntriesEachShowInTestReport()
    var
        BankDepositHeader: Record "Bank Deposit Header";
        Vendor: Record Vendor;
        FirstLine, SecondLine : Record "Gen. Journal Line";
        VendorLedgerEntries: array[4] of Record "Vendor Ledger Entry";
    begin
        // [SCENARIO 543664] Applying two deposit lines to two open vendor entries each should show the four lines on the Test Report
        Initialize();
        LibraryPurchase.CreateVendor(Vendor);
        // [GIVEN] A bank deposit with two deposit lines
        CreateBankDepositHeader(BankDepositHeader);
        CreateGenJournalLine(FirstLine, BankDepositHeader, FirstLine."Account Type"::Vendor, Vendor."No.");
        UpdateApplyToDocGenJournalLine(FirstLine);
        CreateGenJournalLine(SecondLine, BankDepositHeader, SecondLine."Account Type"::Vendor, Vendor."No.");
        UpdateApplyToDocGenJournalLine(SecondLine);
        // [GIVEN] 4 open customer ledger entries
        CreateVendorLedgerEntry(VendorLedgerEntries[1], 'INV1', Vendor."No.");
        CreateVendorLedgerEntry(VendorLedgerEntries[2], 'INV2', Vendor."No.");
        CreateVendorLedgerEntry(VendorLedgerEntries[3], 'INV3', Vendor."No.");
        CreateVendorLedgerEntry(VendorLedgerEntries[4], 'INV4', Vendor."No.");
        // [GIVEN] Each deposit line applied to two of the customer ledger entries
        UpdateApplyToDocVendorLedgerEntry(VendorLedgerEntries[1], FirstLine);
        UpdateApplyToDocVendorLedgerEntry(VendorLedgerEntries[2], FirstLine);
        UpdateApplyToDocVendorLedgerEntry(VendorLedgerEntries[3], SecondLine);
        UpdateApplyToDocVendorLedgerEntry(VendorLedgerEntries[4], SecondLine);
        Commit();
        // [WHEN] Running the test report
        LibraryVariableStorage.Enqueue(BankDepositHeader."No.");
        Report.Run(Report::"Bank Deposit Test Report");
        LibraryReportDataSet.LoadDataSetFile();
        // [THEN] The 4 invoices should appear in the report
        LibraryReportDataSet.AssertElementWithValueExists('Vendor_Ledger_Entry__Document_No__', 'INV1');
        LibraryReportDataSet.AssertElementWithValueExists('Vendor_Ledger_Entry__Document_No__', 'INV2');
        LibraryReportDataSet.AssertElementWithValueExists('Vendor_Ledger_Entry__Document_No__', 'INV3');
        LibraryReportDataSet.AssertElementWithValueExists('Vendor_Ledger_Entry__Document_No__', 'INV4');
        BankDepositHeader.Delete();
    end;

    local procedure Initialize()
    begin
        LibraryVariableStorage.Clear();

        if Initialized then
            exit;

        OnBeforeInitialize(InitializeHandled);
        if InitializeHandled then
            exit;

        OnAfterInitialize(InitializeHandled);
        Initialized := true;
    end;

    local procedure CreateBankDepositHeader(var BankDepositHeader: Record "Bank Deposit Header")
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        BankDepositHeader."No." := LibraryUTUtility.GetNewCode();
        BankDepositHeader."Posting Date" := WorkDate();
        BankDepositHeader."Document Date" := WorkDate();
        BankDepositHeader."Bank Account No." := CreateBankAccount();
        BankDepositHeader."Total Deposit Amount" := LibraryRandom.RandDec(10, 2);
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        BankDepositHeader."Journal Template Name" := GenJournalTemplate.Name;
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        BankDepositHeader."Journal Batch Name" := GenJournalBatch.Name;
        BankDepositHeader.Insert();
    end;

    local procedure CreatePostedBankDeposit(var PostedBankDepositLine: Record "Posted Bank Deposit Line"; AccountType: Option; AccountNo: Code[20])
    var
        PostedBankDepositHeader: Record "Posted Bank Deposit Header";
    begin
        PostedBankDepositHeader."No." := LibraryUTUtility.GetNewCode();
        PostedBankDepositHeader.Insert();

        PostedBankDepositLine."Bank Deposit No." := PostedBankDepositHeader."No.";
        PostedBankDepositLine."Line No." := LibraryRandom.RandInt(10);
        PostedBankDepositLine."Account Type" := AccountType;
        PostedBankDepositLine."Document Type" := PostedBankDepositLine."Document Type"::Payment;
        PostedBankDepositLine."Account No." := AccountNo;
        PostedBankDepositLine.Amount := LibraryRandom.RandDec(10, 2);
        PostedBankDepositLine.Insert();
    end;

    local procedure CreateGenJournalLine(var GenJournalLine: Record "Gen. Journal Line"; BankDepositHeader: Record "Bank Deposit Header"; AccountType: Option; AccountNo: Code[20])
    begin
        GenJournalLine."Journal Batch Name" := BankDepositHeader."Journal Batch Name";
        GenJournalLine."Journal Template Name" := BankDepositHeader."Journal Template Name";
        GenJournalLine."Line No." := LibraryUtility.GetNewRecNo(GenJournalLine, GenJournalLine.FieldNo("Line No."));
        GenJournalLine."Document Type" := GenJournalLine."Document Type"::Payment;
        GenJournalLine."Account Type" := AccountType;
        GenJournalLine."Account No." := AccountNo;
        GenJournalLine.Amount := -BankDepositHeader."Total Deposit Amount";
        GenJournalLine."Document No." := LibraryUTUtility.GetNewCode();
        GenJournalLine."Applies-to ID" := LibraryUTUtility.GetNewCode();
        GenJournalLine."Document Date" := WorkDate();
        GenJournalLine.Insert();
    end;

    local procedure CreateGLAccount(): Code[20]
    var
        GLAccount: Record "G/L Account";
    begin
        GLAccount."No." := LibraryUTUtility.GetNewCode();
        GLAccount.Insert();
        exit(GLAccount."No.");
    end;

    local procedure CreateCustomer(): Code[20]
    var
        Customer: Record Customer;
    begin
        Customer."No." := LibraryUTUtility.GetNewCode();
        Customer.Insert();
        exit(Customer."No.");
    end;

    local procedure CreateVendor(): Code[20]
    var
        Vendor: Record Vendor;
    begin
        Vendor."No." := LibraryUTUtility.GetNewCode();
        Vendor.Insert();
        exit(Vendor."No.");
    end;

    local procedure CreateICPartner(): Code[20]
    var
        ICPartner: Record "IC Partner";
    begin
        ICPartner.Code := LibraryUTUtility.GetNewCode();
        ICPartner.Insert();
        exit(ICPartner.Code);
    end;

    local procedure CreateEmployee(var Employee: Record Employee): Code[20]
    begin
        Employee."No." := LibraryUTUtility.GetNewCode();
        Employee."First Name" := LibraryUTUtility.GetNewCode();
        Employee.Insert();
        exit(Employee."No.");
    end;

    local procedure CreateBankAccount(): Code[20]
    var
        BankAccount: Record "Bank Account";
    begin
        BankAccount."No." := LibraryUTUtility.GetNewCode();
        BankAccount.Insert();
        exit(BankAccount."No.");
    end;

    local procedure CreateDimension(var DimensionSetEntry: Record "Dimension Set Entry")
    var
        DimensionValue: Record "Dimension Value";
        Dimension: Record Dimension;
    begin
        Dimension.Code := LibraryUTUtility.GetNewCode();
        Dimension.Insert();
        DimensionValue.Code := LibraryUTUtility.GetNewCode();
        DimensionValue."Dimension Code" := Dimension.Code;
        DimensionValue.Insert();
        CreateDimensionSetEntry(DimensionSetEntry, DimensionValue."Dimension Code", DimensionValue.Code);
    end;

    local procedure CreateDimensionSetEntry(var DimensionSetEntry: Record "Dimension Set Entry"; DimensionCode: Code[20]; DimensionValueCode: Code[20])
    var
        DimensionSetEntry2: Record "Dimension Set Entry";
    begin
        DimensionSetEntry2.FindLast();
        DimensionSetEntry."Dimension Set ID" := DimensionSetEntry2."Dimension Set ID" + 1;
        DimensionSetEntry."Dimension Code" := DimensionCode;
        DimensionSetEntry."Dimension Value Code" := DimensionValueCode;
        DimensionSetEntry.Insert();
    end;

    local procedure CreateCustomerLedgerEntry(var CustLedgerEntry: Record "Cust. Ledger Entry"; DocumentNo: Code[20]; CustomerNo: Code[20])
    var
        CustLedgerEntry2: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry2.FindLast();
        CustLedgerEntry."Entry No." := CustLedgerEntry2."Entry No." + 1;
        CustLedgerEntry."Document Type" := CustLedgerEntry."Document Type"::Invoice;
        CustLedgerEntry."Document No." := DocumentNo;
        CustLedgerEntry.Open := true;
        CustLedgerEntry."Customer No." := CustomerNo;
        CustLedgerEntry.Insert();
    end;

    local procedure CreateDetailedCustomerLedgerEntry(CustLedgerEntryNo: Integer; CustomerNo: Code[20])
    var
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        DetailedCustLedgEntry2: Record "Detailed Cust. Ledg. Entry";
    begin
        DetailedCustLedgEntry2.FindLast();
        DetailedCustLedgEntry."Entry No." := DetailedCustLedgEntry2."Entry No." + 1;
        DetailedCustLedgEntry."Cust. Ledger Entry No." := CustLedgerEntryNo;
        DetailedCustLedgEntry."Customer No." := CustomerNo;
        DetailedCustLedgEntry.Amount := LibraryRandom.RandDec(10, 2);
        DetailedCustLedgEntry.Insert(true);
    end;

    local procedure CreateVendorLedgerEntry(var VendorLedgerEntry: Record "Vendor Ledger Entry"; DocumentNo: Code[20]; VendorNo: Code[20])
    var
        VendorLedgerEntry2: Record "Vendor Ledger Entry";
    begin
        VendorLedgerEntry2.FindLast();
        VendorLedgerEntry."Entry No." := VendorLedgerEntry2."Entry No." + 1;
        VendorLedgerEntry."Document Type" := VendorLedgerEntry."Document Type"::Invoice;
        VendorLedgerEntry."Document No." := DocumentNo;
        VendorLedgerEntry."Vendor No." := VendorNo;
        VendorLedgerEntry.Open := true;
        VendorLedgerEntry.Insert();
    end;

    local procedure CreateDetailedVendorLedgerEntry(VendorLedgerEntryNo: Integer; VendorNo: Code[20])
    var
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
        DetailedVendorLedgEntry2: Record "Detailed Vendor Ledg. Entry";
    begin
        DetailedVendorLedgEntry2.FindLast();
        DetailedVendorLedgEntry."Entry No." := DetailedVendorLedgEntry2."Entry No." + 1;
        DetailedVendorLedgEntry."Vendor Ledger Entry No." := VendorLedgerEntryNo;
        DetailedVendorLedgEntry."Vendor No." := VendorNo;
        DetailedVendorLedgEntry.Amount := LibraryRandom.RandDec(10, 2);
        DetailedVendorLedgEntry.Insert(true);
    end;

    local procedure UpdateEntryNoPostedBankDepositLine(PostedBankDepositLine: Record "Posted Bank Deposit Line"; EntryNo: Integer)
    begin
        PostedBankDepositLine."Entry No." := EntryNo;
        PostedBankDepositLine.Modify();
    end;

    local procedure UpdateGenJournalLineAppliesToID(var GenJournalLine: Record "Gen. Journal Line"; AppliesToID: Code[50])
    begin
        GenJournalLine."Applies-to Doc. Type" := GenJournalLine."Applies-to Doc. Type"::Invoice;
        GenJournalLine."Applies-to ID" := AppliesToID;
        GenJournalLine.Modify();
    end;

    local procedure UpdateApplyToDocGenJournalLine(var GenJournalLine: Record "Gen. Journal Line")
    begin
        GenJournalLine."Applies-to Doc. Type" := GenJournalLine."Applies-to Doc. Type"::Invoice;
        GenJournalLine."Applies-to Doc. No." := LibraryUTUtility.GetNewCode();
        GenJournalLine.Modify();
    end;

    local procedure UpdateApplyToDocVendorLedgerEntry(VendorLedgerEntry: Record "Vendor Ledger Entry"; GenJournalLine: Record "Gen. Journal Line")
    begin
        VendorLedgerEntry."Applies-to ID" := GenJournalLine."Applies-to ID";
        VendorLedgerEntry."Applies-to Doc. Type" := GenJournalLine."Applies-to Doc. Type";
        VendorLedgerEntry."Applies-to Doc. No." := GenJournalLine."Applies-to Doc. No.";
        VendorLedgerEntry.Modify();
    end;

    local procedure UpdateApplyToDocCustomerLedgerEntry(CustLedgerEntry: Record "Cust. Ledger Entry"; GenJournalLine: Record "Gen. Journal Line")
    begin
        CustLedgerEntry."Applies-to ID" := GenJournalLine."Applies-to ID";
        CustLedgerEntry."Applies-to Doc. Type" := GenJournalLine."Applies-to Doc. Type";
        CustLedgerEntry."Applies-to Doc. No." := GenJournalLine."Applies-to Doc. No.";
        CustLedgerEntry.Modify();
    end;

    local procedure UpdateDimensionOnBankDepositHeader(BankDepositHeader: Record "Bank Deposit Header"; DimensionSetID: Integer)
    begin
        BankDepositHeader."Dimension Set ID" := DimensionSetID;
        BankDepositHeader.Modify();
    end;

    local procedure UpdateDimendionOnDepositLine(var GenJournalLine: Record "Gen. Journal Line"; DimensionSetID: Integer)
    begin
        GenJournalLine.Validate("Dimension Set ID", DimensionSetID);
        GenJournalLine.Modify(true);
    end;

    local procedure VerifyDepositTestReportEmployee(GenJournalLine: Record "Gen. Journal Line"; AccountName: Text)
    begin
        LibraryReportDataSet.AssertElementWithValueExists(GenJournalLineAccountTypeCapTxt, Format(GenJournalLine."Account Type"::Employee));
        LibraryReportDataSet.AssertElementWithValueExists(GenJournalLineDocumentTypeCapTxt, Format(GenJournalLine."Document Type"::Payment));
        LibraryReportDataSet.AssertElementWithValueExists(AmountCapTxt, -GenJournalLine.Amount);
        LibraryReportDataSet.AssertElementWithValueExists('Gen__Journal_Line_Account_No_', GenJournalLine."Account No.");
        LibraryReportDataSet.AssertElementWithValueExists('Account_No_____________AccountName', AccountName);
    end;

    [RequestPageHandler]
    procedure DepositRequestPageHandler(var BankDeposit: TestRequestPage "Bank Deposit")
    var
        No: Variant;
        ShowApplications: Variant;
    begin
        LibraryVariableStorage.Dequeue(No);
        LibraryVariableStorage.Dequeue(ShowApplications);
        BankDeposit."Posted Bank Deposit Header".SetFilter("No.", No);
        BankDeposit.ShowApplications.SetValue(ShowApplications);
        BankDeposit.SaveAsXml(LibraryReportDataSet.GetParametersFileName(), LibraryReportDataSet.GetFileName());
    end;

    [RequestPageHandler]
    procedure DepositTestReportRequestPageHandler(var BankDepositTestReport: TestRequestPage "Bank Deposit Test Report")
    var
        NoVariant: Variant;
    begin
        LibraryVariableStorage.Dequeue(NoVariant);
        BankDepositTestReport."Bank Deposit Header".SetFilter("No.", NoVariant);
        BankDepositTestReport.ShowApplications.SetValue(true);
        BankDepositTestReport.ShowDimensions.SetValue(true);
        BankDepositTestReport.SaveAsXml(LibraryReportDataSet.GetParametersFileName(), LibraryReportDataSet.GetFileName());
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitialize(var InitializeHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitialize(var InitializeHandled: Boolean)
    begin
    end;
}

