// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Finance.VAT.Calculation;
using Microsoft.Finance.VAT.Ledger;
using Microsoft.Finance.VAT.Setup;
using System.Utilities;

report 11756 "VAT Documents List CZL"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/VATDocumentsList.rdl';
    ApplicationArea = Basic, Suite;
    Caption = 'VAT Documents';
    UsageCategory = ReportsAndAnalysis;
    PreviewMode = PrintLayout;

    dataset
    {
        dataitem(Request; "VAT Entry")
        {
            DataItemTableView = sorting(Type, Closed, "VAT Bus. Posting Group", "VAT Prod. Posting Group", "Posting Date");
#if not CLEAN22
#pragma warning disable AL0432
            RequestFilterFields = "VAT Date CZL", "VAT Bus. Posting Group", "VAT Prod. Posting Group", "VAT Settlement No. CZL", "Source Code";
#pragma warning restore AL0432
#else
            RequestFilterFields = "VAT Reporting Date", "VAT Bus. Posting Group", "VAT Prod. Posting Group", "VAT Settlement No. CZL", "Source Code";
#endif

            trigger OnPreDataItem()
            var
                VATEntry: Record "VAT Entry";
            begin
                VATEntry.Copy(FilterVATEntry);

                TempVATEntry.SetCurrentKey("Document No.", "Posting Date");
                if VATEntry.FindSet() then
                    repeat
                        TempVATEntry.SetRange("Document No.", VATEntry."Document No.");
#if not CLEAN22
#pragma warning disable AL0432
                        if not TempVATEntry.IsReplaceVATDateEnabled() then
                            TempVATEntry.SetRange("VAT Date CZL", VATEntry."VAT Date CZL")
                        else
#pragma warning restore AL0432
#endif
                        TempVATEntry.SetRange("VAT Reporting Date", VATEntry."VAT Reporting Date");
                        if not TempVATEntry.FindFirst() then begin
                            TempVATEntry := VATEntry;
                            TempVATEntry.Insert();
                        end;
                    until VATEntry.Next() = 0;
                CurrReport.Break();
            end;
        }
        dataitem(Loop; "Integer")
        {
            DataItemTableView = sorting(Number) where(Number = filter(1 ..));
            column(COMPANYNAME; CompanyProperty.DisplayName())
            {
            }
            column(VATEntryFilters; VATEntryFilters)
            {
            }
            column(Integer_Number; Number)
            {
            }
            column(PrintDetail; PrintDetail)
            {
            }
            column(PrintSummary; PrintSummary)
            {
            }
            column(PrintTotal; PrintTotal)
            {
            }
            dataitem("VAT Entry"; "VAT Entry")
            {
                DataItemTableView = sorting("Document No.", "Posting Date");
                column(Loop_Number; Loop.Number)
                {
                }
                column(VATEntry_Type; Type)
                {
                    IncludeCaption = true;
                }
                column(VATEntry_Amount; Amount)
                {
                    IncludeCaption = true;
                }
                column(VATEntry_Base; Base)
                {
                    IncludeCaption = true;
                }
                column(VATEntry_VAT_Prod_Posting_Group; "VAT Prod. Posting Group")
                {
                    IncludeCaption = true;
                }
                column(VATEntry_VAT_Bus_Posting_Group; "VAT Bus. Posting Group")
                {
                    IncludeCaption = true;
                }
                column(VATEntry_External_Document_No; "External Document No.")
                {
                    IncludeCaption = true;
                }
                column(VATEntry_Document_No; "Document No.")
                {
                    IncludeCaption = true;
                }
                column(VATEntry_Document_Type; "Document Type")
                {
                    IncludeCaption = true;
                }
                column(VATEntry_VAT_Date; "VAT Reporting Date")
                {
                    IncludeCaption = true;
                }
                column(Advance; Advance)
                {
                }
                column(AmountWithReverseChargeVAT; AmountWithReverseChargeVAT)
                {
                }
                column(VATEntry_VATRegistrationNo; "VAT Registration No.")
                {
                    IncludeCaption = true;
                }
                column(VATEntry_CountryRegionCode; "Country/Region Code")
                {
                    IncludeCaption = true;
                }
                column(VATEntry_VATCalculationType; "VAT Calculation Type")
                {
                }
                column(HiddenTotalForReverseChargeVAT; HiddenTotalForReverseChargeVAT)
                {
                }
                trigger OnAfterGetRecord()
                var
                    NoneTxt: Label '<NONE>';
                begin
                    if not VATPostingSetup.Get("VAT Bus. Posting Group", "VAT Prod. Posting Group") then begin
                        VATPostingSetup.Init();
                        VATPostingSetup."VAT Identifier" := NoneTxt;
                    end;

                    TempDocVATAmountLine.Init();
                    TempDocVATAmountLine."VAT Identifier" := VATPostingSetup."VAT Identifier";
                    TempDocVATAmountLine."VAT Calculation Type" := "VAT Calculation Type";
                    TempDocVATAmountLine."Tax Group Code" := "Tax Group Code";
                    TempDocVATAmountLine."VAT %" := VATPostingSetup."VAT %";
                    TempDocVATAmountLine."VAT Base" := Base;
                    TempDocVATAmountLine."Amount Including VAT" := Amount + Base;
                    TempDocVATAmountLine.InsertLine();

                    TempTotVATAmountLine.Init();
                    TempTotVATAmountLine."VAT Identifier" := VATPostingSetup."VAT Identifier";
                    TempTotVATAmountLine."VAT Calculation Type" := "VAT Calculation Type";
                    TempTotVATAmountLine."Tax Group Code" := "Tax Group Code";
                    TempTotVATAmountLine."VAT %" := VATPostingSetup."VAT %";
                    TempTotVATAmountLine."VAT Base" := Base;
                    TempTotVATAmountLine."Amount Including VAT" := Amount + Base;
                    TempTotVATAmountLine.InsertLine();

                    Advance := IsAdvanceEntryCZL();
                    AmountWithReverseChargeVAT := Amount;
                    if "VAT Calculation Type" = "VAT Calculation Type"::"Reverse Charge VAT" then
                        AmountWithReverseChargeVAT := 0;

                    HiddenTotalForReverseChargeVAT :=
                      ("VAT Calculation Type" <> "VAT Calculation Type"::"Reverse Charge VAT") or
                      (Type <> Type::Purchase);
#if not CLEAN22
#pragma warning disable AL0432
                    if not IsReplaceVATDateEnabled() then
                        "VAT Reporting Date" := "VAT Date CZL";
#pragma warning restore AL0432
#endif
                end;

                trigger OnPreDataItem()
                begin
                    Clear(TempDocVATAmountLine);
                    TempDocVATAmountLine.Reset();
                    TempDocVATAmountLine.DeleteAll();

                    CopyFilters(FilterVATEntry);
                    SetRange("Document No.", TempVATEntry."Document No.");
#if not CLEAN22
#pragma warning disable AL0432
                    if not IsReplaceVATDateEnabled() then
                        SetRange("VAT Date CZL", TempVATEntry."VAT Date CZL")
                    else
#pragma warning restore AL0432
#endif
                    SetRange("VAT Reporting Date", TempVATEntry."VAT Reporting Date");
                end;
            }
            dataitem(DocSummary; "Integer")
            {
                DataItemTableView = sorting(Number) where(Number = filter(1 ..));
                column(DocSummary_VAT_Base; TempDocVATAmountLine."VAT Base")
                {
                }
                column(DocSummary_VAT_Amount; TempDocVATAmountLine."VAT Amount")
                {
                }
                column(DocSummary_TaxRate; StrSubstNo(TaxRateTxt, Format(TempDocVATAmountLine."VAT Identifier")))
                {
                }
                column(DocSummary_VAT_Calculation_Type; Format(TempDocVATAmountLine."VAT Calculation Type"))
                {
                }
                column(DocSummary_Number; Number)
                {
                }
                trigger OnAfterGetRecord()
                begin
                    if Number = 1 then
                        TempDocVATAmountLine.FindSet()
                    else
                        TempDocVATAmountLine.Next();
                end;

                trigger OnPreDataItem()
                var
                    TempVATAmountLine1: Record "VAT Amount Line" temporary;
                begin
                    TempDocVATAmountLine.Reset();
                    if TempDocVATAmountLine.FindSet() then begin
                        repeat
                            TempVATAmountLine1.SetRange("VAT Identifier", TempDocVATAmountLine."VAT Identifier");
                            TempVATAmountLine1.SetRange("VAT Calculation Type", TempDocVATAmountLine."VAT Calculation Type");
                            TempVATAmountLine1.SetRange("Tax Group Code", TempDocVATAmountLine."Tax Group Code");
                            TempVATAmountLine1.SetRange("Use Tax", TempDocVATAmountLine."Use Tax");
                            if TempVATAmountLine1.FindFirst() then begin
                                TempVATAmountLine1."VAT Base" += TempDocVATAmountLine."VAT Base";
                                TempVATAmountLine1."VAT Amount" += TempDocVATAmountLine."VAT Amount";
                                TempVATAmountLine1.Modify();
                            end;
                            TempVATAmountLine1 := TempDocVATAmountLine;
                            TempVATAmountLine1.Insert();
                        until TempDocVATAmountLine.Next() = 0;

                        TempDocVATAmountLine.Reset();
                        TempDocVATAmountLine.DeleteAll();

                        TempVATAmountLine1.Reset();
                        if TempVATAmountLine1.FindSet() then
                            repeat
                                TempDocVATAmountLine := TempVATAmountLine1;
                                TempDocVATAmountLine.Insert();
                            until TempVATAmountLine1.Next() = 0;

                        TempVATAmountLine1.Reset();
                        TempVATAmountLine1.DeleteAll();
                    end;

                    TempDocVATAmountLine.Reset();
                    SetRange(Number, 1, TempDocVATAmountLine.Count());
                end;
            }
            trigger OnAfterGetRecord()
            begin
                if Number = 1 then
                    TempVATEntry.FindSet()
                else
                    TempVATEntry.Next();
            end;

            trigger OnPreDataItem()
            begin
                TempVATEntry.Reset();
                TempVATEntry.SetCurrentKey("Document No.", "Posting Date");
                SetRange(Number, 1, TempVATEntry.Count());
            end;
        }
        dataitem(Total; "Integer")
        {
            DataItemTableView = sorting(Number) where(Number = filter(1 ..));
            column(Total_VAT_Calculation_Type; Format(TempTotVATAmountLine."VAT Calculation Type"))
            {
            }
            column(Total_TaxRate; StrSubstNo(TaxRateTxt, Format(TempTotVATAmountLine."VAT Identifier")))
            {
            }
            column(Total_VAT_Base; TempTotVATAmountLine."VAT Base")
            {
            }
            column(Total_VAT_Amount; TempTotVATAmountLine."VAT Amount")
            {
            }
            column(Total_Number; Number)
            {
            }
            column(HideHeader; PrintDetail or PrintSummary or PrintTotal)
            {
            }
            trigger OnAfterGetRecord()
            begin
                if Number = 1 then
                    TempTotVATAmountLine.FindSet()
                else
                    TempTotVATAmountLine.Next();
            end;

            trigger OnPreDataItem()
            var
                TempVATAmountLine1: Record "VAT Amount Line" temporary;
            begin
                TempTotVATAmountLine.Reset();

                if TempTotVATAmountLine.FindSet() then begin
                    repeat
                        TempVATAmountLine1.SetRange("VAT Identifier", TempTotVATAmountLine."VAT Identifier");
                        TempVATAmountLine1.SetRange("VAT Calculation Type", TempTotVATAmountLine."VAT Calculation Type");
                        TempVATAmountLine1.SetRange("Tax Group Code", TempTotVATAmountLine."Tax Group Code");
                        TempVATAmountLine1.SetRange("Use Tax", TempTotVATAmountLine."Use Tax");
                        if TempVATAmountLine1.FindSet() then begin
                            TempVATAmountLine1."VAT Base" += TempTotVATAmountLine."VAT Base";
                            TempVATAmountLine1."VAT Amount" += TempTotVATAmountLine."VAT Amount";
                            TempVATAmountLine1.Modify();
                        end;
                        TempVATAmountLine1 := TempTotVATAmountLine;
                        TempVATAmountLine1.Insert();
                    until TempTotVATAmountLine.Next() = 0;

                    TempTotVATAmountLine.Reset();
                    TempTotVATAmountLine.DeleteAll();

                    TempVATAmountLine1.Reset();
                    if TempVATAmountLine1.FindSet() then
                        repeat
                            TempTotVATAmountLine := TempVATAmountLine1;
                            TempTotVATAmountLine.Insert();
                        until TempVATAmountLine1.Next() = 0;

                    TempVATAmountLine1.Reset();
                    TempVATAmountLine1.DeleteAll();
                end;

                TempTotVATAmountLine.Reset();
                SetRange(Number, 1, TempTotVATAmountLine.Count());
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
                    field(EntryTypeFilterCZL; EntryTypeFilter)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'VAT Type';
                        OptionCaption = 'Purchase,Sale,All';
                        ToolTip = 'Specifies vat type';
                    }
                    field(PrintDetailCZL; PrintDetail)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Print Document VAT Entries';
                        ToolTip = 'Specifies if document VAT entries have to be printed.';
                    }
                    field(PrintSummaryCZL; PrintSummary)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Print Document Summary';
                        ToolTip = 'Specifies if document summary has to be printed.';
                    }
                    field(PrintTotalCZL; PrintTotal)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Print Document Totals';
                        ToolTip = 'Specifies if document totals has to be printed.';
                    }
                }
            }
        }
    }
    labels
    {
        ReportCaptionLbl = 'VAT Document List';
        PageLbl = 'Page';
        AdvanceLbl = 'Adv.';
        TotalsLbl = 'Totals';
        Total_VATsLbl = 'Total VATs';
        DocTotalsRevChargeVATLbl = 'Document Totals (Reverse Charge VAT)';
    }
    trigger OnPreReport()
    var
        SalesEntriesTxt: Label 'Sales VAT Entries';
        PurchEntriesTxt: Label 'Purchase VAT Entries';
        AllEntriesTxt: Label 'Both Purchase and Sales VAT Entries';
    begin
        Request.SetRange(Type);
        case EntryTypeFilter of
            EntryTypeFilter::Purchase:
                begin
                    Request.SetRange(Type, Request.Type::Purchase);
                    VATEntryFilters := PurchEntriesTxt;
                end;
            EntryTypeFilter::Sale:
                begin
                    Request.SetRange(Type, Request.Type::Sale);
                    VATEntryFilters := SalesEntriesTxt;
                end;
            EntryTypeFilter::All:
                begin
                    Request.SetRange(Type, Request.Type::Purchase, Request.Type::Sale);
                    VATEntryFilters := AllEntriesTxt;
                end;
        end;
        if Request.GetFilters() <> '' then
            VATEntryFilters += '; ' + Request.TableCaption() + ': ' + Request.GetFilters();
#if not CLEAN22
#pragma warning disable AL0432
        if Request.IsReplaceVATDateEnabled() then begin
            Request.CopyFilter("VAT Date CZL", Request."VAT Reporting Date");
            Request.SetRange("VAT Date CZL");
        end;
#pragma warning restore AL0432
#endif
        FilterVATEntry.Copy(Request);
    end;

    var
        TempVATEntry: Record "VAT Entry" temporary;
        FilterVATEntry: Record "VAT Entry";
        TempDocVATAmountLine: Record "VAT Amount Line" temporary;
        TempTotVATAmountLine: Record "VAT Amount Line" temporary;
        VATPostingSetup: Record "VAT Posting Setup";
        EntryTypeFilter: Option Purchase,Sale,All;
        PrintDetail, PrintSummary, PrintTotal, Advance, HiddenTotalForReverseChargeVAT : Boolean;
        VATEntryFilters: Text;
        TaxRateTxt: Label 'Tax Rate %1', Comment = '%1 = VAT Identifier';
        AmountWithReverseChargeVAT: Decimal;
}
