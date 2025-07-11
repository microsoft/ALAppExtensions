namespace Microsoft.Finance.PowerBIReports;

using Microsoft.PowerBIReports;

tableextension 36953 "Setup - Finance" extends "PowerBI Reports Setup"
{
    fields
    {
        field(36952; "Finance Start Date"; Date)
        {
            Caption = 'Finance Report Start Date';
            DataClassification = CustomerContent;
        }
        field(36953; "Finance End Date"; Date)
        {
            Caption = 'Finance Report End Date';
            DataClassification = CustomerContent;
        }
        field(36954; "Cust. Ledger Entry Start Date"; Date)
        {
            Caption = 'Customer Ledger Entry Start Date';
            DataClassification = CustomerContent;
        }
        field(36955; "Cust. Ledger Entry End Date"; Date)
        {
            Caption = 'Customer Ledger Entry End Date';
            DataClassification = CustomerContent;
        }
        field(36956; "Vend. Ledger Entry Start Date"; Date)
        {
            Caption = 'Vendor Ledger Entry Start Date';
            DataClassification = CustomerContent;
        }
        field(36957; "Vend. Ledger Entry End Date"; Date)
        {
            Caption = 'Vendor Ledger Entry End Date';
            DataClassification = CustomerContent;
        }
        field(36950; "Finance Report Id"; Guid)
        {
            Caption = 'Finance Report ID';
            DataClassification = CustomerContent;
        }
        field(36951; "Finance Report Name"; Text[200])
        {
            Caption = 'Finance Report Name';
            DataClassification = CustomerContent;
        }
    }
}