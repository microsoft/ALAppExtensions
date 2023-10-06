// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Reports;

using Microsoft.Bank.BankAccount;
using Microsoft.Bank.VoucherInterface;
using Microsoft.CRM.Campaign;
using Microsoft.CRM.Team;
using Microsoft.Finance.Currency;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;
using Microsoft.Finance.TCS.TCSBase;
using Microsoft.Finance.VAT.Setup;
using Microsoft.FixedAssets.Depreciation;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.FixedAssets.Journal;
using Microsoft.FixedAssets.Ledger;
using Microsoft.FixedAssets.Maintenance;
using Microsoft.FixedAssets.Setup;
using Microsoft.Foundation.NoSeries;
using Microsoft.Foundation.PaymentTerms;
using Microsoft.Foundation.Period;
using Microsoft.Intercompany.BankAccount;
using Microsoft.Intercompany.GLAccount;
using Microsoft.Intercompany.Journal;
using Microsoft.Intercompany.Partner;
using Microsoft.Projects.Project.Job;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Setup;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Receivables;
using Microsoft.Sales.Setup;
using System.Security.User;
using System.Utilities;

report 18031 "General Journal - Test GST"
{
    DefaultLayout = RDLC;
    RDLCLayout = './rdlc/GeneralJournalTest.rdl';
    Caption = 'General Journal - Test';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;

    dataset
    {
        dataitem("Gen. Journal Batch"; "Gen. Journal Batch")
        {
            DataItemTableView = sorting("Journal Template Name", Name);

            column(Gen__Journal_Batch_Journal_Template_Name; "Journal Template Name")
            {
            }
            column(Gen__Journal_Batch_Name; Name)
            {
            }
            dataitem(Integer; Integer)
            {
                DataItemTableView = sorting(Number)
                                    where(Number = const(1));
                PrintOnlyIfDetail = true;

                column(COMPANYNAME; CompanyName())
                {
                }
                column(Gen__Journal_Batch___Journal_Template_Name_; "Gen. Journal Batch"."Journal Template Name")
                {
                }
                column(Gen__Journal_Batch__Name; "Gen. Journal Batch".Name)
                {
                }
                column(GenJnlLineFilter; GenJnlLineFilter)
                {
                }
                column(Gen__Journal_Line__TABLECAPTION__________GenJnlLineFilter; "Gen. Journal Line".TableCaption + ': ' + GenJnlLineFilter)
                {
                }
                column(General_Journal___TestCaption; CurrReport_PAGENOCapLbl)
                {
                }
                column(CurrReport_PAGENOCaption; CurrReport_PAGENOCapLbl)
                {
                }
                column(Gen__Journal_Batch___Journal_Template_Name_Caption; "Gen. Journal Batch".FieldCaption("Journal Template Name"))
                {
                }
                column(Gen__Journal_Batch__NameCaption; Gen__Journal_Batch__NameCapLbl)
                {
                }
                column(Gen__Journal_Line__Posting_Date_Caption; Gen__Journal_Line__Posting_Date_CapLbl)
                {
                }
                column(Gen__Journal_Line__Document_Type_Caption; Gen__Journal_Line__Document_Type_CapLbl)
                {
                }
                column(Gen__Journal_Line__Document_No__Caption; "Gen. Journal Line".FieldCaption("Document No."))
                {
                }
                column(Gen__Journal_Line__Account_Type_Caption; Gen__Journal_Line__Account_Type_CapLbl)
                {
                }
                column(Gen__Journal_Line__Account_No__Caption; "Gen. Journal Line".FieldCaption("Account No."))
                {
                }
                column(AccNameCaption; AccNameCapLbl)
                {
                }
                column(Gen__Journal_Line_DescriptionCaption; "Gen. Journal Line".FieldCaption(Description))
                {
                }
                column(Gen__Journal_Line__Gen__Posting_Type_Caption; Gen__Journal_Line__Gen__Posting_Type_CapLbl)
                {
                }
                column(Gen__Journal_Line__Gen__Bus__Posting_Group_Caption; Gen__Journal_Line__Gen__Bus__Posting_Group_CapLbl)
                {
                }
                column(Gen__Journal_Line__Gen__Prod__Posting_Group_Caption; Gen__Journal_Line__Gen__Prod__Posting_Group_CapLbl)
                {
                }
                column(Gen__Journal_Line_AmountCaption; "Gen. Journal Line".FieldCaption(Amount))
                {
                }
                column(Gen__Journal_Line__Bal__Account_No__Caption; "Gen. Journal Line".FieldCaption("Bal. Account No."))
                {
                }
                column(Gen__Journal_Line__Balance__LCY__Caption; "Gen. Journal Line".FieldCaption("Balance (LCY)"))
                {
                }
                dataitem("Gen. Journal Line"; "Gen. Journal Line")
                {
                    DataItemLink = "Journal Template Name" = field("Journal Template Name"),
                                   "Journal Batch Name" = field(Name);
                    DataItemLinkReference = "Gen. Journal Batch";
                    DataItemTableView = sorting("Journal Template Name", "Journal Batch Name", "Line No.");
                    RequestFilterFields = "Posting Date";

                    column(GSTComponentCode1; GSTComponentCodeName[2] + ' Amount')
                    {
                    }
                    column(GSTComponentCode2; GSTComponentCodeName[3] + ' Amount')
                    {
                    }
                    column(GSTComponentCode3; GSTComponentCodeName[5] + ' Amount')
                    {
                    }
                    column(GSTComponentCode4; GSTComponentCodeName[6] + 'Amount')
                    {
                    }
                    column(GSTCompAmount1; Abs(GSTCompAmount[2]))
                    {
                    }
                    column(GSTCompAmount2; Abs(GSTCompAmount[3]))
                    {
                    }
                    column(GSTCompAmount3; Abs(GSTCompAmount[5]))
                    {
                    }
                    column(GSTCompAmount4; Abs(GSTCompAmount[6]))
                    {
                    }
                    column(IsGSTApplicable; IsGSTApplicable)
                    {
                    }
                    column(Gen__Journal_Line__Posting_Date_; Format("Posting Date"))
                    {
                    }
                    column(Gen__Journal_Line__Document_Type_; "Document Type")
                    {
                    }
                    column(Gen__Journal_Line__Document_No__; "Document No.")
                    {
                    }
                    column(Gen__Journal_Line__Account_Type_; "Account Type")
                    {
                    }
                    column(AccountNo_GenJnlLine; "Account No.")
                    {
                    }
                    column(AccName; AccName)
                    {
                    }
                    column(Gen__Journal_Line_Description; Description)
                    {
                    }
                    column(Gen__Journal_Line__Gen__Posting_Type_; "Gen. Posting Type")
                    {
                    }
                    column(Gen__Journal_Line__Gen__Bus__Posting_Group_; "Gen. Bus. Posting Group")
                    {
                    }
                    column(Gen__Journal_Line__Gen__Prod__Posting_Group_; "Gen. Prod. Posting Group")
                    {
                    }
                    column(Gen__Journal_Line_Amount; Amount)
                    {
                    }
                    column(Gen__Journal_Line__Currency_Code_; "Currency Code")
                    {
                    }
                    column(Gen__Journal_Line__Bal__Account_No__; "Bal. Account No.")
                    {
                    }
                    column(Gen__Journal_Line__Balance__LCY__; "Balance (LCY)")
                    {
                    }
                    column(AmountLCY; AmountLCY)
                    {
                    }
                    column(BalanceLCY; BalanceLCY)
                    {
                    }
                    column(Gen__Journal_Line__Amount__LCY__; "Amount (LCY)" - TDSAmount + TCSAmount + TCSAmountApplied + BankChargeAmt)
                    {
                    }
                    column(TDSAmount; TDSAmount)
                    {
                    }
                    column(ABS__Work_Tax_Amount___; 0)
                    {
                    }
                    column(TCSAmount; TCSAmount)
                    {
                    }
                    column(TCSAmountApplied; TCSAmountApplied)
                    {
                    }
                    column(BankChargeAmt; BankChargeAmt)
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
                    column(Gen__Journal_Line__Amount__LCY__Caption; Gen__Journal_Line__Amount__LCY__CapLbl)
                    {
                    }
                    column(TDS_Amount_Including_eCessCaption; TDS_Amount_Including_eCessCapLbl)
                    {
                    }
                    column(Work_Tax_AmountCaption; Work_Tax_AmountCapLbl)
                    {
                    }
                    column(TCS_AmountCaption; TCS_AmountCapLbl)
                    {
                    }
                    column(TCS_Amount__Applied_Caption; TCS_Amount__Applied_CapLbl)
                    {
                    }
                    column(Bank_ChargesCaption; Bank_ChargesCapLbl)
                    {
                    }
                    dataitem(DimensionLoop; Integer)
                    {
                        DataItemTableView = sorting(Number)
                                            where(Number = filter(1 ..));

                        column(DimText; DimText)
                        {
                        }
                        column(DimensionLoop_Number; Number)
                        {
                        }
                        column(DimensionsCaption; DimensionsCapLbl)
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            if Number = 1 then begin
                                if not DimSetEntry.FindSet() then
                                    CurrReport.Break();
                            end else
                                if not Continue then
                                    CurrReport.Break();
                            DimText := GetDimensionText(DimSetEntry);
                        end;

                        trigger OnPreDataItem()
                        begin
                            if not ShowDim then
                                CurrReport.Break();
                            DimSetEntry.Reset();
                            DimSetEntry.SetRange("Dimension Set ID", "Gen. Journal Line"."Dimension Set ID")
                        end;
                    }
                    dataitem("Gen. Jnl. Allocation"; "Gen. Jnl. Allocation")
                    {
                        DataItemLink = "Journal Template Name" = field("Journal Template Name"),
                                       "Journal Batch Name" = field("Journal Batch Name"),
                                       "Journal Line No." = field("Line No.");
                        DataItemTableView = sorting("Journal Template Name", "Journal Batch Name", "Journal Line No.", "Line No.");

                        column(AccountNo_GenJnlAllocation; "Account No.")
                        {
                        }
                        column(AccountName_GenJnlAllocation; "Account Name")
                        {
                        }
                        column(AllocationQuantity_GenJnlAllocation; "Allocation Quantity")
                        {
                        }
                        column(AllocationPct_GenJnlAllocation; "Allocation %")
                        {
                        }
                        column(Amount_GenJnlAllocation; Amount)
                        {
                        }
                        column(JournalLineNo_GenJnlAllocation; "Journal Line No.")
                        {
                        }
                        column(LineNo_GenJnlAllocation; "Line No.")
                        {
                        }
                        column(JournalBatchName_GenJnlAllocation; "Journal Batch Name")
                        {
                        }
                        column(AccountNoCaption_GenJnlAllocation; FieldCaption("Account No."))
                        {
                        }
                        column(AccountNameCaption_GenJnlAllocation; FieldCaption("Account Name"))
                        {
                        }
                        column(AllocationQuantityCaption_GenJnlAllocation; FieldCaption("Allocation Quantity"))
                        {
                        }
                        column(AllocationPctCaption_GenJnlAllocation; FieldCaption("Allocation %"))
                        {
                        }
                        column(AmountCaption_GenJnlAllocation; FieldCaption(Amount))
                        {
                        }
                        column(Recurring_GenJnlTemplate; GenJnlTemplate.Recurring)
                        {
                        }
                        dataitem(DimensionLoopAllocations; Integer)
                        {
                            DataItemTableView = sorting(Number)
                                                where(Number = filter(1 ..));

                            column(AllocationDimText; AllocationDimText)
                            {
                            }
                            column(Number_DimensionLoopAllocations; Number)
                            {
                            }
                            column(DimensionAllocationsCaption; DimensionAllocationsCapLbl)
                            {
                            }

                            trigger OnAfterGetRecord()
                            begin
                                if Number = 1 then begin
                                    if not DimSetEntry.FindFirst() then
                                        CurrReport.Break();
                                end else
                                    if not Continue then
                                        CurrReport.Break();

                                AllocationDimText := CopyStr(GetDimensionText(DimSetEntry), 1, MaxStrLen(AllocationDimText));
                            end;

                            trigger OnPreDataItem()
                            begin
                                if not ShowDim then
                                    CurrReport.Break();
                                DimSetEntry.Reset();
                                DimSetEntry.SetRange("Dimension Set ID", "Gen. Jnl. Allocation"."Dimension Set ID")
                            end;
                        }
                    }
                    dataitem(ErrorLoop; Integer)
                    {
                        DataItemTableView = sorting(Number);

                        column(ErrorText_Number_; ErrorText[Number])
                        {
                        }
                        column(ErrorText_Number_Caption; ErrorText_Number_CapLbl)
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

                    trigger OnPreDataItem()
                    begin
                        PreTestGenJnlAllocation("Gen. Journal Batch", "Gen. Journal Line", "Gen. Jnl. Allocation");
                    end;

                    trigger OnAfterGetRecord()
                    begin
                        TestGenJnlAllocation("Gen. Journal Line", "Gen. Jnl. Allocation");
                    end;
                }
                dataitem(ReconcileLoop; Integer)
                {
                    DataItemTableView = sorting(Number);

                    column(GLAccNetChange__No__; TempGLAccNetChange."No.")
                    {
                    }
                    column(GLAccNetChange_Name; TempGLAccNetChange.Name)
                    {
                    }
                    column(GLAccNetChange__Net_Change_in_Jnl__; TempGLAccNetChange."Net Change in Jnl.")
                    {
                    }
                    column(GLAccNetChange__Balance_after_Posting_; TempGLAccNetChange."Balance after Posting")
                    {
                    }
                    column(ReconciliationCaption; ReconciliationCapLbl)
                    {
                    }
                    column(GLAccNetChange__No__Caption; GLAccNetChange__No__CapLbl)
                    {
                    }
                    column(GLAccNetChange_NameCaption; GLAccNetChange_NameCapLbl)
                    {
                    }
                    column(GLAccNetChange__Net_Change_in_Jnl__Caption; GLAccNetChange__Net_Change_in_Jnl__CapLbl)
                    {
                    }
                    column(GLAccNetChange__Balance_after_Posting_Caption; GLAccNetChange__Balance_after_Posting_CapLbl)
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        if Number = 1 then
                            TempGLAccNetChange.Find('-')
                        else
                            TempGLAccNetChange.Next();
                    end;

                    trigger OnPostDataItem()
                    begin
                        TempGLAccNetChange.DeleteAll();
                    end;

                    trigger OnPreDataItem()
                    begin
                        SetRange(Number, 1, TempGLAccNetChange.Count);
                    end;
                }
            }

            trigger OnPreDataItem()
            begin
                GeneralLedgerSetup.Get();
                SalesSetup.Get();
                PurchSetup.Get();
                AmountLCY := 0;
                BalanceLCY := 0;
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
                    field(ShowDim_; ShowDim)
                    {
                        Caption = 'Show Dimensions';
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies whether the dimensions have to be displayed or not.';
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

    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        SalesSetup: Record "Sales & Receivables Setup";
        PurchSetup: Record "Purchases & Payables Setup";
        UserSetup: Record "User Setup";
        AccountingPeriod: Record "Accounting Period";
        GLAccount: Record "G/L Account";
        Currency: Record "Currency";
        Cust: Record "Customer";
        Vend: Record "Vendor";
        BankAccPostingGr: Record "Bank Account Posting Group";
        BankAcc: Record "Bank Account";
        GenJnlTemplate: Record "Gen. Journal Template";
        GenJnlLine2: Record "Gen. Journal Line";
        TempGenJnlLine: Record "Gen. Journal Line" temporary;
        TempGenJournalLineCustVendIC: Record "Gen. Journal Line" temporary;
        GenJnlAlloc: Record "Gen. Jnl. Allocation";
        OldCustLedgEntry: Record "Cust. Ledger Entry";
        OldVendLedgEntry: Record "Vendor Ledger Entry";
        VATPostingSetup: Record "VAT Posting Setup";
        NoSeries: Record "No. Series";
        FA: Record "Fixed Asset";
        ICPartner: Record "IC Partner";
        DeprBook: Record "Depreciation Book";
        FADeprBook: Record "FA Depreciation Book";
        FASetup: Record "FA Setup";
        TempGLAccNetChange: Record "G/L Account Net Change" temporary;
        DimSetEntry: Record "Dimension Set Entry";
        GenJnlLine3: Record "Gen. Journal Line";
        ExchAccGLJnlLine: Codeunit "Exchange Acc. G/L Journal Line";
        CurrentICPartner: Code[20];
        TDSCompAmount: array[20] of Decimal;
        GSTCompAmount: array[20] of Decimal;
        TDSComponentCode: array[20] of Integer;
        TCSCompAmount: array[20] of Decimal;
        TCSComponentCode: array[20] of Integer;
        GSTComponentCode: array[20] of Integer;
        GSTComponentCodeName: array[20] of Code[20];
        IsGSTApplicable: Boolean;
        GenJnlLineFilter: Text;
        AllowPostingFrom: Date;
        AllowPostingTo: Date;
        AllowFAPostingFrom: Date;
        AllowFAPostingTo: Date;
        LastDate: Date;
        LastDocType: Enum "Gen. Journal Document Type";
        LastDocNo: Code[20];
        LastEntrdDocNo: Code[20];
        LastEntrdDate: Date;
        BalanceLCY: Decimal;
        AmountLCY: Decimal;
        k: Integer;
        DocBalance: Decimal;
        DocBalanceReverse: Decimal;
        DateBalance: Decimal;
        DateBalanceReverse: Decimal;
        TotalBalance: Decimal;
        BankChargeAmt: Decimal;
        TotalBalanceReverse: Decimal;
        AccName: Text[100];
        LastLineNo: Integer;
        Day: Integer;
        Week: Integer;
        Month: Integer;
        MonthText: Text[30];
        AmountError: Boolean;
        ErrorCounter: Integer;
        TDSAmount: Decimal;
        TCSAmount: Decimal;
        TCSAmountApplied: Decimal;
        ErrorText: array[50] of Text[250];
        TempErrorText: Text[250];
        BalAccName: Text[100];
        VATEntryCreated: Boolean;
        CustPosting: Boolean;
        VendPosting: Boolean;
        SalesPostingType: Boolean;
        PurchPostingType: Boolean;
        DimText: Text;
        AllocationDimText: Text[75];
        ShowDim: Boolean;
        Continue: Boolean;
        DocTypeLbl: Label 'Document,Payment,Invoice,Credit Memo,Finance Charge Memo,Reminder,Refund';
        ExternalDocLbl: Label '%1 %2 is already used in line %3 (%4 %5).', Comment = '%1 = External Document No. field caption, %2 = "External Document No.", %3 = "Line No." , %4 = Document No. field Caption, %5 = Document No.';
        CustBlockLbl: Label '%1 must not be blocked with type %2 when %3 is %4', Comment = '%1 = Account Type", %2 = Cust.Blocked, %3 = Document Type field Caption, %4 = Document Type';
        VendBlockLbl: Label '%1 must not be blocked with type %2 when %3 is %4', Comment = '%1 = Account Type", %2 = Cust.Blocked, %3 = Document Type field Caption, %4 = Document Type';
        AccountTypeErrLbl: Label 'You cannot enter G/L Account or Bank Account in both %1 and %2.', Comment = '%1 = Account No. is field Caption, %2 =  Bal. Account No. field Caption';
        ICPartnerBlockedLbl: Label '%1 %2 is linked to %3 %4.', Comment = '%1 = TableCaption , %2 = Account No., %3 = ICPartner.Table Caption, %4 =  IC Partner Code';
        ICPartnerGLAccDirectionLbl: Label '%1 must not be specified when %2 is %3.', Comment = '%1 =FieldCaption("IC Account No."), %2 = FieldCaption("IC Direction"),%3 = Format("IC Direction")';
        ICPartnerGLAccLbl: Label '%1 must not be specified when the document is not an intercompany transaction.', Comment = '%1 = FieldCaption("IC Account No.")';
        JobNoCaptionLbl: Label '%1 %2 does not exist.', Comment = '%1 =Job.TableCaption,%2 = GenJnlLine."Job No."';
        JobNoBlockedLbl: Label '%1 must not be %2 for %3 %4.', Comment = '%1 = Job.FieldCaption(Blocked), %2 = Job.Blocked, %3 = Job.TableCaption, %4 = GenJnlLine."Job No."';
        DocumentNoLbl: Label '%1 %2 already exists.', Comment = '%1= FieldCaption("Document No."), %2 = "Document No."';
        DateCationLbl: Label '%1 cannot be filtered when you post recurring journals.', Comment = '%1 = FieldCaption("Posting Date")';
        Text001Lbl: Label '%1 or %2 must be specified.', Comment = '%1 = FieldCaption("Account No."),%2 = FieldCaption("Bal. Account No.")';
        Text002Lbl: Label '%1 must be specified.', Comment = '%1 FieldCaption("Bal. Gen. Posting Type")';
        VatAmountLbl: Label '%1 + %2 must be %3.', Comment = '%1 = FieldCaption("VAT Amount"),%2 =FieldCaption("VAT Base Amount"),%3= FieldCaption(Amount)';
        Text004Lbl: Label '%1 must be " " when %2 is %3.', Comment = '%1 = FieldCaption("Gen. Posting Type"),%2= FieldCaption("Account Type") ,%3="Account Type"';
        Text005Lbl: Label '%1, %2, %3 or %4 must not be completed when %5 is %6.', Comment = '%1 =FieldCaption("Gen. Bus. Posting Group"),%2=FieldCaption("Gen. Prod. Posting Group"),%3=FieldCaption("VAT Bus. Posting Group"),%4=FieldCaption("VAT Prod. Posting Group"),%5 =FieldCaption("Account Type"),%6 ="Account Type"';
        AmountNegtiveLbl: Label '%1 must be negative.', Comment = '%1 = FieldCaption(Amount)';
        PositiveLbl: Label '%1 must be positive.', Comment = '%1 =  Amount field Caption';
        AmountSignLbl: Label '%1 must have the same sign as %2.', Comment = '%1 = Sales/Purch. (LCY), %2 = Amount Field Caption';
        SpecifiedLbl: Label '%1 cannot be specified.', Comment = '%1 Specified Field Caption';
        CheckPrintLbl: Label '%1 must be Yes.', Comment = '%1 = "Check Printed" field Caption';
        VatAmountCaptionLbl: Label '%1 + %2 must be -%3.', Comment = '%1 = "Bal. VAT Amount" field Caption , %2 = "Bal. VAT Base Amount" field Caption, %3 = Amount is Caption';
        AmountCaptionLbl: Label '%1 must have a different sign than %2.', Comment = '%1 = Sales/Purch. (LCY) field Caption, %2 = Amount field Caption';
        PostingDateCaptionLbl: Label '%1 must only be a closing date for G/L entries.', Comment = '%1 = Posting Date Caption';
        PostingDateLbl: Label '%1 is not within your allowed range of posting dates.', Comment = '%1 = Posting Date';
        NoSeriesDateOrderLbl: Label 'The lines are not listed according to Posting Date because they were not entered in that order.';
        DocumentDateCaptionLbl: Label '%1', Comment = '%1 = Document Date Caption';
        NoSeriesErrLbl: Label 'There is a gap in the number series.';
        PaymentDiscountCaptionLbl: Label '%1 must be 0.', Comment = '%1 = Payment Discount% field Caption';
        BalAccountNoCaptionLbl: Label '%1 cannot be specified when using recurring journals.', Comment = '%1  Bal. Account No. field caption';
        RecurringMethodLbl: Label '%1 must not be %2 when %3 = %4.', Comment = '%1 = Recurring Method field Caption, %2 = Account Type field Caption,%3 =  Recurring Method , %4 = Account Type';
        RecurringErrLbl: Label 'Allocations can only be used with recurring journals.';
        GenJnlAllocLbl: Label 'Please specify %1 in the %2 allocation lines.', Comment = '%1 =  Account No. filed caption, %2 = Tolal allocation Lines';
        MonthTextLbl: Label '<Month Text>';
        GenJournalLineLbl: Label '%1 %2 posted on %3, must be separated by an empty line', Comment = '%1 = Document Type,%2 = Document No., %3 = Posting Date';
        DocBalanceLbl: Label '%1 %2 is out of balance by %3.', Comment = '%1 = LastDocType ,  %2 = LastDocNo, %3= DocBalance';
        DocBalanceReverseLbl: Label 'The reversing entries for %1 %2 are out of balance by %3.', Comment = '%1 = SELECTSTR(LastDocType + 1, DocTypeLbl), %2 = Last Document No. , %3 =  DocBalanceReverse';
        DateBalanceLbl: Label 'As of %1, the lines are out of balance by %2.', Comment = '%1 = LastDate, %2 = DateBalance';
        LastDateBalanceReverseLbl: Label 'As of %1, the reversing entries are out of balance by %2.', Comment = '%1 = Last Date, %2 = DateBalanceReverse';
        TotalBalanceLbl: Label 'The total of the lines is out of balance by %1.', Comment = '%1 = Total Balance';
        TotalBalanceReverseLbl: Label 'The total of the reversing entries is out of balance by %1.', Comment = '%1 = TotalBalanceReverse';
        TableCaptionLbl: Label '%1 %2 does not exist.', Comment = '%1 = Vend.TableCaption ,%2 = Account No.';
        TableFieldLbl: Label '%1 must be %2 for %3 %4.', Comment = '%1 = Field Caption , %2 = "Account Type" ,%3 = Table Caption",%4 = "Account No."';
        VATPostingLbl: Label '%1 %2 %3 does not exist.', Comment = '%1 = Table Caption, %2 = "VAT Bus. Posting Group", %3 = "VAT Prod. Posting Group"';
        VATCalculationLbl: Label '%1 must be %2.', Comment = '%1 = VAT Calculation Type Caption, %2 = VATPostingSetup."VAT Calculation Type';
        CurrencyCodeLbl: Label 'The currency %1 cannot be found. Please check the currency table.', Comment = '%1 = "Currency Code"';
        SalesDocumentLbl: Label 'Sales %1 %2 already exists.', Comment = '%1 = "Document Type", %2 = "Document No."';
        PurchaseDocumentLbl: Label 'Purchase %1 %2 already exists.', Comment = '%1 = "Document Type", %2 ="Document No."';
        ExternalDocumentNoLbl: Label '%1 must be entered.', Comment = '%1 = "External Document No."';
        BankAccCurrencyLbl: Label '%1 must not be filled when %2 is different in %3 and %4.', Comment = '%1 = "Bank Payment Type" field caption,%2 = "Account No." , %3 = Bank Acc.Table Caption %4 =Currency Code';
        FABudgetedAssetLbl: Label '%1 %2 must not have %3 = %4.', Comment = '%1 = FA.TableCaption ,%2 = "Account No.",%3 = "Budgeted Asset" field caption ,%4 = TRUE';
        JobNoLbl: Label '%1 must not be specified in fixed asset journal lines.', Comment = '%1 = "Job No." field caption';
        FieldCaptionLbl: Label '%1 must be specified in fixed asset journal lines.', Comment = '%1 = "FA Posting Type" field caption';
        DepreciationBookLbl: Label '%1 must be different than %2.', Comment = '%1 = "Depreciation Book Code", %2 = "Duplicate in Depreciation Book" field caption';
        BalAccountCaptionTypeLbl: Label '%1 and %2 must not both be %3.', Comment = '%1 = "Account Type" field caption %2 = "Bal. Account Type" field caption, %3 = "Account Type"';
        PostingTypeLbl: Label '%1  must not be specified when %2 = %3.', Comment = '%1 = "Gen. Posting Type" field caption, %2 = "FA Posting Type" field caption, %3 = "FA Posting Type"';
        FAPostingTypeLbl: Label 'must not be specified together with %1 = %2.', Comment = '%1 ="FA Posting Type" field Caption , %2 = "FA Posting Type"';
        FAPostingDateLbl: Label '%1 must be identical to %2.', Comment = '%1 = FieldCaption("Posting Date"), %2 = FieldCaption("FA Posting Date")';
        ClosingDateLbl: Label '%1 cannot be a closing date.', Comment = '%1 = "Posting Date" ';
        FAPostingDateCaptionLbl: Label '%1 is not within your range of allowed posting dates.', Comment = '%1 = FieldCaption("FA Posting Date")';
        InsuranceLbl: Label 'Insurance integration is not activated for %1 %2.', Comment = '%1 = "Depreciation Book Code", %2 = "Duplicate in Depreciation Book" field caption';
        FAErrorLbl: Label 'must not be specified when %1 is specified.', Comment = '%1 = FieldCaption("FA Error Entry No.")';
        GLIntegrationLbl: Label 'When G/L integration is not activated, %1 must not be posted in the general journal.', Comment = '%1 = FA Posting Type';
        Text057Lbl: Label 'When G/L integration is not activated, %1 must not be specified in the general journal.', Comment = '%1 =  FieldCaption("Depr. until FA Posting Date")';
        FAPostingLbl: Label '%1 must not be specified.', Comment = '%1 = FieldCaption("FA Posting Type")';
        PostingTypeErrLbl: Label 'The combination of Customer and Gen. Posting Type Purchase is not allowed.';
        Text060Lbl: Label 'The combination of Vendor and Gen. Posting Type Sales is not allowed.';
        Text061Lbl: Label 'The Balance and Reversing Balance recurring methods can be used only with Allocations.';
        AmountLbl: Label '%1 must not be 0.', Comment = '%1 GenJnlLine.FieldCaption(Amount)';
        AccNoCashAccLbl: Label 'Account No. %1 is not defined as cash account for the Voucher Sub Type %2 and Document No.%3.', Comment = '%1 = GenJnlLine3."Account No.", %2 = CashVoucherType, %3 =GenJnlLine3."Document No."';
        AccBankAccLbl: Label 'Account No. %1 is not defined as bank account for the Voucher Sub Type %2 and Document No.%3.', Comment = '%1 =  GenJnlLine3."Account No.", %2 =  BankVoucherType, %3 = GenJnlLine3."Document No."';
        BalAccTypeLbl: Label 'Account Type or Bal. Account Type can only be G/L Account or Bank Account for Sub Voucher Type %1 and Document No.%2.', Comment = '%1 = "Sub Voucher Type", %2= "Document No"';
        CashAccVoucherLbl: Label 'Cash Account No. %1 should not be used for Sub Voucher Type %2 and Document No.%3.', Comment = '%1 = Cash Account No., %2 = " Voucher Type", %3= "Document No"';
        BalAccDocNoLbl: Label 'Bal. Account Type should not be Bank Account for Document No.%1.', Comment = '%1 = "Document No."';
        CashAccNoVoucherLbl: Label 'Cash Account No. %1 cannot be credited for the Voucher Type %2 and Document No.%3.', Comment = '%1 = Cash Account No., %2 = " Voucher Type", %3= "Document No"';
        AccTypeBankAccDocLbl: Label 'Account Type should not be Bank Account for Document No.%1.', Comment = '%1 = "Document No."';
        CashAccNoVoucherDocNoLbl: Label 'Cash Account No. %1 cannot be debited for the Voucher Type %2 and Document No.%3.', Comment = '%1 = Cash Account No., %2 = " Voucher Type", %3= "Document No"';
        AccTypeGlAccGenTempLbl: Label 'Account Type must be G/L Account in Gen. Journal Line Journal Template Name=%1,Journal Batch Name=%2,Line No.=%3.', Comment = '%1 = "Journal Template Name", %2 = "Journal Batch Name", %3= "Line No."';
        GLACCGenJourLbl: Label 'Bal. Account Type must be G/L Account in Gen. Journal Line Journal Template Name=%1,Journal Batch Name=%2,Line No.=%3.', Comment = '%1 = "Journal Template Name", %2 = "Journal Batch Name", %3= "Line No."';
        AccTypeBanGenLineTempLbl: Label 'Account Type must be Bank Account in Gen. Journal Line Journal Template Name=%1,Journal Batch Name=%2,Line No.=%3.', Comment = '%1 = "Journal Template Name", %2 = "Journal Batch Name", %3= "Line No."';
        BalAccGEnJouTempLbl: Label 'Bal. Account Type must be Bank Account in Gen. Journal Line Journal Template Name=%1,Journal Batch Name=%2,Line No.=%3.', Comment = '%1 = "Journal Template Name", %2 = "Journal Batch Name", %3= "Line No."';
        CreditEntryDocLbl: Label 'You must specify only one credit entry for Document No = %1.', Comment = '%1 = "Document No."';
        DimValueLbl: Label '%1 - %2', Comment = '%1 = DimensionSetEntry."Dimension Code", %2= DimensionSetEntry."Dimension Value Code"';
        ICPartnerLbl: Label '%1 %2', Comment = '%1 = ICPartnerBlockedLbl , %2= TableFieldLbl';
        ICPartnerDetailLbl: Label '%1 %2', Comment = '%1 = ICPartnerBlockedLbl , %2= TableCaptionLbl';
        CurrReport_PAGENOCapLbl: Label 'Page';
        Gen__Journal_Batch__NameCapLbl: Label 'Journal Batch';
        Gen__Journal_Line__Posting_Date_CapLbl: Label 'Posting Date';
        Gen__Journal_Line__Document_Type_CapLbl: Label 'Document Type';
        Gen__Journal_Line__Account_Type_CapLbl: Label 'Account Type';
        AccNameCapLbl: Label 'Name';
        Gen__Journal_Line__Gen__Posting_Type_CapLbl: Label 'Gen. Posting Type';
        Gen__Journal_Line__Gen__Bus__Posting_Group_CapLbl: Label 'Gen. Bus. Posting Group';
        Gen__Journal_Line__Gen__Prod__Posting_Group_CapLbl: Label 'Gen. Prod. Posting Group';
        Gen__Journal_Line__Amount__LCY__CapLbl: Label 'Total (LCY)';
        TDS_Amount_Including_eCessCapLbl: Label 'TDS Amount';
        Work_Tax_AmountCapLbl: Label 'Work Tax Amount';
        TCS_AmountCapLbl: Label 'TCS Amount';
        TCS_Amount__Applied_CapLbl: Label 'TCS Amount (Applied)';
        Bank_ChargesCapLbl: Label 'Bank Charges';
        DimensionsCapLbl: Label 'Dimensions';
        ErrorText_Number_CapLbl: Label 'Warning!';
        ReconciliationCapLbl: Label 'Reconciliation';
        GLAccNetChange__No__CapLbl: Label 'No.';
        GLAccNetChange_NameCapLbl: Label 'Name';
        GLAccNetChange__Net_Change_in_Jnl__CapLbl: Label 'Net Change in Jnl.';
        GLAccNetChange__Balance_after_Posting_CapLbl: Label 'Balance after Posting';
        DimensionAllocationsCapLbl: Label 'Allocation Dimensions';

    procedure CheckICPartner(var GenJnlLine: Record "Gen. Journal Line"; var AccName: Text[100])
    begin
        if not ICPartner.Get(GenJnlLine."Account No.") then
            AddError(
              StrSubstNo(
               TableCaptionLbl,
                ICPartner.TableCaption, GenJnlLine."Account No."))
        else begin
            AccName := ICPartner.Name;
            if ICPartner.Blocked then
                AddError(
                  StrSubstNo(
                    TableFieldLbl,
                    ICPartner.FieldCaption(Blocked), false, ICPartner.TableCaption, GenJnlLine."Account No."));
        end;
    end;

    procedure TestPostingType()
    begin
        case true of
            CustPosting and PurchPostingType:
                AddError(PostingTypeErrLbl);
            VendPosting and SalesPostingType:
                AddError(Text060Lbl);
        end;
    end;

    procedure CheckICDocument()
    var
        GenJnlLine4: Record "Gen. Journal Line";
    begin
        if GenJnlTemplate.Type = GenJnlTemplate.Type::Intercompany then begin
            if ("Gen. Journal Line"."Posting Date" <> LastDate) or ("Gen. Journal Line"."Document Type" <> LastDocType) or ("Gen. Journal Line"."Document No." <> LastDocNo) then begin
                GenJnlLine4.SetCurrentKey("Journal Template Name", "Journal Batch Name", "Posting Date", "Document No.");
                GenJnlLine4.SetRange("Journal Template Name", "Gen. Journal Line"."Journal Template Name");
                GenJnlLine4.SetRange("Journal Batch Name", "Gen. Journal Line"."Journal Batch Name");
                GenJnlLine4.SetRange("Posting Date", "Gen. Journal Line"."Posting Date");
                GenJnlLine4.SetRange("Document No.", "Gen. Journal Line"."Document No.");
                GenJnlLine4.SetFilter("IC Partner Code", '<>%1', '');
                if GenJnlLine4.FindFirst() then
                    CurrentICPartner := GenJnlLine4."IC Partner Code"
                else
                    CurrentICPartner := '';
            end;
            CheckICAccountNo();
        end;
    end;

    local procedure CheckICAccountNo()
    var
        ICGLAccount: Record "IC G/L Account";
        ICBankAccount: Record "IC Bank Account";
    begin
#if not CLEAN22
        if (CurrentICPartner <> '') and ("Gen. Journal Line"."IC Direction" = "Gen. Journal Line"."IC Direction"::Outgoing) then begin
            if ("Gen. Journal Line"."Account Type" in ["Gen. Journal Line"."Account Type"::"G/L Account", "Gen. Journal Line"."Account Type"::"Bank Account"]) and
               ("Gen. Journal Line"."Bal. Account Type" in ["Gen. Journal Line"."Bal. Account Type"::"G/L Account", "Gen. Journal Line"."Account Type"::"Bank Account"]) and
               ("Gen. Journal Line"."Account No." <> '') and
               ("Gen. Journal Line"."Bal. Account No." <> '')
            then
                AddError(StrSubstNo(AccountTypeErrLbl, "Gen. Journal Line".FieldCaption("Gen. Journal Line"."Account No."),
                    "Gen. Journal Line".FieldCaption("Gen. Journal Line"."Bal. Account No.")))
            else
                if (("Gen. Journal Line"."Account Type" in ["Gen. Journal Line"."Account Type"::"G/L Account", "Gen. Journal Line"."Account Type"::"Bank Account"]) and ("Gen. Journal Line"."Account No." <> '')) XOR
                   (("Gen. Journal Line"."Bal. Account Type" in ["Gen. Journal Line"."Bal. Account Type"::"G/L Account", "Gen. Journal Line"."Account Type"::"Bank Account"]) and
                    ("Gen. Journal Line"."Bal. Account No." <> ''))
                then begin
                    if "Gen. Journal Line"."IC Partner G/L Acc. No." = '' then
                        AddError(StrSubstNo(Text002Lbl, "Gen. Journal Line".FieldCaption("IC Partner G/L Acc. No.")))
                    else begin
                        if ICGLAccount.Get("Gen. Journal Line"."IC Partner G/L Acc. No.") then
                            if ICGLAccount.Blocked then
                                AddError(StrSubstNo(TableFieldLbl, ICGLAccount.FieldCaption(Blocked), false,
                                    "Gen. Journal Line".FieldCaption("IC Partner G/L Acc. No."), "Gen. Journal Line"."IC Partner G/L Acc. No."));

                        if "Gen. Journal Line"."IC Account Type" = "IC Journal Account Type"::"Bank Account" then
                            if ICBankAccount.Get("Gen. Journal Line"."IC Account No.", CurrentICPartner) then
                                if ICBankAccount.Blocked then
                                    AddError(StrSubstNo(TableFieldLbl, ICBankAccount.FieldCaption(Blocked), false,
                                        "Gen. Journal Line".FieldCaption("IC Account No."), "Gen. Journal Line"."IC Account No."));
                    end;
                end else
                    if "Gen. Journal Line"."IC Partner G/L Acc. No." <> '' then
                        AddError(StrSubstNo(SpecifiedLbl, "Gen. Journal Line".FieldCaption("Gen. Journal Line"."IC Partner G/L Acc. No.")));
        end else
            if "Gen. Journal Line"."IC Partner G/L Acc. No." <> '' then begin
                if "Gen. Journal Line"."IC Direction" = "Gen. Journal Line"."IC Direction"::Incoming then
                    AddError(StrSubstNo(ICPartnerGLAccDirectionLbl, "Gen. Journal Line".FieldCaption(
                        "Gen. Journal Line"."IC Partner G/L Acc. No."), "Gen. Journal Line".FieldCaption("Gen. Journal Line"."IC Direction"),
                        Format("Gen. Journal Line"."IC Direction")));
                if CurrentICPartner = '' then
                    AddError(StrSubstNo(ICPartnerGLAccLbl, "Gen. Journal Line".FieldCaption("Gen. Journal Line"."IC Partner G/L Acc. No.")));
            end;
#else
        if (CurrentICPartner <> '') and ("Gen. Journal Line"."IC Direction" = "Gen. Journal Line"."IC Direction"::Outgoing) then begin
            if ("Gen. Journal Line"."Account Type" in ["Gen. Journal Line"."Account Type"::"G/L Account", "Gen. Journal Line"."Account Type"::"Bank Account"]) and
               ("Gen. Journal Line"."Bal. Account Type" in ["Gen. Journal Line"."Bal. Account Type"::"G/L Account", "Gen. Journal Line"."Account Type"::"Bank Account"]) and
               ("Gen. Journal Line"."Account No." <> '') and
               ("Gen. Journal Line"."Bal. Account No." <> '')
            then
                AddError(StrSubstNo(AccountTypeErrLbl, "Gen. Journal Line".FieldCaption("Gen. Journal Line"."Account No."),
                    "Gen. Journal Line".FieldCaption("Gen. Journal Line"."Bal. Account No.")))
            else
                if (("Gen. Journal Line"."Account Type" in ["Gen. Journal Line"."Account Type"::"G/L Account", "Gen. Journal Line"."Account Type"::"Bank Account"]) and ("Gen. Journal Line"."Account No." <> '')) XOR
                   (("Gen. Journal Line"."Bal. Account Type" in ["Gen. Journal Line"."Bal. Account Type"::"G/L Account", "Gen. Journal Line"."Account Type"::"Bank Account"]) and
                    ("Gen. Journal Line"."Bal. Account No." <> ''))
                then begin
                    if "Gen. Journal Line"."IC Account No." = '' then
                        AddError(StrSubstNo(Text002Lbl, "Gen. Journal Line".FieldCaption("IC Account No.")))
                    else begin
                        if "Gen. Journal Line"."IC Account Type" = "IC Journal Account Type"::"G/L Account" then
                            if ICGLAccount.Get("Gen. Journal Line"."IC Account No.") then
                                if ICGLAccount.Blocked then
                                    AddError(StrSubstNo(TableFieldLbl, ICGLAccount.FieldCaption(Blocked), false,
                                        "Gen. Journal Line".FieldCaption("IC Account No."), "Gen. Journal Line"."IC Account No."));

                        if "Gen. Journal Line"."IC Account Type" = "IC Journal Account Type"::"Bank Account" then
                            if ICBankAccount.Get("Gen. Journal Line"."IC Account No.", CurrentICPartner) then
                                if ICBankAccount.Blocked then
                                    AddError(StrSubstNo(TableFieldLbl, ICBankAccount.FieldCaption(Blocked), false,
                                        "Gen. Journal Line".FieldCaption("IC Account No."), "Gen. Journal Line"."IC Account No."));
                    end;
                end else
                    if "Gen. Journal Line"."IC Account No." <> '' then
                        AddError(StrSubstNo(SpecifiedLbl, "Gen. Journal Line".FieldCaption("Gen. Journal Line"."IC Account No.")));
        end else
            if "Gen. Journal Line"."IC Account No." <> '' then begin
                if "Gen. Journal Line"."IC Direction" = "Gen. Journal Line"."IC Direction"::Incoming then
                    AddError(StrSubstNo(ICPartnerGLAccDirectionLbl, "Gen. Journal Line".FieldCaption(
                        "Gen. Journal Line"."IC Account No."), "Gen. Journal Line".FieldCaption("Gen. Journal Line"."IC Direction"),
                        Format("Gen. Journal Line"."IC Direction")));
                if CurrentICPartner = '' then
                    AddError(StrSubstNo(ICPartnerGLAccLbl, "Gen. Journal Line".FieldCaption("Gen. Journal Line"."IC Account No.")));
            end;
#endif
    end;

    procedure TestJobFields(var GenJnlLine: Record "Gen. Journal Line")
    var
        Job: Record "Job";
        JT: Record "Job Task";
    begin
        if (GenJnlLine."Job No." = '') or (GenJnlLine."Account Type" <> GenJnlLine."Account Type"::"G/L Account") then
            exit;
        if not Job.Get(GenJnlLine."Job No.") then
            AddError(StrSubstNo(JobNoCaptionLbl, Job.TableCaption, GenJnlLine."Job No."))
        else
            if Job.Blocked::" " <> Job.Blocked::" " then
                AddError(
                  StrSubstNo(
                    JobNoBlockedLbl, Job.FieldCaption(Blocked), Job.Blocked, Job.TableCaption, GenJnlLine."Job No."));

        if GenJnlLine."Job Task No." = '' then
            AddError(StrSubstNo(Text002Lbl, GenJnlLine.FieldCaption(GenJnlLine."Job Task No.")))
        else
            if not JT.Get(GenJnlLine."Job No.", GenJnlLine."Job Task No.") then
                AddError(StrSubstNo(JobNoCaptionLbl, JT.TableCaption, GenJnlLine."Job Task No."))
    end;

    procedure ShowVoucherValidations(var GenJnlline: Record "Gen. Journal Line")
    var
        GenJrnTemp: Record "Gen. Journal Template";
    begin
        GenJrnTemp.SetRange(Name, GenJnlline."Journal Alloc. Template Name");
        if GenJrnTemp.FindFirst() then;
        if (GenJnlline."Journal Template Name" <> '') and (GenJnlline."Journal Batch Name" <> '')
        then begin
            if GenJrnTemp.Type = GenJrnTemp.Type::"Cash Receipt Voucher" then
                IdentifyCashAccount(GenJnlline, GenJrnTemp.Type::"Cash Receipt Voucher");
            if GenJrnTemp.Type = GenJrnTemp.Type::"Cash Payment Voucher" then
                IdentifyCashAccount(GenJnlline, GenJrnTemp.Type::"Cash Payment Voucher");
            if GenJrnTemp.Type = GenJrnTemp.Type::"Bank Receipt Voucher" then
                IdentifyBankAccount(GenJnlline, GenJrnTemp.Type::"Bank Receipt Voucher");
            if GenJrnTemp.Type = GenJrnTemp.Type::"Bank Payment Voucher" then
                IdentifyBankAccount(GenJnlline, GenJrnTemp.Type::"Bank Payment Voucher");
            if GenJrnTemp.Type = GenJrnTemp.Type::"Contra Voucher" then
                IdentifyContraAccount(GenJnlline);
            if GenJrnTemp.Type = GenJrnTemp.Type::"Journal Voucher" then
                IdentifyJournalAccount(GenJnlline);
        end;
    end;

    procedure IdentifycashAccount(
        GenJnlLine2: Record "Gen. Journal Line";
        cashVoucherType: Enum "Gen. Journal Template Type")
    var
        VoucherAcc: Record "Voucher Posting Debit Account";
    begin
        if GenJnlLine2.Amount = 0 then
            exit;
        GenJnlLine3 := GenJnlLine2;
        if CashVoucherType = CashVoucherType::"Cash Receipt Voucher" then begin
            if GenJnlLine3.Amount > 0 then begin
                if GenJnlLine3."Account No." <> '' then begin
                    if GenJnlLine3."Account Type" <> GenJnlLine3."Account Type"::"G/L Account" then
                        AddError(StrSubstNo(AccTypeGlAccGenTempLbl, GenJnlLine3."Journal Template Name", GenJnlLine3."Journal Batch Name",
                          GenJnlLine3."Line No."));
                    VoucherAcc.SetRange("Location code", GenJnlLine3."Location Code");
                    VoucherAcc.SetRange(Type, VoucherAcc.Type::"Cash Receipt Voucher");
                    VoucherAcc.SetRange("Account Type", GenJnlLine3."Account Type"::"G/L Account");
                    VoucherAcc.SetRange("Account No.", GenJnlLine3."Account No.");
                    if not VoucherAcc.FindFirst() then
                        AddError(StrSubstNo(AccNoCashAccLbl, GenJnlLine3."Account No.", CashVoucherType, GenJnlLine3."Document No."));
                end;

                if GenJnlLine3."Bal. Account Type" = GenJnlLine3."Bal. Account Type"::"Bank Account" then
                    AddError(StrSubstNo(BalAccDocNoLbl, GenJnlLine3."Document No."));

                if GenJnlLine3."Bal. Account Type" = GenJnlLine3."Bal. Account Type"::"G/L Account" then begin
                    VoucherAcc.SetRange("Location code", GenJnlLine3."Location Code");
                    VoucherAcc.SetFilter(Type, '%1|%2', VoucherAcc.Type::"Cash Receipt Voucher",
                      VoucherAcc.Type::"Cash Payment Voucher");
                    VoucherAcc.SetRange("Account Type", GenJnlLine3."Bal. Account Type"::"G/L Account");
                    VoucherAcc.SetRange("Account No.", GenJnlLine3."Bal. Account No.");
                    if VoucherAcc.FindFirst() then
                        AddError(StrSubstNo(CashAccNoVoucherLbl, GenJnlLine3."Account No.", CashVoucherType, GenJnlLine3."Document No."));
                end;
            end;
            if GenJnlLine3.Amount < 0 then begin
                if GenJnlLine3."Bal. Account No." <> '' then begin
                    if GenJnlLine3."Bal. Account Type" <> GenJnlLine3."Bal. Account Type"::"G/L Account" then
                        AddError(StrSubstNo(GLACCGenJourLbl, GenJnlLine3."Journal Template Name", GenJnlLine3."Journal Batch Name",
                          GenJnlLine3."Line No."));

                    VoucherAcc.SetRange("Location code", GenJnlLine3."Location Code");
                    VoucherAcc.SetRange(Type, VoucherAcc.Type::"Cash Receipt Voucher");
                    VoucherAcc.SetRange("Account Type", GenJnlLine3."Bal. Account Type"::"G/L Account");
                    VoucherAcc.SetRange("Account No.", GenJnlLine3."Bal. Account No.");
                    if not VoucherAcc.FindFirst() then
                        AddError(StrSubstNo(AccNoCashAccLbl, GenJnlLine3."Bal. Account No.", CashVoucherType, GenJnlLine3."Document No."));
                end;

                if GenJnlLine3."Account Type" = GenJnlLine3."Account Type"::"Bank Account" then
                    AddError(StrSubstNo(AccTypeBankAccDocLbl, GenJnlLine3."Document No."));

                if GenJnlLine3."Account Type" = GenJnlLine3."Account Type"::"G/L Account" then begin
                    VoucherAcc.SetRange("Location code", GenJnlLine3."Location Code");
                    VoucherAcc.SetFilter(Type, '%1|%2', VoucherAcc.Type::"Cash Receipt Voucher",
                      VoucherAcc.Type::"Cash Payment Voucher");
                    VoucherAcc.SetRange("Account Type", GenJnlLine3."Account Type"::"G/L Account");
                    VoucherAcc.SetRange("Account No.", GenJnlLine3."Account No.");
                    if VoucherAcc.FindFirst() then
                        AddError(StrSubstNo(CashAccNoVoucherLbl, GenJnlLine3."Account No.", CashVoucherType, GenJnlLine3."Document No."));
                end;
            end;
        end;
        if CashVoucherType = CashVoucherType::"Cash Payment Voucher" then begin
            if GenJnlLine3.Amount < 0 then begin
                if GenJnlLine3."Account No." <> '' then begin
                    if GenJnlLine3."Account Type" <> GenJnlLine3."Account Type"::"G/L Account" then
                        AddError(StrSubstNo(AccTypeGlAccGenTempLbl, GenJnlLine3."Journal Template Name", GenJnlLine3."Journal Batch Name",
                          GenJnlLine3."Line No."));
                    VoucherAcc.SetRange("Location code", GenJnlLine3."Location Code");
                    VoucherAcc.SetRange(Type, VoucherAcc.Type::"Cash Payment Voucher");
                    VoucherAcc.SetRange("Account Type", GenJnlLine3."Account Type"::"G/L Account");
                    VoucherAcc.SetRange("Account No.", GenJnlLine3."Account No.");
                    if not VoucherAcc.FindFirst() then
                        AddError(StrSubstNo(AccNoCashAccLbl, GenJnlLine3."Account No.", CashVoucherType, GenJnlLine3."Document No."));
                end;

                if GenJnlLine3."Bal. Account Type" = GenJnlLine3."Bal. Account Type"::"Bank Account" then
                    AddError(StrSubstNo(BalAccDocNoLbl, GenJnlLine3."Document No."));

                if GenJnlLine3."Bal. Account Type" = GenJnlLine3."Bal. Account Type"::"G/L Account" then begin
                    VoucherAcc.SetRange("Location code", GenJnlLine3."Location Code");
                    VoucherAcc.SetFilter(Type, '%1|%2', VoucherAcc.Type::"Cash Receipt Voucher",
                      VoucherAcc.Type::"Cash Payment Voucher");
                    VoucherAcc.SetRange("Account Type", GenJnlLine3."Bal. Account Type"::"G/L Account");
                    VoucherAcc.SetRange("Account No.", GenJnlLine3."Bal. Account No.");
                    if VoucherAcc.FindFirst() then
                        AddError(StrSubstNo(CashAccNoVoucherDocNoLbl, GenJnlLine3."Account No.", CashVoucherType, GenJnlLine3."Document No."));
                end;
            end;
            if GenJnlLine3.Amount > 0 then begin
                if GenJnlLine3."Bal. Account No." <> '' then begin
                    if GenJnlLine3."Bal. Account Type" <> GenJnlLine3."Bal. Account Type"::"G/L Account" then
                        AddError(StrSubstNo(GLACCGenJourLbl, GenJnlLine3."Journal Template Name", GenJnlLine3."Journal Batch Name",
                          GenJnlLine3."Line No."));

                    VoucherAcc.SetRange("Location code", GenJnlLine3."Location Code");
                    VoucherAcc.SetRange(Type, VoucherAcc.Type::"Cash Payment Voucher");
                    VoucherAcc.SetRange("Account Type", GenJnlLine3."Bal. Account Type"::"G/L Account");
                    VoucherAcc.SetRange("Account No.", GenJnlLine3."Bal. Account No.");
                    if not VoucherAcc.FindFirst() then
                        AddError(StrSubstNo(AccNoCashAccLbl, GenJnlLine3."Bal. Account No.", CashVoucherType, GenJnlLine3."Document No."));
                end;

                if GenJnlLine3."Account Type" = GenJnlLine3."Account Type"::"Bank Account" then
                    AddError(StrSubstNo(AccTypeBankAccDocLbl, GenJnlLine3."Document No."));

                if GenJnlLine3."Account Type" = GenJnlLine3."Account Type"::"G/L Account" then begin
                    VoucherAcc.SetRange("Location code", GenJnlLine3."Location Code");
                    VoucherAcc.SetFilter(Type, '%1|%2', VoucherAcc.Type::"Cash Receipt Voucher",
                      VoucherAcc.Type::"Cash Payment Voucher");
                    VoucherAcc.SetRange("Account Type", GenJnlLine3."Account Type"::"G/L Account");
                    VoucherAcc.SetRange("Account No.", GenJnlLine3."Account No.");
                    if not VoucherAcc.IsEmpty() then
                        AddError(StrSubstNo(CashAccNoVoucherDocNoLbl, GenJnlLine3."Account No.", CashVoucherType, GenJnlLine3."Document No."));
                end;
            end;
        end;
    end;

    procedure IdentifyBankAccount(
        GenJnlLine2: Record "Gen. Journal Line";
        BankVoucherType: Enum "Gen. Journal Template Type")
    var
        VoucherAcc: Record "Voucher Posting Credit Account";
    begin
        if GenJnlLine2.Amount = 0 then
            exit;
        GenJnlLine3 := GenJnlLine2;
        if BankVoucherType = BankVoucherType::"Bank Receipt Voucher" then begin
            if GenJnlLine3.Amount > 0 then begin
                if GenJnlLine3."Account No." <> '' then begin
                    if GenJnlLine3."Account Type" <> GenJnlLine3."Account Type"::"Bank Account" then
                        AddError(StrSubstNo(AccTypeBanGenLineTempLbl, GenJnlLine3."Journal Template Name", GenJnlLine3."Journal Batch Name",
                          GenJnlLine3."Line No."));
                    VoucherAcc.SetRange("Location code", GenJnlLine3."Location Code");
                    VoucherAcc.SetRange(Type, VoucherAcc.Type::"Bank Receipt Voucher");
                    VoucherAcc.SetRange("Account Type", GenJnlLine3."Account Type"::"Bank Account");
                    VoucherAcc.SetRange("Account No.", GenJnlLine3."Account No.");
                    if not VoucherAcc.FindFirst() then
                        AddError(StrSubstNo(AccBankAccLbl, GenJnlLine3."Account No.", BankVoucherType, GenJnlLine3."Document No."));
                end;

                if GenJnlLine3."Bal. Account Type" = GenJnlLine3."Bal. Account Type"::"G/L Account" then begin
                    VoucherAcc.SetRange("Location code", GenJnlLine3."Location Code");
                    VoucherAcc.SetFilter(Type, '%1|%2', VoucherAcc.Type::"Cash Receipt Voucher",
                      VoucherAcc.Type::"Cash Payment Voucher");
                    VoucherAcc.SetRange("Account Type", GenJnlLine3."Bal. Account Type"::"G/L Account");
                    VoucherAcc.SetRange("Account No.", GenJnlLine3."Bal. Account No.");
                    if VoucherAcc.FindFirst() then
                        AddError(StrSubstNo(CashAccNoVoucherLbl, GenJnlLine3."Bal. Account No.", BankVoucherType, GenJnlLine3."Document No."));
                end;

                if GenJnlLine3."Bal. Account Type" = GenJnlLine3."Bal. Account Type"::"Bank Account" then
                    AddError(StrSubstNo(BalAccDocNoLbl, GenJnlLine3."Document No."));
            end;
            if GenJnlLine3.Amount < 0 then begin
                if GenJnlLine3."Bal. Account No." <> '' then begin
                    if GenJnlLine3."Bal. Account Type" <> GenJnlLine3."Bal. Account Type"::"Bank Account" then
                        AddError(StrSubstNo(BalAccGEnJouTempLbl, GenJnlLine3."Journal Template Name", GenJnlLine3."Journal Batch Name",
                          GenJnlLine3."Line No."));

                    VoucherAcc.SetRange("Location code", GenJnlLine3."Location Code");
                    VoucherAcc.SetRange(Type, VoucherAcc.Type::"Bank Receipt Voucher");
                    VoucherAcc.SetRange("Account Type", GenJnlLine3."Bal. Account Type"::"Bank Account");
                    VoucherAcc.SetRange("Account No.", GenJnlLine3."Bal. Account No.");
                    if not VoucherAcc.FindFirst() then
                        AddError(StrSubstNo(AccBankAccLbl, GenJnlLine3."Bal. Account No.", BankVoucherType, GenJnlLine3."Document No."));
                end;

                if GenJnlLine3."Account Type" = GenJnlLine3."Account Type"::"G/L Account" then begin
                    VoucherAcc.SetRange("Location code", GenJnlLine3."Location Code");
                    VoucherAcc.SetFilter(Type, '%1|%2', VoucherAcc.Type::"Cash Receipt Voucher",
                      VoucherAcc.Type::"Cash Payment Voucher");
                    VoucherAcc.SetRange("Account Type", GenJnlLine3."Account Type"::"G/L Account");
                    VoucherAcc.SetRange("Account No.", GenJnlLine3."Account No.");
                    if VoucherAcc.FindFirst() then
                        AddError(StrSubstNo(CashAccNoVoucherLbl, GenJnlLine3."Bal. Account No.", BankVoucherType, GenJnlLine3."Document No."));
                end;

                if GenJnlLine3."Account Type" = GenJnlLine3."Account Type"::"Bank Account" then
                    AddError(StrSubstNo(AccTypeBankAccDocLbl, GenJnlLine3."Document No."));
            end;
        end;
        if BankVoucherType = BankVoucherType::"Bank Payment Voucher" then begin
            if GenJnlLine3.Amount < 0 then begin
                if GenJnlLine3."Account No." <> '' then begin
                    if GenJnlLine3."Account Type" <> GenJnlLine3."Account Type"::"Bank Account" then
                        AddError(StrSubstNo(AccTypeBanGenLineTempLbl, GenJnlLine3."Journal Template Name", GenJnlLine3."Journal Batch Name",
                          GenJnlLine3."Line No."));
                    VoucherAcc.SetRange("Location code", GenJnlLine3."Location Code");
                    VoucherAcc.SetRange(Type, VoucherAcc.Type::"Bank Payment Voucher");
                    VoucherAcc.SetRange("Account Type", GenJnlLine3."Account Type"::"Bank Account");
                    VoucherAcc.SetRange("Account No.", GenJnlLine3."Account No.");
                    if not VoucherAcc.FindFirst() then
                        AddError(StrSubstNo(AccBankAccLbl, GenJnlLine3."Account No.", BankVoucherType, GenJnlLine3."Document No."));
                end;

                if GenJnlLine3."Bal. Account Type" = GenJnlLine3."Bal. Account Type"::"G/L Account" then begin
                    VoucherAcc.SetRange("Location code", GenJnlLine3."Location Code");
                    VoucherAcc.SetFilter(Type, '%1|%2', VoucherAcc.Type::"Cash Receipt Voucher",
                      VoucherAcc.Type::"Cash Payment Voucher");
                    VoucherAcc.SetRange("Account Type", GenJnlLine3."Bal. Account Type"::"G/L Account");
                    VoucherAcc.SetRange("Account No.", GenJnlLine3."Bal. Account No.");
                    if VoucherAcc.FindFirst() then
                        AddError(StrSubstNo(CashAccNoVoucherDocNoLbl, GenJnlLine3."Bal. Account No.", BankVoucherType, GenJnlLine3."Document No."));
                end;

                if GenJnlLine3."Bal. Account Type" = GenJnlLine3."Bal. Account Type"::"Bank Account" then
                    AddError(StrSubstNo(BalAccDocNoLbl, GenJnlLine3."Document No."));
            end;
            if GenJnlLine3.Amount > 0 then begin
                if GenJnlLine3."Bal. Account No." <> '' then begin
                    if GenJnlLine3."Bal. Account Type" <> GenJnlLine3."Bal. Account Type"::"Bank Account" then
                        AddError(StrSubstNo(BalAccGEnJouTempLbl, GenJnlLine3."Journal Template Name", GenJnlLine3."Journal Batch Name",
                          GenJnlLine3."Line No."));

                    VoucherAcc.SetRange("Location code", GenJnlLine3."Location Code");
                    VoucherAcc.SetRange(Type, VoucherAcc.Type::"Bank Payment Voucher");
                    VoucherAcc.SetRange("Account Type", GenJnlLine3."Bal. Account Type"::"Bank Account");
                    VoucherAcc.SetRange("Account No.", GenJnlLine3."Bal. Account No.");
                    if not VoucherAcc.FindFirst() then
                        AddError(StrSubstNo(AccBankAccLbl, GenJnlLine3."Bal. Account No.", BankVoucherType, GenJnlLine3."Document No."));
                end;

                if GenJnlLine3."Account Type" = GenJnlLine3."Account Type"::"G/L Account" then begin
                    VoucherAcc.SetRange("Location code", GenJnlLine3."Location Code");
                    VoucherAcc.SetFilter(Type, '%1|%2', VoucherAcc.Type::"Cash Receipt Voucher",
                      VoucherAcc.Type::"Cash Payment Voucher");
                    VoucherAcc.SetRange("Account Type", GenJnlLine3."Account Type"::"G/L Account");
                    VoucherAcc.SetRange("Account No.", GenJnlLine3."Account No.");
                    if not VoucherAcc.IsEmpty() then
                        AddError(StrSubstNo(CashAccNoVoucherDocNoLbl, GenJnlLine3."Bal. Account No.", BankVoucherType, GenJnlLine3."Document No."));
                end;

                if GenJnlLine3."Account Type" = GenJnlLine3."Account Type"::"Bank Account" then
                    AddError(StrSubstNo(AccTypeBankAccDocLbl, GenJnlLine3."Document No."));
            end;
        end;
    end;

    procedure IdentifyContraAccount(GenJnlLine2: Record "Gen. Journal Line")
    var
        VoucherAcc: Record "Voucher Posting Credit Account";
    begin
        if GenJnlLine2.Amount = 0 then
            exit;
        GenJnlLine3 := GenJnlLine2;
        if GenJnlLine3."Bal. Account No." <> '' then begin
            case GenJnlLine3."Bal. Account Type" of
                GenJnlLine3."Bal. Account Type"::"Bank Account":
                    begin
                        VoucherAcc.SetRange("Location code", GenJnlLine3."Location Code");
                        VoucherAcc.SetFilter(Type, '%1|%2', VoucherAcc.Type::"Bank Payment Voucher",
                          VoucherAcc.Type::"Bank Receipt Voucher");
                        VoucherAcc.SetRange("Account Type", GenJnlLine3."Bal. Account Type"::"Bank Account");
                        VoucherAcc.SetRange("Account No.", GenJnlLine3."Bal. Account No.");
                        if not VoucherAcc.FindFirst() then
                            AddError(StrSubstNo(AccBankAccLbl, GenJnlLine3."Bal. Account No.", 'Contra', GenJnlLine3."Document No."));
                    end;
                GenJnlLine3."Bal. Account Type"::"G/L Account":
                    begin
                        VoucherAcc.SetRange("Location code", GenJnlLine3."Location Code");
                        VoucherAcc.SetFilter(Type, '%1|%2', VoucherAcc.Type::"Cash Receipt Voucher",
                          VoucherAcc.Type::"Cash Payment Voucher");
                        VoucherAcc.SetRange("Account Type", GenJnlLine3."Bal. Account Type"::"G/L Account");
                        VoucherAcc.SetRange("Account No.", GenJnlLine3."Bal. Account No.");
                        if not VoucherAcc.FindFirst() then
                            AddError(StrSubstNo(AccNoCashAccLbl, GenJnlLine3."Bal. Account No.", 'Contra', GenJnlLine3."Document No."));
                    end
                else
                    AddError(StrSubstNo(BalAccTypeLbl, 'Contra', GenJnlLine3."Document No."));
            end;

            if GenJnlLine3."Account No." <> '' then
                case GenJnlLine3."Account Type" of
                    GenjnlLine3."Account Type"::"Bank Account":
                        begin
                            VoucherAcc.SetRange("Location code", GenJnlLine3."Location Code");
                            VoucherAcc.SetFilter(Type, '%1|%2', VoucherAcc.Type::"Bank Payment Voucher",
                              VoucherAcc.Type::"Bank Receipt Voucher");
                            VoucherAcc.SetRange("Account Type", GenJnlLine3."Account Type"::"Bank Account");
                            VoucherAcc.SetRange("Account No.", GenJnlLine3."Account No.");
                            if not VoucherAcc.FindFirst() then
                                AddError(StrSubstNo(AccBankAccLbl, GenJnlLine3."Account No.", 'Contra', GenJnlLine3."Document No."));
                        end;
                    GenJnlLine3."Account Type"::"G/L Account":
                        begin
                            VoucherAcc.SetRange("Location code", GenJnlLine3."Location Code");
                            VoucherAcc.SetFilter(Type, '%1|%2', VoucherAcc.Type::"Cash Receipt Voucher",
                              VoucherAcc.Type::"Cash Payment Voucher");
                            VoucherAcc.SetRange("Account Type", GenJnlLine3."Account Type"::"G/L Account");
                            VoucherAcc.SetRange("Account No.", GenJnlLine3."Account No.");
                            if VoucherAcc.IsEmpty() then
                                AddError(StrSubstNo(AccNoCashAccLbl, GenJnlLine3."Account No.", 'Contra', GenJnlLine3."Document No."));
                        end else
                                AddError(StrSubstNo(BalAccTypeLbl, 'Contra', GenJnlLine3."Document No."));
                end;
        end;
    end;

    procedure IdentifyJournalAccount(GenJnlLine2: Record "Gen. Journal Line")
    var
        VoucherAcc: Record "Voucher Posting Debit Account";
    begin
        if GenJnlLine2.Amount = 0 then
            exit;
        GenJnlLine3 := GenJnlLine2;
        if GenJnlLine3."Bal. Account No." <> '' then
            if GenJnlLine3."Bal. Account Type" = GenJnlLine3."Bal. Account Type"::"Bank Account" then
                AddError(StrSubstNo(BalAccDocNoLbl, GenJnlLine3."Document No."))
            else
                if GenJnlLine3."Bal. Account Type" = GenJnlLine3."Bal. Account Type"::"G/L Account" then begin
                    VoucherAcc.SetRange("Location code", GenJnlLine3."Location Code");
                    VoucherAcc.SetFilter(Type, '%1|%2', VoucherAcc.Type::"Cash Receipt Voucher",
                      VoucherAcc.Type::"Cash Payment Voucher");
                    VoucherAcc.SetRange("Account Type", GenJnlLine3."Bal. Account Type"::"G/L Account");
                    VoucherAcc.SetRange("Account No.", GenJnlLine3."Bal. Account No.");
                    if VoucherAcc.FindFirst() then
                        AddError(StrSubstNo(CashAccVoucherLbl, GenJnlLine3."Bal. Account No.", 'Journal', GenJnlLine3."Document No."));
                end;

        if GenJnlLine3."Account No." <> '' then
            if GenJnlLine3."Account Type" = GenJnlLine3."Account Type"::"Bank Account" then
                AddError(StrSubstNo(AccTypeBankAccDocLbl, GenJnlLine3."Document No."))
            else
                if GenJnlLine3."Account Type" = GenJnlLine3."Account Type"::"G/L Account" then begin
                    VoucherAcc.SetRange("Location code", GenJnlLine3."Location Code");
                    VoucherAcc.SetFilter(Type, '%1|%2', VoucherAcc.Type::"Cash Receipt Voucher",
                      VoucherAcc.Type::"Cash Payment Voucher");
                    VoucherAcc.SetRange("Account Type", GenJnlLine3."Account Type"::"G/L Account");
                    VoucherAcc.SetRange("Account No.", GenJnlLine3."Account No.");
                    if not VoucherAcc.IsEmpty() then
                        AddError(StrSubstNo(CashAccVoucherLbl, GenJnlLine3."Account No.", 'Journal', GenJnlLine3."Document No."));
                end;
    end;

    procedure CheckTDSAmount(var GenJnlLine: Record "Gen. Journal Line"): Boolean
    var
        GenJournalLine2: Record "Gen. Journal Line";
    begin
        GenJournalLine2.Reset();
        GenJournalLine2.SetRange("Journal Template Name", GenJnlLine."Journal Template Name");
        GenJournalLine2.SetRange("Journal Batch Name", GenJnlLine."Journal Batch Name");
        GenJournalLine2.SetRange("Document No.", GenJnlLine."Document No.");
        GenJournalLine2.SetFilter(Amount, '>0');
        exit(not GenJournalLine2.IsEmpty());
    end;

    procedure InitializeRequest(NewShowDim: Boolean)
    begin
        ShowDim := NewShowDim;
    end;

    local procedure CheckRecurringLine(GenJnlLine2: Record "Gen. Journal Line")
    begin
        if GenJnlTemplate.Recurring then begin
            if GenJnlLine2."Recurring Method" = GenJnlLine2."Recurring Method"::" " then
                AddError(StrSubstNo(Text002Lbl, GenJnlLine2.FieldCaption("Recurring Method")));
            if Format(GenJnlLine2."Recurring Frequency") = '' then
                AddError(StrSubstNo(Text002Lbl, GenJnlLine2.FieldCaption("Recurring Frequency")));
            if GenJnlLine2."Bal. Account No." <> '' then
                AddError(
                  StrSubstNo(
                    BalAccountNoCaptionLbl,
                    GenJnlLine2.FieldCaption(GenJnlLine2."Bal. Account No.")));
            case GenJnlLine2."Recurring Method" of
                GenJnlLine2."Recurring Method"::"V  Variable", GenJnlLine2."Recurring Method"::"RV Reversing Variable",
              GenJnlLine2."Recurring Method"::"F  Fixed", GenJnlLine2."Recurring Method"::"RF Reversing Fixed":
                    WarningIfZeroAmt("Gen. Journal Line");
                GenJnlLine2."Recurring Method"::"B  Balance", GenJnlLine2."Recurring Method"::"RB Reversing Balance":
                    WarningIfNonZeroAmt("Gen. Journal Line");
            end;
            if GenJnlLine2."Recurring Method" <> GenJnlLine2."Recurring Method"::"V  Variable" then begin
                if GenJnlLine2."Account Type" = GenJnlLine2."Account Type"::"Fixed Asset" then
                    AddError(
                      StrSubstNo(
                        RecurringMethodLbl,
                        GenJnlLine2.FieldCaption(GenJnlLine2."Recurring Method"), GenJnlLine2."Recurring Method",
                        GenJnlLine2.FieldCaption(GenJnlLine2."Account Type"), GenJnlLine2."Account Type"));
                if GenJnlLine2."Bal. Account Type" = GenJnlLine2."Bal. Account Type"::"Fixed Asset" then
                    AddError(
                      StrSubstNo(
                        RecurringMethodLbl,
                        GenJnlLine2.FieldCaption("Recurring Method"), GenJnlLine2."Recurring Method",
                        GenJnlLine2.FieldCaption("Bal. Account Type"), GenJnlLine2."Bal. Account Type"));
            end;
        end else begin
            if GenJnlLine2."Recurring Method" <> GenJnlLine2."Recurring Method"::" " then
                AddError(StrSubstNo(SpecifiedLbl, GenJnlLine2.FieldCaption(GenJnlLine2."Recurring Method")));
            if Format(GenJnlLine2."Recurring Frequency") <> '' then
                AddError(StrSubstNo(SpecifiedLbl, GenJnlLine2.FieldCaption(GenJnlLine2."Recurring Frequency")));
        end;
    end;

    local procedure CheckAllocations(GenJnlLine2: Record "Gen. Journal Line")
    begin
        if GenJnlLine2."Recurring Method" in
           [GenJnlLine2."Recurring Method"::"B  Balance",
            GenJnlLine2."Recurring Method"::"RB Reversing Balance"]
        then begin
            GenJnlAlloc.Reset();
            GenJnlAlloc.SetRange("Journal Template Name", GenJnlLine2."Journal Template Name");
            GenJnlAlloc.SetRange("Journal Batch Name", GenJnlLine2."Journal Batch Name");
            GenJnlAlloc.SetRange("Journal Line No.", GenJnlLine2."Line No.");
            if not GenJnlAlloc.FindFirst() then
                AddError(Text061Lbl);
        end;

        GenJnlAlloc.Reset();
        GenJnlAlloc.SetRange("Journal Template Name", GenJnlLine2."Journal Template Name");
        GenJnlAlloc.SetRange("Journal Batch Name", GenJnlLine2."Journal Batch Name");
        GenJnlAlloc.SetRange("Journal Line No.", GenJnlLine2."Line No.");
        GenJnlAlloc.SetFilter(Amount, '<>0');
        if GenJnlAlloc.FindFirst() then
            if not GenJnlTemplate.Recurring then
                AddError(RecurringErrLbl)
            else begin
                GenJnlAlloc.SetRange("Account No.", '');
                if GenJnlAlloc.FindFirst() then
                    AddError(
                      StrSubstNo(
                        GenJnlAllocLbl,
                        GenJnlAlloc.FieldCaption("Account No."), GenJnlAlloc.Count));
            end;
    end;

    local procedure MakeRecurringTexts(var GenJnlLine2: Record "Gen. Journal Line")
    begin
        if (GenJnlLine2."Posting Date" <> 0D) and (GenJnlLine2."Account No." <> '') and (GenJnlLine2."Recurring Method" <> GenJnlLine2."Recurring Method"::" ") then begin
            Day := Date2DMY(GenJnlLine2."Posting Date", 1);
            Week := Date2DWY(GenJnlLine2."Posting Date", 2);
            Month := Date2DMY(GenJnlLine2."Posting Date", 2);
            MonthText := Format(GenJnlLine2."Posting Date", 0, MonthTextLbl);
            AccountingPeriod.SetRange("Starting Date", 0D, GenJnlLine2."Posting Date");
            if not AccountingPeriod.FindLast() then
                AccountingPeriod.Name := '';
            GenJnlLine2."Document No." :=
              Format(DelChr(
                PadStr(
                  StrSubstNo(Format(GenJnlLine2."Document No."), Day, Week, Month, MonthText, AccountingPeriod.Name),
                  MaxStrLen(GenJnlLine2."Document No.")),
                '>'));
            GenJnlLine2.Description :=
              Format(DelChr(
                PadStr(
                  StrSubstNo(Format(GenJnlLine2.Description), Day, Week, Month, MonthText, AccountingPeriod.Name),
                  MaxStrLen(GenJnlLine2.Description)),
                '>'));
        end;
    end;

    local procedure CheckBalance()
    var
        GenJnlLine: Record "Gen. Journal Line";
        NextGenJnlLine: Record "Gen. Journal Line";
        RecordCount: Integer;
    begin
        GenJnlLine := "Gen. Journal Line";
        LastLineNo := "Gen. Journal Line"."Line No.";
        NextGenJnlLine := "Gen. Journal Line";
        RecordCount := NextGenJnlLine.Count;
        k := k + 1;
        if RecordCount = k then
            MakeRecurringTexts(NextGenJnlLine);

        if not GenJnlLine.EmptyLine() then begin
            DocBalance := DocBalance + GenJnlLine."Balance (LCY)";
            DateBalance := DateBalance + GenJnlLine."Balance (LCY)";
            TotalBalance := TotalBalance + GenJnlLine."Balance (LCY)";

            if GenJnlLine."Recurring Method".AsInteger() >= GenJnlLine."Recurring Method"::"RF Reversing Fixed".AsInteger() then begin
                DocBalanceReverse := DocBalanceReverse + GenJnlLine."Balance (LCY)";
                DateBalanceReverse := DateBalanceReverse + GenJnlLine."Balance (LCY)";
                TotalBalanceReverse := TotalBalanceReverse + GenJnlLine."Balance (LCY)";
            end;

            LastDocType := GenJnlLine."Document Type";
            LastDocNo := GenJnlLine."Document No.";
            LastDate := GenJnlLine."Posting Date";
            if TotalBalance = 0 then
                VATEntryCreated := false;
            if GenJnlTemplate."Force Doc. Balance" then begin
                VATEntryCreated :=
                  VATEntryCreated or
                  ((GenJnlLine."Account Type" = GenJnlLine."Account Type"::"G/L Account") and (GenJnlLine."Account No." <> '') and
                   (GenJnlLine."Gen. Posting Type" in [GenJnlLine."Gen. Posting Type"::Purchase, GenJnlLine."Gen. Posting Type"::Sale])) or
                  ((GenJnlLine."Bal. Account Type" = "Bal. Account Type"::"G/L Account") and (GenJnlLine."Bal. Account No." <> '') and
                   (GenJnlLine."Bal. Gen. Posting Type" in [GenJnlLine."Bal. Gen. Posting Type"::Purchase, GenJnlLine."Bal. Gen. Posting Type"::Sale]));
                TempGenJournalLineCustVendIC.IsCustVendICAdded(GenJnlLine);
                if (TempGenJournalLineCustVendIC.Count > 1) and VATEntryCreated then
                    AddError(
                      StrSubstNo(
                        GenJournalLineLbl,
                        GenJnlLine."Document Type", GenJnlLine."Document No.", GenJnlLine."Posting Date"));
            end;
        end;

        if (LastDate <> 0D) and (LastDocNo <> '') and
           ((NextGenJnlLine."Posting Date" <> LastDate) or
            (NextGenJnlLine."Document Type" <> LastDocType) or
            (NextGenJnlLine."Document No." <> LastDocNo) or
            (NextGenJnlLine."Line No." = LastLineNo))
        then begin
            if GenJnlTemplate."Force Doc. Balance" then begin
                case true of
                    DocBalance <> 0:
                        AddError(
                          StrSubstNo(
                            DocBalanceLbl,
                            SelectStr(LastDocType.AsInteger() + 1, DocTypeLbl), LastDocNo, DocBalance));
                    DocBalanceReverse <> 0:
                        AddError(
                          StrSubstNo(
                            DocBalanceReverseLbl,
                            SelectStr(LastDocType.AsInteger() + 1, DocTypeLbl), LastDocNo, DocBalanceReverse));
                end;
                DocBalance := 0;
                DocBalanceReverse := 0;
            end;
            if (NextGenJnlLine."Posting Date" <> LastDate) or
               (NextGenJnlLine."Document Type" <> LastDocType) or (NextGenJnlLine."Document No." <> LastDocNo)
            then begin
                TempGenJournalLineCustVendIC.Reset();
                TempGenJournalLineCustVendIC.DeleteAll();
                VATEntryCreated := false;
                CustPosting := false;
                VendPosting := false;
                SalesPostingType := false;
                PurchPostingType := false;
            end;
        end;

        if (LastDate <> 0D) and ((NextGenJnlLine."Posting Date" <> LastDate) or (NextGenJnlLine."Line No." = LastLineNo)) then begin
            case true of
                DateBalance <> 0:
                    AddError(
                      StrSubstNo(
                        DateBalanceLbl,
                        LastDate, DateBalance));
                DateBalanceReverse <> 0:
                    AddError(
                      StrSubstNo(
                        LastDateBalanceReverseLbl,
                        LastDate, DateBalanceReverse));
            end;
            DocBalance := 0;
            DocBalanceReverse := 0;
            DateBalance := 0;
            DateBalanceReverse := 0;
        end;

        if NextGenJnlLine."Line No." = LastLineNo then begin
            case true of
                TotalBalance <> 0:
                    AddError(
                      StrSubstNo(
                        TotalBalanceLbl,
                        TotalBalance));
                TotalBalanceReverse <> 0:
                    AddError(
                      StrSubstNo(
                        TotalBalanceReverseLbl,
                        TotalBalanceReverse));
            end;
            DocBalance := 0;
            DocBalanceReverse := 0;
            DateBalance := 0;
            DateBalanceReverse := 0;
            TotalBalance := 0;
            TotalBalanceReverse := 0;
            LastDate := 0D;
            LastDocType := LastDocType::" ";
            LastDocNo := '';
        end;
    end;

    local procedure AddError(Text: Text[250])
    begin
        ErrorCounter := ErrorCounter + 1;
        ErrorText[ErrorCounter] := Text;
    end;

    local procedure ReconcileGLAccNo(GLAccNo: Code[20]; ReconcileAmount: Decimal)
    begin
        if not TempGLAccNetChange.Get(GLAccNo) then begin
            GLAccount.Get(GLAccNo);
            GLAccount.CalcFields("Balance at Date");
            TempGLAccNetChange.Init();
            TempGLAccNetChange."No." := GLAccount."No.";
            TempGLAccNetChange.Name := GLAccount.Name;
            TempGLAccNetChange."Balance after Posting" := GLAccount."Balance at Date";
            TempGLAccNetChange.Insert();
        end;
        TempGLAccNetChange."Net Change in Jnl." := TempGLAccNetChange."Net Change in Jnl." + ReconcileAmount;
        TempGLAccNetChange."Balance after Posting" := TempGLAccNetChange."Balance after Posting" + ReconcileAmount;
        TempGLAccNetChange.Modify();
    end;

    local procedure CheckGLAcc(var GenJnlLine: Record "Gen. Journal Line"; var AccName: Text[100])
    begin
        if not GLAccount.Get(GenJnlLine."Account No.") then
            AddError(
              StrSubstNo(
                TableCaptionLbl,
                GLAccount.TableCaption, GenJnlLine."Account No."))
        else begin
            AccName := GLAccount.Name;

            if GLAccount.Blocked then
                AddError(
                  StrSubstNo(
                    TableFieldLbl,
                    GLAccount.FieldCaption(Blocked), false, GLAccount.TableCaption, GenJnlLine."Account No."));
            if GLAccount."Account Type" <> GLAccount."Account Type"::Posting then begin
                GLAccount."Account Type" := GLAccount."Account Type"::Posting;
                AddError(
                  StrSubstNo(
                    TableFieldLbl,
                    GLAccount.FieldCaption("Account Type"), GLAccount."Account Type", GLAccount.TableCaption, GenJnlLine."Account No."));
            end;
            if not GenJnlLine."System-Created Entry" then
                if GenJnlLine."Posting Date" = NormalDate(GenJnlLine."Posting Date") then
                    if not GLAccount."Direct Posting" then
                        AddError(
                          StrSubstNo(
                            TableFieldLbl,
                            GLAccount.FieldCaption("Direct Posting"), true, GLAccount.TableCaption, GenJnlLine."Account No."));

            if GenJnlLine."Gen. Posting Type" <> GenJnlLine."Gen. Posting Type"::" " then begin
                case GenJnlLine."Gen. Posting Type" of
                    GenJnlLine."Gen. Posting Type"::Sale:
                        SalesPostingType := true;
                    GenJnlLine."Gen. Posting Type"::Purchase:
                        PurchPostingType := true;
                end;
                TestPostingType();

                if not VATPostingSetup.Get(GenJnlLine."VAT Bus. Posting Group", GenJnlLine."VAT Prod. Posting Group") then
                    AddError(
                      StrSubstNo(
                        VATPostingLbl,
                        VATPostingSetup.TableCaption, GenJnlLine."VAT Bus. Posting Group", GenJnlLine."VAT Prod. Posting Group"))
                else
                    if GenJnlLine."VAT Calculation Type" <> VATPostingSetup."VAT Calculation Type" then
                        AddError(
                          StrSubstNo(
                            VATCalculationLbl,
                            GenJnlLine.FieldCaption(GenJnlLine."VAT Calculation Type"), VATPostingSetup."VAT Calculation Type"))
            end;

            if GLAccount."Reconciliation Account" then
                ReconcileGLAccNo(GenJnlLine."Account No.", Round((GenJnlLine."Amount (LCY)")) /
                  (1 + GenJnlLine."VAT %" / 100));
        end;
    end;

    local procedure CheckCust(var GenJnlLine: Record "Gen. Journal Line"; var AccName: Text[100])
    begin
        if not Cust.Get(GenJnlLine."Account No.") then
            AddError(
              StrSubstNo(
                TableCaptionLbl,
                Cust.TableCaption, GenJnlLine."Account No."))
        else begin
            AccName := Cust.Name;
            if Cust."Privacy Blocked" then
                AddError(Cust.GetPrivacyBlockedGenericErrorText(Cust));
            if ((Cust.Blocked = Cust.Blocked::All) or
                ((Cust.Blocked = Cust.Blocked::Invoice) and
                 (GenJnlLine."Document Type" in [GenJnlLine."Document Type"::Invoice, GenJnlLine."Document Type"::" "]))
                )
            then
                AddError(
                  StrSubstNo(
                    CustBlockLbl,
                    GenJnlLine."Account Type", Cust.Blocked, GenJnlLine.FieldCaption(GenJnlLine."Document Type"), GenJnlLine."Document Type"));
            if GenJnlLine."Currency Code" <> '' then
                if not Currency.Get(GenJnlLine."Currency Code") then
                    AddError(
                      StrSubstNo(
                        CurrencyCodeLbl,
                        GenJnlLine."Currency Code"));
            if (Cust."IC Partner Code" <> '') and (GenJnlTemplate.Type = GenJnlTemplate.Type::Intercompany) then
                if ICPartner.Get(Cust."IC Partner Code") then begin
                    if ICPartner.Blocked then
                        AddError(
                          StrSubstNo(
                            ICPartnerLbl,
                            StrSubstNo(
                              ICPartnerBlockedLbl,
                              Cust.TableCaption, GenJnlLine."Account No.", ICPartner.TableCaption, GenJnlLine."IC Partner Code"),
                            StrSubstNo(
                              TableFieldLbl,
                              ICPartner.FieldCaption(Blocked), false, ICPartner.TableCaption, Cust."IC Partner Code")));
                end else
                    AddError(
                      StrSubstNo(
                        ICPartnerDetailLbl,
                        StrSubstNo(
                          ICPartnerBlockedLbl,
                          Cust.TableCaption, GenJnlLine."Account No.", ICPartner.TableCaption, Cust."IC Partner Code"),
                        StrSubstNo(
                          TableCaptionLbl,
                          ICPartner.TableCaption, Cust."IC Partner Code")));
            CustPosting := true;
            TestPostingType();

            if GenJnlLine."Recurring Method" = GenJnlLine."Recurring Method"::" " then
                if GenJnlLine."Document Type" in
                   [GenJnlLine."Document Type"::Invoice, GenJnlLine."Document Type"::"Credit Memo",
                    GenJnlLine."Document Type"::"Finance Charge Memo", GenJnlLine."Document Type"::Reminder]
                then begin
                    OldCustLedgEntry.Reset();
                    OldCustLedgEntry.SetCurrentKey("Document No.");
                    OldCustLedgEntry.SetRange("Document Type", GenJnlLine."Document Type");
                    OldCustLedgEntry.SetRange("Document No.", GenJnlLine."Document No.");
                    if OldCustLedgEntry.FindFirst() then
                        AddError(
                          StrSubstNo(
                            SalesDocumentLbl, GenJnlLine."Document Type", GenJnlLine."Document No."));

                    if SalesSetup."Ext. Doc. No. Mandatory" or
                       (GenJnlLine."External Document No." <> '')
                    then begin
                        if GenJnlLine."External Document No." = '' then
                            AddError(
                              StrSubstNo(
                                ExternalDocumentNoLbl, GenJnlLine.FieldCaption(GenJnlLine."External Document No.")));

                        OldCustLedgEntry.Reset();
                        OldCustLedgEntry.SetCurrentKey("External Document No.");
                        OldCustLedgEntry.SetRange("Document Type", GenJnlLine."Document Type");
                        OldCustLedgEntry.SetRange("Customer No.", GenJnlLine."Account No.");
                        OldCustLedgEntry.SetRange("External Document No.", GenJnlLine."External Document No.");
                        if OldCustLedgEntry.FindFirst() then
                            AddError(
                              StrSubstNo(
                                SalesDocumentLbl,
                                GenJnlLine."Document Type", GenJnlLine."External Document No."));
                        CheckAgainstPrevLines("Gen. Journal Line");
                    end;
                end;
        end;
    end;

    local procedure CheckVend(var GenJnlLine: Record "Gen. Journal Line"; var AccName: Text[100])
    begin
        if not Vend.Get(GenJnlLine."Account No.") then
            AddError(
              StrSubstNo(
                TableCaptionLbl,
                Vend.TableCaption, GenJnlLine."Account No."))
        else begin
            AccName := Vend.Name;
            if Vend."Privacy Blocked" then
                AddError(Vend.GetPrivacyBlockedGenericErrorText(Vend));
            if ((Vend.Blocked = Vend.Blocked::All) or
                ((Vend.Blocked = Vend.Blocked::Payment) and (GenJnlLine."Document Type" = GenJnlLine."Document Type"::Payment))
                )
            then
                AddError(
                  StrSubstNo(
                    VendBlockLbl,
                    GenJnlLine."Account Type", Vend.Blocked, GenJnlLine.FieldCaption(GenJnlLine."Document Type"), GenJnlLine."Document Type"));
            if GenJnlLine."Currency Code" <> '' then
                if not Currency.Get(GenJnlLine."Currency Code") then
                    AddError(
                      StrSubstNo(
                        CurrencyCodeLbl,
                        GenJnlLine."Currency Code"));
            if (Vend."IC Partner Code" <> '') and (GenJnlTemplate.Type = GenJnlTemplate.Type::Intercompany) then
                if ICPartner.Get(Vend."IC Partner Code") then begin
                    if ICPartner.Blocked then
                        AddError(
                          StrSubstNo(
                            ICPartnerLbl,
                            StrSubstNo(
                              ICPartnerBlockedLbl,
                              Vend.TableCaption, GenJnlLine."Account No.", ICPartner.TableCaption, Vend."IC Partner Code"),
                            StrSubstNo(
                              TableFieldLbl,
                              ICPartner.FieldCaption(Blocked), false, ICPartner.TableCaption, Vend."IC Partner Code")));
                end else
                    AddError(
                      StrSubstNo(
                        ICPartnerDetailLbl,
                        StrSubstNo(
                          ICPartnerBlockedLbl,
                          Vend.TableCaption, GenJnlLine."Account No.", ICPartner.TableCaption, GenJnlLine."IC Partner Code"),
                        StrSubstNo(
                          TableCaptionLbl,
                          ICPartner.TableCaption, Vend."IC Partner Code")));
            VendPosting := true;
            TestPostingType();

            if GenJnlLine."Recurring Method" = GenJnlLine."Recurring Method"::" " then
                if GenJnlLine."Document Type" in
                   [GenJnlLine."Document Type"::Invoice, GenJnlLine."Document Type"::"Credit Memo",
                    GenJnlLine."Document Type"::"Finance Charge Memo", GenJnlLine."Document Type"::Reminder]
                then begin
                    OldVendLedgEntry.Reset();
                    OldVendLedgEntry.SetCurrentKey("Document No.");
                    OldVendLedgEntry.SetRange("Document Type", GenJnlLine."Document Type");
                    OldVendLedgEntry.SetRange("Document No.", GenJnlLine."Document No.");
                    if OldVendLedgEntry.FindFirst() then
                        AddError(
                          StrSubstNo(
                            PurchaseDocumentLbl,
                           GenJnlLine."Document Type", GenJnlLine."Document No."));

                    if PurchSetup."Ext. Doc. No. Mandatory" or
                       (GenJnlLine."External Document No." <> '')
                    then begin
                        if GenJnlLine."External Document No." = '' then
                            AddError(
                              StrSubstNo(
                                ExternalDocumentNoLbl, GenJnlLine.FieldCaption(GenJnlLine."External Document No.")));

                        OldVendLedgEntry.Reset();
                        OldVendLedgEntry.SetCurrentKey("External Document No.");
                        if OldVendLedgEntry.FindFirst() then
                            AddError(
                              StrSubstNo(
                                PurchaseDocumentLbl,
                                GenJnlLine."Document Type", GenJnlLine."External Document No."));
                        CheckAgainstPrevLines("Gen. Journal Line");
                    end;
                end;
        end;
    end;

    local procedure CheckBankAcc(var GenJnlLine: Record "Gen. Journal Line"; var AccName: Text[100])
    begin
        if not BankAcc.Get(GenJnlLine."Account No.") then
            AddError(
              StrSubstNo(
                TableCaptionLbl,
                BankAcc.TableCaption, GenJnlLine."Account No."))
        else begin
            AccName := BankAcc.Name;

            if BankAcc.Blocked then
                AddError(
                  StrSubstNo(
                    TableFieldLbl,
                    BankAcc.FieldCaption(Blocked), false, BankAcc.TableCaption, GenJnlLine."Account No."));
            if (GenJnlLine."Currency Code" <> BankAcc."Currency Code") and (BankAcc."Currency Code" <> '') then
                AddError(
                  StrSubstNo(
                    VATCalculationLbl,
                    GenJnlLine.FieldCaption(GenJnlLine."Currency Code"), BankAcc."Currency Code"));

            if GenJnlLine."Currency Code" <> '' then
                if not Currency.Get(GenJnlLine."Currency Code") then
                    AddError(
                      StrSubstNo(
                        CurrencyCodeLbl,
                        GenJnlLine."Currency Code"));
            if GenJnlLine."Bank Payment Type" <> GenJnlLine."Bank Payment Type"::" " then
                if (GenJnlLine."Bank Payment Type" = "Bank Payment Type"::"Computer Check") and (GenJnlLine.Amount < 0) then
                    if BankAcc."Currency Code" <> GenJnlLine."Currency Code" then
                        AddError(
                          StrSubstNo(
                            BankAccCurrencyLbl,
                            GenJnlLine.FieldCaption(GenJnlLine."Bank Payment Type"), GenJnlLine.FieldCaption("Currency Code"),
                            GenJnlLine.TableCaption, BankAcc.TableCaption));

            if BankAccPostingGr.Get(BankAcc."Bank Acc. Posting Group") then
                if BankAccPostingGr."G/L Account No." <> '' then
                    ReconcileGLAccNo(
                      BankAccPostingGr."G/L Account No.",
                      Round((GenJnlLine."Amount (LCY)")));
        end;
    end;

    local procedure CheckFixedAsset(var GenJnlLine: Record "Gen. Journal Line"; var AccName: Text[100])
    begin
        if not FA.Get(GenJnlLine."Account No.") then
            AddError(
              StrSubstNo(
                TableCaptionLbl,
                FA.TableCaption, GenJnlLine."Account No."))
        else begin
            AccName := FA.Description;
            if FA.Blocked then
                AddError(
                  StrSubstNo(
                    TableFieldLbl,
                    FA.FieldCaption(Blocked), false, FA.TableCaption, GenJnlLine."Account No."));
            if FA.Inactive then
                AddError(
                  StrSubstNo(
                    TableFieldLbl,
                    FA.FieldCaption(Inactive), false, FA.TableCaption, GenJnlLine."Account No."));
            if FA."Budgeted Asset" then
                AddError(
                  StrSubstNo(
                    FABudgetedAssetLbl,
                    FA.TableCaption, GenJnlLine."Account No.", FA.FieldCaption("Budgeted Asset"), true));
            if DeprBook.Get(GenJnlLine."Depreciation Book Code") then
                CheckFAIntegration(GenJnlLine)
            else
                AddError(
                  StrSubstNo(
                    TableCaptionLbl,
                    DeprBook.TableCaption, GenJnlLine."Depreciation Book Code"));
            if not FADeprBook.Get(FA."No.", GenJnlLine."Depreciation Book Code") then
                AddError(
                  StrSubstNo(
                    VATPostingLbl,
                    FADeprBook.TableCaption, FA."No.", GenJnlLine."Depreciation Book Code"));
        end;
    end;

    local procedure TestFixedAsset(var GenJnlLine: Record "Gen. Journal Line")
    begin

        if GenJnlLine."Job No." <> '' then
            AddError(
              StrSubstNo(
                JobNoLbl, GenJnlLine.FieldCaption(GenJnlLine."Job No.")));
        if GenJnlLine."FA Posting Type" = GenJnlLine."FA Posting Type"::" " then
            AddError(
              StrSubstNo(
                FieldCaptionLbl, GenJnlLine.FieldCaption(GenJnlLine."FA Posting Type")));
        if GenJnlLine."Depreciation Book Code" = '' then
            AddError(
              StrSubstNo(
                FieldCaptionLbl, GenJnlLine.FieldCaption(GenJnlLine."Depreciation Book Code")));
        if GenJnlLine."Depreciation Book Code" = GenJnlLine."Duplicate in Depreciation Book" then
            AddError(
              StrSubstNo(
                DepreciationBookLbl,
                GenJnlLine.FieldCaption(GenJnlLine."Depreciation Book Code"), GenJnlLine.FieldCaption(GenJnlLine."Duplicate in Depreciation Book")));
        CheckFADocNo(GenJnlLine);
        if GenJnlLine."Account Type" = GenJnlLine."Bal. Account Type" then
            AddError(
              StrSubstNo(
                BalAccountCaptionTypeLbl,
                GenJnlLine.FieldCaption("Account Type"), GenJnlLine.FieldCaption(GenJnlLine."Bal. Account Type"), GenJnlLine."Account Type"));
        if GenJnlLine."Account Type" = GenJnlLine."Account Type"::"Fixed Asset" then
            if GenJnlLine."FA Posting Type" in
               [GenJnlLine."FA Posting Type"::"Acquisition Cost", GenJnlLine."FA Posting Type"::Disposal, GenJnlLine."FA Posting Type"::Maintenance]
            then begin
                if (GenJnlLine."Gen. Bus. Posting Group" <> '') or (GenJnlLine."Gen. Prod. Posting Group" <> '') then
                    if GenJnlLine."Gen. Posting Type" = GenJnlLine."Gen. Posting Type"::" " then
                        AddError(StrSubstNo(Text002Lbl, GenJnlLine.FieldCaption("Gen. Posting Type")));
            end else begin
                if GenJnlLine."Gen. Posting Type" <> GenJnlLine."Gen. Posting Type"::" " then
                    AddError(
                      StrSubstNo(
                        PostingTypeLbl,
                        GenJnlLine.FieldCaption(GenJnlLine."Gen. Posting Type"), GenJnlLine.FieldCaption("FA Posting Type"), GenJnlLine."FA Posting Type"));
                if GenJnlLine."Gen. Bus. Posting Group" <> '' then
                    AddError(
                      StrSubstNo(
                        PostingTypeLbl,
                        GenJnlLine.FieldCaption(GenJnlLine."Gen. Bus. Posting Group"), GenJnlLine.FieldCaption("FA Posting Type"), GenJnlLine."FA Posting Type"));
                if GenJnlLine."Gen. Prod. Posting Group" <> '' then
                    AddError(
                      StrSubstNo(
                        PostingTypeLbl,
                        GenJnlLine.FieldCaption(GenJnlLine."Gen. Prod. Posting Group"), GenJnlLine.FieldCaption("FA Posting Type"), GenJnlLine."FA Posting Type"));
            end;
        if GenJnlLine."Bal. Account Type" = GenJnlLine."Bal. Account Type"::"Fixed Asset" then
            if GenJnlLine."FA Posting Type" in
               [GenJnlLine."FA Posting Type"::"Acquisition Cost", GenJnlLine."FA Posting Type"::Disposal, GenJnlLine."FA Posting Type"::Maintenance]
            then begin
                if (GenJnlLine."Bal. Gen. Bus. Posting Group" <> '') or (GenJnlLine."Bal. Gen. Prod. Posting Group" <> '') then
                    if GenJnlLine."Bal. Gen. Posting Type" = GenJnlLine."Bal. Gen. Posting Type"::" " then
                        AddError(StrSubstNo(Text002Lbl, GenJnlLine.FieldCaption("Bal. Gen. Posting Type")));
            end else begin
                if GenJnlLine."Bal. Gen. Posting Type" <> GenJnlLine."Bal. Gen. Posting Type"::" " then
                    AddError(
                      StrSubstNo(
                        PostingTypeLbl,
                        GenJnlLine.FieldCaption("Bal. Gen. Posting Type"), GenJnlLine.FieldCaption("FA Posting Type"), GenJnlLine."FA Posting Type"));
                if GenJnlLine."Bal. Gen. Bus. Posting Group" <> '' then
                    AddError(
                      StrSubstNo(
                        PostingTypeLbl,
                        GenJnlLine.FieldCaption("Bal. Gen. Bus. Posting Group"), GenJnlLine.FieldCaption("FA Posting Type"), GenJnlLine."FA Posting Type"));
                if GenJnlLine."Bal. Gen. Prod. Posting Group" <> '' then
                    AddError(
                      StrSubstNo(
                        PostingTypeLbl,
                        GenJnlLine.FieldCaption("Bal. Gen. Prod. Posting Group"), GenJnlLine.FieldCaption("FA Posting Type"), GenJnlLine."FA Posting Type"));
            end;
        TempErrorText :=
          '%1 ' +
          StrSubstNo(
            FAPostingTypeLbl,
            GenJnlLine.FieldCaption(GenJnlLine."FA Posting Type"), GenJnlLine."FA Posting Type");
        if GenJnlLine."FA Posting Type" <> GenJnlLine."FA Posting Type"::"Acquisition Cost" then begin
            if GenJnlLine."Depr. Acquisition Cost" then
                AddError(StrSubstNo(Format(TempErrorText), GenJnlLine.FieldCaption("Depr. Acquisition Cost")));
            if GenJnlLine."Salvage Value" <> 0 then
                AddError(StrSubstNo(Format(TempErrorText), GenJnlLine.FieldCaption("Salvage Value")));
            if GenJnlLine."FA Posting Type" <> GenJnlLine."FA Posting Type"::Maintenance then
                if GenJnlLine.Quantity <> 0 then
                    AddError(StrSubstNo(Format(TempErrorText), GenJnlLine.FieldCaption(Quantity)));
            if GenJnlLine."Insurance No." <> '' then
                AddError(StrSubstNo(Format(TempErrorText), GenJnlLine.FieldCaption("Insurance No.")));
        end;
        if (GenJnlLine."FA Posting Type" = GenJnlLine."FA Posting Type"::Maintenance) and GenJnlLine."Depr. until FA Posting Date" then
            AddError(StrSubstNo(Format(TempErrorText), GenJnlLine.FieldCaption(GenJnlLine."Depr. until FA Posting Date")));
        if (GenJnlLine."FA Posting Type" <> GenJnlLine."FA Posting Type"::Maintenance) and (GenJnlLine."Maintenance Code" <> '') then
            AddError(StrSubstNo(Format(TempErrorText), GenJnlLine.FieldCaption("Maintenance Code")));

        if (GenJnlLine."FA Posting Type" <> GenJnlLine."FA Posting Type"::Depreciation) and
           (GenJnlLine."FA Posting Type" <> GenJnlLine."FA Posting Type"::"Custom 1") and
           (GenJnlLine."No. of Depreciation Days" <> 0)
        then
            AddError(StrSubstNo(Format(TempErrorText), GenJnlLine.FieldCaption(GenJnlLine."No. of Depreciation Days")));

        if (GenJnlLine."FA Posting Type" = GenJnlLine."FA Posting Type"::Disposal) and GenJnlLine."FA Reclassification Entry" then
            AddError(StrSubstNo(Format(TempErrorText), GenJnlLine.FieldCaption(GenJnlLine."FA Reclassification Entry")));

        if (GenJnlLine."FA Posting Type" = GenJnlLine."FA Posting Type"::Disposal) and (GenJnlLine."Budgeted FA No." <> '') then
            AddError(StrSubstNo(Format(TempErrorText), GenJnlLine.FieldCaption("Budgeted FA No.")));

        if GenJnlLine."FA Posting Date" = 0D then
            GenJnlLine."FA Posting Date" := GenJnlLine."Posting Date";
        if DeprBook.Get(GenJnlLine."Depreciation Book Code") then
            if DeprBook."Use Same FA+G/L Posting Dates" and (GenJnlLine."Posting Date" <> GenJnlLine."FA Posting Date") then
                AddError(
                  StrSubstNo(
                    FAPostingDateLbl,
                    GenJnlLine.FieldCaption(GenJnlLine."Posting Date"), GenJnlLine.FieldCaption(GenJnlLine."FA Posting Date")));
        if GenJnlLine."FA Posting Date" <> 0D then begin
            if GenJnlLine."FA Posting Date" <> NormalDate(GenJnlLine."FA Posting Date") then
                AddError(
                  StrSubstNo(
                    ClosingDateLbl,
                    GenJnlLine.FieldCaption(GenJnlLine."FA Posting Date")));
            if (AllowFAPostingFrom = 0D) and (AllowFAPostingTo = 0D) then begin
                if UserId <> '' then
                    if UserSetup.Get(UserId) then begin
                        AllowFAPostingFrom := UserSetup."Allow FA Posting From";
                        AllowFAPostingTo := UserSetup."Allow FA Posting To";
                    end;
                if (AllowFAPostingFrom = 0D) and (AllowFAPostingTo = 0D) then begin
                    FASetup.Get();
                    AllowFAPostingFrom := FASetup."Allow FA Posting From";
                    AllowFAPostingTo := FASetup."Allow FA Posting To";
                end;
            end;
            if (GenJnlLine."FA Posting Date" < AllowFAPostingFrom) or
               (GenJnlLine."FA Posting Date" > AllowFAPostingTo)
            then
                AddError(
                  StrSubstNo(
                    FAPostingDateCaptionLbl,
                    GenJnlLine.FieldCaption(GenJnlLine."FA Posting Date")));
        end;
        FASetup.Get();
        if (GenJnlLine."FA Posting Type" = GenJnlLine."FA Posting Type"::"Acquisition Cost") and
           (GenJnlLine."Insurance No." <> '') and (GenJnlLine."Depreciation Book Code" <> FASetup."Insurance Depr. Book")
        then
            AddError(
              StrSubstNo(
                InsuranceLbl,
                GenJnlLine.FieldCaption("Depreciation Book Code"), GenJnlLine."Depreciation Book Code"));

        if GenJnlLine."FA Error Entry No." > 0 then begin
            TempErrorText :=
              '%1 ' +
              StrSubstNo(
                FAErrorLbl,
                GenJnlLine.FieldCaption("FA Error Entry No."));
            if GenJnlLine."Depr. until FA Posting Date" then
                AddError(StrSubstNo(Format(TempErrorText), GenJnlLine.FieldCaption(GenJnlLine."Depr. until FA Posting Date")));
            if GenJnlLine."Depr. Acquisition Cost" then
                AddError(StrSubstNo(Format(TempErrorText), GenJnlLine.FieldCaption(GenJnlLine."Depr. Acquisition Cost")));
            if GenJnlLine."Duplicate in Depreciation Book" <> '' then
                AddError(StrSubstNo(Format(TempErrorText), GenJnlLine.FieldCaption(GenJnlLine."Duplicate in Depreciation Book")));
            if GenJnlLine."Use Duplication List" then
                AddError(StrSubstNo(Format(TempErrorText), GenJnlLine.FieldCaption(GenJnlLine."Use Duplication List")));
            if GenJnlLine."Salvage Value" <> 0 then
                AddError(StrSubstNo(Format(TempErrorText), GenJnlLine.FieldCaption(GenJnlLine."Salvage Value")));
            if GenJnlLine."Insurance No." <> '' then
                AddError(StrSubstNo(Format(TempErrorText), GenJnlLine.FieldCaption(GenJnlLine."Insurance No.")));
            if GenJnlLine."Budgeted FA No." <> '' then
                AddError(StrSubstNo(Format(TempErrorText), GenJnlLine.FieldCaption(GenJnlLine."Budgeted FA No.")));
            if GenJnlLine."Recurring Method" <> GenJnlLine."Recurring Method"::" " then
                AddError(StrSubstNo(Format(TempErrorText), GenJnlLine.FieldCaption(GenJnlLine."Recurring Method")));
            if GenJnlLine."FA Posting Type" = GenJnlLine."FA Posting Type"::Maintenance then
                AddError(StrSubstNo(Format(TempErrorText), GenJnlLine."FA Posting Type"));
        end;
    end;

    local procedure CheckFAIntegration(var GenJnlLine: Record "Gen. Journal Line")
    var
        GLIntegration: Boolean;
    begin
        if GenJnlLine."FA Posting Type" = GenJnlLine."FA Posting Type"::" " then
            exit;
        case GenJnlLine."FA Posting Type" of
            GenJnlLine."FA Posting Type"::"Acquisition Cost":
                GLIntegration := DeprBook."G/L Integration - Acq. Cost";
            GenJnlLine."FA Posting Type"::Depreciation:
                GLIntegration := DeprBook."G/L Integration - Depreciation";
            GenJnlLine."FA Posting Type"::"Write-Down":
                GLIntegration := DeprBook."G/L Integration - Write-Down";
            GenJnlLine."FA Posting Type"::Appreciation:
                GLIntegration := DeprBook."G/L Integration - Appreciation";
            GenJnlLine."FA Posting Type"::"Custom 1":
                GLIntegration := DeprBook."G/L Integration - Custom 1";
            GenJnlLine."FA Posting Type"::"Custom 2":
                GLIntegration := DeprBook."G/L Integration - Custom 2";
            GenJnlLine."FA Posting Type"::Disposal:
                GLIntegration := DeprBook."G/L Integration - Disposal";
            GenJnlLine."FA Posting Type"::Maintenance:
                GLIntegration := DeprBook."G/L Integration - Maintenance";
        end;
        if not GLIntegration then
            AddError(
              StrSubstNo(
                GLIntegrationLbl,
                GenJnlLine."FA Posting Type"));

        if not DeprBook."G/L Integration - Depreciation" then begin
            if GenJnlLine."Depr. until FA Posting Date" then
                AddError(
                  StrSubstNo(
                    Text057Lbl,
                    GenJnlLine.FieldCaption(GenJnlLine."Depr. until FA Posting Date")));
            if GenJnlLine."Depr. Acquisition Cost" then
                AddError(
                  StrSubstNo(
                    Text057Lbl,
                    GenJnlLine.FieldCaption(GenJnlLine."Depr. Acquisition Cost")));
        end;
    end;

    local procedure TestFixedAssetFields(var GenJnlLine: Record "Gen. Journal Line")
    begin
        if GenJnlLine."FA Posting Type" <> GenJnlLine."FA Posting Type"::" " then
            AddError(StrSubstNo(FAPostingLbl, GenJnlLine.FieldCaption(GenJnlLine."FA Posting Type")));
        if GenJnlLine."Depreciation Book Code" <> '' then
            AddError(StrSubstNo(FAPostingLbl, GenJnlLine.FieldCaption(GenJnlLine."Depreciation Book Code")));
    end;

    local procedure WarningIfNegativeAmt(GenJnlLine: Record "Gen. Journal Line")
    begin
        if (GenJnlLine.Amount < 0) and not AmountError then begin
            AmountError := true;
            AddError(StrSubstNo(PositiveLbl, GenJnlLine.FieldCaption(Amount)));
        end;
    end;

    local procedure WarningIfPositiveAmt(GenJnlLine: Record "Gen. Journal Line")
    begin
        if (GenJnlLine.Amount > 0) and not AmountError then begin
            AmountError := true;
            AddError(StrSubstNo(AmountNegtiveLbl, GenJnlLine.FieldCaption(Amount)));
        end;
    end;

    local procedure WarningIfZeroAmt(GenJnlLine: Record "Gen. Journal Line")
    begin
        if (GenJnlLine.Amount = 0) and not AmountError then begin
            AmountError := true;
            AddError(StrSubstNo(Text002Lbl, GenJnlLine.FieldCaption(Amount)));
        end;
    end;

    local procedure WarningIfNonZeroAmt(GenJnlLine: Record "Gen. Journal Line")
    begin
        if (GenJnlLine.Amount <> 0) and not AmountError then begin
            AmountError := true;
            AddError(StrSubstNo(AmountLbl, GenJnlLine.FieldCaption(Amount)));
        end;
    end;

    local procedure CheckAgainstPrevLines(GenJnlLine: Record "Gen. Journal Line")
    var
        i: Integer;
        AccType: Integer;
        AccNo: Code[20];
        ErrorFound: Boolean;
    begin
        ErrorFound := false;
        if (GenJnlLine."External Document No." = '') or
           not (GenJnlLine."Account Type" in
                [GenJnlLine."Account Type"::Customer, GenJnlLine."Account Type"::Vendor]) and
           not (GenJnlLine."Bal. Account Type" in
                [GenJnlLine."Bal. Account Type"::Customer, GenJnlLine."Bal. Account Type"::Vendor])
        then
            exit;

        if GenJnlLine."Account Type" in [GenJnlLine."Account Type"::Customer, GenJnlLine."Account Type"::Vendor] then begin
            AccType := GenJnlLine."Account Type".AsInteger();
            AccNo := GenJnlLine."Account No.";
        end else begin
            AccType := GenJnlLine."Bal. Account Type".AsInteger();
            AccNo := GenJnlLine."Bal. Account No.";
        end;

        TempGenJnlLine.Reset();
        TempGenJnlLine.SetRange("External Document No.", GenJnlLine."External Document No.");
        i := 0;
        while (i < 2) and not ErrorFound do begin
            i := i + 1;
            if i = 1 then begin
                TempGenJnlLine.SetRange("Account Type", AccType);
                TempGenJnlLine.SetRange("Account No.", AccNo);
                TempGenJnlLine.SetRange("Bal. Account Type");
                TempGenJnlLine.SetRange("Bal. Account No.");
            end else begin
                TempGenJnlLine.SetRange("Account Type");
                TempGenJnlLine.SetRange("Account No.");
                TempGenJnlLine.SetRange("Bal. Account Type", AccType);
                TempGenJnlLine.SetRange("Bal. Account No.", AccNo);
            end;
            if TempGenJnlLine.FindFirst() then begin
                ErrorFound := true;
                AddError(
                  StrSubstNo(
                    ExternalDocLbl, GenJnlLine.FieldCaption("External Document No."), GenJnlLine."External Document No.",
                    TempGenJnlLine."Line No.", GenJnlLine.FieldCaption("Document No."), TempGenJnlLine."Document No."));
            end;
        end;

        TempGenJnlLine.Reset();
        TempGenJnlLine := GenJnlLine;
        TempGenJnlLine.Insert();
    end;

    local procedure CheckFADocNo(GenJnlLine: Record "Gen. Journal Line")
    var
        FAJnlLine: Record "FA Journal Line";
        OldFALedgEntry: Record "FA Ledger Entry";
        OldMaintenanceLedgEntry: Record "Maintenance Ledger Entry";
        FANo: Code[20];
    begin
        if GenJnlLine."Account Type" = GenJnlLine."Account Type"::"Fixed Asset" then
            FANo := GenJnlLine."Account No.";
        if GenJnlLine."Bal. Account Type" = GenJnlLine."Bal. Account Type"::"Fixed Asset" then
            FANo := GenJnlLine."Bal. Account No.";
        if (FANo = '') or
           (GenJnlLine."FA Posting Type" = GenJnlLine."FA Posting Type"::" ") or
           (GenJnlLine."Depreciation Book Code" = '') or
           (GenJnlLine."Document No." = '')
        then
            exit;
        if not DeprBook.Get(GenJnlLine."Depreciation Book Code") then
            exit;
        if DeprBook."Allow Identical Document No." then
            exit;

        FAJnlLine."FA Posting Type" := GenJnlLine."FA Posting Type";
        if GenJnlLine."FA Posting Type" <> GenJnlLine."FA Posting Type"::Maintenance then begin
            OldFALedgEntry.SetCurrentKey(
              "FA No.", "Depreciation Book Code", "FA Posting Category", "FA Posting Type", "Document No.");
            OldFALedgEntry.SetRange("FA No.", FANo);
            OldFALedgEntry.SetRange("Depreciation Book Code", GenJnlLine."Depreciation Book Code");
            OldFALedgEntry.SetRange("FA Posting Category", OldFALedgEntry."FA Posting Category"::" ");
            OldFALedgEntry.SetRange("FA Posting Type", FAJnlLine.ConvertToLedgEntry(FAJnlLine));
            OldFALedgEntry.SetRange("Document No.", GenJnlLine."Document No.");
            if not OldFALedgEntry.IsEmpty() then
                AddError(
                  StrSubstNo(
                    DocumentNoLbl,
                    GenJnlLine.FieldCaption("Document No."), GenJnlLine."Document No."));
        end else begin
            OldMaintenanceLedgEntry.SetCurrentKey("FA No.", "Depreciation Book Code", "Document No.");
            OldMaintenanceLedgEntry.SetRange("FA No.", FANo);
            OldMaintenanceLedgEntry.SetRange("Depreciation Book Code", GenJnlLine."Depreciation Book Code");
            OldMaintenanceLedgEntry.SetRange("Document No.", GenJnlLine."Document No.");
            if not OldMaintenanceLedgEntry.IsEmpty() then
                AddError(
                  StrSubstNo(
                    DocumentNoLbl,
                    GenJnlLine.FieldCaption("Document No."), GenJnlLine."Document No."));
        end;
    end;

    local procedure GetDimensionText(var DimensionSetEntry: Record "Dimension Set Entry"): Text
    var
        DimensionText: Text;
        Separator: Code[10];
        DimValue: Text[45];
    begin
        Separator := '';
        DimValue := '';
        Continue := false;
        repeat
            DimValue := StrSubstNo(DimValueLbl, DimensionSetEntry."Dimension Code", DimensionSetEntry."Dimension Value Code");
            if MaxStrLen(DimensionText) < StrLen(DimensionText + Separator + DimValue) then begin
                Continue := true;
                exit(DimensionText);
            end;
            DimensionText := DimensionText + Separator + DimValue;
            Separator := '; ';
        until DimSetEntry.Next() = 0;
        exit(DimensionText);
    end;

    local procedure CheckAccountTypes(AccountType: Enum "Gen. Journal Account Type"; var Name: Text[100])
    begin
        case AccountType of
            AccountType::"G/L Account":
                CheckGLAcc("Gen. Journal Line", Name);
            AccountType::Customer:
                CheckCust("Gen. Journal Line", Name);
            AccountType::Vendor:
                CheckVend("Gen. Journal Line", Name);
            AccountType::"Bank Account":
                CheckBankAcc("Gen. Journal Line", Name);
            AccountType::"Fixed Asset":
                CheckFixedAsset("Gen. Journal Line", Name);
            AccountType::"IC Partner":
                CheckICPartner("Gen. Journal Line", Name);
        end;
    end;

    local procedure GetAccountTypes(AccountType: Enum "Gen. Journal Account Type"): Integer;
    begin
        case AccountType of
            AccountType::"G/L Account":
                exit(0);
            AccountType::Customer:
                exit(1);
            AccountType::Vendor:
                exit(2);
            AccountType::"Bank Account":
                exit(3);
            AccountType::"Fixed Asset":
                exit(4);
            AccountType::"IC Partner":
                exit(5);
        end;
    end;

    local procedure UpdateTaxComponents(
        RecordID: RecordID;
        TaxType: Code[20];
        var GSTComponentCode: array[20] of Integer;
        var GSTCompAmount: array[20] of Decimal): Decimal
    var
        TaxTrnasactionValue: Record "Tax Transaction Value";
        TaxTrnasactionValue1: Record "Tax Transaction Value";
        TotalAmount: Decimal;
    begin
        TaxTrnasactionValue.Reset();
        TaxTrnasactionValue.SetRange("Tax Record ID", RecordId);
        TaxTrnasactionValue.SetRange("Tax Type", TaxType);
        TaxTrnasactionValue.SetRange("Value Type", TaxTrnasactionValue."Value Type"::COMPONENT);
        TaxTrnasactionValue.SetFilter(Percent, '<>%1', 0);
        if TaxTrnasactionValue.FindSet() then
            repeat
                GSTComponentCode[TaxTrnasactionValue."Value ID"] := TaxTrnasactionValue."Value ID";

                TaxTrnasactionValue1.Reset();
                TaxTrnasactionValue1.SetRange("Tax Record ID", RecordId);
                TaxTrnasactionValue1.SetRange("Tax Type", TaxType);
                TaxTrnasactionValue1.SetRange("Value Type", TaxTrnasactionValue1."Value Type"::COMPONENT);
                TaxTrnasactionValue1.SetRange("Value ID", GSTComponentCode[TaxTrnasactionValue."Value ID"]);
                if TaxTrnasactionValue1.FindSet() then
                    repeat
                        GSTCompAmount[TaxTrnasactionValue."Value ID"] += TaxTrnasactionValue1.Amount;
                        TotalAmount += TaxTrnasactionValue1.Amount;
                    until TaxTrnasactionValue1.Next() = 0;
            until TaxTrnasactionValue.Next() = 0;
        exit(TotalAmount);
    end;

    local procedure GetGSTComponentNames(RecordId: RecordID; var GSTComponentCodeName: array[20] of Code[20])
    var
        TaxTrnasactionValue: Record "Tax Transaction Value";
    begin
        TaxTrnasactionValue.Reset();
        TaxTrnasactionValue.SetRange("Tax Record ID", RecordId);
        TaxTrnasactionValue.SetRange("Tax Type", 'GST');
        TaxTrnasactionValue.SetRange("Value Type", TaxTrnasactionValue."Value Type"::COMPONENT);
        TaxTrnasactionValue.SetFilter(Percent, '<>%1', 0);
        if TaxTrnasactionValue.FindSet() then
            repeat
                case TaxTrnasactionValue."Value ID" of
                    2:
                        GSTComponentCodeName[TaxTrnasactionValue."Value ID"] := 'CGST';
                    3:
                        GSTComponentCodeName[TaxTrnasactionValue."Value ID"] := 'IGST';
                    5:
                        GSTComponentCodeName[TaxTrnasactionValue."Value ID"] := 'UTGST';
                    6:
                        GSTComponentCodeName[TaxTrnasactionValue."Value ID"] := 'SGST';
                end;
            until TaxTrnasactionValue.Next() = 0;
    end;

    local procedure TestAccountTypeGLAccount(
        GenJnlLine: Record "Gen. Journal Line";
        GenJnlAllocation: Record "Gen. Jnl. Allocation")
    begin
        if GenJnlLine."Account Type" <> GenJnlLine."Account Type"::"G/L Account" then
            exit;

        if (GenJnlAllocation."Gen. Bus. Posting Group" <> '') or
            (GenJnlAllocation."Gen. Prod. Posting Group" <> '') or
            (GenJnlAllocation."VAT Bus. Posting Group" <> '') or
            (GenJnlAllocation."VAT Prod. Posting Group" <> '')
        then
            if GenJnlAllocation."Gen. Posting Type" = GenJnlAllocation."Gen. Posting Type"::" " then
                AddError(StrSubstNo(Text002Lbl, GenJnlAllocation.FieldCaption("Gen. Posting Type")));

        if (GenJnlAllocation."Gen. Posting Type" <> GenJnlAllocation."Gen. Posting Type"::" ") and
           (GenJnlLine."VAT Posting" = GenJnlLine."VAT Posting"::"Automatic VAT Entry")
        then begin
            if GenJnlAllocation."VAT Amount" + GenJnlLine."VAT Base Amount" <> GenJnlAllocation.Amount then
                AddError(
                  StrSubstNo(
                    VatAmountLbl,
                    GenJnlLine.FieldCaption("VAT Amount"),
                    GenJnlLine.FieldCaption("VAT Base Amount"),
                    GenJnlAllocation.FieldCaption(Amount)));

            if GenJnlLine."Currency Code" <> '' then
                if GenJnlLine."VAT Amount (LCY)" + GenJnlLine."VAT Base Amount (LCY)" <> GenJnlLine."Amount (LCY)" then
                    AddError(
                      StrSubstNo(
                        VatAmountLbl,
                        GenJnlLine.FieldCaption("VAT Amount (LCY)"),
                        GenJnlLine.FieldCaption("VAT Base Amount (LCY)"),
                        GenJnlLine.FieldCaption("Amount (LCY)")));
        end;

        TestJobFields(GenJnlLine);
    end;

    local procedure TestAccountTypeParty(
        GenJnlLine: Record "Gen. Journal Line";
        GenJnlAllocation: Record "Gen. Jnl. Allocation")
    begin
        if not (GenJnlLine."Account Type" in [GenJnlLine."Account Type"::Customer, GenJnlLine."Account Type"::Vendor]) then
            exit;

        if GenJnlAllocation."Gen. Posting Type" <> GenJnlAllocation."Gen. Posting Type"::" " then
            AddError(
              StrSubstNo(
                Text004Lbl,
                GenJnlAllocation.FieldCaption("Gen. Posting Type"),
                GenJnlLine.FieldCaption("Account Type"),
                GenJnlLine."Account Type"));

        if (GenJnlAllocation."Gen. Bus. Posting Group" <> '') or
            (GenJnlAllocation."Gen. Prod. Posting Group" <> '') or
            (GenJnlAllocation."VAT Bus. Posting Group" <> '') or
            (GenJnlAllocation."VAT Prod. Posting Group" <> '')
        then
            AddError(
              StrSubstNo(
                Text005Lbl,
                GenJnlAllocation.FieldCaption("Gen. Bus. Posting Group"),
                GenJnlAllocation.FieldCaption("Gen. Prod. Posting Group"),
                GenJnlAllocation.FieldCaption("VAT Bus. Posting Group"),
                GenJnlAllocation.FieldCaption("VAT Prod. Posting Group"),
                GenJnlLine.FieldCaption("Account Type"),
                GenJnlLine."Account Type"));

        if GenJnlLine."Document Type" <> GenJnlLine."Document Type"::" " then
            if GenJnlLine."Account Type" = GenJnlLine."Account Type"::Customer then
                case GenJnlLine."Document Type" of
                    GenJnlLine."Document Type"::"Credit Memo":
                        WarningIfPositiveAmt(GenJnlLine);
                    GenJnlLine."Document Type"::Payment:
                        if (GenJnlLine."Applies-to Doc. Type" = GenJnlLine."Applies-to Doc. Type"::"Credit Memo") and
                           (GenJnlLine."Applies-to Doc. No." <> '')
                        then
                            WarningIfNegativeAmt(GenJnlLine)
                        else
                            WarningIfPositiveAmt(GenJnlLine);
                    GenJnlLine."Document Type"::Refund:
                        WarningIfNegativeAmt(GenJnlLine);
                    else
                        WarningIfNegativeAmt(GenJnlLine);
                end
            else
                case GenJnlLine."Document Type" of
                    GenJnlLine."Document Type"::"Credit Memo":
                        WarningIfNegativeAmt(GenJnlLine);
                    GenJnlLine."Document Type"::Payment:
                        if (GenJnlLine."Applies-to Doc. Type" = GenJnlLine."Applies-to Doc. Type"::"Credit Memo") and
                           (GenJnlLine."Applies-to Doc. No." <> '')
                        then
                            WarningIfPositiveAmt(GenJnlLine)
                        else
                            WarningIfNegativeAmt(GenJnlLine);
                    GenJnlLine."Document Type"::Refund:
                        WarningIfPositiveAmt(GenJnlLine);
                    else
                        WarningIfPositiveAmt(GenJnlLine);
                end;

        if GenJnlAllocation.Amount * GenJnlLine."Sales/Purch. (LCY)" < 0 then
            AddError(
              StrSubstNo(
                AmountSignLbl,
                GenJnlLine.FieldCaption("Sales/Purch. (LCY)"),
                GenJnlAllocation.FieldCaption(Amount)));

        if GenJnlLine."Job No." <> '' then
            AddError(StrSubstNo(SpecifiedLbl, GenJnlLine.FieldCaption("Job No.")));
    end;

    local procedure TestAccountTypeBankAccount(
        GenJnlLine: Record "Gen. Journal Line";
        GenJnlAllocation: Record "Gen. Jnl. Allocation")
    begin
        if GenJnlLine."Account Type" <> GenJnlLine."Account Type"::"Bank Account" then
            exit;

        if GenJnlAllocation."Gen. Posting Type" <> GenJnlAllocation."Gen. Posting Type"::" " then
            AddError(
              StrSubstNo(
                Text004Lbl,
                GenJnlAllocation.FieldCaption("Gen. Posting Type"),
                GenJnlLine.FieldCaption("Account Type"),
                GenJnlLine."Account Type"));

        if (GenJnlAllocation."Gen. Bus. Posting Group" <> '') or
            (GenJnlAllocation."Gen. Prod. Posting Group" <> '') or
            (GenJnlAllocation."VAT Bus. Posting Group" <> '') or
            (GenJnlAllocation."VAT Prod. Posting Group" <> '')
        then
            AddError(
              StrSubstNo(
                Text005Lbl,
                GenJnlAllocation.FieldCaption("Gen. Bus. Posting Group"),
                GenJnlAllocation.FieldCaption("Gen. Prod. Posting Group"),
                GenJnlAllocation.FieldCaption("VAT Bus. Posting Group"),
                GenJnlAllocation.FieldCaption("VAT Prod. Posting Group"),
                GenJnlLine.FieldCaption("Account Type"),
                GenJnlLine."Account Type"));

        if GenJnlLine."Job No." <> '' then
            AddError(StrSubstNo(SpecifiedLbl, GenJnlLine.FieldCaption("Job No.")));

        if (GenJnlAllocation.Amount < 0) and
            (GenJnlLine."Bank Payment Type" = GenJnlLine."Bank Payment Type"::"Computer Check")
        then
            if not GenJnlLine."Check Printed" then
                AddError(StrSubstNo(CheckPrintLbl, GenJnlLine.FieldCaption("Check Printed")));
    end;

    local procedure TestBalAccTypeGLAccount(
        GenJnlLine: Record "Gen. Journal Line";
        GenJnlAllocation: Record "Gen. Jnl. Allocation")
    begin
        if GenJnlLine."Bal. Account Type" <> GenJnlLine."Bal. Account Type"::"G/L Account" then
            exit;

        if (GenJnlLine."Bal. Gen. Bus. Posting Group" <> '') or
            (GenJnlLine."Bal. Gen. Prod. Posting Group" <> '') or
            (GenJnlLine."Bal. VAT Bus. Posting Group" <> '') or
            (GenJnlLine."Bal. VAT Prod. Posting Group" <> '')
        then
            if GenJnlLine."Bal. Gen. Posting Type" = GenJnlAllocation."Gen. Posting Type"::" " then
                AddError(StrSubstNo(Text002Lbl, GenJnlLine.FieldCaption("Bal. Gen. Posting Type")));

        if (GenJnlLine."Bal. Gen. Posting Type" <> GenJnlLine."Bal. Gen. Posting Type"::" ") and
           (GenJnlLine."VAT Posting" = GenJnlLine."VAT Posting"::"Automatic VAT Entry")
        then begin
            if GenJnlLine."Bal. VAT Amount" + GenJnlLine."Bal. VAT Base Amount" <> -GenJnlAllocation.Amount then
                AddError(
                  StrSubstNo(
                    VatAmountCaptionLbl,
                    GenJnlLine.FieldCaption("Bal. VAT Amount"),
                    GenJnlLine.FieldCaption("Bal. VAT Base Amount"),
                    GenJnlAllocation.FieldCaption(Amount)));

            if GenJnlLine."Currency Code" <> '' then
                if GenJnlLine."Bal. VAT Amount (LCY)" + GenJnlLine."Bal. VAT Base Amount (LCY)" <> -GenJnlLine."Amount (LCY)" then
                    AddError(
                      StrSubstNo(
                        VatAmountCaptionLbl,
                        GenJnlLine.FieldCaption("Bal. VAT Amount (LCY)"),
                        GenJnlLine.FieldCaption("Bal. VAT Base Amount (LCY)"),
                        GenJnlLine.FieldCaption("Amount (LCY)")));
        end;
    end;

    local procedure TestBalAccTypeParty(
        GenJnlLine: Record "Gen. Journal Line";
        GenJnlAllocation: Record "Gen. Jnl. Allocation")
    begin
        if not (GenJnlLine."Bal. Account Type" in [GenJnlLine."Bal. Account Type"::Customer, GenJnlLine."Bal. Account Type"::Vendor]) then
            exit;

        if GenJnlLine."Bal. Gen. Posting Type" <> GenJnlLine."Bal. Gen. Posting Type"::" " then
            AddError(
              StrSubstNo(
                Text004Lbl,
                GenJnlLine.FieldCaption("Bal. Gen. Posting Type"),
                GenJnlLine.FieldCaption("Bal. Account Type"),
                GenJnlLine."Bal. Account Type"));

        if (GenJnlLine."Bal. Gen. Bus. Posting Group" <> '') or
            (GenJnlLine."Bal. Gen. Bus. Posting Group" <> '') or
            (GenJnlLine."Bal. VAT Bus. Posting Group" <> '') or
            (GenJnlLine."Bal. VAT Prod. Posting Group" <> '')
        then
            AddError(
              StrSubstNo(
                Text005Lbl,
                GenJnlLine.FieldCaption("Bal. Gen. Bus. Posting Group"),
                GenJnlLine.FieldCaption("Bal. Gen. Bus. Posting Group"),
                GenJnlLine.FieldCaption("Bal. VAT Bus. Posting Group"),
                GenJnlLine.FieldCaption("Bal. VAT Prod. Posting Group"),
                GenJnlLine.FieldCaption("Bal. Account Type"),
                GenJnlLine."Bal. Account Type"));

        if GenJnlLine."Document Type" <> GenJnlLine."Document Type"::" " then
            if (GenJnlLine."Bal. Account Type" = GenJnlLine."Bal. Account Type"::Customer) =
               (GenJnlLine."Document Type" in [GenJnlLine."Document Type"::Payment, GenJnlLine."Document Type"::"Credit Memo"])
            then
                WarningIfNegativeAmt(GenJnlLine)
            else
                WarningIfPositiveAmt(GenJnlLine);

        if GenJnlAllocation.Amount * GenJnlLine."Sales/Purch. (LCY)" > 0 then
            AddError(
              StrSubstNo(
                AmountCaptionLbl,
                GenJnlLine.FieldCaption("Sales/Purch. (LCY)"),
                GenJnlAllocation.FieldCaption(Amount)));

        if GenJnlLine."Job No." <> '' then
            AddError(StrSubstNo(SpecifiedLbl, GenJnlLine.FieldCaption("Job No.")));
    end;

    local procedure TestBalAccTypeBankAccount(
        GenJnlLine: Record "Gen. Journal Line";
        GenJnlAllocation: Record "Gen. Jnl. Allocation")
    begin
        if GenJnlLine."Bal. Account Type" <> GenJnlLine."Bal. Account Type"::"Bank Account" then
            exit;

        if GenJnlLine."Bal. Gen. Posting Type" <> GenJnlLine."Bal. Gen. Posting Type"::" " then
            AddError(
              StrSubstNo(
                Text004Lbl,
                GenJnlLine.FieldCaption("Bal. Gen. Posting Type"),
                GenJnlLine.FieldCaption("Bal. Account Type"),
                GenJnlLine."Bal. Account Type"));

        if (GenJnlLine."Bal. Gen. Bus. Posting Group" <> '') or
            (GenJnlLine."Bal. Gen. Bus. Posting Group" <> '') or
            (GenJnlLine."Bal. VAT Bus. Posting Group" <> '') or
            (GenJnlLine."Bal. VAT Prod. Posting Group" <> '')
        then
            AddError(
              StrSubstNo(
                Text005Lbl,
                GenJnlLine.FieldCaption("Bal. Gen. Bus. Posting Group"),
                GenJnlLine.FieldCaption(GenJnlLine."Bal. Gen. Bus. Posting Group"),
                GenJnlLine.FieldCaption("Bal. VAT Bus. Posting Group"),
                GenJnlLine.FieldCaption("Bal. VAT Prod. Posting Group"),
                GenJnlLine.FieldCaption("Bal. Account Type"),
                GenJnlLine."Bal. Account Type"));

        if GenJnlLine."Job No." <> '' then
            AddError(StrSubstNo(SpecifiedLbl, GenJnlLine.FieldCaption("Job No.")));

        if (GenJnlAllocation.Amount > 0) and (GenJnlLine."Bank Payment Type" = GenJnlLine."Bank Payment Type"::"Computer Check") then
            if not GenJnlLine."Check Printed" then
                AddError(StrSubstNo(CheckPrintLbl, GenJnlLine.FieldCaption("Check Printed")));
    end;

    local procedure TestAccountType(
        GenJnlLine: Record "Gen. Journal Line";
        GenJnlAllocation: Record "Gen. Jnl. Allocation")
    begin
        if GenJnlAllocation."Account No." <> '' then
            case GenJnlLine."Account Type" of
                GenJnlLine."Account Type"::"G/L Account":
                    TestAccountTypeGLAccount(GenJnlLine, GenJnlAllocation);
                GenJnlLine."Account Type"::Customer,
                GenJnlLine."Account Type"::Vendor:
                    TestAccountTypeParty(GenJnlLine, GenJnlAllocation);
                GenJnlLine."Account Type"::"Bank Account":
                    TestAccountTypeBankAccount(GenJnlLine, GenJnlAllocation);
                GenJnlLine."Account Type"::"Fixed Asset":
                    TestFixedAsset(GenJnlLine);
            end;

    end;

    local procedure TestBalAccountType(
        GenJnlLine: Record "Gen. Journal Line";
        GenJnlAllocation: Record "Gen. Jnl. Allocation")
    begin
        if GenJnlLine."Bal. Account No." <> '' then
            case GenJnlLine."Bal. Account Type" of
                "Bal. Account Type"::"G/L Account":
                    TestBalAccTypeGLAccount(GenJnlLine, GenJnlAllocation);
                "Bal. Account Type"::Customer, "Bal. Account Type"::Vendor:
                    TestBalAccTypeParty(GenJnlLine, GenJnlAllocation);
                "Bal. Account Type"::"Bank Account":
                    TestBalAccTypeBankAccount(GenJnlLine, GenJnlAllocation);
                GenJnlLine."Bal. Account Type"::"Fixed Asset":
                    TestFixedAsset(GenJnlLine);
            end;
    end;

    local procedure TestPostingDate(
        GenJnlLine: Record "Gen. Journal Line")
    begin
        if GenJnlLine."Posting Date" = 0D then
            AddError(StrSubstNo(Text002Lbl, GenJnlLine.FieldCaption("Posting Date")))
        else begin
            if GenJnlLine."Posting Date" <> NormalDate(GenJnlLine."Posting Date") then
                if (GenJnlLine."Account Type" <> GenJnlLine."Account Type"::"G/L Account") or
                   (GenJnlLine."Bal. Account Type" <> GenJnlLine."Bal. Account Type"::"G/L Account")
                then
                    AddError(
                      StrSubstNo(
                        PostingDateCaptionLbl,
                        GenJnlLine.FieldCaption("Posting Date")));

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
                    AllowPostingTo := DMY2Date(31, 12, 9999);
            end;

            if (GenJnlLine."Posting Date" < AllowPostingFrom) or (GenJnlLine."Posting Date" > AllowPostingTo) then
                AddError(StrSubstNo(PostingDateLbl, Format(GenJnlLine."Posting Date")));

            if "Gen. Journal Batch"."No. Series" <> '' then begin
                if NoSeries."Date Order" and (GenJnlLine."Posting Date" < LastEntrdDate) then
                    AddError(NoSeriesDateOrderLbl);
                LastEntrdDate := GenJnlLine."Posting Date";
            end;
        end;
    end;

    local procedure TestDocumentNo(
        GenJnlLine: Record "Gen. Journal Line")
    begin
        if GenJnlLine."Document No." = '' then
            AddError(StrSubstNo(Text002Lbl, GenJnlLine.FieldCaption("Document No.")))
        else
            if "Gen. Journal Batch"."No. Series" <> '' then begin
                if (LastEntrdDocNo <> '') and
                   (GenJnlLine."Document No." <> LastEntrdDocNo) and
                   (GenJnlLine."Document No." <> IncStr(LastEntrdDocNo))
                then
                    AddError(NoSeriesErrLbl);
                LastEntrdDocNo := GenJnlLine."Document No.";
            end;
    end;

    local procedure GetTCSAmountApplied(DocumentType: Enum "Gen. Journal Document Type"; DocumentNo: Code[20]): Decimal
    var
        TCSEntry2: Record "TCS Entry";
        AmountApplied: Decimal;
    begin
        TCSEntry2.Reset();
        TCSEntry2.SetRange("Document Type", DocumentType);
        TCSEntry2.SetRange("Document No.", DocumentNo);
        if TCSEntry2.FindSet() then
            repeat
                AmountApplied += TCSEntry2."TCS Amount" + TCSEntry2."Surcharge Amount" +
                  TCSEntry2."eCESS Amount" + TCSEntry2."SHE Cess Amount";
            until (TCSEntry2.Next() = 0);
        exit(AmountApplied)
    end;

    local procedure TestGenJnlAllocation(
        GenJnlLine: Record "Gen. Journal Line";
        GenJnlAllocation: Record "Gen. Jnl. Allocation")
    var
        PaymentTerms: Record "Payment Terms";
        DimMgt: Codeunit DimensionManagement;
        TableID: array[10] of Integer;
        No: array[10] of Code[20];
    begin
        if GenJnlLine."Currency Code" = '' then
            GenJnlLine."Amount (LCY)" := GenJnlAllocation.Amount;

        GenJnlLine.UpdateLineBalance();
        if (GenJnlLine."Document Type" <> GenJnlLine."Document Type"::" ") then begin
            UpdateTaxComponents(GenJnlLine.RecordId, 'GST', GSTComponentCode, GSTCompAmount);
            TDSAmount := TDSAmount + UpdateTaxComponents(GenJnlLine.RecordId, 'TDS', TDSComponentCode, TDSCompAmount);
            TCSAmount := TCSAmount + UpdateTaxComponents(GenJnlLine.RecordId, 'TCS', TCSComponentCode, TCSCompAmount);
        end;
        TCSAmount := Round(TCSAmount, 1);

        GetGSTComponentNames(GenJnlLine.RecordId, GSTComponentCodeName);

        AccName := '';
        BalAccName := '';
        if not GenJnlLine.EmptyLine() then begin
            MakeRecurringTexts(GenJnlLine);
            AmountError := false;

            if (GenJnlAllocation."Account No." = '') and (GenJnlLine."Bal. Account No." = '') then
                AddError(
                    StrSubstNo(
                        Text001Lbl,
                        GenJnlAllocation.FieldCaption("Account No."),
                        GenJnlLine.FieldCaption("Bal. Account No.")))
            else
                if (GenJnlLine."Account Type" <> GenJnlLine."Account Type"::"Fixed Asset") and
                   (GenJnlLine."Bal. Account Type" <> GenJnlLine."Bal. Account Type"::"Fixed Asset")
                then
                    TestFixedAssetFields(GenJnlLine);

            CheckICDocument();
            TestAccountType(GenJnlLine, GenJnlAllocation);
            TestBalAccountType(GenJnlLine, GenJnlAllocation);

            if (GenJnlAllocation."Account No." <> '') and
               not GenJnlLine."System-Created Entry" and
               (GenJnlAllocation.Amount = 0) and
               not GenJnlTemplate.Recurring and
               not GenJnlLine."Allow Zero-Amount Posting" and
               (GenJnlLine."Account Type" <> GenJnlLine."Account Type"::"Fixed Asset")
            then
                WarningIfZeroAmt(GenJnlLine);

            CheckRecurringLine(GenJnlLine);
            CheckAllocations(GenJnlLine);

            TestPostingDate(GenJnlLine);

            if GenJnlLine."Document Date" <> 0D then
                if (GenJnlLine."Document Date" <> NormalDate(GenJnlLine."Document Date")) and
                   ((GenJnlLine."Account Type" <> GenJnlLine."Account Type"::"G/L Account") or
                    (GenJnlLine."Bal. Account Type" <> GenJnlLine."Bal. Account Type"::"G/L Account"))
                then
                    AddError(StrSubstNo(DocumentDateCaptionLbl, GenJnlLine.FieldCaption("Document Date")));

            TestDocumentNo(GenJnlLine);

            if (GenJnlLine."Account Type" in [
                    GenJnlLine."Account Type"::Customer,
                    GenJnlLine."Account Type"::Vendor,
                    GenJnlLine."Account Type"::"Fixed Asset"]) and
               (GenJnlLine."Bal. Account Type" in [
                   GenJnlLine."Bal. Account Type"::Customer,
                   GenJnlLine."Bal. Account Type"::Vendor,
                   GenJnlLine."Bal. Account Type"::"Fixed Asset"])
            then
                AddError(
                  StrSubstNo(
                    AccountTypeErrLbl,
                    GenJnlLine.FieldCaption("Account Type"),
                    GenJnlLine.FieldCaption("Bal. Account Type")));

            if GenJnlAllocation.Amount * GenJnlLine."Amount (LCY)" < 0 then
                AddError(
                  StrSubstNo(
                    AmountSignLbl,
                    GenJnlLine.FieldCaption("Amount (LCY)"),
                    GenJnlAllocation.FieldCaption(Amount)));

            if (GenJnlLine."Account Type" = GenJnlLine."Account Type"::"G/L Account") and
               (GenJnlLine."Bal. Account Type" = GenJnlLine."Bal. Account Type"::"G/L Account")
            then
                if GenJnlLine."Applies-to Doc. No." <> '' then
                    AddError(StrSubstNo(SpecifiedLbl, GenJnlLine.FieldCaption("Applies-to Doc. No.")));

            if ((GenJnlLine."Account Type" = GenJnlLine."Account Type"::"G/L Account") and
                (GenJnlLine."Bal. Account Type" = GenJnlLine."Bal. Account Type"::"G/L Account")) or
               (GenJnlLine."Document Type" <> GenJnlLine."Document Type"::Invoice)
            then
                if PaymentTerms.Get(GenJnlLine."Payment Terms Code") then begin
                    if (GenJnlLine."Document Type" = GenJnlLine."Document Type"::"Credit Memo") and
                       (not PaymentTerms."Calc. Pmt. Disc. on Cr. Memos")
                    then begin
                        if GenJnlLine."Pmt. Discount Date" <> 0D then
                            AddError(StrSubstNo(SpecifiedLbl, GenJnlLine.FieldCaption("Pmt. Discount Date")));
                        if GenJnlLine."Payment Discount %" <> 0 then
                            AddError(StrSubstNo(PaymentDiscountCaptionLbl, GenJnlLine.FieldCaption("Payment Discount %")));
                    end;
                end else begin
                    if GenJnlLine."Pmt. Discount Date" <> 0D then
                        AddError(StrSubstNo(SpecifiedLbl, GenJnlLine.FieldCaption("Pmt. Discount Date")));
                    if GenJnlLine."Payment Discount %" <> 0 then
                        AddError(StrSubstNo(PaymentDiscountCaptionLbl, GenJnlLine.FieldCaption("Payment Discount %")));
                end;

            if ((GenJnlLine."Account Type" = GenJnlLine."Account Type"::"G/L Account") and
                (GenJnlLine."Bal. Account Type" = "Bal. Account Type"::"G/L Account")) or
               (GenJnlLine."Applies-to Doc. No." <> '')
            then
                if GenJnlLine."Applies-to ID" <> '' then
                    AddError(StrSubstNo(SpecifiedLbl, GenJnlLine.FieldCaption("Applies-to ID")));

            if (GenJnlLine."Account Type" <> GenJnlLine."Account Type"::"Bank Account") and
               (GenJnlLine."Bal. Account Type" <> GenJnlLine."Bal. Account Type"::"Bank Account")
            then
                if GenJnlLine2."Bank Payment Type" <> GenJnlLine2."Bank Payment Type"::" " then
                    AddError(StrSubstNo(SpecifiedLbl, GenJnlLine.FieldCaption("Bank Payment Type")));

            if (GenJnlAllocation."Account No." <> '') and (GenJnlLine."Bal. Account No." <> '') then begin
                PurchPostingType := false;
                SalesPostingType := false;
            end;

            if GenJnlAllocation."Account No." <> '' then
                CheckAccountTypes(GenJnlLine."Account Type", AccName);

            if GenJnlLine."Bal. Account No." <> '' then begin
                ExchAccGLJnlLine.Run(GenJnlLine);
                CheckAccountTypes(GenJnlLine."Account Type", BalAccName);
                ExchAccGLJnlLine.Run(GenJnlLine);
            end;

            if not DimMgt.CheckDimIDComb(GenJnlAllocation."Dimension Set ID") then
                AddError(DimMgt.GetDimCombErr());

            TableID[1] := DimMgt.TypeToTableID1(GetAccountTypes(GenJnlLine."Account Type"));
            No[1] := GenJnlAllocation."Account No.";
            TableID[2] := DimMgt.TypeToTableID1(GetAccountTypes(GenJnlLine."Bal. Account Type"));
            No[2] := GenJnlLine."Bal. Account No.";
            TableID[3] := Database::Job;
            No[3] := GenJnlLine."Job No.";
            TableID[4] := Database::"Salesperson/Purchaser";
            No[4] := GenJnlLine."Salespers./Purch. Code";
            TableID[5] := Database::Campaign;
            No[5] := GenJnlLine."Campaign No.";

            if not DimMgt.CheckDimValuePosting(TableID, No, GenJnlAllocation."Dimension Set ID") then
                AddError(DimMgt.GetDimValuePostingErr());
        end;

        GetTCSAmountApplied(GenJnlLine."Applies-to Doc. Type", GenJnlLine."Applies-to Doc. No.");
        CheckBalance();

        ShowVoucherValidations(GenJnlLine);
        TestGenJnlLines2(GenJnlLine, GenJnlAllocation);

        AmountLCY += GenJnlLine."Amount (LCY)";
        BalanceLCY += GenJnlLine."Balance (LCY)";
    end;

    local procedure TestGenJnlLines2(
        GenJnlLine: Record "Gen. Journal Line";
        GenJnlAllocation: Record "Gen. Jnl. Allocation")
    var
        GenJnlLine4: Record "Gen. Journal Line";
    begin
        GenJnlLine4.Reset();
        GenJnlLine4.SetRange("Journal Template Name", GenJnlAllocation."Journal Template Name");
        GenJnlLine4.SetRange("Journal Batch Name", GenJnlAllocation."Journal Batch Name");
        GenJnlLine4.SetRange("Document No.", GenJnlLine."Document No.");
        GenJnlLine4.SetFilter(
            "Account Type",
            '%1|%2',
            GenJnlLine."Account Type"::"Bank Account",
            GenJnlLine."Account Type"::"G/L Account");
        GenJnlLine4.SetFilter("GST TDS/TCS Base Amount", '=%1', 0);
        GenJnlLine4.SetFilter(Amount, '<0');
        if GenJnlLine4.FindFirst() then
            if (GenJnlLine4.Count > 1) and CheckTDSAmount(GenJnlLine) then
                AddError(StrSubstNo(CreditEntryDocLbl, GenJnlLine4."Document No."));
    end;

    local procedure PreTestGenJnlAllocation(
        "Gen. Journal Batch": Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        GenJnlAllocation: Record "Gen. Jnl. Allocation")
    begin
        GenJnlAllocation.CopyFilter("Journal Batch Name", "Gen. Journal Batch".Name);
        GenJnlLineFilter := GenJnlAllocation.GetFilters();

        GenJnlTemplate.Get("Gen. Journal Batch"."Journal Template Name");
        if GenJnlTemplate.Recurring then begin
            if GenJnlLine.GetFilter("Posting Date") <> '' then
                AddError(
                  StrSubstNo(
                    DateCationLbl,
                    GenJnlLine.FieldCaption("Posting Date")));
            GenJnlLine.SetRange("Posting Date", 0D, WorkDate());
            if GenJnlLine.GetFilter("Expiration Date") <> '' then
                AddError(
                  StrSubstNo(
                    DateCationLbl,
                    GenJnlLine.FieldCaption("Expiration Date")));
            GenJnlLine.SetFilter("Expiration Date", '%1 | %2..', 0D, WorkDate());
        end;

        if "Gen. Journal Batch"."No. Series" <> '' then begin
            NoSeries.Get("Gen. Journal Batch"."No. Series");
            LastEntrdDocNo := '';
            LastEntrdDate := 0D;
        end;

        TempGenJournalLineCustVendIC.Reset();
        TempGenJournalLineCustVendIC.DeleteAll();
        VATEntryCreated := false;

        GenJnlLine2.Reset();
        GenJnlLine2.CopyFilters("Gen. Journal Line");

        TempGLAccNetChange.DeleteAll();
        TDSAmount := 0;
        TCSAmount := 0;
        k := 0;
        BankChargeAmt := 0;
    end;
}
