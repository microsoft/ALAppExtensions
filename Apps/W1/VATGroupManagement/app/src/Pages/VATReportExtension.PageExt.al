pageextension 4701 "VAT Report Extension" extends "VAT Report"
{
    layout
    {
        addafter("Amounts in Add. Rep. Currency")
        {
            group(VATGroupReturnControl)
            {
                Visible = IsGroupRepresentative;
                ShowCaption = false;

                field("VAT Group Return"; Rec."VAT Group Return")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'VAT Group Included';
                    ToolTip = 'Specifies whether this is a VAT group return.';
                    Editable = false;
                }
            }
            group(VATGroupStatusControl)
            {
                ShowCaption = false;
                Visible = (not Rec."VAT Group Return") and IsGroupMember;

                field("VAT Group Status"; Rec."VAT Group Status")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the status of the VAT return on the group representative side. If this VAT return was used in a VAT group return by the group representative, the status is shown here.';
                    Editable = false;
                }
            }
            group(VATGroupSettlementPostedControl)
            {
                ShowCaption = false;
                Visible = IsGroupRepresentative and Rec."VAT Group Return";

                field("VAT Group Settlement Posted"; Rec."VAT Group Settlement Posted")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'VAT Group Settlement Posted';
                    ToolTip = 'Specifies whether the VAT settlement has been posted for the group members.';
                    Editable = false;
                }
            }
        }
    }
    actions
    {
        // Add changes to page actions here
        addafter(SuggestLines)
        {
            action("Include VAT Group")
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Caption = 'Include VAT Group';
                Image = Add;
                ToolTip = 'Includes the amounts of submitted VAT returns from members in this period.';
                Visible = (not Rec."VAT Group Return") and (Rec.Status = Rec.Status::Open) and IsGroupRepresentative;

                trigger OnAction()
                var
                    VATGroupApprovedMember: Record "VAT Group Approved Member";
                    VATGroupHelperFunctions: Codeunit "VAT Group Helper Functions";
                    VATGroupRetrievefromSubmission: Codeunit "VAT Group Retrieve From Sub.";
                begin
                    if VATGroupHelperFunctions.CountApprovedMemberSubmissionsForPeriod(Rec."Start Date", Rec."End Date") < VATGroupApprovedMember.Count() then
                        Error(NotAllMembersSubmittedErr);

                    VATGroupRetrievefromSubmission.Run(Rec);
                    Rec."VAT Group Return" := true;
                end;
            }
        }
        addafter("Include VAT Group")
        {
            action(UpdateStatus)
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Caption = 'Update Status';
                Image = ReOpen;
                ToolTip = 'Give the VAT return the same status as the return for the VAT group in the group representative company.';
                Visible = IsGroupMember and IsVATReportValid;

                trigger OnAction()
                var
                    VATGroupSubmissionStatus: Codeunit "VAT Group Submission Status";
                begin
                    VATGroupSubmissionStatus.UpdateSingleVATReportStatus(Rec."No.");
                end;
            }
        }
        addafter("Calc. and Post VAT Settlement")
        {
            action("Post VAT Group Settlement")
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedOnly = true;
                Caption = 'Post VAT Group Settlement';
                Image = Report2;
                ToolTip = 'Post the VAT amount that is due to the VAT settlement account for each group member, and balance the amounts in the account for VAT group settlements.';
                Visible = VATGroupSettlementVisible;

                trigger OnAction()
                begin
                    ConfirmAndRunVATGroupSettlement();
                end;
            }
        }
        addafter("Mark as Submitted")
        {
            action("Mark as Accepted")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Mark as Accepted';
                Visible = Rec.Status = Rec.Status::Submitted;
                Image = Approve;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Indicate that the submitted report has been accepted by the tax authority';
                trigger OnAction()
                begin
                    Rec.Status := Rec.Status::Accepted;
                end;
            }
        }
        modify(SuggestLines)
        {
            trigger OnBeforeAction()
            begin
                DateTimeBeforeSuggestLines := CurrentDateTime();
            end;

            trigger OnAfterAction()
            var
                VATGroupHelperFunctions: Codeunit "VAT Group Helper Functions";
            begin
                if SuggestLinesExecuted() then
                    VATGroupHelperFunctions.SetOriginalRepresentativeAmount(Rec);
            end;
        }
        modify(Release)
        {
            trigger OnAfterAction()
            var
                ErrorMessage: Record "Error Message";
                VATGroupHelperFunctions: Codeunit "VAT Group Helper Functions";
                VATGroupRetrievefromSubmission: Codeunit "VAT Group Retrieve From Sub.";
                ValuesChanged: Notification;
            begin
                ErrorMessage.SetRange("Context Record ID", Rec.RecordId());

                if IsGroupRepresentative and Rec."VAT Group Return" and ErrorMessage.IsEmpty() then begin
                    VATGroupRetrievefromSubmission.Run(Rec);
                    VATGroupHelperFunctions.MarkReleasedVATSubmissions(Rec);
                    if VATGroupRetrievefromSubmission.IsNotificationNeeded() then begin
                        ValuesChanged.Message(ValuesChangedMsg);
                        ValuesChanged.Send();
                    end;
                end;
            end;
        }
        modify(Reopen)
        {
            trigger OnAfterAction()
            var
                VATGroupHelperFunctions: Codeunit "VAT Group Helper Functions";
                VATGroupRetrievefromSubmission: Codeunit "VAT Group Retrieve From Sub.";
            begin
                if IsGroupRepresentative and Rec."VAT Group Return" then begin
                    VATGroupHelperFunctions.MarkReopenedVATSubmissions(Rec);
                    VATGroupRetrievefromSubmission.Run(Rec);
                end;
            end;
        }
        modify("Calc. and Post VAT Settlement")
        {
            trigger OnAfterAction()
            begin
                if not IsVATGroupSettlementTriggered() then
                    exit;

                ConfirmAndRunVATGroupSettlement();
            end;
        }
    }

    var
        VATReportSetup: Record "VAT Report Setup";
        IsGroupRepresentative, IsVATReportValid, IsGroupMember, VATGroupSettlementVisible : Boolean;
        DateTimeBeforeSuggestLines: DateTime;
        ValuesChangedMsg: Label 'The amounts submitted by group members have changed. Please review the new values.';
        NewerSubmissionsMsg: Label 'There are newer VAT Group submissions from members for this period. Click Reopen to incorporate the new values.';
        NotAllMembersSubmittedErr: Label 'One or more VAT group members have not submitted their VAT return for this period. Wait until all members have submitted before you continue.\\You can see the current submissions on the VAT Group Submission page.';
        VATGroupSettlementQst: Label 'Do you want to post the VAT settlement for the group members?';
        VATGroupSettlementErr: Label 'Could not post the VAT group settlement because the following error occurred. %1', Comment = '%1 is the error itself';
        VatGroupSettlementMsg: Label 'The VAT group settlement was posted successfully.';

    trigger OnAfterGetRecord()
    var
        VATGroupSubmissionStatus: Codeunit "VAT Group Submission Status";
        VATGroupHelperFunctions: Codeunit "VAT Group Helper Functions";
        NewerSubmissions: Notification;
    begin
        if not VATReportSetup.Get() then
            exit;

        IsGroupRepresentative := VATReportSetup.IsGroupRepresentative();
        IsGroupMember := VATReportSetup.IsGroupMember();
        IsVATReportValid := VATGroupSubmissionStatus.IsVATReportValid(Rec);
        VATGroupSettlementVisible := IsVATGroupSettlementTriggered() and (Rec.Status = Rec.Status::Accepted);

        if IsGroupRepresentative and (Rec.Status = Rec.Status::Released) then
            if VATGroupHelperFunctions.NewerVATSubmissionsExist(Rec) then begin
                NewerSubmissions.Id := '0ebad5d7-4655-4ff5-bc7b-bfff6b9c4b28';
                NewerSubmissions.Message(NewerSubmissionsMsg);
                NewerSubmissions.Scope(NotificationScope::LocalScope);
                NewerSubmissions.Send();
            end;
    end;

    local procedure IsVATGroupSettlementTriggered(): Boolean
    begin
        if not IsGroupRepresentative then
            exit(false);
        if not Rec."VAT Group Return" then
            exit(false);
        if Rec."VAT Group Settlement Posted" then
            exit(false);

        exit(true);
    end;

    local procedure ConfirmAndRunVATGroupSettlement()
    var
        ConfirmManagement: Codeunit "Confirm Management";
        VATGroupSettlement: Codeunit "VAT Group Settlement";
    begin
        if ConfirmManagement.GetResponse(VATGroupSettlementQst, false) then
            if not VATGroupSettlement.Run(Rec) then
                Error(VATGroupSettlementErr, GetLastErrorText())
            else
                Message(VatGroupSettlementMsg);
    end;

    local procedure SuggestLinesExecuted(): Boolean
    var
        VATStatementReportLine: Record "VAT Statement Report Line";
    begin
        VATStatementReportLine.SetRange("VAT Report No.", Rec."No.");
        VATStatementReportLine.SetRange("VAT Report Config. Code", Rec."VAT Report Config. Code");
        VATStatementReportLine.SetFilter(SystemModifiedAt, '>%1', DateTimeBeforeSuggestLines);
        exit(not VATStatementReportLine.IsEmpty());
    end;
}