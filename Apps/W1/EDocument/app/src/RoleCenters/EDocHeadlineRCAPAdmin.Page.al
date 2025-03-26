namespace Microsoft.eServices.EDocument;

using System.Visualization;

page 6102 "E-Doc. Headline RC A/P Admin"
{
    Caption = 'Headline';
    PageType = HeadlinePart;
    RefreshOnActivate = true;

    //TODO Replace with real Headline

    layout
    {
        area(Content)
        {
            group(Control1)
            {
                ShowCaption = false;
                Visible = true;
                field(GreetingText; RCHeadlinesPageCommon.GetGreetingText())
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Greeting headline';
                    Editable = false;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        // Set the headline to be the first one in the list.
        RCHeadlinesPageCommon.HeadlineOnOpenPage(Page::"E-Doc. Headline RC A/P Admin");
    end;

    var
        RCHeadlinesPageCommon: Codeunit "RC Headlines Page Common";
}
