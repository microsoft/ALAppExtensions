namespace Microsoft.Finance.PowerBIReports;

query 37013 "Close Income Source - PBI API"
{
    Caption = 'Power BI Close Income Statement Source Code';
    QueryType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    ApiVersion = 'v0.5', 'v1.0';
    EntityName = 'closeIncomeStmtSourceCode';
    EntitySetName = 'closeIncomeStmtSourceCodes';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(closeIncomeStmtSourceCode; "PBI C. Income St. Source Code")
        {
            column(sourceCode; "Source Code")
            {
            }
        }
    }
}