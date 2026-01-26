namespace Microsoft.Sustainability.Journal;

using Microsoft.Finance.GeneralLedger.Journal;

pageextension 6225 "Sust. Posted General Journal" extends "Posted General Journal"
{
    layout
    {
        addafter("Bal. Account No.")
        {
            field("Sust. Account No."; Rec."Sust. Account No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the value of the Sustainability Account No. field.';
            }
            field("Total Emission CO2"; Rec."Total Emission CO2")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the value of the Total Emission CO2 field.';
            }
            field("Total Emission CH4"; Rec."Total Emission CH4")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the value of the Total Emission CH4 field.';
            }
            field("Total Emission N2O"; Rec."Total Emission N2O")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the value of the Total Emission N2O field.';
            }
        }
    }
}