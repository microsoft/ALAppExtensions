namespace Microsoft.Finance.PowerBIReports;

page 36964 "PBI Close Income Stmt. SC."
{
    Caption = 'Power BI Close Income Statement Source Codes';
    PageType = List;
    SourceTable = "PBI C. Income St. Source Code";
    AnalysisModeEnabled = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Source Code"; Rec."Source Code")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}