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
            RequestFilterFields = "VAT Date CZL", "VAT Bus. Posting Group", "VAT Prod. Posting Group", "VAT Settlement No. CZL", "Source Code";

            trigger OnPreDataItem()
            var
                VATEntry: Record "VAT Entry";
            begin
                VATEntry.Copy(VATFilter);

                TempVATEntry.SetCurrentKey("Document No.", "Posting Date");
                if VATEntry.FindSet() then
                    repeat
                        TempVATEntry.SetRange("Document No.", VATEntry."Document No.");
                        TempVATEntry.SetRange("VAT Date CZL", VATEntry."VAT Date CZL");
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
                column(VATEntry_VAT_Date; "VAT Date CZL")
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

                    TempVATAmountLineDoc.Init();
                    TempVATAmountLineDoc."VAT Identifier" := VATPostingSetup."VAT Identifier";
                    TempVATAmountLineDoc."VAT Calculation Type" := "VAT Calculation Type";
                    TempVATAmountLineDoc."Tax Group Code" := "Tax Group Code";
                    TempVATAmountLineDoc."VAT %" := VATPostingSetup."VAT %";
                    if "VAT Entry"."Advance Base" <> 0 then begin
                        TempVATAmountLineDoc."VAT Base" := "Advance Base";
                        TempVATAmountLineDoc."Amount Including VAT" := Amount + "Advance Base";
                    end else begin
                        TempVATAmountLineDoc."VAT Base" := Base;
                        TempVATAmountLineDoc."Amount Including VAT" := Amount + Base;
                    end;
                    TempVATAmountLineDoc.InsertLine();

                    TempVATAmountLineTot.Init();
                    TempVATAmountLineTot."VAT Identifier" := VATPostingSetup."VAT Identifier";
                    TempVATAmountLineTot."VAT Calculation Type" := "VAT Calculation Type";
                    TempVATAmountLineTot."Tax Group Code" := "Tax Group Code";
                    TempVATAmountLineTot."VAT %" := VATPostingSetup."VAT %";
                    if "VAT Entry"."Advance Base" <> 0 then begin
                        TempVATAmountLineTot."VAT Base" := "Advance Base";
                        TempVATAmountLineTot."Amount Including VAT" := Amount + "Advance Base";
                    end else begin
                        TempVATAmountLineTot."VAT Base" := Base;
                        TempVATAmountLineTot."Amount Including VAT" := Amount + Base;
                    end;
                    TempVATAmountLineTot.InsertLine();

                    Advance := "Advance Letter No." <> '';
                    if "Advance Base" <> 0 then
                        Base := "Advance Base";
                    AmountWithReverseChargeVAT := Amount;
                    if "VAT Calculation Type" = "VAT Calculation Type"::"Reverse Charge VAT" then
                        AmountWithReverseChargeVAT := 0;

                    HiddenTotalForReverseChargeVAT :=
                      ("VAT Calculation Type" <> "VAT Calculation Type"::"Reverse Charge VAT") or
                      (Type <> Type::Purchase);
                end;

                trigger OnPreDataItem()
                begin
                    Clear(TempVATAmountLineDoc);
                    TempVATAmountLineDoc.Reset();
                    TempVATAmountLineDoc.DeleteAll();

                    CopyFilters(VATFilter);
                    SetRange("Document No.", TempVATEntry."Document No.");
                    SetRange("VAT Date CZL", TempVATEntry."VAT Date CZL");
                end;
            }
            dataitem(DocSummary; "Integer")
            {
                DataItemTableView = sorting(Number) where(Number = filter(1 ..));
                column(DocSummary_VAT_Base; TempVATAmountLineDoc."VAT Base")
                {
                }
                column(DocSummary_VAT_Amount; TempVATAmountLineDoc."VAT Amount")
                {
                }
                column(DocSummary_TaxRate; StrSubstNo(TaxRateTxt, Format(TempVATAmountLineDoc."VAT Identifier")))
                {
                }
                column(DocSummary_VAT_Calculation_Type; Format(TempVATAmountLineDoc."VAT Calculation Type"))
                {
                }
                column(DocSummary_Number; Number)
                {
                }
                trigger OnAfterGetRecord()
                begin
                    if Number = 1 then
                        TempVATAmountLineDoc.FindSet()
                    else
                        TempVATAmountLineDoc.Next();
                end;

                trigger OnPreDataItem()
                var
                    TempVATAmountLine1: Record "VAT Amount Line" temporary;
                begin
                    TempVATAmountLineDoc.Reset();
                    if TempVATAmountLineDoc.FindSet() then begin
                        repeat
                            TempVATAmountLine1.SetRange("VAT Identifier", TempVATAmountLineDoc."VAT Identifier");
                            TempVATAmountLine1.SetRange("VAT Calculation Type", TempVATAmountLineDoc."VAT Calculation Type");
                            TempVATAmountLine1.SetRange("Tax Group Code", TempVATAmountLineDoc."Tax Group Code");
                            TempVATAmountLine1.SetRange("Use Tax", TempVATAmountLineDoc."Use Tax");
                            if TempVATAmountLine1.FindFirst() then begin
                                TempVATAmountLine1."VAT Base" += TempVATAmountLineDoc."VAT Base";
                                TempVATAmountLine1."VAT Amount" += TempVATAmountLineDoc."VAT Amount";
                                TempVATAmountLine1.Modify();
                            end;
                            TempVATAmountLine1 := TempVATAmountLineDoc;
                            TempVATAmountLine1.Insert();
                        until TempVATAmountLineDoc.Next() = 0;

                        TempVATAmountLineDoc.Reset();
                        TempVATAmountLineDoc.DeleteAll();

                        TempVATAmountLine1.Reset();
                        if TempVATAmountLine1.FindSet() then
                            repeat
                                TempVATAmountLineDoc := TempVATAmountLine1;
                                TempVATAmountLineDoc.Insert();
                            until TempVATAmountLine1.Next() = 0;

                        TempVATAmountLine1.Reset();
                        TempVATAmountLine1.DeleteAll();
                    end;

                    TempVATAmountLineDoc.Reset();
                    SetRange(Number, 1, TempVATAmountLineDoc.Count());
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
            DataItemTableView = sorting(Number) WHERE(Number = FILTER(1 ..));
            column(Total_VAT_Calculation_Type; Format(TempVATAmountLineTot."VAT Calculation Type"))
            {
            }
            column(Total_TaxRate; StrSubstNo(TaxRateTxt, Format(TempVATAmountLineTot."VAT Identifier")))
            {
            }
            column(Total_VAT_Base; TempVATAmountLineTot."VAT Base")
            {
            }
            column(Total_VAT_Amount; TempVATAmountLineTot."VAT Amount")
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
                    TempVATAmountLineTot.FindSet()
                else
                    TempVATAmountLineTot.Next();

                if TempVATAmountLineTot."VAT Calculation Type" = TempVATAmountLineTot."VAT Calculation Type"::"Reverse Charge VAT" then
                    TempVATAmountLineTot."VAT Amount" := 0;
            end;

            trigger OnPreDataItem()
            var
                TempVATAmountLine1: Record "VAT Amount Line" temporary;
            begin
                TempVATAmountLineTot.Reset();

                if TempVATAmountLineTot.FindSet() then begin
                    repeat
                        TempVATAmountLine1.SetRange("VAT Identifier", TempVATAmountLineTot."VAT Identifier");
                        TempVATAmountLine1.SetRange("VAT Calculation Type", TempVATAmountLineTot."VAT Calculation Type");
                        TempVATAmountLine1.SetRange("Tax Group Code", TempVATAmountLineTot."Tax Group Code");
                        TempVATAmountLine1.SetRange("Use Tax", TempVATAmountLineTot."Use Tax");
                        if TempVATAmountLine1.FindSet() then begin
                            TempVATAmountLine1."VAT Base" += TempVATAmountLineTot."VAT Base";
                            TempVATAmountLine1."VAT Amount" += TempVATAmountLineTot."VAT Amount";
                            TempVATAmountLine1.Modify();
                        end;
                        TempVATAmountLine1 := TempVATAmountLineTot;
                        TempVATAmountLine1.Insert();
                    until TempVATAmountLineTot.Next() = 0;

                    TempVATAmountLineTot.Reset();
                    TempVATAmountLineTot.DeleteAll();

                    TempVATAmountLine1.Reset();
                    if TempVATAmountLine1.FindSet() then
                        repeat
                            TempVATAmountLineTot := TempVATAmountLine1;
                            TempVATAmountLineTot.Insert();
                        until TempVATAmountLine1.Next() = 0;

                    TempVATAmountLine1.Reset();
                    TempVATAmountLine1.DeleteAll();
                end;

                TempVATAmountLineTot.Reset();
                SetRange(Number, 1, TempVATAmountLineTot.Count());
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

        VATFilter.Copy(Request);
    end;

    var
        TempVATEntry: Record "VAT Entry" temporary;
        VATFilter: Record "VAT Entry";
        TempVATAmountLineDoc: Record "VAT Amount Line" temporary;
        TempVATAmountLineTot: Record "VAT Amount Line" temporary;
        VATPostingSetup: Record "VAT Posting Setup";
        EntryTypeFilter: Option Purchase,Sale,All;
        PrintDetail: Boolean;
        PrintSummary: Boolean;
        PrintTotal: Boolean;
        VATEntryFilters: Text;
        Advance: Boolean;
        TaxRateTxt: Label 'Tax Rate %1', Comment = '%1 = VAT Identifier';
        AmountWithReverseChargeVAT: Decimal;
        HiddenTotalForReverseChargeVAT: Boolean;
}
