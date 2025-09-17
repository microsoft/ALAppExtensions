namespace Microsoft.Sustainability.PowerBIReports;

using Microsoft.HumanResources.Absence;

query 6212 "Employee Absence - PBI API"
{
    Access = Internal;
    QueryType = API;
    Caption = 'Power BI Employee Absence';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    ApiVersion = 'v0.5', 'v1.0';
    EntityName = 'pbiEmployeeAbsence';
    EntitySetName = 'pbiEmployeeAbsences';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(employeeabsence; "Employee Absence")
        {
            column(employeeNo; "Employee No.") { }
            column(entryNo; "Entry No.") { }
            column(fromDate; "From Date") { }
            column(toDate; "To Date") { }
            column(causeofAbsenceCode; "Cause of Absence Code") { }
            column(quantitybase; "Quantity (Base)") { }
            column(description; Description) { }
        }
    }
}