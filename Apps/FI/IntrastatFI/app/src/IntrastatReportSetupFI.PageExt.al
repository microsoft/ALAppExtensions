pageextension 13407 "Intrastat Report Setup FI" extends "Intrastat Report Setup"
{
    layout
    {
        addlast(content)
        {
            group(FileSetup)
            {
                Caption = 'File Setup';
                field("Custom Code"; Rec."Custom Code")
                {
                    ApplicationArea = BasicEU;
                    ToolTip = 'Specifies a custom code for the Intrastat file setup information.';
                }
                field("Company Serial No."; Rec."Company Serial No.")
                {
                    ApplicationArea = BasicEU;
                    ToolTip = 'Specifies a company serial number for the Intrastat file setup information.';
                }
                field("Last Transfer Date"; Rec."Last Transfer Date")
                {
                    ApplicationArea = BasicEU;
                    ToolTip = 'Specifies a last transfer date for the Intrastat file setup information.';
                }
                field("File No."; Rec."File No.")
                {
                    ApplicationArea = BasicEU;
                    ToolTip = 'Specifies a file number for the Intrastat file setup information.';
                }
            }
        }
    }
}