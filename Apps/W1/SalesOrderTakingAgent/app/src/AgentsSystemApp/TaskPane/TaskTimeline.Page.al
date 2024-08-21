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
                field(ConfirmationStatus; ConfirmationStatusOption)
                {
                    Caption = 'Confirmation Status';
                    ToolTip = 'Specifies the confirmation status of the timeline entry.';
                    OptionCaption = ' ,Confirmed,ConfirmationRequired,ConfirmationNotRequired';
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
    begin
        ConfirmedBy := '';
        ConfirmedAt := 0DT;

        if Rec.CalcFields("Primary Page Summary") then
            if Rec."Primary Page Summary".HasValue then begin
                Rec."Primary Page Summary".CreateInStream(InStream);
                PageSummary.Read(InStream);
            end;

        case
            Rec."Last Step Type" of
            Rec."Last Step Type"::"User Intervention":
                begin
                    ConfirmationStatusOption := ConfirmationStatusOption::Confirmed;
                    TaskTimelineEntryStep.SetRange("Task ID", Rec."Task ID");
                    TaskTimelineEntryStep.SetRange("Timeline Entry ID", Rec.ID);
                    TaskTimelineEntryStep.SetRange("Step Number", Rec."Last Step Number");
                    if TaskTimelineEntryStep.FindLast() then begin
                        User.SetRange("User Security ID", TaskTimelineEntryStep."User Security ID");
                        if User.FindFirst() then
                            if User."Full Name" <> '' then
                                ConfirmedBy := User."Full Name"
                            else
                                ConfirmedBy := User."User Name";

                        ConfirmedAt := Rec.SystemModifiedAt;
                    end;
                end;
            Rec."Last Step Type"::"User Intervention Request":
                ConfirmationStatusOption := ConfirmationStatusOption::ConfirmationRequired;
            else
                ConfirmationStatusOption := ConfirmationStatusOption::ConfirmationNotRequired;
        end;
    end;

    var
        PageSummary: BigText;
        ConfirmedBy: Text[250];
        ConfirmedAt: DateTime;
        ConfirmationStatusOption: Option " ",Confirmed,ConfirmationRequired,ConfirmationNotRequired;
}


