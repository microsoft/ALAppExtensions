#if CLEAN27
namespace Microsoft.Sustainability.PowerBIReports;

using Microsoft.PowerBIReports;

tableextension 6262 "Power BI Setup - Sust." extends "PowerBI Reports Setup"
{
    fields
    {
        field(37099; "Sustainability Load Date Type"; Option)
        {
            Caption = 'Sustainability Report Load Date Type';
            OptionCaption = ' ,Start/End Date,Relative Date';
            OptionMembers = " ","Start/End Date","Relative Date";
            DataClassification = CustomerContent;
            MovedFrom = 'e4e86220-cac0-4ec3-b853-7c2fa610399d';
        }
        field(37098; "Sustainability Start Date"; Date)
        {
            Caption = 'Sustainability Report Start Date';
            DataClassification = CustomerContent;
            MovedFrom = 'e4e86220-cac0-4ec3-b853-7c2fa610399d';
        }
        field(37097; "Sustainability End Date"; Date)
        {
            Caption = 'Sustainability Report End Date';
            DataClassification = CustomerContent;
            MovedFrom = 'e4e86220-cac0-4ec3-b853-7c2fa610399d';
        }
        field(37096; "Sustainability Date Formula"; DateFormula)
        {
            Caption = 'Sustainability Report Date Formula';
            DataClassification = CustomerContent;
            MovedFrom = 'e4e86220-cac0-4ec3-b853-7c2fa610399d';
        }
        field(37095; "Sustainability Report Id"; Guid)
        {
            Caption = 'Sustainability Report ID';
            DataClassification = CustomerContent;
            MovedFrom = 'e4e86220-cac0-4ec3-b853-7c2fa610399d';
        }
        field(37094; "Sustainability Report Name"; Text[200])
        {
            Caption = 'Sustainability Report Name';
            DataClassification = CustomerContent;
            MovedFrom = 'e4e86220-cac0-4ec3-b853-7c2fa610399d';
        }
    }
}
#endif