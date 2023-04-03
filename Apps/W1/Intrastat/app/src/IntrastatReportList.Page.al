page 4811 "Intrastat Report List"
{
    ApplicationArea = BasicEU, BasicNO, BasicCH;
    Caption = 'Intrastat Report List';
    CardPageID = "Intrastat Report";
    DataCaptionFields = "No.", Description;
    Editable = false;
    PageType = List;
    RefreshOnActivate = true;
    SourceTable = "Intrastat Report Header";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("No."; Rec."No.")
                {
                    ApplicationArea = BasicEU, BasicNO, BasicCH;
                    ToolTip = 'Specifies the Intrastat Report number.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = BasicEU, BasicNO, BasicCH;
                    ToolTip = 'Specifies some information about the Intrastat Report.';
                }
                field("Statistics Period"; Rec."Statistics Period")
                {
                    ApplicationArea = BasicEU, BasicNO, BasicCH;
                    ToolTip = 'Specifies the month to report data for. Enter the period as a four-digit number, with no spaces or symbols. Enter the year first and then the month, for example, enter 1706 for June, 2017.';
                }
                field("Currency Identifier"; Rec."Currency Identifier")
                {
                    ApplicationArea = BasicEU, BasicNO, BasicCH;
                    ToolTip = 'Specifies a code that identifies the currency of the Intrastat Report.';
                }
                field("Amounts in Add. Currency"; Rec."Amounts in Add. Currency")
                {
                    ApplicationArea = BasicEU, BasicNO, BasicCH;
                    ToolTip = 'Specifies that you use an additional reporting currency in the general ledger and that you want to report Intrastat in this currency.';
                    Visible = false;
                }
                field(Reported; Rec.Reported)
                {
                    ApplicationArea = BasicEU, BasicNO, BasicCH;
                    ToolTip = 'Specifies whether the entry has already been reported to the tax authorities.';
                }
            }
        }
        area(factboxes)
        {
            systempart(LinksFactBox; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(NotesFactBox; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }

#if not CLEAN22
    trigger OnOpenPage()
    var
        IntrastatReportMgt: Codeunit IntrastatReportManagement;
        ApplicationAreaMgmt: Codeunit "Application Area Mgmt.";
    begin
        if not IntrastatReportMgt.IsFeatureEnabled() then begin
            IntrastatReportMgt.ShowNotEnabledMessage(CurrPage.Caption);
            if ApplicationAreaMgmt.IsBasicCountryEnabled('EU') then
                Page.Run(Page::"Intrastat Journal")
            else
                Page.Run(Page::"Feature Management");
            Error('');
        end;
    end;
#endif
}