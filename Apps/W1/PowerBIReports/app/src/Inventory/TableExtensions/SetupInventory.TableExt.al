namespace Microsoft.Projects.PowerBIReports;

using Microsoft.PowerBIReports;

tableextension 36960 "Setup - Inventory" extends "PowerBI Reports Setup"
{
    fields
    {
        field(36980; "Inventory Report Id"; Guid)
        {
            Caption = 'Inventory Report ID';
            DataClassification = CustomerContent;
        }
        field(36981; "Inventory Report Name"; Text[200])
        {
            Caption = 'Inventory Report Name';
            DataClassification = CustomerContent;
        }
        field(36990; "Inventory Val. Report Id"; Guid)
        {
            Caption = 'Inventory Valuation Report ID';
            DataClassification = CustomerContent;
        }
        field(36991; "Inventory Val. Report Name"; Text[200])
        {
            Caption = 'Inventory Valuation Report Name';
            DataClassification = CustomerContent;
        }
    }
}