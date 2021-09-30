#pragma implicitwith disable
page 31136 "VAT Statement Preview Line CZL"
{
    Caption = 'Lines';
    Editable = false;
    LinksAllowed = false;
    PageType = ListPart;
    SourceTable = "VAT Statement Line";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Row No."; Rec."Row No.")
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies a number that identifies the line.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies a description of the VAT statement line.';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies what the VAT statement line will include.';
                }
                field("G/L Amount Type CZL"; Rec."G/L Amount Type CZL")
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies the general ledger amount type for the VAT statement line.';
                    Visible = false;
                }
                field("Gen. Posting Type"; Rec."Gen. Posting Type")
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies a general posting type that will be used with the VAT statement.';
                }
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies the VAT specification of the involved customer or vendor to link transactions made for this record with the appropriate general ledger account according to the VAT posting setup.';
                }
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies the VAT specification of the involved item or resource to link transactions made for this record with the appropriate general ledger account according to the VAT posting setup.';
                }
                field("Amount Type"; Rec."Amount Type")
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies if the VAT statement line shows the VAT amounts, or the base amounts on which the VAT is calculated.';
                }
                field("Gen. Bus. Posting Group CZL"; Rec."Gen. Bus. Posting Group CZL")
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies the code for the Gen. Bus. Posting Group that applies to the entry.';
                    Visible = false;
                }
                field("Gen. Prod. Posting Group CZL"; Rec."Gen. Prod. Posting Group CZL")
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies the code for the Gen. Prod. Posting Group that applies to the entry.';
                    Visible = false;
                }
                field("EU-3 Party Trade CZL"; Rec."EU-3 Party Trade CZL")
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies whether the document is part of a three-party trade.';
                    Visible = false;
                }
                field("EU 3-Party Intermed. Role CZL"; Rec."EU 3-Party Intermed. Role CZL")
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies when the VAT entry will use European Union third-party intermediate trade rules. This option complies with VAT accounting standards for EU third-party trade.';
                    Visible = false;
                }
#if not CLEAN19
                field("Prepayment Type"; Rec."Prepayment Type")
                {
                    ApplicationArea = Prepayments;
                    ToolTip = 'Specifies the VAT statement prepayment type.';
                    Visible = false;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Replaced by Advance Payments Localization for Czech.';
                    ObsoleteTag = '19.0';
                }
#endif
                field("Tax Jurisdiction Code"; Rec."Tax Jurisdiction Code")
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies a tax jurisdiction code for the statement.';
                    Visible = false;
                }
                field("Use Tax"; Rec."Use Tax")
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies whether to use only entries from the VAT Entry table that are marked as Use Tax to be totaled on this line.';
                    Visible = false;
                }
                field(ColumnValue; ColumnValue)
                {
                    ApplicationArea = VAT;
                    AutoFormatType = 1;
                    BlankZero = true;
                    Caption = 'Column Amount';
                    DrillDown = true;
                    ToolTip = 'Specifies the type of entries that will be included in the amounts in columns.';

                    trigger OnDrillDown()
                    var
                        IsHandled: Boolean;
                    begin
                        case Rec.Type of
                            Rec.Type::"Account Totaling":
                                begin
                                    GLEntry.SetFilter("G/L Account No.", Rec."Account Totaling");
                                    GLEntry.SetRange("VAT Bus. Posting Group");
                                    GLEntry.SetRange("VAT Prod. Posting Group");
                                    if Rec."VAT Bus. Posting Group" <> '' then
                                        GLEntry.SetRange("VAT Bus. Posting Group", Rec."VAT Bus. Posting Group");
                                    if Rec."VAT Prod. Posting Group" <> '' then
                                        GLEntry.SetRange("VAT Prod. Posting Group", Rec."VAT Prod. Posting Group");
                                    Rec.CopyFilter("Date Filter", GLEntry."VAT Date CZL");

                                    Page.Run(Page::"General Ledger Entries", GLEntry);
                                end;
                            Rec.Type::"VAT Entry Totaling":
                                begin
                                    VATEntry.Reset();
                                    if not VATEntry.SetCurrentKey(
                                         Type, Closed, "VAT Bus. Posting Group", "VAT Prod. Posting Group",
                                         "Gen. Bus. Posting Group", "Gen. Prod. Posting Group",
                                         "EU 3-Party Trade")
                                    then
                                        VATEntry.SetCurrentKey(
                                          Type, Closed, "Tax Jurisdiction Code", "Use Tax", "Posting Date");
                                    VATEntry.SetVATStatementLineFiltersCZL(Rec);
                                    if Rec.GetFilter("Date Filter") <> '' then
                                        VATEntry.SetPeriodFilterCZL(VATStatementReportPeriodSelection, Rec.GetRangeMin("Date Filter"), Rec.GetRangeMax("Date Filter"), GeneralLedgerSetup."Use VAT Date CZL");
                                    if SettlementNoFilter <> '' then
                                        VATEntry.SetRange("VAT Settlement No. CZL", SettlementNoFilter);
                                    VATEntry.SetClosedFilterCZL(VATStatementReportSelection);
                                    OnBeforeOpenPageVATEntryTotaling(VATEntry, Rec);
                                    Page.Run(Page::"VAT Entries", VATEntry);
                                end;
                            else begin
                                    IsHandled := false;
                                    OnColumnValueDrillDownVATStatementLineTypeCase(Rec, IsHandled);
                                    if not IsHandled then
                                        Error(DrilldownErr, Rec.FieldCaption(Type), Rec.Type);
                                end;
                        end;
                    end;
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        if not GeneralLedgerSetup.Get() then
            GeneralLedgerSetup.Init();
        Clear(Currency);
        Currency.InitRoundingPrecision();
    end;

    trigger OnAfterGetRecord()
    begin
        CalcColumnValue(Rec, ColumnValue, 0);
        if Rec."Print with" = Rec."Print with"::"Opposite Sign" then
            ColumnValue := -ColumnValue;

        ColumnValue := Round(ColumnValue, Currency."Amount Rounding Precision");
    end;

    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        Currency: Record Currency;
        GLEntry: Record "G/L Entry";
        VATEntry: Record "VAT Entry";
        VATStatementCZL: Report "VAT Statement CZL";
        UseAmtsInAddCurr: Boolean;
        ColumnValue: Decimal;
        VATStatementReportPeriodSelection: Enum "VAT Statement Report Period Selection";
        VATStatementReportSelection: Enum "VAT Statement Report Selection";
        SettlementNoFilter: Text[50];
        DrilldownErr: Label 'Drilldown is not possible when %1 is %2.', Comment = '%1=fieldcaption, %2=VAT statement line type';

    local procedure CalcColumnValue(VATStatementLine: Record "VAT Statement Line"; var ColumnValue: Decimal; Level: Integer)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCalcColumnValue(VATStatementLine, ColumnValue, Level, IsHandled);
        if IsHandled then
            exit;

        if VATStatementLine.Type = VATStatementLine.Type::"VAT Entry Totaling" then
            VATStatementLine.TestField("Amount Type");
        VATStatementCZL.CalcLineTotal(VATStatementLine, ColumnValue, Level);
        case VATStatementLine."Show CZL" of
            VATStatementLine."Show CZL"::"Zero If Negative":
                if ColumnValue < 0 then
                    ColumnValue := 0;
            VATStatementLine."Show CZL"::"Zero If Positive":
                if ColumnValue > 0 then
                    ColumnValue := 0;
        end;
    end;

    procedure UpdateForm(var VATStatementName: Record "VAT Statement Name"; NewSelection: Enum "VAT Statement Report Selection"; NewPeriodSelection: Enum "VAT Statement Report Period Selection"; NewUseAmtsInAddCurr: Boolean; SettlementNoFilter2: Text[50])
    begin
        Rec.SetRange("Statement Template Name", VATStatementName."Statement Template Name");
        Rec.SetRange("Statement Name", VATStatementName.Name);
        VATStatementName.CopyFilter("Date Filter", Rec."Date Filter");
        VATStatementReportSelection := NewSelection;
        VATStatementReportPeriodSelection := NewPeriodSelection;
        UseAmtsInAddCurr := NewUseAmtsInAddCurr;
        VATStatementCZL.InitializeRequest(VATStatementName, Rec, VATStatementReportSelection, VATStatementReportPeriodSelection, false, UseAmtsInAddCurr, SettlementNoFilter2);
        SettlementNoFilter := SettlementNoFilter2;
        OnUpdateFormOnBeforePageUpdate(VATStatementName, Rec, VATStatementReportSelection, VATStatementReportPeriodSelection, false, UseAmtsInAddCurr, SettlementNoFilter2);
        CurrPage.Update();
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeCalcColumnValue(VATStatementLine: Record "VAT Statement Line"; var TotalAmount: Decimal; Level: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeOpenPageVATEntryTotaling(var VATEntry: Record "VAT Entry"; var VATStatementLine: Record "VAT Statement Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateFormOnBeforePageUpdate(var NewVATStatementName: Record "VAT Statement Name"; var NewVATStatementLine: Record "VAT Statement Line"; NewSelection: Enum "VAT Statement Report Selection"; NewPeriodSelection: Enum "VAT Statement Report Period Selection"; NewPrintInIntegers: Boolean; NewUseAmtsInAddCurr: Boolean; SettlementNoFilter2: Text[50])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnColumnValueDrillDownVATStatementLineTypeCase(VATStatementLine: Record "VAT Statement Line"; var IsHandled: Boolean)
    begin
    end;
}
