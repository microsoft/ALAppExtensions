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

                }
                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = All;
                }
                field(LastRecordUnderProcessing; Rec."Last Record Under Processing")
                {
                    Caption = 'Last Processed Record';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the last record that was processed before the error occurred.';
                }
                field(StackTrace; StackTraceTxt)
                {
                    Caption = 'Error Stack Trace';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the stack trace that relates to the error.';
                    trigger OnDrillDown()
                    begin
                        Message(StackTraceTxt);
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
                ToolTip = 'Open the company in which the error occurred.';

                trigger OnAction()
                begin
                    Hyperlink(GetUrl(ClientType::Web, Rec."Company Name", ObjectType::Page, Page::"Data Migration Overview"));
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

    var
        StackTraceTxt: Text;
}