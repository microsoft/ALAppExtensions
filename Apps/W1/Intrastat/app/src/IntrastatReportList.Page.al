page 4811 "Intrastat Report List"
{
    ApplicationArea = All;
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
                    ToolTip = 'Specifies the Intrastat Report number.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies some information about the Intrastat Report.';
                }
                field("Statistics Period"; Rec."Statistics Period")
                {
                    ToolTip = 'Specifies the month to report data for. Enter the period as a four-digit number, with no spaces or symbols. Enter the year first and then the month, for example, enter 1706 for June, 2017.';
                }
                field("Currency Identifier"; Rec."Currency Identifier")
                {
                    ToolTip = 'Specifies a code that identifies the currency of the Intrastat Report.';
                }
                field("Amounts in Add. Currency"; Rec."Amounts in Add. Currency")
                {
                    ToolTip = 'Specifies that you use an additional reporting currency in the general ledger and that you want to report Intrastat in this currency.';
                    Visible = false;
                }
                field(Reported; Rec.Reported)
                {
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
}