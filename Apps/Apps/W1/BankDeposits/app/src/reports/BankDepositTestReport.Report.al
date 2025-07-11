namespace Microsoft.Bank.Deposit;

using Microsoft.Foundation.Company;
using Microsoft.Bank.BankAccount;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.Currency;
using Microsoft.Sales.Customer;
using Microsoft.Purchases.Vendor;
using Microsoft.Intercompany.Partner;
using Microsoft.Finance.GeneralLedger.Account;
using System.Security.User;
using Microsoft.Sales.Receivables;
using Microsoft.Purchases.Payables;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.HumanResources.Employee;
using System.Utilities;

report 1691 "Bank Deposit Test Report"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/reports/BankDepositTestReport.rdlc';
    ApplicationArea = Basic, Suite;
    Caption = 'Bank Deposit Test Report';
    UsageCategory = ReportsAndAnalysis;
    Permissions = tabledata "Bank Deposit Header" = r;

    dataset
    {
        dataitem("Bank Deposit Header"; "Bank Deposit Header")
        {
            CalcFields = "Total Deposit Lines";
            RequestFilterFields = "No.", "Bank Account No.";
            column(Bank_Deposit_Header_No_; "No.")
            {
            }
            column(Bank_Deposit_Header_Journal_Template_Name; "Journal Template Name")
            {
            }
            column(Bank_Deposit_Header_Journal_Batch_Name; "Journal Batch Name")
            {
            }
            dataitem(PageHeader; "Integer")
            {
                DataItemTableView = sorting(Number) where(Number = const(1));
                column(USERID; UserId)
                {
                }
                column(TIME; Time)
                {
                }
                column(FORMAT_TODAY_0_4_; Format(Today, 0, 4))
                {
                }
                column(STRSUBSTNO_Text000__Bank_Deposit_Header___No___; StrSubstNo(BankDepositTestReportTxt, "Bank Deposit Header"."No."))
                {
                }
                column(CompanyInformation_Name; CompanyInformation.Name)
                {
                }
                column(Bank_Deposit_Header___Bank_Account_No__; "Bank Deposit Header"."Bank Account No.")
                {
                }
                column(BankAccount_Name; BankAccount.Name)
                {
                }
                column(Bank_Deposit_Header___Document_Date_; "Bank Deposit Header"."Document Date")
                {
                }
                column(Bank_Deposit_Header___Posting_Date_; "Bank Deposit Header"."Posting Date")
                {
                }
                column(Bank_Deposit_Header___Posting_Description_; "Bank Deposit Header"."Posting Description")
                {
                }
                column(Bank_Deposit_Header___Total_Deposit_Amount_; "Bank Deposit Header"."Total Deposit Amount")
                {
                }
                column(ShowDim; ShowDim)
                {
                }
                column(PrintApplications; PrintApplications)
                {
                }
                column(ShowApplyToOutput; ShowApplyToOutput)
                {
                }
                column(Dim1Number; Dim1Number)
                {
                }
                column(Dim2Number; Dim2Number)
                {
                }
                column(PageHeader_Number; Number)
                {
                }
                column(CurrReport_PAGENOCaption; CurrReport_PAGENOCaptionLbl)
                {
                }
                column(To_Be_Deposited_InCaption; To_Be_Deposited_InCaptionLbl)
                {
                }
                column(Bank_Deposit_Header___Bank_Account_No__Caption; Bank_Deposit_Header___Bank_Account_No__CaptionLbl)
                {
                }
                column(Currency_CodeCaption; Currency_CodeCaptionLbl)
                {
                }
                column(Bank_Deposit_Header___Document_Date_Caption; Bank_Deposit_Header___Document_Date_CaptionLbl)
                {
                }
                column(Bank_Deposit_Header___Posting_Date_Caption; Bank_Deposit_Header___Posting_Date_CaptionLbl)
                {
                }
                column(Bank_Deposit_Header___Posting_Description_Caption; Bank_Deposit_Header___Posting_Description_CaptionLbl)
                {
                }
                column(Control1020023Caption; GetCurrencyCaptionCode("Bank Deposit Header"."Currency Code"))
                {
                }
                column(Control1020024Caption; GetCurrencyCaptionDesc("Bank Deposit Header"."Currency Code"))
                {
                }
                column(Bank_Deposit_Header___Total_Deposit_Amount_Caption; Bank_Deposit_Header___Total_Deposit_Amount_CaptionLbl)
                {
                }
                column(Gen__Journal_Line__Account_Type_Caption; "Gen. Journal Line".FieldCaption("Account Type"))
                {
                }
                column(Gen__Journal_Line__Document_Type_Caption; "Gen. Journal Line".FieldCaption("Document Type"))
                {
                }
                column(Gen__Journal_Line__Document_No__Caption; "Gen. Journal Line".FieldCaption("Document No."))
                {
                }
                column(AmountCaption; AmountCaptionLbl)
                {
                }
                column(Gen__Journal_Line_DescriptionCaption; "Gen. Journal Line".FieldCaption(Description))
                {
                }
                column(Account_No_____________AccountNameCaption; Account_No_____________AccountNameCaptionLbl)
                {
                }
                column(Cust__Ledger_Entry__Due_Date_Caption; "Cust. Ledger Entry".FieldCaption("Due Date"))
                {
                }
                column(Gen__Journal_Line__Document_Date_Caption; Gen__Journal_Line__Document_Date_CaptionLbl)
                {
                }
                column(Gen__Journal_Line__Applies_to_Doc__Type_Caption; Gen__Journal_Line__Applies_to_Doc__Type_CaptionLbl)
                {
                }
                column(Gen__Journal_Line__Applies_to_Doc__No__Caption; Gen__Journal_Line__Applies_to_Doc__No__CaptionLbl)
                {
                }
                column(AmountDueCaption; AmountDueCaptionLbl)
                {
                }
                column(AmountDiscountedCaption; AmountDiscountedCaptionLbl)
                {
                }
                column(AmountPaidCaption; AmountPaidCaptionLbl)
                {
                }
                column(AmountAppliedCaption; AmountAppliedCaptionLbl)
                {
                }
                column(AmountPmtDiscToleranceCaption; AmountPmtDiscToleranceCaptionLbl)
                {
                }
                column(AmountPmtToleranceCaption; AmountPmtToleranceCaptionLbl)
                {
                }
                dataitem(DimensionLoop1; "Integer")
                {
                    DataItemTableView = sorting(Number);
                    column(DimensionSetEntry__Dimension_Code_; DimensionSetEntry."Dimension Code")
                    {
                    }
                    column(DimensionSetEntry__Dimension_Value_Code_; DimensionSetEntry."Dimension Value Code")
                    {
                    }
                    column(DimensionSetEntry__Dimension_Value_Code__Control1020068; DimensionSetEntry."Dimension Value Code")
                    {
                    }
                    column(DimensionSetEntry__Dimension_Code__Control1020069; DimensionSetEntry."Dimension Code")
                    {
                    }
                    column(DimensionLoop1_Number; Number)
                    {
                    }
                    column(Header_DimensionsCaption; Header_DimensionsCaptionLbl)
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        if Number = 1 then
                            DimensionSetEntry.Find('-')
                        else
                            DimensionSetEntry.Next();

                        Dim1Number := Number;
                    end;

                    trigger OnPreDataItem()
                    begin
                        if ShowDim then
                            SetRange(Number, 1, DimensionSetEntry.Count)
                        else
                            CurrReport.Break();
                    end;
                }
                dataitem(HeaderErrorLoop; "Integer")
                {
                    DataItemTableView = sorting(Number);
                    column(ErrorText_Number_; ErrorText[Number])
                    {
                    }
                    column(HeaderErrorLoop_Number; Number)
                    {
                    }
                    column(Warning_Caption; Warning_CaptionLbl)
                    {
                    }

                    trigger OnPostDataItem()
                    begin
                        ErrorCounter := 0;
                    end;

                    trigger OnPreDataItem()
                    begin
                        SetRange(Number, 1, ErrorCounter);
                    end;
                }
                dataitem("Gen. Journal Line"; "Gen. Journal Line")
                {
                    DataItemLink = "Journal Template Name" = field("Journal Template Name"), "Journal Batch Name" = field("Journal Batch Name");
                    DataItemLinkReference = "Bank Deposit Header";
                    DataItemTableView = sorting("Journal Template Name", "Journal Batch Name", "Line No.");
                    column(Gen__Journal_Line__Account_Type_; "Account Type")
                    {
                    }
                    column(Account_No_____________AccountName; "Account No." + ' - ' + AccountName)
                    {
                    }
                    column(Gen__Journal_Line__Document_Date_; "Document Date")
                    {
                    }
                    column(Gen__Journal_Line__Document_Type_; "Document Type")
                    {
                    }
                    column(Gen__Journal_Line__Document_No__; "Document No.")
                    {
                    }
                    column(Gen__Journal_Line_Description; Description)
                    {
                    }
                    column(Amount; -Amount)
                    {
                    }
                    column(Gen__Journal_Line__Applies_to_Doc__Type_; "Applies-to Doc. Type")
                    {
                    }
                    column(Gen__Journal_Line__Applies_to_Doc__No__; "Applies-to Doc. No.")
                    {
                    }
                    column(Gen__Journal_Line__Due_Date_; "Due Date")
                    {
                    }
                    column(AmountDue; AmountDue)
                    {
                        AutoFormatExpression = "Currency Code";
                        AutoFormatType = 1;
                    }
                    column(AmountApplied; AmountApplied)
                    {
                        AutoFormatExpression = "Currency Code";
                        AutoFormatType = 1;
                    }
                    column(AmountDiscounted; AmountDiscounted)
                    {
                        AutoFormatExpression = "Currency Code";
                        AutoFormatType = 1;
                    }
                    column(AmountPaid; AmountPaid)
                    {
                        AutoFormatExpression = "Currency Code";
                        AutoFormatType = 1;
                    }
                    column(AmountPmtDiscTolerance; AmountPmtDiscTolerance)
                    {
                        AutoFormatExpression = "Currency Code";
                        AutoFormatType = 1;
                    }
                    column(AmountPmtTolerance; AmountPmtTolerance)
                    {
                        AutoFormatExpression = "Currency Code";
                        AutoFormatType = 1;
                    }
                    column(ApplicationText; ApplicationText)
                    {
                    }
                    column(Gen__Journal_Line_Amount; Amount)
                    {
                    }
                    column(Bank_Deposit_Header___Total_Deposit_Amount__Control1000000000; "Bank Deposit Header"."Total Deposit Amount")
                    {
                    }
                    column(Bank_Deposit_Header___Total_Deposit_Amount____Amount; "Bank Deposit Header"."Total Deposit Amount" + Amount)
                    {
                    }
                    column(Gen__Journal_Line_Journal_Template_Name; "Journal Template Name")
                    {
                    }
                    column(Gen__Journal_Line_Journal_Batch_Name; "Journal Batch Name")
                    {
                    }
                    column(Gen__Journal_Line_Line_No_; "Line No.")
                    {
                    }
                    column(Gen__Journal_Line_Account_No_; "Account No.")
                    {
                    }
                    column(Gen__Journal_Line_Applies_to_ID; "Applies-to ID")
                    {
                    }
                    column(Gen__Journal_Line__Applies_to_Doc__No__Caption_Control2; Gen__Journal_Line__Applies_to_Doc__No__Caption_Control2Lbl)
                    {
                    }
                    column(AmountDueCaption_Control7; AmountDueCaption_Control7Lbl)
                    {
                    }
                    column(AmountDiscountedCaption_Control10; AmountDiscountedCaption_Control10Lbl)
                    {
                    }
                    column(AmountAppliedCaption_Control12; AmountAppliedCaption_Control12Lbl)
                    {
                    }
                    column(Gen__Journal_Line__Applies_to_Doc__Type_Caption_Control13; Gen__Journal_Line__Applies_to_Doc__Type_Caption_Control13Lbl)
                    {
                    }
                    column(Cust__Ledger_Entry__Due_Date_Caption_Control14; "Cust. Ledger Entry".FieldCaption("Due Date"))
                    {
                    }
                    column(Gen__Journal_Line_DescriptionCaption_Control15; FieldCaption(Description))
                    {
                    }
                    column(Account_TypeCaption; Account_TypeCaptionLbl)
                    {
                    }
                    column(Gen__Journal_Line__Document_Type_Caption_Control17; FieldCaption("Document Type"))
                    {
                    }
                    column(Gen__Journal_Line__Document_No__Caption_Control18; FieldCaption("Document No."))
                    {
                    }
                    column(Account_No_____________AccountNameCaption_Control20; Account_No_____________AccountNameCaption_Control20Lbl)
                    {
                    }
                    column(Gen__Journal_Line__Document_Date_Caption_Control21; Gen__Journal_Line__Document_Date_Caption_Control21Lbl)
                    {
                    }
                    column(AmountPaidCaption_Control11; AmountPaidCaption_Control11Lbl)
                    {
                    }
                    column(AmountCaption_Control19; AmountCaption_Control19Lbl)
                    {
                    }
                    column(AmountPmtDiscToleranceCaption_Control1020031; AmountPmtDiscToleranceCaption_Control1020031Lbl)
                    {
                    }
                    column(AmountPmtToleranceCaption_Control1020033; AmountPmtToleranceCaption_Control1020033Lbl)
                    {
                    }
                    column(Total_Deposit_AmountCaption; Total_Deposit_AmountCaptionLbl)
                    {
                    }
                    column(Total_Deposit_LinesCaption; Total_Deposit_LinesCaptionLbl)
                    {
                    }
                    column(DifferenceCaption; DifferenceCaptionLbl)
                    {
                    }
                    dataitem("Cust. Ledger Entry"; "Cust. Ledger Entry")
                    {
                        DataItemLink = "Customer No." = field("Account No."), "Applies-to ID" = field("Applies-to ID");
                        DataItemTableView = sorting("Customer No.", "Applies-to ID", Open, Positive, "Due Date");
                        column(Cust__Ledger_Entry__Document_Type_; "Document Type")
                        {
                        }
                        column(Cust__Ledger_Entry__Document_No__; "Document No.")
                        {
                        }
                        column(Cust__Ledger_Entry__Due_Date_; "Due Date")
                        {
                        }
                        column(Cust__Ledger_Entry_Description; Description)
                        {
                        }
                        column(AmountDue_Control1480024; AmountDue)
                        {
                            AutoFormatExpression = "Currency Code";
                            AutoFormatType = 1;
                        }
                        column(AmountPaid_Control1480025; AmountPaid)
                        {
                            AutoFormatExpression = "Currency Code";
                            AutoFormatType = 1;
                        }
                        column(AmountDiscounted_Control1480026; AmountDiscounted)
                        {
                            AutoFormatExpression = "Currency Code";
                            AutoFormatType = 1;
                        }
                        column(AmountApplied_Control1480027; AmountApplied)
                        {
                            AutoFormatExpression = "Currency Code";
                            AutoFormatType = 1;
                        }
                        column(ApplicationText_Control24; ApplicationText)
                        {
                        }
                        column(AmountPmtDiscTolerance_Control1020035; AmountPmtDiscTolerance)
                        {
                            AutoFormatExpression = "Currency Code";
                            AutoFormatType = 1;
                        }
                        column(AmountPmtTolerance_Control1020036; AmountPmtTolerance)
                        {
                            AutoFormatExpression = "Currency Code";
                            AutoFormatType = 1;
                        }
                        column(Cust__Ledger_Entry_Entry_No_; "Entry No.")
                        {
                        }
                        column(Cust__Ledger_Entry_Customer_No_; "Customer No.")
                        {
                        }
                        column(Cust__Ledger_Entry_Applies_to_ID; "Applies-to ID")
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            if isShow then
                                isShow := false
                            else
                                ApplicationText := '';

                            if RemainingAmountToApply <= 0 then
                                CurrReport.Skip();
                            if CustomerLedgerEntryBalances.ContainsKey("Cust. Ledger Entry"."Entry No.") then begin
                                if CustomerLedgerEntryBalances.Get("Cust. Ledger Entry"."Entry No.") <= 0 then
                                    CurrReport.Skip();
                            end
                            else
                                CustomerLedgerEntryBalances.Add("Cust. Ledger Entry"."Entry No.", 0);

                            CalcFields("Remaining Amount");
                            if "Currency Code" <> Currency.Code then begin
                                "Remaining Amount" :=
                                  Round(
                                    CurrencyExchangeRate.ExchangeAmtFCYToFCY(
                                      "Gen. Journal Line"."Posting Date",
                                      "Currency Code",
                                      Currency.Code,
                                      "Remaining Amount"),
                                    Currency."Amount Rounding Precision");
                                "Amount to Apply" :=
                                  Round(
                                    CurrencyExchangeRate.ExchangeAmtFCYToFCY(
                                      "Gen. Journal Line"."Posting Date",
                                      "Currency Code",
                                      Currency.Code,
                                      "Amount to Apply"),
                                    Currency."Amount Rounding Precision");
                                "Accepted Payment Tolerance" :=
                                  Round(
                                    CurrencyExchangeRate.ExchangeAmtFCYToFCY(
                                      "Gen. Journal Line"."Posting Date",
                                      "Currency Code",
                                      Currency.Code,
                                      "Accepted Payment Tolerance"),
                                    Currency."Amount Rounding Precision");
                                "Remaining Pmt. Disc. Possible" :=
                                  Round(
                                    CurrencyExchangeRate.ExchangeAmtFCYToFCY(
                                      "Gen. Journal Line"."Posting Date",
                                      "Currency Code",
                                      Currency.Code,
                                      "Remaining Pmt. Disc. Possible"),
                                    Currency."Amount Rounding Precision");
                            end;
                            AmountDue := "Remaining Amount";
                            AmountPmtTolerance := "Accepted Payment Tolerance";
                            AmountDiscounted := 0;
                            AmountPmtDiscTolerance := 0;
                            if ("Remaining Pmt. Disc. Possible" <> 0) and
                               (("Pmt. Discount Date" >= "Gen. Journal Line"."Posting Date") or "Accepted Pmt. Disc. Tolerance") and
                               (RemainingAmountToApply + AmountPmtTolerance + "Remaining Pmt. Disc. Possible" >= AmountDue)
                            then
                                if "Pmt. Discount Date" >= "Gen. Journal Line"."Posting Date" then
                                    AmountDiscounted := "Remaining Pmt. Disc. Possible"
                                else
                                    AmountPmtDiscTolerance := "Remaining Pmt. Disc. Possible";
                            AmountApplied := RemainingAmountToApply + AmountPmtTolerance + AmountDiscounted + AmountPmtDiscTolerance;
                            if AmountApplied > "Amount to Apply" then
                                AmountApplied := "Amount to Apply";
                            AmountPaid := AmountApplied - AmountPmtTolerance - AmountDiscounted - AmountPmtDiscTolerance;
                            if AmountApplied > AmountDue then
                                AmountApplied := AmountDue;
                            RemainingAmountToApply := RemainingAmountToApply - AmountPaid;
                            TotalAmountApplied := TotalAmountApplied + AmountApplied;
                            CustomerLedgerEntryBalances.Set("Cust. Ledger Entry"."Entry No.", "Cust. Ledger Entry"."Remaining Amount" - AmountApplied);
                        end;

                        trigger OnPreDataItem()
                        begin
                            if not PrintApplications or
                               ("Gen. Journal Line"."Account Type" <> "Gen. Journal Line"."Account Type"::Customer) or
                               ("Gen. Journal Line"."Applies-to ID" = '')
                            then
                                CurrReport.Break();
                            GetCurrencyRecord(Currency, "Bank Deposit Header"."Currency Code");
                        end;
                    }
                    dataitem("Vendor Ledger Entry"; "Vendor Ledger Entry")
                    {
                        DataItemLink = "Vendor No." = field("Account No."), "Applies-to ID" = field("Applies-to ID");
                        DataItemTableView = sorting("Vendor No.", "Applies-to ID", Open, Positive, "Due Date");
                        column(AmountDue_Control1480028; AmountDue)
                        {
                            AutoFormatExpression = "Currency Code";
                            AutoFormatType = 1;
                        }
                        column(Vendor_Ledger_Entry__Document_Type_; "Document Type")
                        {
                        }
                        column(Vendor_Ledger_Entry__Document_No__; "Document No.")
                        {
                        }
                        column(Vendor_Ledger_Entry__Due_Date_; "Due Date")
                        {
                        }
                        column(Vendor_Ledger_Entry_Description; Description)
                        {
                        }
                        column(AmountPaid_Control1480033; AmountPaid)
                        {
                            AutoFormatExpression = "Currency Code";
                            AutoFormatType = 1;
                        }
                        column(AmountDiscounted_Control1480034; AmountDiscounted)
                        {
                            AutoFormatExpression = "Currency Code";
                            AutoFormatType = 1;
                        }
                        column(AmountApplied_Control1480035; AmountApplied)
                        {
                            AutoFormatExpression = "Currency Code";
                            AutoFormatType = 1;
                        }
                        column(ApplicationText_Control1020040; ApplicationText)
                        {
                        }
                        column(AmountPmtTolerance_Control1020041; AmountPmtTolerance)
                        {
                            AutoFormatExpression = "Currency Code";
                            AutoFormatType = 1;
                        }
                        column(AmountPmtDiscTolerance_Control1020042; AmountPmtDiscTolerance)
                        {
                            AutoFormatExpression = "Currency Code";
                            AutoFormatType = 1;
                        }
                        column(Vendor_Ledger_Entry_Entry_No_; "Entry No.")
                        {
                        }
                        column(Vendor_Ledger_Entry_Vendor_No_; "Vendor No.")
                        {
                        }
                        column(Vendor_Ledger_Entry_Applies_to_ID; "Applies-to ID")
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            if RemainingAmountToApply <= 0 then
                                CurrReport.Skip();
                            if VendorLedgerEntryBalances.ContainsKey("Vendor Ledger Entry"."Entry No.") then begin
                                if VendorLedgerEntryBalances.Get("Vendor Ledger Entry"."Entry No.") <= 0 then
                                    CurrReport.Skip();
                            end
                            else
                                VendorLedgerEntryBalances.Add("Vendor Ledger Entry"."Entry No.", 0);

                            CalcFields("Remaining Amount");
                            if "Currency Code" <> Currency.Code then begin
                                "Remaining Amount" :=
                                  Round(
                                    CurrencyExchangeRate.ExchangeAmtFCYToFCY(
                                      "Gen. Journal Line"."Posting Date",
                                      "Currency Code",
                                      Currency.Code,
                                      "Remaining Amount"),
                                    Currency."Amount Rounding Precision");
                                "Amount to Apply" :=
                                  Round(
                                    CurrencyExchangeRate.ExchangeAmtFCYToFCY(
                                      "Gen. Journal Line"."Posting Date",
                                      "Currency Code",
                                      Currency.Code,
                                      "Amount to Apply"),
                                    Currency."Amount Rounding Precision");
                                "Accepted Payment Tolerance" :=
                                  Round(
                                    CurrencyExchangeRate.ExchangeAmtFCYToFCY(
                                      "Gen. Journal Line"."Posting Date",
                                      "Currency Code",
                                      Currency.Code,
                                      "Accepted Payment Tolerance"),
                                    Currency."Amount Rounding Precision");
                                "Remaining Pmt. Disc. Possible" :=
                                  Round(
                                    CurrencyExchangeRate.ExchangeAmtFCYToFCY(
                                      "Gen. Journal Line"."Posting Date",
                                      "Currency Code",
                                      Currency.Code,
                                      "Remaining Pmt. Disc. Possible"),
                                    Currency."Amount Rounding Precision");
                            end;
                            AmountDue := "Remaining Amount";
                            AmountPmtTolerance := "Accepted Payment Tolerance";
                            AmountDiscounted := 0;
                            AmountPmtDiscTolerance := 0;
                            if ("Remaining Pmt. Disc. Possible" <> 0) and
                               (("Pmt. Discount Date" >= "Gen. Journal Line"."Posting Date") or "Accepted Pmt. Disc. Tolerance") and
                               (RemainingAmountToApply + AmountPmtTolerance + "Remaining Pmt. Disc. Possible" >= AmountDue)
                            then
                                if "Pmt. Discount Date" >= "Gen. Journal Line"."Posting Date" then
                                    AmountDiscounted := "Remaining Pmt. Disc. Possible"
                                else
                                    AmountPmtDiscTolerance := "Remaining Pmt. Disc. Possible";
                            AmountApplied := RemainingAmountToApply + AmountPmtTolerance + AmountDiscounted + AmountPmtDiscTolerance;
                            if AmountApplied > "Amount to Apply" then
                                AmountApplied := "Amount to Apply";
                            AmountPaid := AmountApplied - AmountPmtTolerance - AmountDiscounted - AmountPmtDiscTolerance;
                            if AmountApplied > AmountDue then
                                AmountApplied := AmountDue;
                            RemainingAmountToApply := RemainingAmountToApply - AmountPaid;
                            TotalAmountApplied := TotalAmountApplied + AmountApplied;
                            VendorLedgerEntryBalances.Set("Vendor Ledger Entry"."Entry No.", "Vendor Ledger Entry"."Remaining Amount" - AmountApplied);
                        end;

                        trigger OnPreDataItem()
                        begin
                            if not PrintApplications or
                               ("Gen. Journal Line"."Account Type" <> "Gen. Journal Line"."Account Type"::Vendor) or
                               ("Gen. Journal Line"."Applies-to ID" = '')
                            then
                                CurrReport.Break();
                            RemainingAmountToApply := -"Gen. Journal Line".Amount;
                            GetCurrencyRecord(Currency, "Bank Deposit Header"."Currency Code");
                        end;
                    }
                    dataitem(TotalApplicationLoop; "Integer")
                    {
                        DataItemTableView = sorting(Number) where(Number = const(1));
                        column(TotalAmountApplied; TotalAmountApplied)
                        {
                            AutoFormatExpression = "Gen. Journal Line"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(RemainingAmountToApply; RemainingAmountToApply)
                        {
                            AutoFormatExpression = "Gen. Journal Line"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(TotalApplicationLoop_Number; Number)
                        {
                        }
                        column(Total_AppliedCaption; Total_AppliedCaptionLbl)
                        {
                        }
                        column(Remaining_UnappliedCaption; Remaining_UnappliedCaptionLbl)
                        {
                        }

                        trigger OnPreDataItem()
                        begin
                            if isShow then
                                CurrReport.Break();
                        end;
                    }
                    dataitem(DimensionLoop2; "Integer")
                    {
                        DataItemTableView = sorting(Number);
                        column(DimensionSetEntry2__Dimension_Value_Code_; DimensionSetEntry2."Dimension Value Code")
                        {
                        }
                        column(DimensionSetEntry2__Dimension_Code_; DimensionSetEntry2."Dimension Code")
                        {
                        }
                        column(DimensionSetEntry2__Dimension_Value_Code__Control1020075; DimensionSetEntry2."Dimension Value Code")
                        {
                        }
                        column(DimensionSetEntry2__Dimension_Code__Control1020076; DimensionSetEntry2."Dimension Code")
                        {
                        }
                        column(DimensionLoop2_Number; Number)
                        {
                        }
                        column(Line_DimensionsCaption; Line_DimensionsCaptionLbl)
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            if Number = 1 then
                                DimensionSetEntry2.Find('-')
                            else
                                DimensionSetEntry2.Next();

                            Dim2Number := Number;
                        end;

                        trigger OnPreDataItem()
                        begin
                            if ShowDim then
                                SetRange(Number, 1, DimensionSetEntry2.Count)
                            else
                                CurrReport.Break();
                        end;
                    }
                    dataitem(LineErrorCounter; "Integer")
                    {
                        DataItemTableView = sorting(Number);
                        column(ErrorText_Number__Control1020070; ErrorText[Number])
                        {
                        }
                        column(LineErrorCounter_Number; Number)
                        {
                        }
                        column(Warning_Caption_Control1020071; Warning_Caption_Control1020071Lbl)
                        {
                        }

                        trigger OnPreDataItem()
                        begin
                            SetRange(Number, 1, ErrorCounter);
                        end;
                    }

                    trigger OnAfterGetRecord()
                    begin
                        DimensionSetEntry2.SetRange("Dimension Set ID", "Dimension Set ID");
                        ErrorCounter := 0;

                        if "Account No." = '' then
                            AddError(
                              StrSubstNo(MustEnterAccontErr, FieldCaption("Account No.")));

                        isShow := true;
                        ApplicationText := ApplicationTxt;
                        RemainingAmountToApply := -Amount;
                        TotalAmountApplied := 0;

                        ApplyAccountTypeLogic("Gen. Journal Line");

                        if "Document Date" = 0D then
                            AddError(
                              StrSubstNo(MustEnterAccontErr, FieldCaption("Document Date")))
                        else
                            if "Document Date" <> NormalDate("Document Date") then
                                AddError(
                                  StrSubstNo(MustBeClosingDateErr, FieldCaption("Document Date")));

                        if "Document No." = '' then
                            AddError(
                              StrSubstNo(MustEnterAccontErr, FieldCaption("Document No.")));

                        if Amount = 0 then
                            AddError(
                              StrSubstNo(MustEnterAccontErr, FieldCaption(Amount)))
                        else
                            if Amount > 0 then
                                AddError(
                                  StrSubstNo(CreditAmountNegativeErr, FieldCaption("Credit Amount")));

                        if not DimensionManagement.CheckDimIDComb("Dimension Set ID") then
                            AddError(DimensionManagement.GetDimCombErr());

                        TableID[1] := DimensionManagement.TypeToTableID1("Account Type".AsInteger());
                        No[1] := "Account No.";
                        if not DimensionManagement.CheckDimValuePosting(TableID, No, "Dimension Set ID") then
                            AddError(DimensionManagement.GetDimValuePostingErr());

                        ShowApplyToOutput := false;
                        if PrintApplications and ("Applies-to Doc. No." <> '') then begin
                            ShowApplyToOutput := true;
                            case "Account Type" of
                                "Account Type"::Customer:
                                    begin
                                        CustLedgerEntry.Reset();
                                        CustLedgerEntry.SetCurrentKey(CustLedgerEntry."Document No.", CustLedgerEntry."Document Type");
                                        CustLedgerEntry.SetRange(CustLedgerEntry."Document Type", "Gen. Journal Line"."Applies-to Doc. Type");
                                        CustLedgerEntry.SetRange(CustLedgerEntry."Document No.", "Gen. Journal Line"."Applies-to Doc. No.");
                                        CustLedgerEntry.SetRange(CustLedgerEntry."Customer No.", "Gen. Journal Line"."Account No.");
                                        if CustLedgerEntry.FindFirst() then begin
                                            CustLedgerEntry.CalcFields(CustLedgerEntry."Remaining Amount");
                                            "Gen. Journal Line"."Due Date" := CustLedgerEntry."Due Date";
                                            "Gen. Journal Line".Description := CustLedgerEntry.Description;
                                            AmountDue := CustLedgerEntry."Remaining Amount";
                                            AmountPaid := -"Gen. Journal Line".Amount;
                                            AmountPmtTolerance := CustLedgerEntry."Accepted Payment Tolerance";
                                            AmountDiscounted := 0;
                                            AmountPmtDiscTolerance := 0;
                                            if (CustLedgerEntry."Remaining Pmt. Disc. Possible" <> 0) and
                                               ((CustLedgerEntry."Pmt. Discount Date" >= "Gen. Journal Line"."Posting Date") or CustLedgerEntry."Accepted Pmt. Disc. Tolerance") and
                                               (AmountPaid + AmountPmtTolerance + CustLedgerEntry."Remaining Pmt. Disc. Possible" >= AmountDue)
                                            then
                                                if CustLedgerEntry."Pmt. Discount Date" >= "Gen. Journal Line"."Posting Date" then
                                                    AmountDiscounted := CustLedgerEntry."Remaining Pmt. Disc. Possible"
                                                else
                                                    AmountPmtDiscTolerance := CustLedgerEntry."Remaining Pmt. Disc. Possible";
                                            AmountApplied := AmountPaid + AmountPmtTolerance + AmountDiscounted + AmountPmtDiscTolerance;
                                            if AmountApplied > AmountDue then
                                                AmountApplied := AmountDue;
                                            RemainingAmountToApply := RemainingAmountToApply - AmountPaid;
                                            TotalAmountApplied := TotalAmountApplied + AmountApplied;
                                            if isShow then
                                                isShow := false
                                            else
                                                ApplicationText := '';
                                        end else
                                            ShowApplyToOutput := false;
                                    end;
                                "Account Type"::Vendor:
                                    begin
                                        VendorLedgerEntry.Reset();
                                        VendorLedgerEntry.SetCurrentKey(VendorLedgerEntry."Document No.", VendorLedgerEntry."Document Type");
                                        VendorLedgerEntry.SetRange(VendorLedgerEntry."Document Type", "Gen. Journal Line"."Applies-to Doc. Type");
                                        VendorLedgerEntry.SetRange(VendorLedgerEntry."Document No.", "Gen. Journal Line"."Applies-to Doc. No.");
                                        VendorLedgerEntry.SetRange(VendorLedgerEntry."Vendor No.", "Gen. Journal Line"."Account No.");
                                        if VendorLedgerEntry.FindFirst() then begin
                                            VendorLedgerEntry.CalcFields(VendorLedgerEntry."Remaining Amount");
                                            "Gen. Journal Line"."Due Date" := VendorLedgerEntry."Due Date";
                                            "Gen. Journal Line".Description := VendorLedgerEntry.Description;
                                            AmountDue := VendorLedgerEntry."Remaining Amount";
                                            AmountPaid := -"Gen. Journal Line".Amount;
                                            AmountPmtTolerance := VendorLedgerEntry."Accepted Payment Tolerance";
                                            AmountDiscounted := 0;
                                            AmountPmtDiscTolerance := 0;
                                            if (VendorLedgerEntry."Remaining Pmt. Disc. Possible" <> 0) and
                                               ((VendorLedgerEntry."Pmt. Discount Date" >= "Gen. Journal Line"."Posting Date") or VendorLedgerEntry."Accepted Pmt. Disc. Tolerance") and
                                               (AmountPaid + AmountPmtTolerance + VendorLedgerEntry."Remaining Pmt. Disc. Possible" >= AmountDue)
                                            then
                                                if VendorLedgerEntry."Pmt. Discount Date" >= "Gen. Journal Line"."Posting Date" then
                                                    AmountDiscounted := VendorLedgerEntry."Remaining Pmt. Disc. Possible"
                                                else
                                                    AmountPmtDiscTolerance := VendorLedgerEntry."Remaining Pmt. Disc. Possible";
                                            AmountApplied := AmountPaid + AmountPmtTolerance + AmountDiscounted + AmountPmtDiscTolerance;
                                            if AmountApplied > AmountDue then
                                                AmountApplied := AmountDue;
                                            RemainingAmountToApply := RemainingAmountToApply - AmountPaid;
                                            TotalAmountApplied := TotalAmountApplied + AmountApplied;
                                            if isShow then
                                                isShow := false
                                            else
                                                ApplicationText := '';
                                        end else
                                            ShowApplyToOutput := false;
                                    end;
                                else
                                    ShowApplyToOutput := false;
                            end;
                        end;
                    end;

                    trigger OnPreDataItem()
                    begin
                        Clear(TableID);
                        Clear(No);
                    end;
                }
            }

            trigger OnAfterGetRecord()
            begin
                ErrorCounter := 0;

                if "Bank Account No." = '' then
                    AddError(
                      StrSubstNo(MustEnterAccontErr, FieldCaption("Bank Account No.")))
                else
                    if not BankAccount.Get("Bank Account No.") then begin
                        AddError(
                          StrSubstNo(AccountNotValidErr, "Bank Account No.", FieldCaption("Bank Account No.")));
                        BankAccount.Name := StrSubstNo(InvalidAccountTxt, BankAccount.TableCaption);
                    end else
                        if BankAccount.Blocked then
                            AddError(
                              StrSubstNo(BankAccountBlockedErr, "Bank Account No."));

                if "Posting Date" = 0D then
                    AddError(
                      StrSubstNo(MustEnterAccontErr, FieldCaption("Posting Date")))
                else
                    if "Posting Date" <> NormalDate("Posting Date") then
                        AddError(
                          StrSubstNo(MustBeClosingDateErr, FieldCaption("Posting Date")))
                    else begin
                        if (AllowPostingFrom = 0D) and (AllowPostingTo = 0D) then begin
                            if UserId <> '' then
                                if UserSetup.Get(UserId) then begin
                                    AllowPostingFrom := UserSetup."Allow Posting From";
                                    AllowPostingTo := UserSetup."Allow Posting To";
                                end;
                            if (AllowPostingFrom = 0D) and (AllowPostingTo = 0D) then begin
                                AllowPostingFrom := GeneralLedgerSetup."Allow Posting From";
                                AllowPostingTo := GeneralLedgerSetup."Allow Posting To";
                            end;
                            if AllowPostingTo = 0D then
                                AllowPostingTo := 99991231D;
                        end;
                        if ("Posting Date" < AllowPostingFrom) or ("Posting Date" > AllowPostingTo) then
                            AddError(
                              StrSubstNo(DateNotWithinRangeErr, FieldCaption("Posting Date")));
                    end;

                if "Document Date" = 0D then
                    AddError(
                      StrSubstNo(MustEnterAccontErr, FieldCaption("Document Date")))
                else
                    if "Document Date" <> NormalDate("Document Date") then
                        AddError(
                          StrSubstNo(MustBeClosingDateErr, FieldCaption("Document Date")));

                if "Total Deposit Amount" = 0 then
                    AddError(
                      StrSubstNo(MustEnterAccontErr, FieldCaption("Total Deposit Amount")));

                if "Total Deposit Amount" <> "Total Deposit Lines" then
                    AddError(
                      StrSubstNo(TotalMismatchErr, FieldCaption("Total Deposit Amount"), FieldCaption("Total Deposit Lines")));

                DimensionSetEntry.SetRange("Dimension Set ID", "Dimension Set ID");
                if not DimensionManagement.CheckDimIDComb("Dimension Set ID") then
                    AddError(DimensionManagement.GetDimCombErr());

                TableID[1] := DATABASE::"Bank Account";
                No[1] := "Bank Account No.";
                if not DimensionManagement.CheckDimValuePosting(TableID, No, "Dimension Set ID") then
                    AddError(DimensionManagement.GetDimValuePostingErr());
            end;
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
                    field(ShowApplications; PrintApplications)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Show Applications';
                        ToolTip = 'Specifies if application information is included in the report.';
                    }
                    field(ShowDimensions; ShowDim)
                    {
                        ApplicationArea = Suite;
                        Caption = 'Show Dimensions';
                        ToolTip = 'Specifies if you want if you want the report to show dimensions.';
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPreReport()
    begin
        CompanyInformation.Get();
        GeneralLedgerSetup.Get();
    end;

    var
        CompanyInformation: Record "Company Information";
        GeneralLedgerSetup: Record "General Ledger Setup";
        BankAccount: Record "Bank Account";
        Currency: Record Currency;
        Customer: Record Customer;
        Vendor: Record Vendor;
        ICPartner: Record "IC Partner";
        GLAccount: Record "G/L Account";
        DimensionSetEntry: Record "Dimension Set Entry";
        DimensionSetEntry2: Record "Dimension Set Entry";
        BankAccount2: Record "Bank Account";
        UserSetup: Record "User Setup";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        DimensionManagement: Codeunit DimensionManagement;
        AccountName: Text;
        ErrorText: array[100] of Text[250];
        ErrorCounter: Integer;
        PrintApplications: Boolean;
        BankDepositTestReportTxt: Label 'Bank Deposit %1 - Test Report', Comment = '%1 - bank deposit number';
        InvalidAccountTxt: Label '<Invalid %1>', Comment = '%1 - GL Account number';
        MustEnterAccontErr: Label 'You must enter the %1.', Comment = '%1 - GL Account';
        AccountNotValidErr: Label '%1 is not a valid %2.', Comment = '%1 - Account code, %2 - Account field caption, can be Bank Account, GL Account etc.';
        TotalMismatchErr: Label 'The %1 must be equal to the %2.', Comment = '%1 - Total Deposit amount, %2 - Total Deposit Lines';
        ShowDim: Boolean;
        AllowPostingFrom: Date;
        AllowPostingTo: Date;
        MustBeClosingDateErr: Label '%1 must not be a closing date.', Comment = '%1 - field caption, either Posting Date or Document Date';
        DateNotWithinRangeErr: Label '%1 is not within your allowed range of posting dates.', Comment = '%1 - field caption, either Posting Date or Document Date';
        TableID: array[10] of Integer;
        No: array[10] of Code[20];
        DirectPostingAccountErr: Label '%1 %2 is not a direct posting account.', Comment = '%1 - account field caption, %2 - account code';
        PostingAccountErr: Label '%1 %2 is not a posting account.', Comment = '%1 - account field caption, %2 - account code';
        CreditAmountNegativeErr: Label '%1 must be a positive number.', Comment = '%1 - Credit Amount field caption';
        AmountPaid: Decimal;
        AmountDue: Decimal;
        AmountDiscounted: Decimal;
        AmountPmtTolerance: Decimal;
        AmountPmtDiscTolerance: Decimal;
        AmountApplied: Decimal;
        RemainingAmountToApply: Decimal;
        TotalAmountApplied: Decimal;
        ShowApplyToOutput: Boolean;
        ApplicationText: Text[30];
        isShow: Boolean;
        ApplicationTxt: Label 'Application';
        Dim1Number: Integer;
        Dim2Number: Integer;
        CustomerLedgerEntryBalances: Dictionary of [Integer, Decimal];
        VendorLedgerEntryBalances: Dictionary of [Integer, Decimal];
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        To_Be_Deposited_InCaptionLbl: Label 'To Be Deposited In';
        Bank_Deposit_Header___Bank_Account_No__CaptionLbl: Label 'Bank Account No.';
        Currency_CodeCaptionLbl: Label 'Currency Code';
        Bank_Deposit_Header___Document_Date_CaptionLbl: Label 'Document Date';
        Bank_Deposit_Header___Posting_Date_CaptionLbl: Label 'Posting Date';
        Bank_Deposit_Header___Posting_Description_CaptionLbl: Label 'Posting Description';
        Bank_Deposit_Header___Total_Deposit_Amount_CaptionLbl: Label 'Total Deposit Amount';
        AmountCaptionLbl: Label 'Credit Amount';
        Account_No_____________AccountNameCaptionLbl: Label 'Account No. / Name';
        Gen__Journal_Line__Document_Date_CaptionLbl: Label 'Doc. Date';
        Gen__Journal_Line__Applies_to_Doc__Type_CaptionLbl: Label 'Applies-to';
        Gen__Journal_Line__Applies_to_Doc__No__CaptionLbl: Label 'Applies-to';
        AmountDueCaptionLbl: Label 'Amount Due';
        AmountDiscountedCaptionLbl: Label 'Payment Discount';
        AmountPaidCaptionLbl: Label 'Amount Paid';
        AmountAppliedCaptionLbl: Label 'Total Amount Applied';
        AmountPmtDiscToleranceCaptionLbl: Label 'Pmt. Discount Tolerance';
        AmountPmtToleranceCaptionLbl: Label 'Payment Tolerance';
        Header_DimensionsCaptionLbl: Label 'Header Dimensions';
        Warning_CaptionLbl: Label 'Warning:';
        Gen__Journal_Line__Applies_to_Doc__No__Caption_Control2Lbl: Label 'Applies-to';
        AmountDueCaption_Control7Lbl: Label 'Amount Due';
        AmountDiscountedCaption_Control10Lbl: Label 'Payment Discount';
        AmountAppliedCaption_Control12Lbl: Label 'Total Amount Applied';
        Gen__Journal_Line__Applies_to_Doc__Type_Caption_Control13Lbl: Label 'Applies-to';
        Account_TypeCaptionLbl: Label 'Account Type';
        Account_No_____________AccountNameCaption_Control20Lbl: Label 'Account No. / Name';
        Gen__Journal_Line__Document_Date_Caption_Control21Lbl: Label 'Doc. Date';
        AmountPaidCaption_Control11Lbl: Label 'Amount Paid';
        AmountCaption_Control19Lbl: Label 'Credit Amount';
        AmountPmtDiscToleranceCaption_Control1020031Lbl: Label 'Pmt. Discount Tolerance';
        AmountPmtToleranceCaption_Control1020033Lbl: Label 'Payment Tolerance';
        Total_Deposit_AmountCaptionLbl: Label 'Total Deposit Amount';
        Total_Deposit_LinesCaptionLbl: Label 'Total Deposit Lines';
        DifferenceCaptionLbl: Label 'Difference';
        Total_AppliedCaptionLbl: Label 'Total Applied';
        Remaining_UnappliedCaptionLbl: Label 'Remaining Unapplied';
        Line_DimensionsCaptionLbl: Label 'Line Dimensions';
        Warning_Caption_Control1020071Lbl: Label 'Warning:';
        CustomerBlockedErr: Label 'Customer %1 is blocked for processing.', Comment = '%1 = customer code';
        VendorBlockedErr: Label 'Vendor %1 is blocked for processing.', Comment = '%1 = vendor code';
        CustomerPrivacyBlockedErr: Label 'Customer %1 is blocked for privacy.', Comment = '%1 = customer code';
        VendorPrivacyBlockedErr: Label 'Vendor %1 is blocked for privacy.', Comment = '%1 = vendor code';
        GLAccountBlockedErr: Label 'G/L Account %1 is blocked for processing.', Comment = '%1 = GL Account code';
        BankAccountBlockedErr: Label 'Bank Account %1 is blocked for processing.', Comment = '%1 = bank account code';
        ICPartnerBlockedErr: Label 'IC Partner %1 is blocked for processing.', Comment = '%1 = IC partner code';

    local procedure AddError(Text: Text[250])
    begin
        ErrorCounter := ErrorCounter + 1;
        ErrorText[ErrorCounter] := Text;
    end;

    local procedure GetCurrencyRecord(var LocalVarCurrency: Record Currency; CurrencyCode: Code[10])
    begin
        if CurrencyCode = '' then begin
            Clear(LocalVarCurrency);
            LocalVarCurrency.Description := CopyStr(GeneralLedgerSetup."Local Currency Description", 1, MaxStrLen(LocalVarCurrency.Description));
            LocalVarCurrency."Amount Rounding Precision" := GeneralLedgerSetup."Amount Rounding Precision";
        end else
            if LocalVarCurrency.Code <> CurrencyCode then
                if not LocalVarCurrency.Get(CurrencyCode) then
                    AddError(
                      StrSubstNo(AccountNotValidErr, CurrencyCode, "Bank Deposit Header".FieldCaption("Currency Code")));
    end;

    local procedure GetCurrencyCaptionCode(CurrencyCode: Code[10]): Text[80]
    begin
        GetCurrencyRecord(Currency, CurrencyCode);
        if Currency.Code = '' then
            exit(GeneralLedgerSetup."LCY Code");
        exit(Currency.Code);
    end;

    local procedure GetCurrencyCaptionDesc(CurrencyCode: Code[10]): Text[80]
    begin
        GetCurrencyRecord(Currency, CurrencyCode);
        if (Format(Currency.Code) = Format(Currency.Description)) then
            exit('');
        exit(Currency.Description);
    end;

    local procedure UpdateFromAccountTypeEmployee(var GenJournalLine: Record "Gen. Journal Line")
    var
        Employee: Record Employee;
    begin
        if Employee.Get(GenJournalLine."Account No.") then
            AccountName := Employee.FullName()
        else begin
            AddError(
              StrSubstNo(AccountNotValidErr, GenJournalLine."Account No.", GenJournalLine."Account Type"));
            AccountName := StrSubstNo(InvalidAccountTxt, Employee.TableCaption);
        end;
        if GenJournalLine.Description = AccountName then
            GenJournalLine.Description := '';
    end;

    local procedure ApplyAccountTypeLogic(var GenJournalLine: Record "Gen. Journal Line")
    begin
        case GenJournalLine."Account Type" of
            GenJournalLine."Account Type"::"G/L Account":
                begin
                    if GLAccount.Get(GenJournalLine."Account No.") then begin
                        AccountName := GLAccount.Name;
                        if GLAccount.Blocked then
                            AddError(
                              StrSubstNo(GLAccountBlockedErr, GenJournalLine."Account No."));
                        if GLAccount."Account Type" <> GLAccount."Account Type"::Posting then
                            AddError(
                              StrSubstNo(PostingAccountErr, GLAccount.TableCaption, GenJournalLine."Account No."))
                        else
                            if not GLAccount."Direct Posting" then
                                AddError(
                                  StrSubstNo(DirectPostingAccountErr, GLAccount.TableCaption, GenJournalLine."Account No."));
                    end else begin
                        AddError(
                          StrSubstNo(AccountNotValidErr, GenJournalLine."Account No.", GenJournalLine."Account Type"));
                        AccountName := StrSubstNo(InvalidAccountTxt, GLAccount.TableCaption);
                    end;
                    if GenJournalLine.Description = AccountName then
                        GenJournalLine.Description := '';
                end;
            GenJournalLine."Account Type"::Customer:
                begin
                    if Customer.Get(GenJournalLine."Account No.") then begin
                        if Customer."Privacy Blocked" then
                            AddError(
                              StrSubstNo(CustomerPrivacyBlockedErr, GenJournalLine."Account No."));
                        if Customer.Blocked <> Customer.Blocked::" " then
                            AddError(
                              StrSubstNo(CustomerBlockedErr, GenJournalLine."Account No."));
                        AccountName := Customer.Name;
                    end else begin
                        AddError(
                          StrSubstNo(AccountNotValidErr, GenJournalLine."Account No.", GenJournalLine."Account Type"));
                        AccountName := StrSubstNo(InvalidAccountTxt, Customer.TableCaption);
                    end;
                    if GenJournalLine.Description = AccountName then
                        GenJournalLine.Description := '';
                end;
            GenJournalLine."Account Type"::Vendor:
                begin
                    if Vendor.Get(GenJournalLine."Account No.") then begin
                        AccountName := Vendor.Name;
                        if Vendor."Privacy Blocked" then
                            AddError(
                              StrSubstNo(VendorPrivacyBlockedErr, GenJournalLine."Account No."));
                        if Vendor.Blocked <> Vendor.Blocked::" " then
                            AddError(
                              StrSubstNo(VendorBlockedErr, GenJournalLine."Account No."));
                    end else begin
                        AddError(
                          StrSubstNo(AccountNotValidErr, GenJournalLine."Account No.", GenJournalLine."Account Type"));
                        AccountName := StrSubstNo(InvalidAccountTxt, Vendor.TableCaption);
                    end;
                    if GenJournalLine.Description = AccountName then
                        GenJournalLine.Description := '';
                end;
            GenJournalLine."Account Type"::"Bank Account":
                begin
                    if BankAccount2.Get(GenJournalLine."Account No.") then begin
                        AccountName := BankAccount2.Name;
                        if BankAccount2.Blocked then
                            AddError(
                              StrSubstNo(BankAccountBlockedErr, GenJournalLine."Account No."));
                    end else begin
                        AddError(
                          StrSubstNo(AccountNotValidErr, GenJournalLine."Account No.", GenJournalLine."Account Type"));
                        AccountName := StrSubstNo(InvalidAccountTxt, BankAccount2.TableCaption);
                    end;
                    if GenJournalLine.Description = AccountName then
                        GenJournalLine.Description := '';
                end;
            GenJournalLine."Account Type"::"IC Partner":
                if not ICPartner.Get(GenJournalLine."Account No.") then
                    AddError(
                      StrSubstNo(AccountNotValidErr, GenJournalLine."Account No.", GenJournalLine."Account Type"))
                else begin
                    AccountName := ICPartner.Name;
                    if ICPartner.Blocked then
                        AddError(
                          StrSubstNo(ICPartnerBlockedErr, GenJournalLine."Account No."));
                end;
            GenJournalLine."Account Type"::Employee:
                UpdateFromAccountTypeEmployee("Gen. Journal Line");
            else
                AddError(
                  StrSubstNo(AccountNotValidErr, GenJournalLine."Account Type", GenJournalLine.FieldCaption(GenJournalLine."Account Type")));
        end;
    end;
}

