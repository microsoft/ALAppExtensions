namespace Microsoft.Sustainability.PowerBIReports;

using Microsoft.HumanResources.Payables;

query 37065 "EmployeeLedgerEntry - PBI API"
{
    Access = Internal;
    QueryType = API;
    Caption = 'Power BI Employee Ledger Entry';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'pbiEmployeeLedgerEntry';
    EntitySetName = 'pbiEmployeeLedgerEntries';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(employeeLedgerEntry; "Employee Ledger Entry")
        {
            column(employeeNo; "Employee No.") { }
            column(entryNo; "Entry No.") { }
            column(postingDate; "Posting Date") { }
            column(documentType; "Document Type") { }
            column(documentNo; "Document No.") { }
            column(amount; Amount) { }
            column(dimensionSetID; "Dimension Set ID") { }
            column(description; Description) { }
        }
    }
}
