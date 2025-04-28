namespace Microsoft.Sustainability.PowerBIReports;

using Microsoft.PowerBIReports;

tableextension 36957 "Setup - Sustainability" extends "PowerBI Reports Setup"
{
    fields
    {
        field(37099; "Sustainability Load Date Type"; Option)
        {
            Caption = 'Sustainability Report Load Date Type';
            OptionCaption = ' ,Start/End Date,Relative Date';
            OptionMembers = " ","Start/End Date","Relative Date";
            DataClassification = CustomerContent;
        }
        field(37098; "Sustainability Start Date"; Date)
        {
            Caption = 'Sustainability Report Start Date';
            DataClassification = CustomerContent;
        }
        field(37097; "Sustainability End Date"; Date)
        {
            Caption = 'Sustainability Report End Date';
            DataClassification = CustomerContent;
        }
        field(37096; "Sustainability Date Formula"; DateFormula)
        {
            Caption = 'Sustainability Report Date Formula';
            DataClassification = CustomerContent;
        }
        field(37095; "Sustainability Report Id"; Guid)
        {
            Caption = 'Sustainability Report ID';
            DataClassification = CustomerContent;
        }
        field(37094; "Sustainability Report Name"; Text[200])
        {
            Caption = 'Sustainability Report Name';
            DataClassification = CustomerContent;
        }
    }
}