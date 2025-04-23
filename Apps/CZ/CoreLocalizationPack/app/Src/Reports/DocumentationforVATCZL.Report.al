// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.VAT.Ledger;
using Microsoft.Finance.VAT.Setup;
using System.Utilities;

report 11757 "Documentation for VAT CZL"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Documentation for VAT';
    UsageCategory = ReportsAndAnalysis;
    PreviewMode = PrintLayout;
    DefaultRenderingLayout = "DocumentationForVAT.rdl";

    dataset
    {
        dataitem("VAT Posting Setup"; "VAT Posting Setup")
        {
            DataItemTableView = sorting("VAT Bus. Posting Group", "VAT Prod. Posting Group");
            RequestFilterFields = "VAT Bus. Posting Group", "VAT Prod. Posting Group";
            column(PeriodVATDateFilter; StrSubstNo(PeriodTxt, VATDateFilter))
            {
            }
            column(CompanyName; CompanyProperty.DisplayName())
            {
            }
            column(PrintVATEntries; PrintVATEntries)
            {
            }
            column(MergeByDocumentNo; MergeByDocumentNo)
            {
            }
            column(VATPostingSetupFilter; VATPostingSetupFilter)
            {
            }
            column(HeaderText; HeaderText)
            {
            }
            column(Heading; Heading)
            {
            }
            column(VATBase; VATBaseTotal[1])
            {
            }
            column(VATAmount; VATAmountTotal[1])
            {
            }
            column(VATBaseSale; VATBaseSaleTotal[1])
            {
            }
            column(VATAmountSale; VATAmountSaleTotal[1])
            {
            }
            column(VATBasePurch; VATBasePurchTotal[1])
            {
            }
            column(VATAmountPurch; VATAmountPurchTotal[1])
            {
            }
            column(VATBaseReverseChargeVAT; VATBaseReverseChargeVATTotal[1])
            {
            }
            column(VATAmountReverseChargeVAT; VATAmountReverseChargeVATTotal[1])
            {
            }
            column(VATBase2; VATBaseTotal[2])
            {
            }
            column(VATAmount2; VATAmountTotal[2])
            {
            }
            column(VATBaseSale2; VATBaseSaleTotal[2])
            {
            }
            column(VATAmountSale2; VATAmountSaleTotal[2])
            {
            }
            column(VATBasePurch2; VATBasePurchTotal[2])
            {
            }
            column(VATAmountPurch2; VATAmountPurchTotal[2])
            {
            }
            column(VATBaseReverseChargeVAT2; VATBaseReverseChargeVATTotal[2])
            {
            }
            column(VATAmountReverseChargeVAT2; VATAmountReverseChargeVATTotal[2])
            {
            }
            column(Selection; Selection)
            {
            }
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
                dataitem("VAT Entry"; "VAT Entry")
                {
                    DataItemTableView = sorting(Type, Closed, "VAT Bus. Posting Group", "VAT Prod. Posting Group", "Country/Region Code") where(Type = filter(Purchase | Sale));
                    UseTemporary = true;
                    column(VATDate_VATEntry; "VAT Reporting Date")
                    {
                        IncludeCaption = true;
                    }
                    column(DocumentNo_VATEntry; "Document No.")
                    {
                        IncludeCaption = true;
                    }
                    column(DocumentType_VATEntry; "Document Type")
                    {
                        IncludeCaption = true;
                    }
                    column(Type_VATEntry; Type)
                    {
                        IncludeCaption = true;
                    }
                    column(CalculatedVATBase; Base)
                    {
                    }
                    column(CalculatedVATAmount; Amount)
                    {
                    }
                    column(OriginalVATBase_VATEntry; "Original VAT Base CZL")
                    {
                        IncludeCaption = true;
                    }
                    column(OriginalVATAmount_VATEntry; "Original VAT Amount CZL")
                    {
                        IncludeCaption = true;
                    }
                    column(VATCalcType_VATEntry; "VAT Calculation Type")
                    {
                        IncludeCaption = true;
                    }
                    column(BilltoPaytoNo_VATEntry; "Bill-to/Pay-to No.")
                    {
                        IncludeCaption = true;
                    }
                    column(EntryNo_VATEntry; "Entry No.")
                    {
                        IncludeCaption = true;
                    }
                    column(UserID_VATEntry; "User ID")
                    {
                        IncludeCaption = true;
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
                        column(CountrySubtotalCaption; StrSubstNo(CountrySubtotalCaptionTxt, "VAT Entry"."Country/Region Code"))
                        {
                        }
                        column(CountrySubBase; CountrySubTotalAmt[1])
                        {
                        }
                        column(CountrySubAmount; CountrySubTotalAmt[2])
                        {
                        }
                        column(CountrySubOriginalBase; CountrySubTotalAmt[3])
                        {
                        }
                        column(CountrySubOriginalAmount; CountrySubTotalAmt[4])
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

                            CountrySubTotalAmt[1] += "VAT Entry".Base;
                            CountrySubTotalAmt[2] += "VAT Entry".Amount;
                            CountrySubTotalAmt[3] += "VAT Entry"."Original VAT Base CZL";
                            CountrySubTotalAmt[4] += "VAT Entry"."Original VAT Amount CZL";

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
                        VATEntrySubtotalAmt[1] += Base;
                        VATEntrySubtotalAmt[2] += Amount;
                        VATEntrySubtotalAmt[3] += "Original VAT Base CZL";
                        VATEntrySubtotalAmt[4] += "Original VAT Amount CZL";

                        case "VAT Posting Setup"."VAT Calculation Type" of
                            "VAT Posting Setup"."VAT Calculation Type"::"Normal VAT",
                            "VAT Posting Setup"."VAT Calculation Type"::"Full VAT",
                            "VAT Posting Setup"."VAT Calculation Type"::"Reverse Charge VAT":
                                AddTotal("VAT Entry");
                            "VAT Posting Setup"."VAT Calculation Type"::"Sales Tax":
                                case Type of
                                    Type::Purchase:
                                        if not "Use Tax" then
                                            AddTotal("VAT Entry");
                                    Type::Sale:
                                        AddTotal("VAT Entry");
                                end;
                        end;
                    end;

                    trigger OnPreDataItem()
                    begin
                        "VAT Entry".Reset();
                        "VAT Entry".SetCurrentKey(Type, Closed, "VAT Bus. Posting Group", "VAT Prod. Posting Group", "Country/Region Code");

                        Clear(CountrySubTotalAmt);
                        Clear(VATEntrySubtotalAmt);
                    end;
                }
                dataitem("Close VAT Entries"; "Integer")
                {
                    DataItemTableView = sorting(Number);
                    MaxIteration = 1;

                    column(VATEntryTotalCaption; StrSubstNo(TotalPerTxt, "VAT Posting Setup"."VAT Bus. Posting Group", "VAT Posting Setup"."VAT Prod. Posting Group", VATEntry.GetFilter(Type)))
                    {
                    }
                    column(VATEntrySumCalculatedBase; VATEntrySubtotalAmt[1])
                    {
                    }
                    column(VATEntrySumCalculatedAmount; VATEntrySubtotalAmt[2])
                    {
                    }
                    column(VATEntrySumOriginalBase; VATEntrySubtotalAmt[3])
                    {
                    }
                    column(VATEntrySumOriginalAmount; VATEntrySubtotalAmt[4])
                    {
                    }
                }
                trigger OnAfterGetRecord()
                begin
                    VATEntry.Reset();
                    VATEntry.SetCurrentKey(Type, Closed, "VAT Bus. Posting Group", "VAT Prod. Posting Group",
                      "Gen. Bus. Posting Group", "Gen. Prod. Posting Group", "EU 3-Party Trade");

                    VATEntry.SetRange(Type, VATType);
                    case Selection of
                        Selection::Open:
                            VATEntry.SetRange(Closed, false);
                        Selection::Closed:
                            VATEntry.SetRange(Closed, true);
                        else
                            VATEntry.SetRange(Closed);
                    end;
                    VATEntry.SetFilter("VAT Reporting Date", VATDateFilter);
                    VATEntry.SetRange("VAT Bus. Posting Group", "VAT Posting Setup"."VAT Bus. Posting Group");
                    VATEntry.SetRange("VAT Prod. Posting Group", "VAT Posting Setup"."VAT Prod. Posting Group");
                    if SettlementNoFilter <> '' then
                        VATEntry.SetFilter("VAT Settlement No. CZL", SettlementNoFilter);

                    case "VAT Posting Setup"."VAT Calculation Type" of
                        "VAT Posting Setup"."VAT Calculation Type"::"Normal VAT",
                        "VAT Posting Setup"."VAT Calculation Type"::"Reverse Charge VAT",
                        "VAT Posting Setup"."VAT Calculation Type"::"Full VAT":
                            begin
                                if FindFirstEntry then begin
                                    if not VATEntry.FindSet() then
                                        repeat
                                            VATType += 1;
                                            VATEntry.SetRange(Type, VATType);
                                        until (VATType = VATEntry.Type::Settlement.AsInteger()) or VATEntry.FindSet();
                                    FindFirstEntry := false;
                                end else
                                    if VATEntry.Next() = 0 then
                                        repeat
                                            VATType += 1;
                                            VATEntry.SetRange(Type, VATType);
                                        until (VATType = VATEntry.Type::Settlement.AsInteger()) or VATEntry.FindSet();
                                if VATType < VATEntry.Type::Settlement.AsInteger() then
                                    VATEntry.FindLast();
                            end;
                        "VAT Posting Setup"."VAT Calculation Type"::"Sales Tax":
                            begin
                                if FindFirstEntry then begin
                                    if not VATEntry.FindSet() then
                                        repeat
                                            VATType += 1;
                                            VATEntry.SetRange(Type, VATType);
                                        until (VATType = VATEntry.Type::Settlement.AsInteger()) or VATEntry.FindSet();
                                    FindFirstEntry := false;
                                end else begin
                                    VATEntry.SetRange("Tax Jurisdiction Code");
                                    VATEntry.SetRange("Use Tax");
                                    if VATEntry.Next() = 0 then
                                        repeat
                                            VATType += 1;
                                            VATEntry.SetRange(Type, VATType);
                                        until (VATType = VATEntry.Type::Settlement.AsInteger()) or VATEntry.FindSet();
                                end;
                                if VATType < VATEntry.Type::Settlement.AsInteger() then begin
                                    VATEntry.SetRange("Tax Jurisdiction Code", VATEntry."Tax Jurisdiction Code");
                                    VATEntry.SetRange("Use Tax", VATEntry."Use Tax");
                                    VATEntry.FindLast();
                                end;
                            end;
                    end;

                    OnCloseVATEntriesAfterGetRecordOnBeforeBreak(VATEntry);
                    if VATType = VATEntry.Type::Settlement.AsInteger() then
                        CurrReport.Break();

                    // clean buffer
                    "VAT Entry".Reset();
                    "VAT Entry".DeleteAll();

                    if VATEntry.FindSet() then
                        repeat
                            if UseAmtsInAddCurr then begin
                                VATEntry.Base := VATEntry."Additional-Currency Base";
                                VATEntry.Amount := VATEntry."Additional-Currency Amount";
                            end;

                            if VATEntry."Original VAT Entry No. CZL" <> 0 then
                                VATEntry.Base := VATEntry.CalcDeductibleVATBaseCZL();

                            if MergeByDocumentNo then begin
                                "VAT Entry".SetRange("VAT Reporting Date", VATEntry."VAT Reporting Date");
                                "VAT Entry".SetRange("VAT Bus. Posting Group", VATEntry."VAT Bus. Posting Group");
                                "VAT Entry".SetRange("VAT Prod. Posting Group", VATEntry."VAT Prod. Posting Group");
                                "VAT Entry".SetRange("Bill-to/Pay-to No.", VATEntry."Bill-to/Pay-to No.");
                                "VAT Entry".SetRange("Document No.", VATEntry."Document No.");
                            end else
                                "VAT Entry".SetRange("Entry No.", VATEntry."Entry No.");

                            if not "VAT Entry".FindFirst() then begin
                                "VAT Entry".Init();
                                "VAT Entry" := VATEntry;
                                "VAT Entry".Insert()
                            end else begin
                                "VAT Entry".Base += VATEntry.Base;
                                "VAT Entry".Amount += VATEntry.Amount;
                                "VAT Entry"."Non-Deductible VAT Base" += VATEntry."Non-Deductible VAT Base";
                                "VAT Entry"."Non-Deductible VAT Amount" += VATEntry."Non-Deductible VAT Amount";
                                "VAT Entry"."Original VAT Base CZL" += VATEntry."Original VAT Base CZL";
                                "VAT Entry"."Original VAT Amount CZL" += VATEntry."Original VAT Amount CZL";
                                "VAT Entry".Modify();
                            end;
                        until VATEntry.Next() = 0;
                end;

                trigger OnPreDataItem()
                begin
                    VATType := VATEntry.Type::Purchase.AsInteger();
                    FindFirstEntry := true;
                end;
            }
            trigger OnPreDataItem()
            var
                OpenVATEntriesTxt: Label 'Open VAT Entries';
                ClosedVATEntriesTxt: Label 'Closed VAT Entries';
                AllVATEntriesTxt: Label 'Open and Closed VAT Entries';
            begin
                GeneralLedgerSetup.Get();
                if UseAmtsInAddCurr then
                    HeaderText := StrSubstNo(CurrencyTxt, GeneralLedgerSetup."Additional Reporting Currency")
                else begin
                    GeneralLedgerSetup.TestField("LCY Code");
                    HeaderText := StrSubstNo(CurrencyTxt, GeneralLedgerSetup."LCY Code");
                end;
                case Selection of
                    Selection::Open:
                        Heading := OpenVATEntriesTxt;
                    Selection::Closed:
                        Heading := ClosedVATEntriesTxt;
                    Selection::"Open and Closed":
                        Heading := AllVATEntriesTxt;
                end;
                if SettlementNoFilter <> '' then
                    Heading += ', ' + VATEntry.FieldCaption("VAT Settlement No. CZL") + ': ' + SettlementNoFilter;
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
                    field(StartDateReqCZL; StartDateReq)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Starting Date';
                        TableRelation = "VAT Period CZL";
                        ToolTip = 'Specifies the first date in the period for posted VAT entries.';

                        trigger OnValidate()
                        begin
                            VATPeriodCZL.Get(StartDateReq);
                            if VATPeriodCZL.Next() > 0 then
                                EndDateReq := CalcDate('<-1D>', VATPeriodCZL."Starting Date");
                        end;
                    }
                    field(EndDateReqCZL; EndDateReq)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Ending Date';
                        ToolTip = 'Specifies the last date in the period for posted cash documents.';
                    }
                    field(SelectionCZL; Selection)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Include VAT Entries';
                        ToolTip = 'Specifies the filter of VAT entries (open, closed, open and closed).';
                    }
                    field(PrintVATEntriesCZL; PrintVATEntries)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Show VAT Entries';
                        ToolTip = 'Specifies when the vat entries are to be show.';
                    }
                    field(UseAmtsInAddCurrCZL; UseAmtsInAddCurr)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Show Amounts in Add. Reporting Currency';
                        ToolTip = 'Specifies when the amounts in add. reporting currency is to be show.';
                    }
                    field(MergeByDocumentNoCZL; MergeByDocumentNo)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Merge by Document No.';
                        ToolTip = 'Specifies when the vat entries are to be merged by document no.';
                    }
                    field(SettlementNoFilterCZL; SettlementNoFilter)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Filter VAT Settlement No.';
                        ToolTip = 'Specifies the filter setup of document number which the VAT entries were closed.';
                    }
                }
            }
        }
    }

    rendering
    {
        layout("DocumentationForVAT.rdl")
        {
            Type = RDLC;
            LayoutFile = './Src/Reports/DocumentationForVAT.rdl';
            Caption = 'Documentation For VAT (RDL)';
            Summary = 'The Documentation For VAT (RDL) provides a detailed layout.';
        }
        layout("DocumentationForVAT.xlsx")
        {
            Type = Excel;
            LayoutFile = './Src/Reports/DocumentationForVAT.xlsx';
            Caption = 'Documentation For VAT (Excel)';
            Summary = 'The Documentation For VAT (Excel) provides a detailed layout.';
        }
    }

    labels
    {
        ReportCaptionLbl = 'Documentation for VAT';
        PageLbl = 'Page';
        BaseLbl = 'Base';
        AmountLbl = 'Amount';
        TotalLbl = 'Total';
        TotalSalesLbl = 'Total Sales VAT';
        TotalPurchLbl = 'Total Purchase VAT';
        TotalPurchRevChargeLbl = 'Total Purchase (Reverse Charge VAT)';
    }

    trigger OnPreReport()
    begin
        if "VAT Posting Setup".GetFilters() <> '' then
            VATPostingSetupFilter := "VAT Posting Setup".TableCaption() + ': ' + "VAT Posting Setup".GetFilters();
        if EndDateReq = 0D then
            VATEntry.SetFilter("VAT Reporting Date", '%1..', StartDateReq)
        else
            VATEntry.SetRange("VAT Reporting Date", StartDateReq, EndDateReq);
        VATDateFilter := VATEntry.GetFilter("VAT Reporting Date");
    end;

    var
        VATEntry: Record "VAT Entry";
        GeneralLedgerSetup: Record "General Ledger Setup";
        VATPeriodCZL: Record "VAT Period CZL";
        Selection: Enum "VAT Statement Report Selection";
        StartDateReq, EndDateReq : Date;
        PrintVATEntries, FindFirstEntry, UseAmtsInAddCurr, MergeByDocumentNo : Boolean;
        VATType, PrintCountrySubTotal : Integer;
        VATBaseTotal, VATAmountTotal, VATBaseSaleTotal, VATAmountSaleTotal, VATBasePurchTotal, VATAmountPurchTotal, VATBaseReverseChargeVATTotal, VATAmountReverseChargeVATTotal : array[2] of Decimal;
        VATPostingSetupFilter, VATDateFilter, Heading, HeaderText, SettlementNoFilter : Text;
        CountrySubTotalAmt, VATEntrySubtotalAmt : array[4] of Decimal;
        PeriodTxt: Label 'Period: %1', Comment = '%1 = Period';
        CurrencyTxt: Label 'All amounts are in %1', Comment = '%1 = Currency Code';
        TotalPerTxt: Label 'Total for %1 %2 %3', Comment = '%1 = VAT Bus. Posting Group; %2 = VAT Prod. Posting Group; %3 = Type';
        CountrySubtotalCaptionTxt: Label 'Total for Country/Region %1', Comment = '%1 = Country Code';

    procedure InitializeRequest(NewStartDate: Date; NewEndDate: Date; NewPrintVATEntries: Boolean; NewUseAmtsInAddCurr: Boolean)
    begin
        StartDateReq := NewStartDate;
        EndDateReq := NewEndDate;
        PrintVATEntries := NewPrintVATEntries;
        UseAmtsInAddCurr := NewUseAmtsInAddCurr;
        if VATPeriodCZL.Get(StartDateReq) then;
    end;

    local procedure AddTotal(VATEntry: Record "VAT Entry")
    begin
        case VATEntry.Type of
            VATEntry.Type::Purchase:
                begin
                    VATBasePurchTotal[1] += VATEntry.Base;
                    VATAmountPurchTotal[1] += VATEntry.Amount;
                    VATBasePurchTotal[2] += VATEntry."Original VAT Base CZL";
                    VATAmountPurchTotal[2] += VATEntry."Original VAT Amount CZL";

                    if VATEntry."VAT Calculation Type" = VATEntry."VAT Calculation Type"::"Reverse Charge VAT" then begin
                        VATBaseReverseChargeVATTotal[1] -= VATEntry."Original VAT Base CZL";
                        VATAmountReverseChargeVATTotal[1] -= VATEntry."Original VAT Amount CZL";
                        VATBaseReverseChargeVATTotal[2] -= VATEntry."Original VAT Base CZL";
                        VATAmountReverseChargeVATTotal[2] -= VATEntry."Original VAT Amount CZL";
                    end;
                end;
            VATEntry.Type::Sale:
                begin
                    VATBaseSaleTotal[1] += VATEntry.Base;
                    VATAmountSaleTotal[1] += VATEntry.Amount;
                    VATBaseSaleTotal[2] += VATEntry."Original VAT Base CZL";
                    VATAmountSaleTotal[2] += VATEntry."Original VAT Amount CZL";
                end;
        end;

        VATBaseTotal[1] := VATBasePurchTotal[1] + VATBaseReverseChargeVATTotal[1] + VATBaseSaleTotal[1];
        VATAmountTotal[1] := VATAmountPurchTotal[1] + VATAmountReverseChargeVATTotal[1] + VATAmountSaleTotal[1];
        VATBaseTotal[2] := VATBasePurchTotal[2] + VATBaseReverseChargeVATTotal[2] + VATBaseSaleTotal[2];
        VATAmountTotal[2] := VATAmountPurchTotal[2] + VATAmountReverseChargeVATTotal[2] + VATAmountSaleTotal[2];
    end;

    [IntegrationEvent(true, false)]
    local procedure OnCloseVATEntriesAfterGetRecordOnBeforeBreak(var VATEntry: Record "VAT Entry")
    begin
    end;
}