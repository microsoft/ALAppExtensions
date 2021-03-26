#if not CLEAN18
page 4013 "Intelligent Cloud Insights"
{
    PageType = Card;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    UsageCategory = Tasks;
    ApplicationArea = Basic, Suite;
    ObsoleteReason = 'Intelligent Cloud Insights is discontinued';
    ObsoleteState = Pending;
    ObsoleteTag = '18.0';
    HelpLink = 'https://go.microsoft.com/fwlink/?linkid=2009758 ';
    layout
    {
        area(Content)
        {
            group(KPIs)
            {
                Caption = 'KPIs';
                part(IntelligentEdgeKPIS; "Intelligent Edge KPIs")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'KPIs';
                }
                part(IntelligentEdgeInsights; "Intelligent Edge Insights")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Insights';
                }

            }
            group(Insight)
            {
                Caption = 'Power BI';
                part(PowerBIReportSpinnerPart; "Power BI Report Spinner Part")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Power BI Report';
                    UpdatePropagation = Both;
                    AccessByPermission = tabledata 6304 = I;
                }
                part(PowerBIReportSpinnerPart2; "Power BI Report Spinner Part")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Power BI Report';
                    UpdatePropagation = Both;
                    AccessByPermission = tabledata 6304 = I;
                }
            }
            group(MachineLearning)
            {
                Caption = 'Azure ML';
                part(CashFlowForecastChart; "Cash Flow Forecast Chart")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Cash Flow Forecast';
                    UpdatePropagation = Both;
                    AccessByPermission = TableData 110 = R;
                }
            }
        }
    }

    var

    trigger OnOpenPage()
    var

    begin
        CurrPage.PowerBIReportSpinnerPart.Page.SetContext('4009PowerBIPartOne');
        CurrPage.PowerBIReportSpinnerPart2.Page.SetContext('4009PowerBIPartTwo');
    end;
}
#endif