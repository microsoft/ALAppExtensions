// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

using System.Integration;

page 47020 "SL Migration Error Overview"
{
    ApplicationArea = All;
    Caption = 'Migration Error Overview';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "SL Migration Error Overview";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(Company; Rec."Company Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the company in which the error occured.';
                }
                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the error message that occurred during the data upgrade.';
                }
                field(LastRecordUnderProcessing; Rec."Last Record Under Processing")
                {
                    ApplicationArea = All;
                    Caption = 'Last Processed Record';
                    Editable = false;
                    ToolTip = 'Specifies the last record that was processed before the error occurred.';

                    trigger OnDrillDown()
                    begin
                        Message(Rec.GetLastRecordsUnderProcessingLog());
                    end;
                }
                field(StackTrace; StackTraceTxt)
                {
                    ApplicationArea = All;
                    Caption = 'Error Stack Trace';
                    ToolTip = 'Specifies the stack trace that relates to the error.';
                    trigger OnDrillDown()
                    var
                        MessageWithStackTrace: Text;
                        NewLine: Text;
                    begin
                        NewLine[1] := 10;
                        MessageWithStackTrace := StackTraceTxt + NewLine + Rec.GetExceptionCallStack();
                        Message(MessageWithStackTrace);
                    end;
                }
                field(ErrorDismissed; Rec."Error Dismissed")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the error has been dismissed.';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(OpenInCompany)
            {
                ApplicationArea = All;
                Caption = 'Open in Company';
                Image = Open;
                ToolTip = 'Open the company in which the error occurred.';
                Visible = false;

                trigger OnAction()
                begin
                    Hyperlink(GetUrl(ClientType::Web, Rec."Company Name", ObjectType::Page, Page::"Data Migration Overview"));
                end;
            }
            action(ShowProcessedRecordsLog)
            {
                ApplicationArea = All;
                Caption = 'Show log of processed records';
                Image = ShowList;
                ToolTip = 'Shows the log of last processed records before error occured.';

                trigger OnAction()
                begin
                    Message(Rec.GetLastRecordsUnderProcessingLog());
                end;
            }
            action(DismissError)
            {
                ApplicationArea = All;
                Caption = 'Dismiss Error';
                Image = CompleteLine;
                ToolTip = 'Dismiss the error.';

                trigger OnAction()
                begin
                    Rec."Error Dismissed" := true;
                    Rec.Modify();
                end;
            }
            action(ShowHideAllErrors)
            {
                ApplicationArea = All;
                Caption = 'Show/Hide All Errors';
                Image = ShowList;
                ToolTip = 'Shows or hides dismissed errors.';

                trigger OnAction()
                var
                    ErrorDismissedTxt: Text;
                begin
                    ErrorDismissedTxt := Rec.GetFilter("Error Dismissed");
                    if ErrorDismissedTxt = '' then
                        Rec.SetRange("Error Dismissed", true)
                    else
                        Rec.SetRange("Error Dismissed");
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(OpenInCompany_Promoted; OpenInCompany)
                {
                }
                actionref(ShowProcessedRecordsLog_Promoted; ShowProcessedRecordsLog)
                {
                }
                actionref(DismissError_Promoted; DismissError)
                {
                }
                actionref(ShowHideAllErrors_Promoted; ShowHideAllErrors)
                {
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        StackTraceTxt := Rec.GetFullExceptionMessage();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        StackTraceTxt := Rec.GetFullExceptionMessage();
    end;

    trigger OnOpenPage()
    begin
        Rec.SetRange("Error Dismissed", false);
    end;

    var
        StackTraceTxt: Text;
}
