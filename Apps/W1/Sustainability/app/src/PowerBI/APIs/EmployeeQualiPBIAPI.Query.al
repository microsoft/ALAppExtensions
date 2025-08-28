namespace Microsoft.Sustainability.PowerBIReports;

using Microsoft.HumanResources.Employee;

query 6214 "Employee Quali - PBI API"
{
    Access = Internal;
    QueryType = API;
    Caption = 'Power BI Employee Qualifications';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    ApiVersion = 'v0.5', 'v1.0';
    EntityName = 'pbiEmployeeQualification';
    EntitySetName = 'pbiEmployeeQualifications';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(employeeQualifications; "Employee Qualification")
        {
            column(employeeNo; "Employee No.") { }
            column(qualificationCode; "Qualification Code") { }

        }
    }
}