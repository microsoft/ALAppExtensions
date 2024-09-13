namespace Microsoft.Manufacturing.PowerBIReports;

using Microsoft.Manufacturing.WorkCenter;

query 36991 "Work Centers"
{
    Access = Internal;
    Caption = 'Power BI Work Centers';
    QueryType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'workCenter';
    EntitySetName = 'workCenters';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(WorkCenter; "Work Center")
        {
            column(no; "No.")
            {
            }
            column(name; Name)
            {
            }
            column(workCenterGroupCode; "Work Center Group Code")
            {
            }
            dataitem(WorkCenterGroup; "Work Center Group")
            {
                DataItemLink = Code = WorkCenter."Work Center Group Code";
                column(workCenterGroupName; Name)
                {
                }
            }
        }
    }
}