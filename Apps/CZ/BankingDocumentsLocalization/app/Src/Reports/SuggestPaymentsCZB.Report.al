// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using Microsoft.Bank.BankAccount;
using Microsoft.Foundation.Calendar;
using Microsoft.HumanResources.Employee;
using Microsoft.HumanResources.Payables;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Receivables;
using System.Utilities;

#pragma warning disable AL0432
report 31280 "Suggest Payments CZB"
{
    Caption = 'Suggest Payments';
    Permissions = tabledata "Bank Statement Line CZB" = im;
    ProcessingOnly = true;

    dataset
    {
        dataitem(Integer; Integer)
        {
            DataItemTableView = sorting(Number) where(Number = const(1));

            dataitem("Cust. Ledger Entry"; "Cust. Ledger Entry")
            {
                DataItemTableView = sorting(Open, "Due Date") where(Open = const(true), "On Hold" = const(''));

                trigger OnPreDataItem()
                var
                    CustEntriesTxt: Label 'Processing Customer Entries...';
                begin
                    if CustomerType = CustomerType::Nothing then
                        CurrReport.Break();
                    WindowDialog.Open(CustEntriesTxt);
                    DialogOpen := true;

                    if CustomerType <> CustomerType::All then
                        SetRange("Document Type", "Document Type"::"Credit Memo");
                    SetRange("Due Date", 0D, LastDueDateToPayReq);
                    case CurrencyType of
                        CurrencyType::"Payment Order":
                            SetRange("Currency Code", PaymentOrderHeaderCZB."Payment Order Currency Code");
                        CurrencyType::"Bank Account":
                            SetRange("Currency Code", PaymentOrderHeaderCZB."Currency Code");
                    end;
                    if CustomerNoFilter <> '' then
                        SetFilter("Customer No.", CustomerNoFilter);
                end;

                trigger OnAfterGetRecord()
                begin
                    if CustomerType = CustomerType::OnlyBalance then
                        if CustomerBalanceTest("Customer No.") then
                            CurrReport.Skip();
                    if SkipBlocked and CustomerBlockedTest("Customer No.") then begin
                        IsSkippedBlocked := true;
                        CurrReport.Skip();
                    end;
                    if (CalcSuggestedAmountToApplyCZL() <> 0) and not BankAccount."Payment Partial Suggestion CZB" then
                        CurrReport.Skip();

                    AddCustLedgEntry("Cust. Ledger Entry");
                    if StopPayments then
                        CurrReport.Break();
                end;

                trigger OnPostDataItem()
                begin
                    if DialogOpen then begin
                        WindowDialog.Close();
                        DialogOpen := false;
                    end;
                end;
            }
            dataitem("Vendor Ledger Entry"; "Vendor Ledger Entry")
            {
                DataItemTableView = sorting(Open, "Due Date") where(Open = const(true), "On Hold" = const(''));

                trigger OnPreDataItem()
                var
                    VendEntriesTxt: Label 'Processing Vendors Entries...';
                begin
                    if VendorType = VendorType::Nothing then
                        CurrReport.Break();
                    if StopPayments then
                        CurrReport.Break();
                    WindowDialog.Open(VendEntriesTxt);
                    DialogOpen := true;

                    if VendorType <> VendorType::All then
                        SetRange("Document Type", "Document Type"::Invoice);
                    SetRange("Due Date", 0D, LastDueDateToPayReq);
                    case CurrencyType of
                        CurrencyType::"Payment Order":
                            SetRange("Currency Code", PaymentOrderHeaderCZB."Payment Order Currency Code");
                        CurrencyType::"Bank Account":
                            SetRange("Currency Code", PaymentOrderHeaderCZB."Currency Code");
                    end;
                    if VendorNoFilter <> '' then
                        SetFilter("Vendor No.", VendorNoFilter);
                end;

                trigger OnAfterGetRecord()
                begin
                    if VendorType = VendorType::OnlyBalance then
                        if VendorBalanceTest("Vendor No.") then
                            CurrReport.Skip();
                    if SkipBlocked and VendorBlockedTest("Vendor No.") then begin
                        IsSkippedBlocked := true;
                        CurrReport.Skip();
                    end;
                    if (CalcSuggestedAmountToApplyCZL() <> 0) and not BankAccount."Payment Partial Suggestion CZB" then
                        CurrReport.Skip();

                    AddVendLedgEntry("Vendor Ledger Entry");
                    if StopPayments then
                        CurrReport.Break();
                end;

                trigger OnPostDataItem()
                begin
                    if DialogOpen then begin
                        WindowDialog.Close();
                        DialogOpen := false;
                    end;
                end;
            }
            dataitem("Vendor Ledger Entry Disc"; "Vendor Ledger Entry")
            {
                DataItemTableView = sorting(Open, "Due Date") where(Open = const(true), "On Hold" = const(''));

                trigger OnPreDataItem()
                var
                    VendDiscEntriesTxt: Label 'Processing Vendors for Payment Discounts...';
                begin
                    if VendorType = VendorType::Nothing then
                        CurrReport.Break();
                    if not UsePaymentDisc then
                        CurrReport.Break();
                    if StopPayments then
                        CurrReport.Break();
                    WindowDialog.Open(VendDiscEntriesTxt);
                    DialogOpen := true;

                    if VendorType <> VendorType::All then
                        SetRange("Document Type", "Document Type"::Invoice);
                    SetRange("Due Date", LastDueDateToPayReq + 1, DMY2Date(31, 12, 9999));
                    SetRange("Pmt. Discount Date", PaymentOrderHeaderCZB."Document Date", LastDueDateToPayReq);
                    SetFilter("Remaining Pmt. Disc. Possible", '<0');
                    case CurrencyType of
                        CurrencyType::"Payment Order":
                            SetRange("Currency Code", PaymentOrderHeaderCZB."Payment Order Currency Code");
                        CurrencyType::"Bank Account":
                            SetRange("Currency Code", PaymentOrderHeaderCZB."Currency Code");
                    end;
                    if VendorNoFilter <> '' then
                        SetFilter("Vendor No.", VendorNoFilter);
                end;

                trigger OnAfterGetRecord()
                begin
                    if VendorType = VendorType::OnlyBalance then
                        if VendorBalanceTest("Vendor No.") then
                            CurrReport.Skip();
                    if SkipBlocked and VendorBlockedTest("Vendor No.") then begin
                        IsSkippedBlocked := true;
                        CurrReport.Skip();
                    end;
                    if (CalcSuggestedAmountToApplyCZL() <> 0) and not BankAccount."Payment Partial Suggestion CZB" then
                        CurrReport.Skip();

                    AddVendLedgEntry("Vendor Ledger Entry Disc");
                    if StopPayments then
                        CurrReport.Break();
                end;

                trigger OnPostDataItem()
                begin
                    if DialogOpen then begin
                        WindowDialog.Close();
                        DialogOpen := false;
                    end;
                end;
            }
            dataitem("Employee Ledger Entry"; "Employee Ledger Entry")
            {
                DataItemTableView = sorting("Entry No.") where(Open = const(true));

                trigger OnPreDataItem()
                var
                    EmpEntriesTxt: Label 'Processing Employee Entries...';
                begin
                    if EmployeeType = EmployeeType::Nothing then
                        CurrReport.Break();
                    if StopPayments then
                        CurrReport.Break();
                    if PaymentOrderHeaderCZB."Currency Code" <> '' then
                        CurrReport.Break();
                    WindowDialog.Open(EmpEntriesTxt);
                    DialogOpen := true;

                    SetRange("Posting Date", 0D, LastDueDateToPayReq);
                    if EmployeeNoFilter <> '' then
                        SetFilter("Employee No.", EmployeeNoFilter);
                end;

                trigger OnAfterGetRecord()
                begin
                    if SkipBlocked and EmployeeBlockedTest("Employee No.") then begin
                        IsSkippedBlocked := true;
                        CurrReport.Skip();
                    end;
                    if (CalcSuggestedAmountToApplyCZL() <> 0) and not BankAccount."Payment Partial Suggestion CZB" then
                        CurrReport.Skip();

                    AddEmplLedgEntry("Employee Ledger Entry");
                    if StopPayments then
                        CurrReport.Break();
                end;

                trigger OnPostDataItem()
                begin
                    if DialogOpen then begin
                        WindowDialog.Close();
                        DialogOpen := false;
                    end;
                end;
            }
        }
    }

    requestpage
    {
        SaveValues = true;
        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(LastDueDateToPayReqCZB; LastDueDateToPayReq)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Last Payment Date';
                        ToolTip = 'Specifies the system goes through entries to this date.';
                    }
                    field(AmountAvailableCZB; AmountAvailable)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Available Amount (LCY)';
                        ToolTip = 'Specifies the max. amount. The amount is in the local currency.';
                    }
                    field(UsePaymentDiscCZB; UsePaymentDisc)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Find Payment Discounts';
                        ToolTip = 'Specifies placing a check mark in the check box if you want the batch job to include vendor ledger entries for which you can receive a payment discount.';
                    }
                    field(CurrencyTypeCZB; CurrencyType)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Currency Type';
                        OptionCaption = ' ,Payment Order,Bank Account';
                        ToolTip = 'Specifies used currency code.';
                    }
                    field(KeepBankCZB; KeepBank)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Only Entries with same Bank Code';
                        ToolTip = 'Specifies whether entries will be in the same bank account.';
                    }
                    field(SkipNonWorkCZB; SkipNonWork)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Modify Nonworking Days';
                        ToolTip = 'Specifies if the nonworking days will be modified.';
                    }
                }
                group(Filters)
                {
                    Caption = 'Filters';
                    field(VendorTypeCZB; VendorType)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Vendor Payables';
                        OptionCaption = 'Only Payable Balance,Only Payables,All Entries,No Suggest';
                        ToolTip = 'Specifies paymentsuggestion of vendor ledger entries.';
                    }
                    field(VendorNoFilterCZB; VendorNoFilter)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Vendor No. Filter';
                        ToolTip = 'Specifies vendor numbers.';

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            VendorList: Page "Vendor List";
                        begin
                            VendorList.LookupMode := true;
                            if VendorList.RunModal() = Action::LookupOK then
                                Text := VendorList.GetSelectionFilter()
                            else
                                exit(false);
                            exit(true);
                        end;
                    }
                    field(CustomerTypeCZB; CustomerType)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Customer Payables';
                        OptionCaption = 'Only Payable Balance,Only Payables,All Entries,No Suggest';
                        ToolTip = 'Specifies payment suggestion of customers ledger entries.';
                    }
                    field(CustomerNoFilterCZB; CustomerNoFilter)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Customer No. Filter';
                        ToolTip = 'Specifies customer numbers.';
                        trigger OnLookup(var Text: Text): Boolean
                        var
                            CustomerList: Page "Customer List";
                        begin
                            CustomerList.LookupMode := true;
                            if CustomerList.RunModal() = Action::LookupOK then
                                Text := CustomerList.GetSelectionFilter()
                            else
                                exit(false);
                            exit(true);
                        end;
                    }
                    field(EmployeeTypeCZB; EmployeeType)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Employee Payables';
                        OptionCaption = 'All Entries,No Suggest';
                        ToolTip = 'Specifies payment suggestion of employee entries.';
                    }
                    field(EmployeeNoFilterCZB; EmployeeNoFilter)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Employee No. Filter';
                        ToolTip = 'Specifies employee numbers.';
                        trigger OnLookup(var Text: Text): Boolean
                        var
                            Employee: Record Employee;
                            EmployeeList: Page "Employee List";
                        begin
                            EmployeeList.LookupMode := true;
                            if EmployeeList.RunModal() = Action::LookupOK then begin
                                EmployeeList.GetRecord(Employee);
                                Text := Employee."No.";
                            end else
                                exit(false);
                            exit(true);
                        end;
                    }
                    field(SkipBlockedCZB; SkipBlocked)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Skip Blocked Records';
                        ToolTip = 'Specifies whether the entries of blocked records will be skipped.';
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            LastDueDateToPayReq := WorkDate();
        end;
    }

    trigger OnPostReport()
    var
        PaymentsSuggestionFinishedMsg: Label 'Payments suggestion was finished.';
        SkipedBlockedVendorCustomerMsg: Label 'Some blocked vendors, customers or employees were skipped.';
        PaymentsSuggestionFinishedTxt: Text;
    begin
        PaymentsSuggestionFinishedTxt := PaymentsSuggestionFinishedMsg;
        if IsSkippedBlocked then
            PaymentsSuggestionFinishedTxt += '\' + SkipedBlockedVendorCustomerMsg;
        Message(PaymentsSuggestionFinishedTxt);
    end;

    trigger OnPreReport()
    var
        EnterLastDateErr: Label 'Please enter the last payment date.';
        EarlierDateQst: Label 'The payment date is earlier than %1.\\Do you still want to run the batch job?', Comment = '%1 = WorkDate';
        NotRecognizedBankCodeErr: Label 'Bank Code does not recognized.';
    begin
        PaymentOrderHeaderCZB.Get(PaymentOrderHeaderCZB."No.");

        if UsePaymentDisc and (LastDueDateToPayReq < WorkDate()) then
            if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(EarlierDateQst, WorkDate()), false) then
                Error('');

        if LastDueDateToPayReq = 0D then
            Error(EnterLastDateErr);

        BankAccount.Get(PaymentOrderHeaderCZB."Bank Account No.");
        if SkipNonWork then
            BankAccount.TestField("Base Calendar Code CZB");

        PaymentOrderLineCZB.SetRange("Payment Order No.", PaymentOrderHeaderCZB."No.");
        LineNo := 10000;
        if PaymentOrderLineCZB.FindLast() then
            LineNo += PaymentOrderLineCZB."Line No.";

        if KeepBank then begin
            if PaymentOrderHeaderCZB."Account No." <> '' then
                BankCode := CopyStr(BankOperationsFunctionsCZB.GetBankCode(PaymentOrderHeaderCZB."Account No."), 1, 10);
            if (PaymentOrderHeaderCZB.IBAN <> '') and (BankCode = '') then
                BankCode := BankOperationsFunctionsCZB.IBANBankCode(PaymentOrderHeaderCZB.IBAN);
            SWIFTCode := PaymentOrderHeaderCZB."SWIFT Code";
            if (BankCode = '') and (SWIFTCode = '') then
                Error(NotRecognizedBankCodeErr);
        end;

        IsSkippedBlocked := false;
    end;

    var
        BankAccount: Record "Bank Account";
        Customer: Record Customer;
        Vendor: Record Vendor;
        Employee: Record Employee;
        PaymentOrderManagementCZB: Codeunit "Payment Order Management CZB";
        BankOperationsFunctionsCZB: Codeunit "Bank Operations Functions CZB";
        ConfirmManagement: Codeunit "Confirm Management";
        BankCode: Code[10];
        SWIFTCode: Code[20];
        AmountAvailable, AppliedAmount : Decimal;

    protected var
        PaymentOrderHeaderCZB: Record "Payment Order Header CZB";
        PaymentOrderLineCZB: Record "Payment Order Line CZB";
        CustomerType, VendorType : Option OnlyBalance,OnlyPayables,All,Nothing;
        EmployeeType: Option All,Nothing;
        WindowDialog: Dialog;
        LastDueDateToPayReq: Date;
        KeepBank, SkipNonWork, UsePaymentDisc, StopPayments, SkipBlocked, IsSkippedBlocked, DialogOpen : Boolean;
        LineNo: Integer;
        CustomerNoFilter, VendorNoFilter, EmployeeNoFilter : Text;
        CurrencyType: Option " ","Payment Order","Bank Account";

    procedure SetPaymentOrder(NewPaymentOrderHeaderCZB: Record "Payment Order Header CZB")
    begin
        PaymentOrderHeaderCZB := NewPaymentOrderHeaderCZB;
    end;

    procedure AddCustLedgEntry(CustLedgerEntry: Record "Cust. Ledger Entry")
    begin
        PaymentOrderLineCZB.Init();
        PaymentOrderLineCZB.Validate(PaymentOrderLineCZB."Payment Order No.", PaymentOrderHeaderCZB."No.");
        PaymentOrderLineCZB."Line No." := LineNo;
        LineNo += 10000;
        PaymentOrderLineCZB.Type := PaymentOrderLineCZB.Type::Customer;
        case CurrencyType of
            CurrencyType::" ":
                if PaymentOrderLineCZB."Payment Order Currency Code" <> CustLedgerEntry."Currency Code" then
                    PaymentOrderLineCZB.Validate(PaymentOrderLineCZB."Payment Order Currency Code", CustLedgerEntry."Currency Code");
            CurrencyType::"Payment Order":
                if PaymentOrderLineCZB."Payment Order Currency Code" <> PaymentOrderHeaderCZB."Payment Order Currency Code" then
                    PaymentOrderLineCZB.Validate(PaymentOrderLineCZB."Payment Order Currency Code", PaymentOrderHeaderCZB."Payment Order Currency Code");
            CurrencyType::"Bank Account":
                if PaymentOrderLineCZB."Payment Order Currency Code" <> PaymentOrderHeaderCZB."Currency Code" then
                    PaymentOrderLineCZB.Validate(PaymentOrderLineCZB."Payment Order Currency Code", PaymentOrderHeaderCZB."Currency Code");
        end;
        PaymentOrderLineCZB.Validate(PaymentOrderLineCZB."Applies-to C/V/E Entry No.", CustLedgerEntry."Entry No.");
        if not UsePaymentDisc and PaymentOrderLineCZB."Pmt. Discount Possible" and
           (PaymentOrderHeaderCZB."Document Date" <= CustLedgerEntry."Pmt. Discount Date")
        then begin
            PaymentOrderLineCZB."Pmt. Discount Possible" := false;
            PaymentOrderLineCZB."Pmt. Discount Date" := 0D;
            PaymentOrderLineCZB."Amount (Paym. Order Currency)" += PaymentOrderLineCZB."Remaining Pmt. Disc. Possible";
            PaymentOrderLineCZB."Remaining Pmt. Disc. Possible" := 0;
            PaymentOrderLineCZB.Validate(PaymentOrderLineCZB."Amount (Paym. Order Currency)");
            PaymentOrderLineCZB."Original Amount" := PaymentOrderLineCZB.Amount;
            PaymentOrderLineCZB."Original Amount (LCY)" := PaymentOrderLineCZB."Amount (LCY)";
            PaymentOrderLineCZB."Orig. Amount(Pay.Order Curr.)" := PaymentOrderLineCZB."Amount (Paym. Order Currency)";
        end;
        AddPaymentLine();
    end;

    procedure AddVendLedgEntry(VendorLedgerEntry: Record "Vendor Ledger Entry")
    begin
        PaymentOrderLineCZB.Init();
        PaymentOrderLineCZB.Validate(PaymentOrderLineCZB."Payment Order No.", PaymentOrderHeaderCZB."No.");
        PaymentOrderLineCZB."Line No." := LineNo;
        LineNo += 10000;
        PaymentOrderLineCZB.Type := PaymentOrderLineCZB.Type::Vendor;
        case CurrencyType of
            CurrencyType::" ":
                if PaymentOrderLineCZB."Payment Order Currency Code" <> VendorLedgerEntry."Currency Code" then
                    PaymentOrderLineCZB.Validate(PaymentOrderLineCZB."Payment Order Currency Code", VendorLedgerEntry."Currency Code");
            CurrencyType::"Payment Order":
                if PaymentOrderLineCZB."Payment Order Currency Code" <> PaymentOrderHeaderCZB."Payment Order Currency Code" then
                    PaymentOrderLineCZB.Validate(PaymentOrderLineCZB."Payment Order Currency Code", PaymentOrderHeaderCZB."Payment Order Currency Code");
            CurrencyType::"Bank Account":
                if PaymentOrderLineCZB."Payment Order Currency Code" <> PaymentOrderHeaderCZB."Currency Code" then
                    PaymentOrderLineCZB.Validate(PaymentOrderLineCZB."Payment Order Currency Code", PaymentOrderHeaderCZB."Currency Code");
        end;
        PaymentOrderLineCZB.Validate(PaymentOrderLineCZB."Applies-to C/V/E Entry No.", VendorLedgerEntry."Entry No.");
        if not UsePaymentDisc and PaymentOrderLineCZB."Pmt. Discount Possible" and
           (PaymentOrderHeaderCZB."Document Date" <= VendorLedgerEntry."Pmt. Discount Date")
        then begin
            PaymentOrderLineCZB."Pmt. Discount Possible" := false;
            PaymentOrderLineCZB."Pmt. Discount Date" := 0D;
            PaymentOrderLineCZB."Amount (Paym. Order Currency)" -= PaymentOrderLineCZB."Remaining Pmt. Disc. Possible";
            PaymentOrderLineCZB."Remaining Pmt. Disc. Possible" := 0;
            PaymentOrderLineCZB.Validate(PaymentOrderLineCZB."Amount (Paym. Order Currency)");
            PaymentOrderLineCZB."Original Amount" := PaymentOrderLineCZB.Amount;
            PaymentOrderLineCZB."Original Amount (LCY)" := PaymentOrderLineCZB."Amount (LCY)";
            PaymentOrderLineCZB."Orig. Amount(Pay.Order Curr.)" := PaymentOrderLineCZB."Amount (Paym. Order Currency)";
            PaymentOrderLineCZB."Due Date" := VendorLedgerEntry."Due Date";
        end;
        AddPaymentLine();
    end;

    procedure AddEmplLedgEntry(EmployeeLedgerEntry: Record "Employee Ledger Entry")
    begin
        PaymentOrderLineCZB.Init();
        PaymentOrderLineCZB.Validate(PaymentOrderLineCZB."Payment Order No.", PaymentOrderHeaderCZB."No.");
        PaymentOrderLineCZB."Line No." := LineNo;
        LineNo += 10000;
        PaymentOrderLineCZB.Type := PaymentOrderLineCZB.Type::Employee;
        if PaymentOrderLineCZB."Payment Order Currency Code" <> EmployeeLedgerEntry."Currency Code" then
            PaymentOrderLineCZB.Validate(PaymentOrderLineCZB."Payment Order Currency Code", EmployeeLedgerEntry."Currency Code");
        PaymentOrderLineCZB.Validate(PaymentOrderLineCZB."Applies-to C/V/E Entry No.", EmployeeLedgerEntry."Entry No.");
        AddPaymentLine();
    end;

    procedure AddPaymentLine()
    var
        CustomizedCalendarChange: Record "Customized Calendar Change";
        CalendarManagement: Codeunit "Calendar Management";
        BankCodeLoc: Code[10];
        IsBlocked, IsApplied : Boolean;
    begin
        if KeepBank then begin
            if PaymentOrderLineCZB."Account No." <> '' then
                BankCodeLoc := CopyStr(BankOperationsFunctionsCZB.GetBankCode(PaymentOrderLineCZB."Account No."), 1, 10);
            if (BankCodeLoc = '') and (PaymentOrderLineCZB.IBAN <> '') then
                BankCodeLoc := BankOperationsFunctionsCZB.IBANBankCode(PaymentOrderLineCZB.IBAN);

            if (SWIFTCode <> '') and (PaymentOrderLineCZB."SWIFT Code" <> '') then
                if SWIFTCode <> PaymentOrderLineCZB."SWIFT Code" then
                    exit;
            if BankCodeLoc <> BankCode then
                exit;
        end;

        StopPayments := ((AppliedAmount + PaymentOrderLineCZB.Amount) > AmountAvailable) and (AmountAvailable <> 0);
        if not StopPayments then begin
            if SkipNonWork then begin
                CalendarManagement.SetSource(BankAccount, CustomizedCalendarChange);
                while CalendarManagement.IsNonworkingDay(PaymentOrderLineCZB."Due Date", CustomizedCalendarChange) do
                    PaymentOrderLineCZB."Due Date" := CalcDate('<-1D>', PaymentOrderLineCZB."Due Date");
            end;

            IsBlocked := not PaymentOrderManagementCZB.CheckPaymentOrderLineCustVendBlocked(PaymentOrderLineCZB, false);
            IsApplied := not PaymentOrderManagementCZB.CheckPaymentOrderLineApply(PaymentOrderLineCZB, false);
            PaymentOrderLineCZB."Amount Must Be Checked" := IsBlocked or IsApplied;

            if (IsApplied and BankAccount."Payment Partial Suggestion CZB") or (not IsApplied) then begin
                PaymentOrderLineCZB.Insert();
                AppliedAmount += PaymentOrderLineCZB.Amount;
            end;
        end;
    end;

    procedure CustomerBalanceTest(No: Code[20]): Boolean
    begin
        GetCustomer(No);
        Customer.CalcFields(Customer."Balance (LCY)");
        exit(Customer."Balance (LCY)" > 0);
    end;

    procedure CustomerBlockedTest(No: Code[20]): Boolean
    begin
        GetCustomer(No);
        exit(Customer.Blocked <> Customer.Blocked::" ");
    end;

    procedure VendorBalanceTest(No: Code[20]): Boolean
    begin
        GetVendor(No);
        Vendor.CalcFields(Vendor."Balance (LCY)");
        exit(Vendor."Balance (LCY)" < 0);
    end;

    procedure VendorBlockedTest(No: Code[20]): Boolean
    begin
        GetVendor(No);
        exit(Vendor.Blocked <> Vendor.Blocked::" ");
    end;

    procedure EmployeeBlockedTest(No: Code[20]): Boolean
    begin
        GetEmployee(No);
        exit(Employee."Privacy Blocked");
    end;

    local procedure GetCustomer(CustomerNo: Code[20])
    begin
        if Customer."No." <> CustomerNo then
            Customer.Get(CustomerNo);
    end;

    local procedure GetVendor(VendorNo: Code[20])
    begin
        if Vendor."No." <> VendorNo then
            Vendor.Get(VendorNo);
    end;

    local procedure GetEmployee(EmployeeNo: Code[20])
    begin
        if Employee."No." <> EmployeeNo then
            Employee.Get(EmployeeNo);
    end;
}
