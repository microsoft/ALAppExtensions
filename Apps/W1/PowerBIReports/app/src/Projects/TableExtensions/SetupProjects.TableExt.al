namespace Microsoft.Projects.PowerBIReports;

using Microsoft.PowerBIReports;

tableextension 36955 "Setup - Projects" extends "PowerBI Reports Setup"
{
    fields
    {
        field(36962; "Job Ledger Entry Start Date"; Date)
        {
            Caption = 'Job Ledger Entry Start Date';
            DataClassification = CustomerContent;
        }
        field(36963; "Job Ledger Entry End Date"; Date)
        {
            Caption = 'Job Ledger Entry End Date';
            DataClassification = CustomerContent;
        }
    }
}