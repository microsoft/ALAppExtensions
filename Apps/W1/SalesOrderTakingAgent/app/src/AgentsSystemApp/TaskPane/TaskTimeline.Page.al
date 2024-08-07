// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents;

using System.Security.AccessControl;

page 4307 "TaskTimeline"
{
    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = "Agent Task Timeline Entry";
    Caption = 'Agent Task Timeline';
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(TaskTimeline)
            {
                field(Header; Rec.Title)
                {
                }
                field(Summary; PageSummary)
                {
                    Caption = 'Summary';
                    ToolTip = 'Specifies the summary of the timeline entry.';
                }
                field(PrimaryPageQuery; Rec."Primary Page Query")
                {
                }
                field(Description; Rec.Description)
                {
                }
                field(Category; Rec.Category)
                {
                }
                field(Type; Rec.Type)
                {
                }
                field(ConfirmationStatus; ConfirmationStatus)
                {
                    Caption = 'Confirmation Status';
                    ToolTip = 'Specifies the confirmation status of the timeline entry.';
                }
                field(ConfirmedBy; ConfirmedBy)
                {
                    Caption = 'Confirmed by';
                    ToolTip = 'Specifies the user who confirmed the timeline entry.';
                }
                field(ConfirmedAt; ConfirmedAt)
                {
                    Caption = 'Confirmed at';
                    ToolTip = 'Specifies the date and time when the timeline entry was confirmed.';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        SetTaskTimelineDetails();
    end;

    procedure SetTaskTimelineDetails()
    var
        TaskTimelineEntryStep: Record "Agent Task Timeline Entry Step";
        User: Record User;
        InStream: InStream;
        PendingConfirmationLbl: Label 'Pending Confirmation';
        ConfirmedLbl: Label 'Confirmed';
    begin
        if Rec.CalcFields("Primary Page Summary") then
            if Rec."Primary Page Summary".HasValue then begin
                Rec."Primary Page Summary".CreateInStream(InStream);
                PageSummary.Read(InStream);
            end;

        if Rec."Last Step Type" = Rec."Last Step Type"::"User Intervention Request" then
            ConfirmationStatus := PendingConfirmationLbl
        else begin
            TaskTimelineEntryStep.SetRange("Task ID", Rec."Task ID");
            TaskTimelineEntryStep.SetRange("Timeline Entry ID", Rec.ID);
            TaskTimelineEntryStep.SetRange(Type, TaskTimelineEntryStep.Type::"User Intervention");
            if TaskTimelineEntryStep.FindLast() then begin
                User.SetRange("User Security ID", TaskTimelineEntryStep."User Security ID");
                if User.FindFirst() then
                    ConfirmedBy := User."Full Name";
                ConfirmedAt := TaskTimelineEntryStep.SystemModifiedAt;
                ConfirmationStatus := ConfirmedLbl;
            end;
        end;
    end;

    var
        PageSummary: BigText;
        ConfirmedBy: Text[250];
        ConfirmedAt: DateTime;
        ConfirmationStatus: Text[100];
}


