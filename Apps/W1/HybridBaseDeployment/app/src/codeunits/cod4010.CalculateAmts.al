codeunit 4010 CalculateAmounts
{
    trigger OnRun()
    begin
    end;

    var
        CashDescriptionTxt: Label 'Cash';
        InventoryDescriptionTxt: Label 'Inventory';
        OverDueSalesTxt: label '%1 of your customers are late with their payments to you', Comment = '%1 - percentage of customers';
        SalesInvoicesThisWeekTxt: label '%1 invoices are supposed to be paid by your customers this week', Comment = '%1 - percentage of invoices';
        PurchInvoicesDueThisWeekTxt: label '%1 invoices from vendors should be paid this week', Comment = '%1 - percentage of invoices';
        PurchInvoicesOverdueTxt: label '%1 invoices weren''t paid by you on time', Comment = '%1 - percentage of invoices';

    procedure CashAvailable(): Decimal;
    var
        GLAccountCategory: Record "G/L Account Category";
    begin
        GLAccountCategory.SetRange(Description, CashDescriptionTxt);  // Note, the description must be 'Cash'
        if GLAccountCategory.Find('-') then
            exit(GLAccountCategory.GetBalance());
    end;

    procedure SalesProfitability(var NetIncome: Decimal): Decimal;
    var
        GLAccountCategoryIncome: Record "G/L Account Category";
        GLAccountCategoryCOGS: Record "G/L Account Category";
        GLAccountCategoryExpense: Record "G/L Account Category";
        Income: Decimal;
        COGS: Decimal;
        Expense: Decimal;

    begin
        GLAccountCategoryIncome.SetRange("Account Category", GLAccountCategoryIncome."Account Category"::Income);
        GLAccountCategoryIncome.SetRange(Indentation, 0);
        if GLAccountCategoryIncome.Find('-') then;

        GLAccountCategoryCOGS.SetRange("Account Category", GLAccountCategoryCOGS."Account Category"::"Cost of Goods Sold");
        GLAccountCategoryCOGS.SetRange(Indentation, 0);
        if GLAccountCategoryCOGS.Find('-') then;

        GLAccountCategoryExpense.SetRange("Account Category", GLAccountCategoryExpense."Account Category"::Expense);
        GLAccountCategoryExpense.SetRange(Indentation, 0);
        if GLAccountCategoryExpense.Find('-') then;

        Income := -GLAccountCategoryIncome.GetBalance();
        COGS := -GLAccountCategoryCOGS.GetBalance();
        Expense := -GLAccountCategoryExpense.GetBalance();
        NetIncome := Income + COGS + Expense;

        if Income <> 0 then
            exit(NetIncome / Income);
    end;

    procedure InventoryValue(): Decimal;
    var
        GLAccountCategory: Record "G/L Account Category";
    begin
        GLAccountCategory.SetRange(Description, InventoryDescriptionTxt);  // Note, the description must be 'Inventory'
        if GLAccountCategory.Find('-') then
            exit(GLAccountCategory.GetBalance());
    end;

    procedure NumOfOverDueSalesInvoice(): text;
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
        CustLedgerEntry.SetRange(Open, true);
        CustLedgerEntry.SetFilter("Due Date", '<%1', WorkDate());
        CustLedgerEntry.SETFILTER("Remaining Amt. (LCY)", '<>0');
        exit(StrSubstNo(OverDueSalesTxt, CustLedgerEntry.Count()));
    end;

    procedure DrillDownNumOfOverDueSalesInvoice()
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.SETRANGE("Document Type", CustLedgerEntry."Document Type"::Invoice);
        CustLedgerEntry.SETRANGE(Open, TRUE);
        CustLedgerEntry.SETFILTER("Due Date", '<%1', workdate());
        CustLedgerEntry.SETFILTER("Remaining Amt. (LCY)", '<>0');
        CustLedgerEntry.SETCURRENTKEY("Remaining Amt. (LCY)");
        CustLedgerEntry.ASCENDING := FALSE;
        PAGE.RUN(PAGE::"Customer Ledger Entries", CustLedgerEntry);
    end;

    procedure NumOfSalesInvoicesDueThisWeek(): text;
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
        CustLedgerEntry.SetRange(Open, true);
        CustLedgerEntry.SetFilter("Due Date", '%1..%2', CALCDATE('<0D>', WorkDate()), CALCDATE('<6D>', workdate()));
        CustLedgerEntry.SETFILTER("Remaining Amt. (LCY)", '<>0');
        exit(StrSubstNo(SalesInvoicesThisWeekTxt, CustLedgerEntry.Count()));
    end;

    procedure DrillDownNumOfSalesInvoicesDueThisWeek()
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.SETRANGE("Document Type", CustLedgerEntry."Document Type"::Invoice);
        CustLedgerEntry.SETRANGE(Open, TRUE);
        CustLedgerEntry.SetFilter("Due Date", '%1..%2', CALCDATE('<0D>', WorkDate()), CALCDATE('<6D>', workdate()));
        CustLedgerEntry.SETFILTER("Remaining Amt. (LCY)", '<>0');
        CustLedgerEntry.SETCURRENTKEY("Remaining Amt. (LCY)");
        CustLedgerEntry.ASCENDING := FALSE;
        PAGE.RUN(PAGE::"Customer Ledger Entries", CustLedgerEntry);
    end;

    procedure NumOfPurchInvoicesDueThisWeek(): text;
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        VendorLedgerEntry.SetRange("Document Type", VendorLedgerEntry."Document Type"::Invoice);
        VendorLedgerEntry.SetRange(Open, true);
        VendorLedgerEntry.SetFilter("Due Date", '%1..%2', CALCDATE('<0D>', WorkDate()), CALCDATE('<6D>', workdate()));
        exit(StrSubstNo(PurchInvoicesDueThisWeekTxt, VendorLedgerEntry.Count()));
    end;

    procedure DrillDownNumOfPurchInvoicesDueThisWeek()
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        VendorLedgerEntry.SETRANGE("Document Type", VendorLedgerEntry."Document Type"::Invoice);
        VendorLedgerEntry.SetFilter("Due Date", '%1..%2', CALCDATE('<0D>', WorkDate()), CALCDATE('<6D>', workdate()));
        VendorLedgerEntry.SETFILTER("Remaining Amt. (LCY)", '<>0');
        VendorLedgerEntry.SETCURRENTKEY("Remaining Amt. (LCY)");
        VendorLedgerEntry.ASCENDING := TRUE;
        PAGE.RUN(PAGE::"Vendor Ledger Entries", VendorLedgerEntry);
    end;

    procedure NumOfPurchInvoicesOverDue(): text;
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        VendorLedgerEntry.SetRange("Document Type", VendorLedgerEntry."Document Type"::Invoice);
        VendorLedgerEntry.SetRange(Open, true);
        VendorLedgerEntry.SetFilter("Due Date", '<%1', WorkDate());
        exit(StrSubstNo(PurchInvoicesOverdueTxt, VendorLedgerEntry.Count()));
    end;

    procedure DrillDownNumOfPurchInvoicesOverDue(): text;
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        VendorLedgerEntry.SETRANGE("Document Type", VendorLedgerEntry."Document Type"::Invoice);
        VendorLedgerEntry.SetFilter("Due Date", '<%1', WorkDate());
        VendorLedgerEntry.SETFILTER("Remaining Amt. (LCY)", '<>0');
        VendorLedgerEntry.SETCURRENTKEY("Remaining Amt. (LCY)");
        VendorLedgerEntry.ASCENDING := TRUE;
        PAGE.RUN(PAGE::"Vendor Ledger Entries", VendorLedgerEntry);
    end;
}