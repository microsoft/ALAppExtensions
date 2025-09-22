// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Projects.PowerBIReports;

using Microsoft.Projects.Project.Job;

query 36995 Jobs
{
    Access = Internal;
    QueryType = API;
    Caption = 'Power BI Project';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    ApiVersion = 'v0.5', 'v1.0';
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
