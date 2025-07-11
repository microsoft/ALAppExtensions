namespace Microsoft.Sales.PowerBIReports;

using Microsoft.PowerBIReports;

tableextension 36958 "Setup - Sales" extends "PowerBI Reports Setup"
{
    fields
    {
        field(36968; "Item Sales Load Date Type"; Option)
        {
            Caption = 'Item Sales Report Load Date Type';
            OptionCaption = ' ,Start/End Date,Relative Date';
            OptionMembers = " ","Start/End Date","Relative Date";
            DataClassification = CustomerContent;
        }
        field(36969; "Item Sales Start Date"; Date)
        {
            Caption = 'Item Sales Report Start Date';
            DataClassification = CustomerContent;
        }
        field(36970; "Item Sales End Date"; Date)
        {
            Caption = 'Item Sales Report End Date';
            DataClassification = CustomerContent;
        }
        field(36971; "Item Sales Date Formula"; DateFormula)
        {
            Caption = 'Item Sales Report Date Formula';
            DataClassification = CustomerContent;
        }
        field(36972; "Sales Report Id"; Guid)
        {
            Caption = 'Sales Report ID';
            DataClassification = CustomerContent;
        }
        field(36973; "Sales Report Name"; Text[200])
        {
            Caption = 'Sales Report Name';
            DataClassification = CustomerContent;
        }
    }
}