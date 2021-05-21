pageextension 11782 "Account Schedule CZL" extends "Account Schedule"
{
    layout
    {
        addfirst(Control1)
        {
            field("Row Correction CZL"; Rec."Row Correction CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the row code for the correction.';
                Visible = false;

                trigger OnLookup(var Text: Text): Boolean
                var
                    AccScheduleLine: Record "Acc. Schedule Line";
                begin
                    AccScheduleLine.SetRange("Schedule Name", Rec."Schedule Name");
                    AccScheduleLine.SetFilter("Row No.", '<>%1', Rec."Row No.");
                    if Page.RunModal(Page::"Acc. Schedule Line List CZL", AccScheduleLine) = Action::LookupOK then
                        Rec."Row Correction CZL" := AccScheduleLine."Row No.";
                end;
            }
        }
        addafter(Show)
        {
            field("Calc CZL"; Rec."Calc CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies when the value can be calculated in the Account Schedule - Always, Never, When Positive, When Negative.';
            }
        }
        addlast(Control1)
        {
            field("Assets/Liabilities Type CZL"; Rec."Assets/Liabilities Type CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the assets or liabilities type for the account schedule line.';
                Visible = false;
            }
        }
    }
    actions
    {
        addlast("O&ther")
        {
            action("File Mapping CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'File Mapping';
                Image = ExportToExcel;
                ToolTip = 'File Mapping allows to set up export to Excel. You can see three dots next to the field with Amount.';

                trigger OnAction()
                var
                    AccScheuledFileMappingCZL: Page "Acc. Schedule File Mapping CZL";
                begin
                    AccScheuledFileMappingCZL.SetAccSchedName(Rec."Schedule Name");
                    AccScheuledFileMappingCZL.RunModal();
                end;
            }
        }
    }
}
