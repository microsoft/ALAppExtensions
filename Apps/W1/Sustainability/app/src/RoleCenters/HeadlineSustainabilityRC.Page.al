namespace Microsoft.Sustainability.RoleCenters;

using System.Visualization;

page 6238 "Headline Sustainability RC"
{
    // NOTE: If you are making changes to this page you might want to make changes to all the other Headline RC pages

    Caption = 'Headline';
    PageType = HeadlinePart;
    RefreshOnActivate = true;

    layout
    {
        area(content)
        {
            group(Greeting)
            {
                ShowCaption = false;
                Visible = UserGreetingVisible;
                field(GreetingText; RCHeadlinesPageCommon.GetGreetingText())
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Greeting headline';
                    Editable = false;
                }
            }
            group(Footprint)
            {
                ShowCaption = false;
                Visible = CanShowCarbonFootprintHeadline;
                field(FootprintText; RCHeadlinePageSust.GetFootPrintText())
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Footprint headline';
                    Editable = false;
                }
            }
            group(Documentation)
            {
                ShowCaption = false;
                Visible = DefaultFieldsVisible;
                field(DocumentationText; RCHeadlinesPageCommon.GetDocumentationText())
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Documentation headline';
                    DrillDown = true;
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        HyperLink(RCHeadlinesPageCommon.DocumentationUrlTxt());
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Refresh Now")
            {
                ApplicationArea = All;
                Caption = 'Refresh Now';
                Image = Refresh;
                ToolTip = 'Refresh Headlines for Sustainability Emission and Carbon Foorprint';

                trigger OnAction()
                begin
                    RCHeadlinePageSust.GetFootPrintText();
                    FormatLine();
                    CurrPage.Update();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        RCHeadlinesPageCommon.HeadlineOnOpenPage(Page::"Headline RC Order Processor");
        DefaultFieldsVisible := RCHeadlinesPageCommon.AreDefaultFieldsVisible();
        UserGreetingVisible := RCHeadlinesPageCommon.IsUserGreetingVisible();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        FormatLine();
    end;

    trigger OnAfterGetRecord()
    begin
        FormatLine();
    end;

    local procedure FormatLine()
    begin
        CanShowCarbonFootprintHeadline := RCHeadlinePageSust.CanShowFootPrint();
    end;

    var
        RCHeadlinesPageCommon: Codeunit "RC Headlines Page Common";
        RCHeadlinePageSust: Codeunit "RC Headline Page Sust.";
        DefaultFieldsVisible: Boolean;
        UserGreetingVisible: Boolean;
        CanShowCarbonFootprintHeadline: Boolean;
}