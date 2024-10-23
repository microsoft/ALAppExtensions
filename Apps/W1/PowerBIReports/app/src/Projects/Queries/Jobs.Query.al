namespace Microsoft.Projects.PowerBIReports;

using Microsoft.Projects.Project.Job;

query 36995 Jobs
{
    Access = Internal;
    QueryType = API;
    Caption = 'Power BI Job';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'job';
    EntitySetName = 'jobs';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(Job; Job)
        {
            column(no; "No.")
            {
            }
            column(description; Description)
            {
            }
            column(billToCustomerNo; "Bill-to Customer No.")
            {
            }
            column(creationDate; "Creation Date")
            {
            }
            column(startingDate; "Starting Date")
            {
            }
            column(endingDate; "Ending Date")
            {
            }
            column(status; Status)
            {
            }
            column(jobPostingGroup; "Job Posting Group")
            {
            }
            column(blocked; Blocked)
            {
            }
            column(projectManager; "Project Manager")
            {
            }
            column(complete; Complete)
            {
            }
        }
    }
}
