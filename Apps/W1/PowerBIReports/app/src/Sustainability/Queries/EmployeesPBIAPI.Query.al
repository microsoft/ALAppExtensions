namespace Microsoft.Sustainability.PowerBIReports;

using Microsoft.HumanResources.Employee;

query 37061 "Employees - PBI API"
{
    Access = Internal;
    QueryType = API;
    Caption = 'Power BI Employees';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'pbiEmployee';
    EntitySetName = 'pbiEmployees';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(Employee; Employee)
        {
            column(no; "No.") { }
            column(firstName; "First Name") { }
            column(lastName; "Last Name") { }
            column(gender; Gender) { }
            column(unionCode; "Union Code") { }
            column(status; Status) { }
            column(casueofInactivty; "Cause of Inactivity Code") { }
            column(inactivedate; "Inactive Date") { }
            column(groudForTermCode; "Grounds for Term. Code") { }
            column(dateOfBirth; "Birth Date") { }

        }
    }
}