namespace Microsoft.Sustainability.Setup;

using System.Security.User;

pageextension 6210 "Sust. User Setup" extends "User Setup"
{
    layout
    {
        addafter("Time Sheet Admin.")
        {
            field("Sustainability Manager"; Rec."Sustainability Manager")
            {
                ApplicationArea = All;
                Caption = 'Sustainability Manager';
                ToolTip = 'Specifies if a user is a Sustainability Manager';
            }
        }
    }
}