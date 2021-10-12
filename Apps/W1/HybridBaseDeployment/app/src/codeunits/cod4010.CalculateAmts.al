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
        AccountCategory: Record "G/L Account Category";
    begin
        AccountCategory.SetRange(Description, CashDescriptionTxt);  // Note, the description must be 'Cash'
        if AccountCategory.Find('-') then
            exit(AccountCategory.GetBalance());
    end;

    procedure SalesProfitability(var NetIncome: Decimal): Decimal;
    var
        AccountCategoryIncome: Record "G/L Account Category";
        AccountCategoryCOGS: Record "G/L Account Category";
        AccountCategoryExpense: Record "G/L Account Category";
        Income: Decimal;
        COGS: Decimal;
        Expense: Decimal;

    begin
        AccountCategoryIncome.SetRange("Account Category", AccountCategoryIncome."Account Category"::Income);
        AccountCategoryIncome.SetRange(Indentation, 0);
        if AccountCategoryIncome.Find('-') then;

        AccountCategoryCOGS.SetRange("Account Category", AccountCategoryCOGS."Account Category"::"Cost of Goods Sold");
        AccountCategoryCOGS.SetRange(Indentation, 0);
        if AccountCategoryCOGS.Find('-') then;

        AccountCategoryExpense.SetRange("Account Category", AccountCategoryExpense."Account Category"::Expense);
        AccountCategoryExpense.SetRange(Indentation, 0);
        if AccountCategoryExpense.Find('-') then;

        Income := -AccountCategoryIncome.GetBalance();
        COGS := -AccountCategoryCOGS.GetBalance();
        Expense := -AccountCategoryExpense.GetBalance();
        NetIncome := Income + COGS + Expense;

        if Income <> 0 then
            exit(NetIncome / Income);
    end;

    procedure InventoryValue(): Decimal;
    var
        AccountCategory: Record "G/L Account Category";
    begin
        AccountCategory.SetRange(Description, InventoryDescriptionTxt);  // Note, the description must be 'Inventory'
        if AccountCategory.Find('-') then
            exit(AccountCategory.GetBalance());
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
        VendLedgerEntry: Record "Vendor Ledger Entry";
    begin
        VendLedgerEntry.SetRange("Document Type", VendLedgerEntry."Document Type"::Invoice);
        VendLedgerEntry.SetRange(Open, true);
        VendLedgerEntry.SetFilter("Due Date", '%1..%2', CALCDATE('<0D>', WorkDate()), CALCDATE('<6D>', workdate()));
        exit(StrSubstNo(PurchInvoicesDueThisWeekTxt, VendLedgerEntry.Count()));
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