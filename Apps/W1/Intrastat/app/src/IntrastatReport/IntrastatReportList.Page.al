#pragma warning disable AA0247
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
                field("No."; Rec."No.") { }
                field(Description; Rec.Description) { }
                field("Statistics Period"; Rec."Statistics Period") { }
                field("Currency Identifier"; Rec."Currency Identifier") { }
                field("Amounts in Add. Currency"; Rec."Amounts in Add. Currency")
                {
                    Visible = false;
                }
                field(Reported; Rec.Reported) { }
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
