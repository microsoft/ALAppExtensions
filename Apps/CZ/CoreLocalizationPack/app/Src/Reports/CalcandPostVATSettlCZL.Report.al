// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.SalesTax;
using Microsoft.Finance.VAT.Ledger;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Foundation.Enums;
using System.Utilities;

report 11971 "Calc. and Post VAT Settl. CZL"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/CalcAndPostVATSett.rdl';
    AdditionalSearchTerms = 'settle vat value added tax,report vat value added tax';
    ApplicationArea = Basic, Suite;
    Caption = 'Calculate and Post VAT Settlement';
    Permissions = tabledata "VAT Entry" = imd;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("VAT Posting Setup"; "VAT Posting Setup")
        {
            DataItemTableView = sorting("VAT Bus. Posting Group", "VAT Prod. Posting Group");
            RequestFilterFields = "VAT Bus. Posting Group", "VAT Prod. Posting Group";
            column(TodayFormatted; Format(Today, 0, 4))
            {
            }
            column(PeriodVATDateFilter; StrSubstNo(PeriodTxt, VATDateFilter))
            {
            }
            column(CompanyName; CompanyProperty.DisplayName())
            {
            }
            column(PostSettlement; PostSettlement)
            {
            }
            column(PostingDate; Format(PostingDate))
            {
            }
            column(DocNo; DocNo)
            {
            }
            column(GLAccSettleNo; SettleGLAccount."No.")
            {
            }
            column(UseAmtsInAddCurr; UseAmtsInAddCurr)
            {
            }
            column(PrintVATEntries; PrintVATEntries)
            {
            }
            column(VATPostingSetupCaption; TableCaption + ': ' + VATPostingSetupFilter)
            {
            }
            column(VATPostingSetupFilter; VATPostingSetupFilter)
            {
            }
            column(HeaderText; HeaderText)
            {
            }
            column(VATAmount; VATAmount)
            {
                AutoFormatExpression = GetCurrency();
                AutoFormatType = 1;
            }
            column(VATAmountAddCurr; VATAmountAddCurr)
            {
                AutoFormatExpression = GetCurrency();
                AutoFormatType = 1;
            }
            column(CalcandPostVATSettlementCaption; CalcandPostVATSettlementCaptionLbl)
            {
            }
            column(PageCaption; PageCaptionLbl)
            {
            }
            column(TestReportnotpostedCaption; TestReportnotpostedCaptionLbl)
            {
            }
            column(DocNoCaption; DocNoCaptionLbl)
            {
            }
            column(SettlementAccCaption; SettlementAccCaptionLbl)
            {
            }
            column(DocumentTypeCaption; DocumentTypeCaptionLbl)
            {
            }
            column(UserIDCaption; UserIDCaptionLbl)
            {
            }
            column(TotalCaption; TotalCaptionLbl)
            {
            }
            column(DocumentNoCaption; "VAT Entry".FieldCaption("Document No."))
            {
            }
            column(TypeCaption; "VAT Entry".FieldCaption(Type))
            {
            }
            column(BaseCaption; "VAT Entry".FieldCaption(Base))
            {
            }
            column(AmountCaption; "VAT Entry".FieldCaption(Amount))
            {
            }
#if not CLEAN25
            column(UnrealizedBaseCaption; "VAT Entry".FieldCaption("Unrealized Base"))
            {
                ObsoleteState = Pending;
                ObsoleteReason = 'This field is obsolete and will be removed in a future version.';
                ObsoleteTag = '25.0';
            }
            column(UnrealizedAmountCaption; "VAT Entry".FieldCaption("Unrealized Amount"))
            {
                ObsoleteState = Pending;
                ObsoleteReason = 'This field is obsolete and will be removed in a future version.';
                ObsoleteTag = '25.0';
            }
#endif
            column(OriginalVATBaseCaption; "VAT Entry".FieldCaption("Original VAT Base CZL"))
            {
            }
            column(OriginalVATAmountCaption; "VAT Entry".FieldCaption("Original VAT Amount CZL"))
            {
            }
            column(VATCalculationCaption; "VAT Entry".FieldCaption("VAT Calculation Type"))
            {
            }
            column(BilltoPaytoNoCaption; "VAT Entry".FieldCaption("Bill-to/Pay-to No."))
            {
            }
            column(EntryNoCaption; "VAT Entry".FieldCaption("Entry No."))
            {
            }
            column(PostingDateCaption; "VAT Entry".FieldCaption("VAT Reporting Date"))
            {
            }
            dataitem(Advance; "Integer")
            {
                DataItemTableView = sorting(Number) where(Number = filter(1 .. 2));
                dataitem("Closing G/L and VAT Entry"; "Integer")
                {
                    DataItemTableView = sorting(Number);
                    column(VATBusPstGr_VATPostSetup; "VAT Posting Setup"."VAT Bus. Posting Group")
                    {
                    }
                    column(VATPrdPstGr_VATPostSetup; "VAT Posting Setup"."VAT Prod. Posting Group")
                    {
                    }
                    column(VATEntryGetFilterType; VATEntry.GetFilter(Type))
                    {
                    }
                    column(VATEntryGetFiltTaxJurisCd; VATEntry.GetFilter("Tax Jurisdiction Code"))
                    {
                    }
                    column(VATEntryGetFilterUseTax; VATEntry.GetFilter("Use Tax"))
                    {
                    }
                    dataitem("VAT Entry"; "VAT Entry")
                    {
                        DataItemTableView = sorting(Type, Closed) where(Closed = const(false), Type = filter(Purchase | Sale));
                        column(PostingDate_VATEntry; Format("VAT Reporting Date"))
                        {
                        }
                        column(DocumentNo_VATEntry; VATEntryDocumentNo)
                        {
                        }
                        column(DocumentType_VATEntry; VATEntryDocumentType)
                        {
                        }
                        column(Type_VATEntry; Type)
                        {
                            IncludeCaption = false;
                        }
                        column(Base_VATEntry; Base)
                        {
                            AutoFormatExpression = GetCurrency();
                            AutoFormatType = 1;
                        }
                        column(Amount_VATEntry; Amount)
                        {
                            AutoFormatExpression = GetCurrency();
                            AutoFormatType = 1;
                        }
                        column(VATCalcType_VATEntry; "VAT Calculation Type")
                        {
                        }
                        column(BilltoPaytoNo_VATEntry; "Bill-to/Pay-to No.")
                        {
                        }
                        column(EntryNo_VATEntry; "Entry No.")
                        {
                        }
                        column(UserID_VATEntry; "User ID")
                        {
                        }
#if not CLEAN25
                        column(UnrealizedAmount_VATEntry; "Unrealized Amount")
                        {
                            AutoFormatExpression = GetCurrency();
                            AutoFormatType = 1;
                            ObsoleteState = Pending;
                            ObsoleteReason = 'This field is obsolete and will be removed in a future version.';
                            ObsoleteTag = '25.0';
                        }
                        column(UnrealizedBase_VATEntry; "Unrealized Base")
                        {
                            AutoFormatExpression = GetCurrency();
                            AutoFormatType = 1;
                            ObsoleteState = Pending;
                            ObsoleteReason = 'This field is obsolete and will be removed in a future version.';
                            ObsoleteTag = '25.0';
                        }
                        column(AddCurrUnrlzdAmt_VATEntry; "Add.-Currency Unrealized Amt.")
                        {
                            AutoFormatExpression = GetCurrency();
                            AutoFormatType = 1;
                            ObsoleteState = Pending;
                            ObsoleteReason = 'This field is obsolete and will be removed in a future version.';
                            ObsoleteTag = '25.0';
                        }
                        column(AddCurrUnrlzdBas_VATEntry; "Add.-Currency Unrealized Base")
                        {
                            AutoFormatExpression = GetCurrency();
                            AutoFormatType = 1;
                            ObsoleteState = Pending;
                            ObsoleteReason = 'This field is obsolete and will be removed in a future version.';
                            ObsoleteTag = '25.0';
                        }
#endif
                        column(OriginalVATAmount_VATEntry; "Original VAT Amount CZL")
                        {
                            AutoFormatExpression = GetCurrency();
                            AutoFormatType = 1;
                        }
                        column(OriginalVATBase_VATEntry; "Original VAT Base CZL")
                        {
                            AutoFormatExpression = GetCurrency();
                            AutoFormatType = 1;
                        }
                        column(OriginalVATAmountACY_VATEntry; "Additional-Currency Amount" + "Non-Deductible VAT Amount ACY")
                        {
                            AutoFormatExpression = GetCurrency();
                            AutoFormatType = 1;
                        }
                        column(OriginalVATBaseACY_VATEntry; "Additional-Currency Base" + "Non-Deductible VAT Base ACY")
                        {
                            AutoFormatExpression = GetCurrency();
                            AutoFormatType = 1;
                        }
                        column(AdditionlCurrAmt_VATEntry; "Additional-Currency Amount")
                        {
                            AutoFormatExpression = GetCurrency();
                            AutoFormatType = 1;
                        }
                        column(AdditinlCurrBase_VATEntry; "Additional-Currency Base")
                        {
                            AutoFormatExpression = GetCurrency();
                            AutoFormatType = 1;
                        }
                        column(VATRegistrationNo_VATEntry; "VAT Registration No.")
                        {
                            IncludeCaption = true;
                        }
                        column(CountryRegionCode_VATEntry; "Country/Region Code")
                        {
                            IncludeCaption = true;
                        }
                        dataitem(CountrySubTotal; "Integer")
                        {
                            DataItemTableView = sorting(Number);
                            column(CountrySubtotalCaption; StrSubstNo(CountrySubtotalCaptionLbl, "VAT Entry"."Country/Region Code"))
                            {
                            }
                            column(CountrySubBase; CountrySubTotalAmt[1])
                            {
                            }
                            column(CountrySubAmount; CountrySubTotalAmt[2])
                            {
                            }
                            column(CountrySubUnrealBase; CountrySubTotalAmt[3])
                            {
                            }
                            column(CountrySubUnrealAmount; CountrySubTotalAmt[4])
                            {
                            }
                            column(CountrySubTotalPrint; PrintCountrySubTotal)
                            {
                            }
                            trigger OnPreDataItem()
                            var
                                VATEntryLocal: Record "VAT Entry";
                            begin
                                if not PrintVATEntries then
                                    CurrReport.Break();

                                if PrintCountrySubTotal = 1 then
                                    Clear(CountrySubTotalAmt);
                                Clear(PrintCountrySubTotal);
                                if not UseAmtsInAddCurr then begin
                                    CountrySubTotalAmt[1] += "VAT Entry".Base;
                                    CountrySubTotalAmt[2] += "VAT Entry".Amount;
                                    CountrySubTotalAmt[3] += "VAT Entry"."Unrealized Base";
                                    CountrySubTotalAmt[4] += "VAT Entry"."Unrealized Amount";
                                end else begin
                                    CountrySubTotalAmt[1] += "VAT Entry"."Additional-Currency Base";
                                    CountrySubTotalAmt[2] += "VAT Entry"."Additional-Currency Amount";
                                    CountrySubTotalAmt[3] += "VAT Entry"."Add.-Currency Unrealized Base";
                                    CountrySubTotalAmt[4] += "VAT Entry"."Add.-Currency Unrealized Amt.";
                                end;

                                SetRange(Number, 0);
                                VATEntryLocal := "VAT Entry";
                                if "VAT Entry".Next() <> 0 then begin
                                    if VATEntryLocal."Country/Region Code" <> "VAT Entry"."Country/Region Code" then
                                        PrintCountrySubTotal := 1;
                                    "VAT Entry".Next(-1);
                                end else
                                    PrintCountrySubTotal := 1;
                                SetRange(Number, PrintCountrySubTotal);
                            end;
                        }
                        trigger OnAfterGetRecord()
                        begin
                            if not PrintVATEntries then
                                CurrReport.Skip();
                            VATEntryDocumentNo := "Document No.";
                            VATEntryDocumentType := Format("Document Type");
                            if "Original VAT Entry No. CZL" <> 0 then
                                Base := CalcDeductibleVATBaseCZL();
                        end;

                        trigger OnPreDataItem()
                        begin
                            CopyFilters(VATEntry);
                            Clear(CountrySubTotalAmt);
                        end;
                    }
                    dataitem("Close VAT Entries"; "Integer")
                    {
                        DataItemTableView = sorting(Number);
                        MaxIteration = 1;
                        column(PostingDate1; Format(PostingDate))
                        {
                        }
                        column(GenJnlLineDocumentNo; GenJournalLine."Document No.")
                        {
                        }
                        column(GenJnlLineVATBaseAmount; GenJournalLine."VAT Base Amount")
                        {
                            AutoFormatExpression = GetCurrency();
                            AutoFormatType = 1;
                        }
                        column(GenJnlLineVATAmount; GenJournalLine."VAT Amount")
                        {
                            AutoFormatExpression = GetCurrency();
                            AutoFormatType = 1;
                        }
                        column(GenJnlLnVATCalcType; Format(GenJournalLine."VAT Calculation Type"))
                        {
                        }
                        column(NextVATEntryNo; NextVATEntryNo)
                        {
                        }
                        column(GenJnlLnSrcCurrVATAmount; GenJournalLine."Source Curr. VAT Amount")
                        {
                            AutoFormatExpression = GetCurrency();
                            AutoFormatType = 1;
                        }
                        column(GenJnlLnSrcCurrVATBaseAmt; GenJournalLine."Source Curr. VAT Base Amount")
                        {
                            AutoFormatExpression = GetCurrency();
                            AutoFormatType = 1;
                        }
                        column(GenJnlLine2Amount; SecondGenJournalLine.Amount)
                        {
                            AutoFormatExpression = GetCurrency();
                            AutoFormatType = 1;
                        }
                        column(GenJnlLine2DocumentNo; SecondGenJournalLine."Document No.")
                        {
                        }
                        column(ReversingEntry; ReversingEntry)
                        {
                        }
                        column(GenJnlLn2SrcCurrencyAmt; SecondGenJournalLine."Source Currency Amount")
                        {
                            AutoFormatExpression = GetCurrency();
                            AutoFormatType = 1;
                        }
                        column(SettlementCaption; SettlementCaptionLbl)
                        {
                        }
                        column(GenJnlLineVATRegistrationNo; GenJournalLine."VAT Registration No.")
                        {
                        }
                        column(GenJnlLineCountryRegionCode; GenJournalLine."Country/Region Code")
                        {
                        }
                        column(GenJnlLine2VATRegistrationNo; SecondGenJournalLine."VAT Registration No.")
                        {
                        }
                        column(GenJnlLine2CountryRegionCode; SecondGenJournalLine."Country/Region Code")
                        {
                        }
                        trigger OnAfterGetRecord()
                        var
                            VATEntry2: Record "VAT Entry";
                        begin
                            // Calculate amount and base
                            VATEntry.CalcSums(
                                Base, Amount,
                                "Additional-Currency Base", "Additional-Currency Amount",
                                "Non-Deductible VAT Amount", "Non-Deductible VAT Amount ACY");
                            ReversingEntry := false;

                            // Balancing entries to VAT accounts
                            if "VAT Posting Setup"."VAT Calculation Type" = "VAT Posting Setup"."VAT Calculation Type"::"Sales Tax" then begin
                                TaxJurisdiction.Get(VATEntry."Tax Jurisdiction Code");
                                GenJournalLine."Tax Area Code" := TaxJurisdiction.Code;
                                GenJournalLine."Use Tax" := VATEntry."Use Tax";
                            end;
                            CheckVATAccountNo(VATEntry, "VAT Posting Setup", TaxJurisdiction);
                            CreateGenJnlLine(
                                GenJournalLine, GetVATAccountNo(VATEntry, "VAT Posting Setup", TaxJurisdiction),
                                VATEntry.Amount, VATEntry."Additional-Currency Amount");
                            SetVatPostingSetupToGenJnlLine(GenJournalLine, "VAT Posting Setup");
                            CopyAmounts(GenJournalLine, VATEntry);
                            OnCloseVATEntriesOnBeforePostGenJnlLine(GenJournalLine, VATEntry, "VAT Posting Setup", VATAmount, VATAmountAddCurr);
                            if PostSettlement then
                                PostGenJnlLine(GenJournalLine);

                            case "VAT Posting Setup"."VAT Calculation Type" of
                                "VAT Posting Setup"."VAT Calculation Type"::"Normal VAT",
                                "VAT Posting Setup"."VAT Calculation Type"::"Full VAT":
                                    begin
                                        VATAmount := VATAmount + VATEntry.Amount;
                                        VATAmountAddCurr := VATAmountAddCurr + VATEntry."Additional-Currency Amount";
                                    end;
                                "VAT Posting Setup"."VAT Calculation Type"::"Reverse Charge VAT":
                                    case VATType of
                                        VATEntry.Type::Purchase:
                                            begin
                                                CreateGenJnlLine(SecondGenJournalLine,
                                                    "VAT Posting Setup".GetRevChargeAccount(false),
                                                    VATEntry.Amount + VATEntry."Non-Deductible VAT Amount",
                                                    VATEntry."Additional-Currency Amount" + VATEntry."Non-Deductible VAT Amount ACY");
                                                SetVatPostingSetupToGenJnlLine(SecondGenJournalLine, "VAT Posting Setup");
                                                if PostSettlement then
                                                    PostGenJnlLine(SecondGenJournalLine);
                                                VATAmount -= VATEntry."Non-Deductible VAT Amount";
                                                VATAmountAddCurr -= VATEntry."Non-Deductible VAT Amount ACY";
                                                ReversingEntry := true;
                                            end;
                                    end;
                                "VAT Posting Setup"."VAT Calculation Type"::"Sales Tax":
                                    case VATType of
                                        VATEntry.Type::Purchase:
                                            if VATEntry."Use Tax" then begin
                                                CreateGenJnlLine(
                                                    SecondGenJournalLine, TaxJurisdiction."Reverse Charge (Purchases)",
                                                    VATEntry.Amount, VATEntry."Additional-Currency Amount");
                                                SecondGenJournalLine."Tax Area Code" := TaxJurisdiction.Code;
                                                SecondGenJournalLine."Use Tax" := VATEntry."Use Tax";
                                                if PostSettlement then
                                                    PostGenJnlLine(SecondGenJournalLine);
                                                ReversingEntry := true;
                                            end else begin
                                                VATAmount := VATAmount + VATEntry.Amount;
                                                VATAmountAddCurr := VATAmountAddCurr + VATEntry."Additional-Currency Amount";
                                            end;
                                        VATEntry.Type::Sale:
                                            begin
                                                VATAmount := VATAmount + VATEntry.Amount;
                                                VATAmountAddCurr := VATAmountAddCurr + VATEntry."Additional-Currency Amount";
                                            end;
                                    end;
                            end;
                            NextVATEntryNo := NextVATEntryNo + 1;

                            // Close current VAT entries
                            if PostSettlement then begin
                                VATEntry.ModifyAll("VAT Settlement No. CZL", DocNo);
                                if VATEntry2.Get(NextVATEntryNo) then begin
                                    VATEntry.ModifyAll("Closed by Entry No.", NextVATEntryNo);
                                    VATEntry2."VAT Settlement No. CZL" := DocNo;
                                    VATEntry2.Modify();
                                end;
                                VATEntry.ModifyAll(Closed, true);
                            end;
                        end;
                    }
                    trigger OnAfterGetRecord()
                    begin
                        VATEntry.Reset();
                        VATEntry.SetRange(Type, VATType);
                        VATEntry.SetRange(Closed, false);
                        VATEntry.SetFilter("VAT Reporting Date", VATDateFilter);
                        VATEntry.SetRange("VAT Bus. Posting Group", "VAT Posting Setup"."VAT Bus. Posting Group");
                        VATEntry.SetRange("VAT Prod. Posting Group", "VAT Posting Setup"."VAT Prod. Posting Group");
                        OnClosingGLAndVATEntryOnAfterGetRecordOnAfterSetVATEntryFilters("VAT Posting Setup", VATEntry, "VAT Entry");

                        case "VAT Posting Setup"."VAT Calculation Type" of
                            "VAT Posting Setup"."VAT Calculation Type"::"Normal VAT",
                            "VAT Posting Setup"."VAT Calculation Type"::"Reverse Charge VAT",
                            "VAT Posting Setup"."VAT Calculation Type"::"Full VAT":
                                begin
                                    VATEntry.SetCurrentKey(
                                      Type, Closed, "VAT Bus. Posting Group", "VAT Prod. Posting Group",
                                      "Gen. Bus. Posting Group", "Gen. Prod. Posting Group",
                                      "EU 3-Party Trade");
                                    if FindFirstEntry then begin
                                        if VATEntry.IsEmpty() then
                                            repeat
                                                VATType := IncrementGenPostingType(VATType);
                                                VATEntry.SetRange(Type, VATType);
                                            until (VATType = VATEntry.Type::Settlement) or not VATEntry.IsEmpty();
                                        FindFirstEntry := false;
                                    end else
                                        if VATEntry.Next() = 0 then
                                            repeat
                                                VATType := IncrementGenPostingType(VATType);
                                                VATEntry.SetRange(Type, VATType);
                                            until (VATType = VATEntry.Type::Settlement) or not VATEntry.IsEmpty();
                                    if IsNotSettlement(VATType) then
                                        VATEntry.FindLast();
                                end;
                            "VAT Posting Setup"."VAT Calculation Type"::"Sales Tax":
                                begin
                                    VATEntry.SetCurrentKey(Type, Closed, "Tax Jurisdiction Code", "Use Tax", "VAT Reporting Date");
                                    if FindFirstEntry then begin
                                        if VATEntry.IsEmpty() then
                                            repeat
                                                VATType := IncrementGenPostingType(VATType);
                                                VATEntry.SetRange(Type, VATType);
                                            until (VATType = VATEntry.Type::Settlement) or not VATEntry.IsEmpty();
                                        FindFirstEntry := false;
                                    end else begin
                                        VATEntry.SetRange("Tax Jurisdiction Code");
                                        VATEntry.SetRange("Use Tax");
                                        if VATEntry.Next() = 0 then
                                            repeat
                                                VATType := IncrementGenPostingType(VATType);
                                                VATEntry.SetRange(Type, VATType);
                                            until (VATType = VATEntry.Type::Settlement) or not VATEntry.IsEmpty();
                                    end;
                                    if IsNotSettlement(VATType) then begin
                                        VATEntry.SetRange("Tax Jurisdiction Code", VATEntry."Tax Jurisdiction Code");
                                        VATEntry.SetRange("Use Tax", VATEntry."Use Tax");
                                        VATEntry.FindLast();
                                    end;
                                end;
                        end;

                        if VATType = VATEntry.Type::Settlement then
                            CurrReport.Break();
                    end;

                    trigger OnPreDataItem()
                    begin
                        VATType := VATEntry.Type::Purchase;
                        FindFirstEntry := true;
                    end;
                }
            }
            trigger OnPostDataItem()
            begin
                // Post to settlement account
                if VATAmount <> 0 then begin
                    GenJournalLine.Init();
                    GenJournalLine."System-Created Entry" := true;
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";

                    SettleGLAccount.TestField("Gen. Posting Type", GenJournalLine."Gen. Posting Type"::" ".AsInteger());
                    SettleGLAccount.TestField("VAT Bus. Posting Group", '');
                    SettleGLAccount.TestField("VAT Prod. Posting Group", '');
                    if VATPostingSetup.Get(SettleGLAccount."VAT Bus. Posting Group", SettleGLAccount."VAT Prod. Posting Group") then
                        VATPostingSetup.TestField("VAT %", 0);
                    SettleGLAccount.TestField("Gen. Bus. Posting Group", '');
                    SettleGLAccount.TestField("Gen. Prod. Posting Group", '');

                    GenJournalLine.Validate("Account No.", SettleGLAccount."No.");
                    GenJournalLine."Posting Date" := PostingDate;
                    GenJournalLine.Validate("VAT Reporting Date", PostingDate);
                    GenJournalLine."Document Type" := GenJournalLine."Document Type"::" ";
                    GenJournalLine."Document No." := DocNo;
                    GenJournalLine.Description := VatSettlementTxt;
                    GenJournalLine.Amount := VATAmount;
                    GenJournalLine."Source Currency Code" := GeneralLedgerSetup."Additional Reporting Currency";
                    GenJournalLine."Source Currency Amount" := VATAmountAddCurr;
                    GenJournalLine."Source Code" := SourceCodeSetup."VAT Settlement";
                    GenJournalLine."VAT Posting" := GenJournalLine."VAT Posting"::"Manual VAT Entry";
                    if PostSettlement then
                        PostGenJnlLine(GenJournalLine);
                end;
            end;

            trigger OnPreDataItem()
            begin
                GLEntry.LockTable(); // Avoid deadlock with function 12
                if GLEntry.FindLast() then;
                VATEntry.LockTable();
                VATEntry.Reset();
                NextVATEntryNo := VATEntry.GetLastEntryNo();

                SourceCodeSetup.Get();
                GeneralLedgerSetup.Get();
                VATAmount := 0;
                VATAmountAddCurr := 0;

                if UseAmtsInAddCurr then
                    HeaderText := StrSubstNo(AllAmountsAreInTxt, GeneralLedgerSetup."Additional Reporting Currency")
                else begin
                    GeneralLedgerSetup.TestField("LCY Code");
                    HeaderText := StrSubstNo(AllAmountsAreInTxt, GeneralLedgerSetup."LCY Code");
                end;
            end;
        }
    }
    requestpage
    {
        SaveValues = true;
        ShowFilter = false;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(StartingDate; EntrdStartDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Starting Date';
                        TableRelation = "VAT Period CZL";
                        ToolTip = 'Specifies the first date in the period from which VAT entries are processed in the batch job.';

                        trigger OnValidate()
                        begin
                            VATPeriodCZL.Get(EntrdStartDate);
                            if VATPeriodCZL.Next() > 0 then
                                EndDateReq := CalcDate('<-1D>', VATPeriodCZL."Starting Date");
                        end;
                    }
                    field(EndingDate; EndDateReq)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Ending Date';
                        ToolTip = 'Specifies the last date in the period from which VAT entries are processed in the batch job.';
                    }
                    field(PostingDt; PostingDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Posting Date';
                        ToolTip = 'Specifies the date on which the transfer to the VAT account is posted. This field must be filled in.';
                    }
                    field(DocumentNo; DocNo)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Document No.';
                        ToolTip = 'Specifies a document number. This field must be filled in.';
                    }
                    field(SettlementAcc; SettleGLAccount."No.")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Settlement Account';
                        TableRelation = "G/L Account";
                        ToolTip = 'Specifies the number of the VAT settlement account. Select the field to see the chart of account. This field must be filled in.';

                        trigger OnValidate()
                        begin
                            if SettleGLAccount."No." <> '' then begin
                                SettleGLAccount.Find();
                                SettleGLAccount.CheckGLAcc();
                            end;
                        end;
                    }
                    field(ShowVATEntries; PrintVATEntries)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Show VAT Entries';
                        ToolTip = 'Specifies if you want the report that is printed during the batch job to contain the individual VAT entries. If you do not choose to print the VAT entries, the settlement amount is shown only for each VAT posting group.';
                    }
                    field(Post; PostSettlement)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Post';
                        ToolTip = 'Specifies if you want the program to post the transfer to the VAT settlement account automatically. If you do not choose to post the transfer, the batch job only prints a test report, and Test Report (not Posted) appears on the report.';
                    }
                    field(AmtsinAddReportingCurr; UseAmtsInAddCurr)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Show Amounts in Add. Reporting Currency';
                        MultiLine = true;
                        ToolTip = 'Specifies if the reported amounts are shown in the additional reporting currency.';
                    }
                }
            }
        }
    }
    trigger OnPostReport()
    begin
        if PostSettlement and VATPeriodCZL.Get(EntrdStartDate) then begin
            VATPeriodCZL.Closed := true;
            VATPeriodCZL.Modify();
        end;
        OnAfterPostReport();
    end;

    trigger OnPreReport()
    var
        ConfirmManagement: Codeunit "Confirm Management";
    begin
        OnBeforePreReport("VAT Posting Setup");

        GeneralLedgerSetup.Get();
        GeneralLedgerSetup.TestIsVATDateEnabledCZL();
        if PostingDate = 0D then
            Error(PostingDateErr);
        if DocNo = '' then
            Error(DocumentNoErr);
        if SettleGLAccount."No." = '' then
            Error(SettlementAccErr);
        SettleGLAccount.Find();

        if PostSettlement and not Initialized then
            if not ConfirmManagement.GetResponseOrDefault(ConfirmCalcPostQst, true) then
                CurrReport.Quit();

        VATPostingSetupFilter := "VAT Posting Setup".GetFilters();
            if EndDateReq = 0D then
                VATEntry.SetFilter("VAT Reporting Date", '%1..', EntrdStartDate)
            else
                VATEntry.SetRange("VAT Reporting Date", EntrdStartDate, EndDateReq);
            VATDateFilter := VATEntry.GetFilter("VAT Reporting Date");
        Clear(GenJnlPostLine);
        OnAfterPreReport();
    end;

    var
        SettleGLAccount: Record "G/L Account";
        SourceCodeSetup: Record "Source Code Setup";
        GenJournalLine: Record "Gen. Journal Line";
        SecondGenJournalLine: Record "Gen. Journal Line";
        GLEntry: Record "G/L Entry";
        VATEntry: Record "VAT Entry";
        TaxJurisdiction: Record "Tax Jurisdiction";
        GeneralLedgerSetup: Record "General Ledger Setup";
        VATPostingSetup: Record "VAT Posting Setup";
        VATPeriodCZL: Record "VAT Period CZL";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        EntrdStartDate: Date;
        EndDateReq: Date;
        PrintVATEntries: Boolean;
        NextVATEntryNo: Integer;
        PostingDate: Date;
        DocNo: Code[20];
        VATType: Enum "General Posting Type";
        VATAmount: Decimal;
        VATAmountAddCurr: Decimal;
        PostSettlement: Boolean;
        FindFirstEntry: Boolean;
        ReversingEntry: Boolean;
        Initialized: Boolean;
        VATPostingSetupFilter: Text;
        VATDateFilter: Text;
        UseAmtsInAddCurr: Boolean;
        HeaderText: Text[30];
        CalcandPostVATSettlementCaptionLbl: Label 'Calculate and Post VAT Settlement';
        PageCaptionLbl: Label 'Page';
        TestReportnotpostedCaptionLbl: Label 'Test Report (Not Posted)';
        DocNoCaptionLbl: Label 'Document No.';
        SettlementAccCaptionLbl: Label 'Settlement Account';
        DocumentTypeCaptionLbl: Label 'Document Type';
        UserIDCaptionLbl: Label 'User ID';
        TotalCaptionLbl: Label 'Total';
        PostingDateErr: Label 'Enter the posting date.';

        SettlementCaptionLbl: Label 'Settlement';
        PrintCountrySubTotal: Integer;
        CountrySubTotalAmt: array[4] of Decimal;
        CountrySubtotalCaptionLbl: Label 'Total for Country/Region %1', Comment = '%1="Country/Region Code"';
        DocumentNoErr: Label 'Enter the document no.';
        SettlementAccErr: Label 'Enter the settlement account.';
        ConfirmCalcPostQst: Label 'Do you want to calculate and post the VAT Settlement?';
        VatSettlementTxt: Label 'VAT Settlement';
        PeriodTxt: Label 'Period: %1', Comment = '%1 = Period';
        AllAmountsAreInTxt: Label 'All amounts are in %1.', Comment = '%1 = Currency Code';
        PurchaseVatSettlementTxt: Label 'Purchase VAT settlement: #1######## #2########', Comment = '%1 = "VAT Bus. Posting Group", %2 = "VAT Prod. Posting Group"';
        SalesVatSettlementTxt: Label 'Sales VAT settlement  : #1######## #2########', Comment = '%1 = "VAT Bus. Posting Group", %2 = "VAT Prod. Posting Group"';
        VATEntryDocumentNo: Code[20];
        VATEntryDocumentType: Text;

    procedure InitializeRequest(NewStartDate: Date; NewEndDate: Date; NewPostingDate: Date; NewDocNo: Code[20]; NewSettlementAcc: Code[20]; ShowVATEntries: Boolean; Post: Boolean)
    begin
        EntrdStartDate := NewStartDate;
        EndDateReq := NewEndDate;
        PostingDate := NewPostingDate;
        DocNo := NewDocNo;
        SettleGLAccount."No." := NewSettlementAcc;
        PrintVATEntries := ShowVATEntries;
        PostSettlement := Post;
        Initialized := true;
        if VATPeriodCZL.Get(EntrdStartDate) then;
    end;

    procedure InitializeRequest2(NewUseAmtsInAddCurr: Boolean)
    begin
        UseAmtsInAddCurr := NewUseAmtsInAddCurr;
    end;

    local procedure GetCurrency(): Code[10]
    begin
        if UseAmtsInAddCurr then
            exit(GeneralLedgerSetup."Additional Reporting Currency");

        exit('');
    end;

    local procedure PostGenJnlLine(var GenJournalLine: Record "Gen. Journal Line")
    var
        DimensionManagement: Codeunit DimensionManagement;
        DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
    begin
        DimensionManagement.AddDimSource(DefaultDimSource, Database::"G/L Account", GenJournalLine."Account No.");
        DimensionManagement.AddDimSource(DefaultDimSource, Database::"G/L Account", GenJournalLine."Bal. Account No.");
        GenJournalLine."Dimension Set ID" := DimensionManagement.GetRecDefaultDimID(GenJournalLine, 0, DefaultDimSource, GenJournalLine."Source Code",
                                               GenJournalLine."Shortcut Dimension 1 Code", GenJournalLine."Shortcut Dimension 2 Code", 0, 0);
        GenJnlPostLine.Run(GenJournalLine);
    end;

    procedure SetInitialized(Initialize: Boolean)
    begin
        Initialized := Initialize;
    end;

    local procedure CopyAmounts(var GenJournalLine: Record "Gen. Journal Line"; VATEntry: Record "VAT Entry")
    begin
        GenJournalLine.Amount := -VATEntry.Amount;
        GenJournalLine."VAT Amount" := -VATEntry.Amount;
        GenJournalLine."VAT Base Amount" := -VATEntry.Base;
        GenJournalLine."Source Currency Code" := GeneralLedgerSetup."Additional Reporting Currency";
        GenJournalLine."Source Currency Amount" := -VATEntry."Additional-Currency Amount";
        GenJournalLine."Source Curr. VAT Amount" := -VATEntry."Additional-Currency Amount";
        GenJournalLine."Source Curr. VAT Base Amount" := -VATEntry."Additional-Currency Base";
    end;

    local procedure CreateGenJnlLine(var CreatedGenJournalLine: Record "Gen. Journal Line"; AccountNo: Code[20]; Amount: Decimal; AmountACY: Decimal)
    begin
        Clear(CreatedGenJournalLine);
        CreatedGenJournalLine."System-Created Entry" := true;
        CreatedGenJournalLine."Account Type" := CreatedGenJournalLine."Account Type"::"G/L Account";
        case VATType of
            VATEntry.Type::Purchase:
                CreatedGenJournalLine.Description := CopyStr(
                  DelChr(
                    StrSubstNo(
                      PurchaseVatSettlementTxt,
                      "VAT Posting Setup"."VAT Bus. Posting Group",
                      "VAT Posting Setup"."VAT Prod. Posting Group"),
                    '>'), 1, MaxStrLen(CreatedGenJournalLine.Description));
            VATEntry.Type::Sale:
                CreatedGenJournalLine.Description := CopyStr(
                  DelChr(
                    StrSubstNo(
                      SalesVatSettlementTxt,
                      "VAT Posting Setup"."VAT Bus. Posting Group",
                      "VAT Posting Setup"."VAT Prod. Posting Group"),
                    '>'), 1, MaxStrLen(CreatedGenJournalLine.Description));
        end;
        CreatedGenJournalLine."Posting Date" := PostingDate;
        CreatedGenJournalLine.Validate("VAT Reporting Date", PostingDate);
        CreatedGenJournalLine."Document Type" := CreatedGenJournalLine."Document Type"::" ";
        CreatedGenJournalLine."Document No." := DocNo;
        CreatedGenJournalLine."Source Code" := SourceCodeSetup."VAT Settlement";
        CreatedGenJournalLine."VAT Posting" := CreatedGenJournalLine."VAT Posting"::"Manual VAT Entry";
        CreatedGenJournalLine."Account No." := AccountNo;
        CreatedGenJournalLine.Amount := Amount;
        CreatedGenJournalLine."Source Currency Code" := GeneralLedgerSetup."Additional Reporting Currency";
        CreatedGenJournalLine."Source Currency Amount" := AmountACY;
    end;

    local procedure SetVatPostingSetupToGenJnlLine(var GenJournalLine: Record "Gen. Journal Line"; VATPostingSetup: Record "VAT Posting Setup")
    begin
        GenJournalLine."Gen. Posting Type" := GenJournalLine."Gen. Posting Type"::Settlement;
        GenJournalLine."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        GenJournalLine."VAT Prod. Posting Group" := VATPostingSetup."VAT Prod. Posting Group";
        GenJournalLine."VAT Calculation Type" := VATPostingSetup."VAT Calculation Type";
    end;

    local procedure IncrementGenPostingType(var OldGenPostingType: Enum "General Posting Type") NewGenPostingType: Enum "General Posting Type"
    begin
        case OldGenPostingType of
            OldGenPostingType::" ":
                exit(NewGenPostingType::Purchase);
            OldGenPostingType::Purchase:
                exit(NewGenPostingType::Sale);
            OldGenPostingType::Sale:
                exit(NewGenPostingType::Settlement);
        end;

        OnAfterIncrementGenPostingType(OldGenPostingType, NewGenPostingType);
    end;

    local procedure IsNotSettlement(GeneralPostingType: Enum "General Posting Type"): Boolean
    begin
        exit(
            (GeneralPostingType = GeneralPostingType::" ") or
            (GeneralPostingType = GeneralPostingType::Purchase) or
            (GeneralPostingType = GeneralPostingType::Sale));
    end;

    local procedure CheckVATAccountNo(VATEntry: Record "VAT Entry"; VATPostingSetup: Record "VAT Posting Setup"; TaxJurisdiction: Record "Tax Jurisdiction")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckVATAccountNo(VATEntry, VATPostingSetup, TaxJurisdiction, IsHandled);
        if IsHandled then
            exit;

        case VATEntry.Type of
            VATEntry.Type::Purchase:
                if VATPostingSetup."VAT Calculation Type" <> "VAT Posting Setup"."VAT Calculation Type"::"Sales Tax" then
                    VATPostingSetup.TestField("Purchase VAT Account")
                else begin
                    TaxJurisdiction.TestField("Tax Account (Purchases)");
                    if VATEntry."Use Tax" then
                        TaxJurisdiction.TestField("Reverse Charge (Purchases)");
                end;
            VATEntry.Type::Sale:
                if VATPostingSetup."VAT Calculation Type" <> "VAT Posting Setup"."VAT Calculation Type"::"Sales Tax" then
                    VATPostingSetup.TestField("Sales VAT Account")
                else
                    TaxJurisdiction.TestField("Tax Account (Sales)");
        end;
    end;

    procedure GetVATAccountNo(VATEntry: Record "VAT Entry"; VATPostingSetup: Record "VAT Posting Setup"; TaxJurisdiction: Record "Tax Jurisdiction"): Code[20]
    var
        VATAccountNo: Code[20];
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeGetVATAccountNo(VATEntry, VATPostingSetup, VATAccountNo, IsHandled);
        if IsHandled then
            exit(VATAccountNo);

        case VATEntry.Type of
            VATEntry.Type::Purchase:
                if VATPostingSetup."VAT Calculation Type" <> "VAT Posting Setup"."VAT Calculation Type"::"Sales Tax" then
                    exit(VATPostingSetup.GetPurchAccount(false))
                else
                    exit(TaxJurisdiction."Tax Account (Purchases)");
            VATEntry.Type::Sale:
                if VATPostingSetup."VAT Calculation Type" <> "VAT Posting Setup"."VAT Calculation Type"::"Sales Tax" then
                    exit(VATPostingSetup.GetSalesAccount(false))
                else
                    exit(TaxJurisdiction."Tax Account (Sales)");
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPreReport()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostReport()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePreReport(var VATPostingSetup: Record "VAT Posting Setup")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterIncrementGenPostingType(OldGenPostingType: Enum "General Posting Type"; var NewGenPostingType: Enum "General Posting Type")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetVATAccountNo(VATEntry: Record "VAT Entry"; VATPostingSetup: Record "VAT Posting Setup"; var VATAccountNo: Code[20]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnClosingGLAndVATEntryOnAfterGetRecordOnAfterSetVATEntryFilters(VATPostingSetup: Record "VAT Posting Setup"; var VATEntry: Record "VAT Entry"; var VATEntry2: Record "VAT Entry")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnCloseVATEntriesOnBeforePostGenJnlLine(var GenJournalLine: Record "Gen. Journal Line"; VATEntry: Record "VAT Entry"; VATPostingSetup: Record "VAT Posting Setup"; var VATAmount: Decimal; var VATAmountAddCurr: Decimal)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeCheckVATAccountNo(VATEntry: Record "VAT Entry"; VATPostingSetup: Record "VAT Posting Setup"; TaxJurisdiction: Record "Tax Jurisdiction"; var IsHandled: Boolean)
    begin
    end;
}
