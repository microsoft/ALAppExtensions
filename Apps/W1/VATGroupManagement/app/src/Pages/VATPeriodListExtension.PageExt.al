pageextension 4700 "VAT Period List Extension" extends "VAT Return Period List"
{
    layout
    {
        // Add changes to page layout here
        addbefore(VATReturnStatus)
        {
            field("Group Member Submissions"; GroupMemberSubmissions)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Group Member Submissions';
                ToolTip = 'Specifies the number of VAT returns submitted by group members in this period.';
                Editable = false;
                Visible = IsVisible;
                DrillDown = true;
                Width = 20;

                trigger OnDrillDown()
                var
                    VATGroupSubmissionHeader: Record "VAT Group Submission Header";
                begin
                    VATGroupSubmissionHeader.SetRange("Start Date", Rec."Start Date");
                    VATGroupSubmissionHeader.SetRange("End Date", Rec."End Date");
                    Page.RunModal(Page::"VAT Group Submission List", VATGroupSubmissionHeader);
                end;
            }
        }
    }


    var
        GroupMemberSubmissionTxt: Label '%1 of %2 submitted', Comment = '%1 = number, %2 = number ex. 2 of 4 submitted';
        GroupMemberSubmissions: Text[20];
        IsVisible: Boolean;

    trigger OnAfterGetRecord()
    var
        VATReportSetup: Record "VAT Report Setup";
        VATGroupApprovedMember: Record "VAT Group Approved Member";
        VATGroupHelperFunctions: Codeunit "VAT Group Helper Functions";

    begin
        if VATReportSetup.Get() then
            IsVisible := VATReportSetup."VAT Group Role" = VATReportSetup."VAT Group Role"::Representative;

        GroupMemberSubmissions := StrSubstNo(GroupMemberSubmissionTxt, VATGroupHelperFunctions.CountApprovedMemberSubmissionsForPeriod(Rec."Start Date", Rec."End Date"), VATGroupApprovedMember.Count());
    end;
}