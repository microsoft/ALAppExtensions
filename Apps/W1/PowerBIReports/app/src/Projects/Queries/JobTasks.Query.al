namespace Microsoft.Projects.PowerBIReports;

using Microsoft.Projects.Project.Job;

query 36994 "Job Tasks"
{
    Access = Internal;
    QueryType = API;
    Caption = 'Power BI Job Tasks';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'jobTask';
    EntitySetName = 'jobTasks';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(jobTask; "Job Task")
        {
            column(jobNo; "Job No.")
            {
            }
            column(jobTaskNo; "Job Task No.")
            {
            }
            column(description; Description)
            {
            }
            column(totaling; Totaling)
            {
            }
            column(jobTaskType; "Job Task Type")
            {
            }
            column(indentation; Indentation)
            {
            }
        }
    }
}
