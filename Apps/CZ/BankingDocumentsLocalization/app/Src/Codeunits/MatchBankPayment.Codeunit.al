codeunit 31362 "Match Bank Payment CZB"
{
    TableNo = "Gen. Journal Line";

    trigger OnRun()
    begin
        GenJournalLine.Copy(Rec);
        Code();
        Rec := GenJournalLine;
    end;

    var
        OriginalGenJournalLine: Record "Gen. Journal Line";
        GenJournalLine: Record "Gen. Journal Line";
        BankAccount: Record "Bank Account";
        SearchRuleLineCZB: Record "Search Rule Line CZB";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        EmployeeLedgerEntry: Record "Employee Ledger Entry";
        TempMatchBankPaymentBufferCZB: Record "Match Bank Payment Buffer CZB" temporary;
        MinAmount, MaxAmount : Decimal;

    local procedure Code()
    begin
        GenJournalLine.TestField("Bal. Account Type", GenJournalLine."Bal. Account Type"::"Bank Account");
        GenJournalLine.TestField("Bal. Account No.");
        GenJournalLine.TestField("Search Rule Code CZB");
        if GenJournalLine.IsLocalCurrencyCZB() then
            GenJournalLine.TestField("Amount (LCY)")
        else
            GenJournalLine.TestField(Amount);
        GenJournalLine."Search Rule Line No. CZB" := 0;

        BankAccount.Get(GenJournalLine."Bal. Account No.");
        BankAccount.TestField("Disable Automatic Pmt Matching", false);
        if GenJournalLine.IsLocalCurrencyCZB() then
            GetAmountRangeForTolerance(BankAccount, -GenJournalLine."Amount (LCY)", MinAmount, MaxAmount)
        else
            GetAmountRangeForTolerance(BankAccount, -GenJournalLine.Amount, MinAmount, MaxAmount);

        SearchRuleLineCZB.SetRange("Search Rule Code", GenJournalLine."Search Rule Code CZB");
        SearchRuleLineCZB.FindSet();
        repeat
            if SearchRuleLineCZB."Search Scope" = SearchRuleLineCZB."Search Scope"::"Account Mapping" then begin
                // filter rule
                GenJournalLine.Reset();
                GenJournalLine.SetRecFilter();
                if SearchRuleLineCZB."Description Filter" <> '' then
                    GenJournalLine.SetFilter(Description, SearchRuleLineCZB."Description Filter");
                if SearchRuleLineCZB."Variable Symbol Filter" <> '' then
                    GenJournalLine.SetFilter("Variable Symbol CZL", SearchRuleLineCZB."Variable Symbol Filter");
                if SearchRuleLineCZB."Constant Symbol Filter" <> '' then
                    GenJournalLine.SetFilter("Constant Symbol CZL", SearchRuleLineCZB."Constant Symbol Filter");
                if SearchRuleLineCZB."Specific Symbol Filter" <> '' then
                    GenJournalLine.SetFilter("Specific Symbol CZL", SearchRuleLineCZB."Specific Symbol Filter");
                case SearchRuleLineCZB."Banking Transaction Type" of
                    SearchRuleLineCZB."Banking Transaction Type"::Credit:
                        GenJournalLine.SetFilter("Amount (LCY)", '>0');
                    SearchRuleLineCZB."Banking Transaction Type"::Debit:
                        GenJournalLine.SetFilter("Amount (LCY)", '<0');
                end;
                if not GenJournalLine.IsEmpty() then begin
                    OriginalGenJournalLine := GenJournalLine;
                    SearchRuleLineCZB.TestField("Account Type");
                    SearchRuleLineCZB.TestField("Account No.");
                    case SearchRuleLineCZB."Account Type" of
                        SearchRuleLineCZB."Account Type"::"G/L Account":
                            GenJournalLine.Validate("Account Type", GenJournalLine."Account Type"::"G/L Account");
                        SearchRuleLineCZB."Account Type"::Customer:
                            GenJournalLine.Validate("Account Type", GenJournalLine."Account Type"::Customer);
                        SearchRuleLineCZB."Account Type"::Vendor:
                            GenJournalLine.Validate("Account Type", GenJournalLine."Account Type"::Vendor);
                        SearchRuleLineCZB."Account Type"::"Bank Account":
                            GenJournalLine.Validate("Account Type", GenJournalLine."Account Type"::"Bank Account");
                        SearchRuleLineCZB."Account Type"::Employee:
                            GenJournalLine.Validate("Account Type", GenJournalLine."Account Type"::Employee);
                    end;
                    GenJournalLine.Validate("Account No.", SearchRuleLineCZB."Account No.");
                    GenJournalLine."Search Rule Line No. CZB" := SearchRuleLineCZB."Line No.";
                    GenJournalLine.Description := OriginalGenJournalLine.Description;
                end;
                SearchRuleLineCZB.SetRange("Description Filter");
                SearchRuleLineCZB.SetRange("Variable Symbol Filter");
                SearchRuleLineCZB.SetRange("Constant Symbol Filter");
                SearchRuleLineCZB.SetRange("Specific Symbol Filter");
            end else begin
                // search rule
                TempMatchBankPaymentBufferCZB.Reset();
                TempMatchBankPaymentBufferCZB.DeleteAll();
                case
                    SearchRuleLineCZB."Search Scope" of
                    SearchRuleLineCZB."Search Scope"::Balance:
                        begin
                            FillMatchBankPaymentBufferCustomer();
                            FillMatchBankPaymentBufferVendor();
                            FillMatchBankPaymentBufferEmployee();
#if not CLEAN19
                            FillMatchBankPaymentBufferSalesAdvance();
                            FillMatchBankPaymentBufferPurchAdvance();
#endif
                        end;
                    SearchRuleLineCZB."Search Scope"::Customer:
                        begin
                            FillMatchBankPaymentBufferCustomer();
#if not CLEAN19
                            FillMatchBankPaymentBufferSalesAdvance();
#endif
                        end;
                    SearchRuleLineCZB."Search Scope"::Vendor:
                        begin
                            FillMatchBankPaymentBufferVendor();
#if not CLEAN19
                            FillMatchBankPaymentBufferPurchAdvance();
#endif
                        end;
                    SearchRuleLineCZB."Search Scope"::Employee:
                        FillMatchBankPaymentBufferEmployee();
                end;
                OnAfterFillMatchBankPaymentBuffer(TempMatchBankPaymentBufferCZB, SearchRuleLineCZB, GenJournalLine);

                if TempMatchBankPaymentBufferCZB.Count() > 0 then begin
                    case SearchRuleLineCZB."Multiple Result" of
                        "Multiple Search Result CZB"::"First Created Entry":
                            TempMatchBankPaymentBufferCZB.Ascending(true);
                        "Multiple Search Result CZB"::"Last Created Entry":
                            TempMatchBankPaymentBufferCZB.Ascending(false);
                        "Multiple Search Result CZB"::"Earliest Due Date":
                            begin
                                TempMatchBankPaymentBufferCZB.SetCurrentKey("Due Date");
                                TempMatchBankPaymentBufferCZB.Ascending(true);
                            end;
                        "Multiple Search Result CZB"::"Latest Due Date":
                            begin
                                TempMatchBankPaymentBufferCZB.SetCurrentKey("Due Date");
                                TempMatchBankPaymentBufferCZB.Ascending(false);
                            end;
                        "Multiple Search Result CZB"::"Earliest Posting Date":
                            begin
                                TempMatchBankPaymentBufferCZB.SetCurrentKey("Posting Date");
                                TempMatchBankPaymentBufferCZB.Ascending(true);
                            end;
                        "Multiple Search Result CZB"::"Latest Posting Date":
                            begin
                                TempMatchBankPaymentBufferCZB.SetCurrentKey("Posting Date");
                                TempMatchBankPaymentBufferCZB.Ascending(false);
                            end;
                        "Multiple Search Result CZB"::"Smallest Remaining Amount":
                            begin
                                TempMatchBankPaymentBufferCZB.SetCurrentKey("Remaining Amount");
                                TempMatchBankPaymentBufferCZB.Ascending(true);
                            end;
                        "Multiple Search Result CZB"::"Greatest Remaining Amount":
                            begin
                                TempMatchBankPaymentBufferCZB.SetCurrentKey("Remaining Amount");
                                TempMatchBankPaymentBufferCZB.Ascending(false);
                            end;
                    end;
                    if not ((TempMatchBankPaymentBufferCZB.Count() > 1) and (SearchRuleLineCZB."Multiple Result" = "Multiple Search Result CZB"::Continue)) then begin
                        OriginalGenJournalLine := GenJournalLine;
                        TempMatchBankPaymentBufferCZB.FindFirst();
                        case TempMatchBankPaymentBufferCZB."Account Type" of
                            TempMatchBankPaymentBufferCZB."Account Type"::Customer:
                                GenJournalLine.Validate("Account Type", GenJournalLine."Account Type"::Customer);
                            TempMatchBankPaymentBufferCZB."Account Type"::Vendor:
                                GenJournalLine.Validate("Account Type", GenJournalLine."Account Type"::Vendor);
                            TempMatchBankPaymentBufferCZB."Account Type"::Employee:
                                GenJournalLine.Validate("Account Type", GenJournalLine."Account Type"::Employee);
                        end;
                        GenJournalLine.Validate("Account No.", TempMatchBankPaymentBufferCZB."Account No.");
#if not CLEAN19
#pragma warning disable AL0432
                        if TempMatchBankPaymentBufferCZB."Letter No." = '' then begin
#pragma warning restore AL0432
#endif
                            GenJournalLine.Validate("Applies-to Doc. Type", TempMatchBankPaymentBufferCZB."Document Type");
                            GenJournalLine.Validate("Applies-to Doc. No.", TempMatchBankPaymentBufferCZB."Document No.");
                            if GenJournalLine."Account Type" in [GenJournalLine."Account Type"::Customer, GenJournalLine."Account Type"::Vendor] then begin
                                if GenJournalLine."Applies-to Doc. Type" = GenJournalLine."Applies-to Doc. Type"::Invoice then
                                    GenJournalLine.Validate("Document Type", GenJournalLine."Document Type"::Payment);
                                if GenJournalLine."Applies-to Doc. Type" = GenJournalLine."Applies-to Doc. Type"::"Credit Memo" then
                                    GenJournalLine.Validate("Document Type", GenJournalLine."Document Type"::Refund);
                            end;
                            if BankAccount."Dimension from Apply Entry CZB" then
                                GenJournalLine.Validate("Dimension Set ID", TempMatchBankPaymentBufferCZB."Dimension Set ID");
#if not CLEAN19
#pragma warning disable AL0432
                        end else
                            ApplyAdvanceLetter(GenJournalLine, TempMatchBankPaymentBufferCZB."Letter No.");
#pragma warning restore AL0432
#endif
                        if GenJournalLine."Currency Code" <> OriginalGenJournalLine."Currency Code" then
                            GenJournalLine.Validate("Currency Code", OriginalGenJournalLine."Currency Code");
                        if GenJournalLine."Currency Factor" <> OriginalGenJournalLine."Currency Factor" then
                            GenJournalLine.Validate("Currency Factor", OriginalGenJournalLine."Currency Factor");
                        if GenJournalLine.Amount <> OriginalGenJournalLine.Amount then
                            GenJournalLine.Validate(Amount, OriginalGenJournalLine.Amount);
                        if GenJournalLine.Description <> OriginalGenJournalLine.Description then
                            GenJournalLine.Description := OriginalGenJournalLine.Description;

                        OnAfterValidateGenJournalLine(TempMatchBankPaymentBufferCZB, GenJournalLine);
                        GenJournalLine."Search Rule Line No. CZB" := SearchRuleLineCZB."Line No.";
                    end;
                end;
            end;
        until (SearchRuleLineCZB.Next() = 0) or (GenJournalLine."Search Rule Line No. CZB" <> 0);
    end;

    local procedure FillMatchBankPaymentBufferCustomer()
    var
        CustomerBankAccount: Record "Customer Bank Account";
        UsePaymentDiscounts: Boolean;
    begin
        CustLedgerEntry.Reset();
        CustLedgerEntry.SetCurrentKey("Customer No.", Open);
        CustLedgerEntry.SetRange(Prepayment, false);
        if (GenJournalLine."Account Type" = GenJournalLine."Account Type"::Customer) and
           (GenJournalLine."Account No." <> '')
        then
            CustLedgerEntry.SetRange("Customer No.", GenJournalLine."Account No.");
        if SearchRuleLineCZB."Bank Account No." then begin
            if (GenJournalLine."Bank Account No. CZL" = '') and
               (GenJournalLine."Bank Account Code CZL" = '') and
               (GenJournalLine."IBAN CZL" = '')
            then
                exit;
            if CustLedgerEntry.GetFilter("Customer No.") <> '' then
                CustLedgerEntry.CopyFilter("Customer No.", CustomerBankAccount."Customer No.");
            if GenJournalLine."Bank Account Code CZL" <> '' then
                CustomerBankAccount.SetRange(Code, GenJournalLine."Bank Account Code CZL");
            if GenJournalLine."Bank Account No. CZL" <> '' then
                CustomerBankAccount.SetRange("Bank Account No.", GenJournalLine."Bank Account No. CZL");
            if GenJournalLine."IBAN CZL" <> '' then
                CustomerBankAccount.SetRange(IBAN, GenJournalLine."IBAN CZL");
            if CustomerBankAccount.Count() <> 1 then
                exit;
            CustomerBankAccount.FindFirst();
            CustLedgerEntry.SetRange("Customer No.", CustomerBankAccount."Customer No.");
        end;
        CustLedgerEntry.SetRange(Open, true);
        if SearchRuleLineCZB.Amount then
            if GenJournalLine.IsLocalCurrencyCZB() then
                CustLedgerEntry.SetRange("Remaining Amt. (LCY)", MinAmount, MaxAmount)
            else
                CustLedgerEntry.SetRange("Remaining Amount", MinAmount, MaxAmount);
        if SearchRuleLineCZB."Variable Symbol" then begin
            if GenJournalLine."Variable Symbol CZL" = '' then
                exit;
            CustLedgerEntry.SetRange("Variable Symbol CZL", GenJournalLine."Variable Symbol CZL");
        end;
        if SearchRuleLineCZB."Specific Symbol" then begin
            if GenJournalLine."Specific Symbol CZL" = '' then
                exit;
            CustLedgerEntry.SetRange("Specific Symbol CZL", GenJournalLine."Specific Symbol CZL");
        end;
        if SearchRuleLineCZB."Constant Symbol" then begin
            if GenJournalLine."Constant Symbol CZL" = '' then
                exit;
            CustLedgerEntry.SetRange("Constant Symbol CZL", GenJournalLine."Constant Symbol CZL");
        end;
        case SearchRuleLineCZB."Banking Transaction Type" of
            SearchRuleLineCZB."Banking Transaction Type"::Credit:
                CustLedgerEntry.SetRange(Positive, true);
            SearchRuleLineCZB."Banking Transaction Type"::Debit:
                CustLedgerEntry.SetRange(Positive, false);
        end;
        if CustLedgerEntry.FindSet() then
            repeat
                TempMatchBankPaymentBufferCZB.InsertFromCustomerLedgerEntry(CustLedgerEntry, true, UsePaymentDiscounts);
            until CustLedgerEntry.Next() = 0;
    end;

    local procedure FillMatchBankPaymentBufferVendor()
    var
        VendorBankAccount: Record "Vendor Bank Account";
        UsePaymentDiscounts: Boolean;
    begin
        VendorLedgerEntry.Reset();
        VendorLedgerEntry.SetCurrentKey("Vendor No.", Open);
        VendorLedgerEntry.SetRange(Prepayment, false);
        if (GenJournalLine."Account Type" = GenJournalLine."Account Type"::Vendor) and
            (GenJournalLine."Account No." <> '')
        then
            VendorLedgerEntry.SetRange("Vendor No.", GenJournalLine."Account No.");
        if SearchRuleLineCZB."Bank Account No." then begin
            if (GenJournalLine."Bank Account No. CZL" = '') and
               (GenJournalLine."Bank Account Code CZL" = '') and
               (GenJournalLine."IBAN CZL" = '')
            then
                exit;
            if VendorLedgerEntry.GetFilter("Vendor No.") <> '' then
                VendorLedgerEntry.CopyFilter("Vendor No.", VendorBankAccount."Vendor No.");
            if GenJournalLine."Bank Account Code CZL" <> '' then
                VendorBankAccount.SetRange(Code, GenJournalLine."Bank Account Code CZL");
            if GenJournalLine."Bank Account No. CZL" <> '' then
                VendorBankAccount.SetRange("Bank Account No.", GenJournalLine."Bank Account No. CZL");
            if GenJournalLine."IBAN CZL" <> '' then
                VendorBankAccount.SetRange(IBAN, GenJournalLine."IBAN CZL");
            if VendorBankAccount.Count() <> 1 then
                exit;
            VendorBankAccount.FindFirst();
            VendorLedgerEntry.SetRange("Vendor No.", VendorBankAccount."Vendor No.");
        end;
        VendorLedgerEntry.SetRange(Open, true);
        if SearchRuleLineCZB.Amount then
            if GenJournalLine.IsLocalCurrencyCZB() then
                VendorLedgerEntry.SetRange("Remaining Amt. (LCY)", MinAmount, MaxAmount)
            else
                VendorLedgerEntry.SetRange("Remaining Amount", MinAmount, MaxAmount);
        if SearchRuleLineCZB."Variable Symbol" then begin
            if GenJournalLine."Variable Symbol CZL" = '' then
                exit;
            VendorLedgerEntry.SetRange("Variable Symbol CZL", GenJournalLine."Variable Symbol CZL");
        end;
        if SearchRuleLineCZB."Specific Symbol" then begin
            if GenJournalLine."Specific Symbol CZL" = '' then
                exit;
            VendorLedgerEntry.SetRange("Specific Symbol CZL", GenJournalLine."Specific Symbol CZL");
        end;
        if SearchRuleLineCZB."Constant Symbol" then begin
            if GenJournalLine."Constant Symbol CZL" = '' then
                exit;
            VendorLedgerEntry.SetRange("Constant Symbol CZL", GenJournalLine."Constant Symbol CZL");
        end;
        case SearchRuleLineCZB."Banking Transaction Type" of
            SearchRuleLineCZB."Banking Transaction Type"::Debit:
                VendorLedgerEntry.SetRange(Positive, true);
            SearchRuleLineCZB."Banking Transaction Type"::Credit:
                VendorLedgerEntry.SetRange(Positive, false);
        end;
        if VendorLedgerEntry.FindSet() then
            repeat
                TempMatchBankPaymentBufferCZB.InsertFromVendorLedgerEntry(VendorLedgerEntry, true, UsePaymentDiscounts);
            until VendorLedgerEntry.Next() = 0;
    end;

    local procedure FillMatchBankPaymentBufferEmployee()
    var
        Employee: Record Employee;
    begin
        EmployeeLedgerEntry.Reset();
        EmployeeLedgerEntry.SetCurrentKey("Employee No.", Open);

        if (GenJournalLine."Account Type" = GenJournalLine."Account Type"::Employee) and
            (GenJournalLine."Account No." <> '')
        then
            EmployeeLedgerEntry.SetRange("Employee No.", GenJournalLine."Account No.");
        if SearchRuleLineCZB."Bank Account No." then begin
            if (GenJournalLine."Bank Account No. CZL" = '') and
               (GenJournalLine."IBAN CZL" = '')
            then
                exit;
            if GenJournalLine."Bank Account No. CZL" <> '' then
                Employee.SetRange("Bank Account No.", GenJournalLine."Bank Account No. CZL");
            if GenJournalLine."IBAN CZL" <> '' then
                Employee.SetRange(IBAN, GenJournalLine."IBAN CZL");
            if Employee.Count() <> 1 then
                exit;
            Employee.FindFirst();
            EmployeeLedgerEntry.SetRange("Employee No.", Employee."No.");
        end;
        EmployeeLedgerEntry.SetRange(Open, true);
        if SearchRuleLineCZB.Amount then
            if GenJournalLine.IsLocalCurrencyCZB() then
                EmployeeLedgerEntry.SetRange("Remaining Amt. (LCY)", MinAmount, MaxAmount)
            else
                EmployeeLedgerEntry.SetRange("Remaining Amount", MinAmount, MaxAmount);
        if SearchRuleLineCZB."Variable Symbol" then begin
            if GenJournalLine."Variable Symbol CZL" = '' then
                exit;
            EmployeeLedgerEntry.SetRange("Variable Symbol CZL", GenJournalLine."Variable Symbol CZL");
        end;
        if SearchRuleLineCZB."Specific Symbol" then begin
            if GenJournalLine."Specific Symbol CZL" = '' then
                exit;
            EmployeeLedgerEntry.SetRange("Specific Symbol CZL", GenJournalLine."Specific Symbol CZL");
        end;
        if SearchRuleLineCZB."Constant Symbol" then begin
            if GenJournalLine."Constant Symbol CZL" = '' then
                exit;
            EmployeeLedgerEntry.SetRange("Constant Symbol CZL", GenJournalLine."Constant Symbol CZL");
        end;
        case SearchRuleLineCZB."Banking Transaction Type" of
            SearchRuleLineCZB."Banking Transaction Type"::Debit:
                EmployeeLedgerEntry.SetRange(Positive, true);
            SearchRuleLineCZB."Banking Transaction Type"::Credit:
                EmployeeLedgerEntry.SetRange(Positive, false);
        end;
        if EmployeeLedgerEntry.FindSet() then
            repeat
                TempMatchBankPaymentBufferCZB.InsertFromEmployeeLedgerEntry(EmployeeLedgerEntry);
            until EmployeeLedgerEntry.Next() = 0;
    end;
#if not CLEAN19
#pragma warning disable AL0432
    local procedure FillMatchBankPaymentBufferSalesAdvance()
    var
        CustomerBankAccount: Record "Customer Bank Account";
        SalesAdvanceLetterHeader: Record "Sales Advance Letter Header";
        InsertToBuffer: Boolean;
        IsHandled: Boolean;
    begin
        OnBeforeFillMatchBankPaymentBufferSalesAdvance(GenJournalLine, SearchRuleLineCZB, TempMatchBankPaymentBufferCZB, IsHandled);
        if IsHandled then
            exit;

        SalesAdvanceLetterHeader.SetRange(Closed, false);
        SalesAdvanceLetterHeader.SetRange(Status, SalesAdvanceLetterHeader.Status::"Pending Payment");
        if (GenJournalLine."Account Type" = GenJournalLine."Account Type"::Customer) and
           (GenJournalLine."Account No." <> '')
        then
            SalesAdvanceLetterHeader.SetRange("Bill-to Customer No.", GenJournalLine."Account No.");
        if SearchRuleLineCZB."Bank Account No." then begin
            if (GenJournalLine."Bank Account No. CZL" = '') and
               (GenJournalLine."Bank Account Code CZL" = '') and
               (GenJournalLine."IBAN CZL" = '')
            then
                exit;
            if SalesAdvanceLetterHeader.GetFilter("Bill-to Customer No.") <> '' then
                SalesAdvanceLetterHeader.CopyFilter("Bill-to Customer No.", CustomerBankAccount."Customer No.");
            if GenJournalLine."Bank Account Code CZL" <> '' then
                CustomerBankAccount.SetRange(Code, GenJournalLine."Bank Account Code CZL");
            if GenJournalLine."Bank Account No. CZL" <> '' then
                CustomerBankAccount.SetRange("Bank Account No.", GenJournalLine."Bank Account No. CZL");
            if GenJournalLine."IBAN CZL" <> '' then
                CustomerBankAccount.SetRange(IBAN, GenJournalLine."IBAN CZL");
            if CustomerBankAccount.Count() <> 1 then
                exit;
            CustomerBankAccount.FindFirst();
            SalesAdvanceLetterHeader.SetRange("Bill-to Customer No.", CustomerBankAccount."Customer No.");
        end;
        if SearchRuleLineCZB."Variable Symbol" then begin
            if GenJournalLine."Variable Symbol CZL" = '' then
                exit;
            SalesAdvanceLetterHeader.SetRange("Variable Symbol", GenJournalLine."Variable Symbol CZL");
        end;
        if SearchRuleLineCZB."Specific Symbol" then begin
            if GenJournalLine."Specific Symbol CZL" = '' then
                exit;
            SalesAdvanceLetterHeader.SetRange("Specific Symbol", GenJournalLine."Specific Symbol CZL");
        end;
        if SearchRuleLineCZB."Constant Symbol" then begin
            if GenJournalLine."Constant Symbol CZL" = '' then
                exit;
            SalesAdvanceLetterHeader.SetRange("Constant Symbol", GenJournalLine."Constant Symbol CZL");
        end;
        if SalesAdvanceLetterHeader.FindSet() then
            repeat
                InsertToBuffer := true;
                if SearchRuleLineCZB.Amount then
                    InsertToBuffer := IsRemAmountInRange(SalesAdvanceLetterHeader, GenJournalLine.IsLocalCurrencyCZB());
                if InsertToBuffer then
                    TempMatchBankPaymentBufferCZB.InsertFromSalesAdvance(SalesAdvanceLetterHeader, GenJournalLine.IsLocalCurrencyCZB())
            until SalesAdvanceLetterHeader.Next() = 0;
    end;

    local procedure FillMatchBankPaymentBufferPurchAdvance()
    var
        VendorBankAccount: Record "Vendor Bank Account";
        PurchAdvanceLetterHeader: Record "Purch. Advance Letter Header";
        InsertToBuffer: Boolean;
        IsHandled: Boolean;
    begin
        OnBeforeFillMatchBankPaymentBufferPurchaseAdvance(GenJournalLine, SearchRuleLineCZB, TempMatchBankPaymentBufferCZB, IsHandled);
        if IsHandled then
            exit;

        PurchAdvanceLetterHeader.SetRange(Closed, false);
        PurchAdvanceLetterHeader.SetRange(Status, PurchAdvanceLetterHeader.Status::"Pending Payment");
        if (GenJournalLine."Account Type" = GenJournalLine."Account Type"::Customer) and
           (GenJournalLine."Account No." <> '')
        then
            PurchAdvanceLetterHeader.SetRange("Pay-to Vendor No.", GenJournalLine."Account No.");
        if SearchRuleLineCZB."Bank Account No." then begin
            if (GenJournalLine."Bank Account No. CZL" = '') and
               (GenJournalLine."Bank Account Code CZL" = '') and
               (GenJournalLine."IBAN CZL" = '')
            then
                exit;
            if PurchAdvanceLetterHeader.GetFilter("Pay-to Vendor No.") <> '' then
                PurchAdvanceLetterHeader.CopyFilter("Pay-to Vendor No.", VendorBankAccount."Vendor No.");
            if GenJournalLine."Bank Account Code CZL" <> '' then
                VendorBankAccount.SetRange(Code, GenJournalLine."Bank Account Code CZL");
            if GenJournalLine."Bank Account No. CZL" <> '' then
                VendorBankAccount.SetRange("Bank Account No.", GenJournalLine."Bank Account No. CZL");
            if GenJournalLine."IBAN CZL" <> '' then
                VendorBankAccount.SetRange(IBAN, GenJournalLine."IBAN CZL");
            if VendorBankAccount.Count() <> 1 then
                exit;
            VendorBankAccount.FindFirst();
            PurchAdvanceLetterHeader.SetRange("Pay-to Vendor No.", VendorBankAccount."Vendor No.");
        end;
        if SearchRuleLineCZB."Variable Symbol" then begin
            if GenJournalLine."Variable Symbol CZL" = '' then
                exit;
            PurchAdvanceLetterHeader.SetRange("Variable Symbol", GenJournalLine."Variable Symbol CZL");
        end;
        if SearchRuleLineCZB."Specific Symbol" then begin
            if GenJournalLine."Specific Symbol CZL" = '' then
                exit;
            PurchAdvanceLetterHeader.SetRange("Specific Symbol", GenJournalLine."Specific Symbol CZL");
        end;
        if SearchRuleLineCZB."Constant Symbol" then begin
            if GenJournalLine."Constant Symbol CZL" = '' then
                exit;
            PurchAdvanceLetterHeader.SetRange("Constant Symbol", GenJournalLine."Constant Symbol CZL");
        end;
        if PurchAdvanceLetterHeader.FindSet() then
            repeat
                InsertToBuffer := true;
                if SearchRuleLineCZB.Amount then
                    InsertToBuffer := IsRemAmountInRange(PurchAdvanceLetterHeader, GenJournalLine.IsLocalCurrencyCZB());
                if InsertToBuffer then
                    TempMatchBankPaymentBufferCZB.InsertFromPurchAdvance(PurchAdvanceLetterHeader, GenJournalLine.IsLocalCurrencyCZB())
            until PurchAdvanceLetterHeader.Next() = 0;
    end;

    local procedure IsRemAmountInRange(SalesAdvanceLetterHeader: Record "Sales Advance Letter Header"; UseLCYAmounts: Boolean): Boolean
    var
        RemAmount: Decimal;
    begin
        if UseLCYAmounts then
            RemAmount := SalesAdvanceLetterHeader.GetRemAmountLCY()
        else
            RemAmount := SalesAdvanceLetterHeader.GetRemAmount();
        exit((RemAmount >= MinAmount) and (RemAmount <= MaxAmount));
    end;

    local procedure IsRemAmountInRange(PurchAdvanceLetterHeader: Record "Purch. Advance Letter Header"; UseLCYAmounts: Boolean): Boolean
    var
        RemAmount: Decimal;
    begin
        if UseLCYAmounts then
            RemAmount := -PurchAdvanceLetterHeader.GetRemAmountLCY()
        else
            RemAmount := -PurchAdvanceLetterHeader.GetRemAmount();
        exit((RemAmount >= MinAmount) and (RemAmount <= MaxAmount));
    end;

    local procedure ApplyAdvanceLetter(var GenJournalLine: Record "Gen. Journal Line"; LetterNo: Code[20])
    var
        LinkCode: Code[30];
        AppliedAmount: Decimal;
        PostingGroupCode: Code[20];
    begin
        LinkCode := GenJournalLine."Document No." + ' ' + Format(GenJournalLine."Line No.");
        if GenJournalLine."Account Type" = GenJournalLine."Account Type"::Customer then
            AppliedAmount := ApplySalesAdvanceLetter(LetterNo, LinkCode, GenJournalLine.Amount, PostingGroupCode)
        else
            AppliedAmount := ApplyPurchaseAdvanceLetter(LetterNo, LinkCode, GenJournalLine.Amount, PostingGroupCode);
        if AppliedAmount <> 0 then begin
            GenJournalLine.Validate("Document Type", GenJournalLine."Document Type"::Payment);
            GenJournalLine.Validate(Prepayment, true);
            GenJournalLine.Validate("Prepayment Type", GenJournalLine."Prepayment Type"::Advance);
            GenJournalLine.Validate("Advance Letter Link Code", LinkCode);
            GenJournalLine.Validate("Posting Group", PostingGroupCode);
        end;
    end;

    local procedure ApplySalesAdvanceLetter(LetterNo: Code[20]; LinkCode: Code[30]; AmountToApply: Decimal; var PostingGroupCode: Code[20]) AppliedAmount: Decimal
    var
        SalesAdvanceLetterHeader: Record "Sales Advance Letter Header";
        SalesAdvanceLetterLine: Record "Sales Advance Letter Line";
        AmountToLink: Decimal;
    begin
        if LinkCode = '' then
            exit;
        AppliedAmount := 0;
        AmountToApply := -AmountToApply;
        SalesAdvanceLetterHeader.Get(LetterNo);
        PostingGroupCode := SalesAdvanceLetterHeader."Customer Posting Group";
        SalesAdvanceLetterLine.SetRange("Letter No.", SalesAdvanceLetterHeader."No.");
        SalesAdvanceLetterLine.SetRange("Amount To Link", AmountToApply);
        if SalesAdvanceLetterLine.IsEmpty() then
            SalesAdvanceLetterLine.SetFilter("Amount To Link", '<>%1', 0);
        if SalesAdvanceLetterLine.FindSet() then
            repeat
                SalesAdvanceLetterLine."Link Code" := LinkCode;
                AmountToLink := SalesAdvanceLetterLine."Amount To Link";
                if AmountToLink >= AmountToApply then begin
                    SalesAdvanceLetterLine."Amount Linked To Journal Line" := AmountToApply;
                    AppliedAmount += AmountToApply;
                    AmountToApply := 0;
                end else begin
                    SalesAdvanceLetterLine."Amount Linked To Journal Line" := AmountToLink;
                    AppliedAmount += AmountToLink;
                    AmountToApply -= AmountToLink;
                end;
                SalesAdvanceLetterLine.Modify();
            until (SalesAdvanceLetterLine.Next() = 0) or (AmountToApply <= 0);
    end;

    local procedure ApplyPurchaseAdvanceLetter(LetterNo: Code[20]; LinkCode: Code[30]; AmountToApply: Decimal; var PostingGroupCode: Code[20]) AppliedAmount: Decimal
    var
        PurchAdvanceLetterHeader: Record "Purch. Advance Letter Header";
        PurchAdvanceLetterLine: Record "Purch. Advance Letter Line";
        AmountToLink: Decimal;
    begin
        if LinkCode = '' then
            exit;
        AppliedAmount := 0;
        PurchAdvanceLetterHeader.Get(LetterNo);
        PostingGroupCode := PurchAdvanceLetterHeader."Vendor Posting Group";
        PurchAdvanceLetterLine.SetRange("Letter No.", PurchAdvanceLetterHeader."No.");
        PurchAdvanceLetterLine.SetRange("Amount To Link", AmountToApply);
        if PurchAdvanceLetterLine.IsEmpty() then
            PurchAdvanceLetterLine.SetFilter("Amount To Link", '<>%1', 0);
        if PurchAdvanceLetterLine.FindSet() then
            repeat
                PurchAdvanceLetterLine."Link Code" := LinkCode;
                AmountToLink := PurchAdvanceLetterLine."Amount To Link";
                if AmountToLink >= AmountToApply then begin
                    PurchAdvanceLetterLine."Amount Linked To Journal Line" := -AmountToApply;
                    AppliedAmount += AmountToApply;
                    AmountToApply := 0;
                end else begin
                    PurchAdvanceLetterLine."Amount Linked To Journal Line" := -AmountToLink;
                    AppliedAmount += AmountToLink;
                    AmountToApply -= AmountToLink;
                end;
                PurchAdvanceLetterLine.Modify();
            until (PurchAdvanceLetterLine.Next() = 0) or (AmountToApply <= 0);
    end;
#pragma warning restore AL0432
#endif

    procedure GetAmountRangeForTolerance(BankAccount: Record "Bank Account"; StatementAmount: Decimal; var MinAmount: Decimal; var MaxAmount: Decimal)
    var
        TempAmount: Decimal;
    begin
        case BankAccount."Match Tolerance Type" of
            BankAccount."Match Tolerance Type"::Amount:
                begin
                    MinAmount := StatementAmount - BankAccount."Match Tolerance Value";
                    MaxAmount := StatementAmount + BankAccount."Match Tolerance Value";
                    if (StatementAmount >= 0) and (MinAmount < 0) then
                        MinAmount := 0
                    else
                        if (StatementAmount < 0) and (MaxAmount > 0) then
                            MaxAmount := 0;
                end;
            BankAccount."Match Tolerance Type"::Percentage:
                begin
                    MinAmount := StatementAmount * (1 - BankAccount."Match Tolerance Value" / 100);
                    MaxAmount := StatementAmount * (1 + BankAccount."Match Tolerance Value" / 100);
                    if StatementAmount < 0 then begin
                        TempAmount := MinAmount;
                        MinAmount := MaxAmount;
                        MaxAmount := TempAmount;
                    end;
                end;
        end;
        MinAmount := Round(MinAmount);
        MaxAmount := Round(MaxAmount);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFillMatchBankPaymentBuffer(var TempMatchBankPaymentBufferCZB: Record "Match Bank Payment Buffer CZB"; SearchRuleLineCZB: Record "Search Rule Line CZB"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterValidateGenJournalLine(var TempMatchBankPaymentBufferCZB: Record "Match Bank Payment Buffer CZB"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFillMatchBankPaymentBufferSalesAdvance(GenJournalLine: Record "Gen. Journal Line"; SearchRuleLineCZB: Record "Search Rule Line CZB"; var TempMatchBankPaymentBufferCZB: Record "Match Bank Payment Buffer CZB"; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFillMatchBankPaymentBufferPurchaseAdvance(GenJournalLine: Record "Gen. Journal Line"; SearchRuleLineCZB: Record "Search Rule Line CZB"; var TempMatchBankPaymentBufferCZB: Record "Match Bank Payment Buffer CZB"; var IsHandled: Boolean);
    begin
    end;
}
