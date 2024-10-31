namespace Microsoft.DataMigration.GP;

using System.Integration;

page 40131 "GP Migration Error Overview"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "GP Migration Error Overview";
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Company"; Rec."Company Name")
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
                    Caption = 'Last Processed Record';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the last record that was processed before the error occurred.';
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        Message(Rec.GetLastRecordsUnderProcessingLog());
                    end;
                }
                field(StackTrace; StackTraceTxt)
                {
                    Caption = 'Error Stack Trace';
                    ApplicationArea = All;
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
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Image = Open;
                Visible = false;
                ToolTip = 'Open the company in which the error occurred.';

                trigger OnAction()
                begin
                    Hyperlink(GetUrl(ClientType::Web, Rec."Company Name", ObjectType::Page, Page::"Data Migration Overview"));
                end;
            }
            action(ShowProcessedRecordsLog)
            {
                ApplicationArea = All;
                Caption = 'Show log of processed records';
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
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
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
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
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
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
        rec.SetRange("Error Dismissed", false);
    end;

    var
        StackTraceTxt: Text;
}