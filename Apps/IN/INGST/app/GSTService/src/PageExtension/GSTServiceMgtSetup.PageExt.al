pageextension 18457 "GST Service Mgt Setup" extends "Service Mgt. Setup"
{
    layout
    {
        addafter("Base Calendar Code")
        {
            field("GST Dependency Type"; Rec."GST Dependency Type")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the GST calculation dependency mentioned in service management setup.';
            }
        }
    }
}