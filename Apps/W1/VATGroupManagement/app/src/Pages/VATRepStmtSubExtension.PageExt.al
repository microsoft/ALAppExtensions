pageextension 4704 "VAT Rep. Stmt. Sub. Extension" extends "VAT Report Statement Subform"
{
    layout
    {
        addbefore(Amount)
        {
            field("Representative Amount"; Rec."Representative Amount")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the representative VAT amount for the specified box number.';
                Visible = IsColumnVisible;
            }
            field("Group Amount"; Rec.Amount - Rec."Representative Amount")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Group Amount';
                ToolTip = 'Specifies the group VAT amount for the specified box number without the representative amount.';
                Visible = IsColumnVisible;
                trigger OnDrillDown()
                var
                    VATReportHeader: Record "VAT Report Header";
                    VATGroupHelperFunctions: Codeunit "VAT Group Helper Functions";
                begin
                    if not VATReportHeader.Get(Rec."VAT Report Config. Code", Rec."VAT Report No.") then
                        exit;
                    if not VATReportHeader."VAT Group Return" then
                        exit;

                    VATGroupHelperFunctions.PrepareVATCalculation(VATReportHeader, Rec);
                end;
            }
        }

        modify(Amount)
        {
            Caption = 'Total Amount';
        }
    }

    var
        VATReportHeader: Record "VAT Report Header";
        IsColumnVisible: Boolean;

    trigger OnAfterGetRecord()
    var
        VATGroupRetrievefromSubmission: Codeunit "VAT Group Retrieve From Sub.";
    begin
        VATReportHeader.SetRange("No.", Rec."VAT Report No.");
        VATReportHeader.SetRange("VAT Report Config. Code", Rec."VAT Report Config. Code");
        if VATReportHeader.FindFirst() then
            IsColumnVisible := VATReportHeader."VAT Group Return";

        if IsColumnVisible and (VATReportHeader.Status = VATReportHeader.Status::Open) then
            VATGroupRetrievefromSubmission.Run(VATReportHeader);
    end;
}
