// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Shared.Error;

using System.Utilities;
using System.Telemetry;
pageextension 7900 ErrorMessagesRecommendationExt extends "Error Messages"
{
    layout
    {
        modify(Context)
        {
            Visible = false;
        }
        modify("Context Field Name")
        {
            Visible = false;
        }
        modify(Source)
        {
            Visible = false;
        }
        modify("Field Name")
        {
            Visible = false;
        }
        modify("Additional Information")
        {
            Visible = false;
        }
        modify("Support Url")
        {
            Visible = false;
        }
        modify(CallStack)
        {
            Visible = false;
        }
        modify(TimeOfError)
        {
            Visible = false;
        }

        modify(Description)
        {
            StyleExpr = StyleText;

            trigger OnDrillDown()
            var
                ErrInfo: ErrorInfo;
            begin
                ErrInfo.Title := Rec.Title;
                ErrInfo.Message := Rec.Message;
                ErrInfo.Verbosity := ErrInfo.Verbosity::Verbose;
                ErrInfo.DataClassification := DataClassification::CustomerContent;
                ErrInfo.CustomDimensions.Add('ErrorCallStack', Rec.GetErrorCallStack());
                ErrInfo.CustomDimensions.Add('CreatedOn', Format(Rec."Created On"));
                Error(ErrInfo);
            end;
        }
        addafter(Description)
        {
            field("Recommended Action"; Rec."Recommended Action Caption")
            {
                ApplicationArea = All;
                Caption = 'Recommended action';
                ToolTip = 'This is the recommended action by the system for the error message.';

                trigger OnDrillDown()
                var
                    ErrorMessagesActionHandler: Codeunit ErrorMessagesActionHandler;
                begin
                    ErrorMessagesActionHandler.OnActionDrillDown(Rec);
                    CurrPage.Update();
                end;
            }
            field("Message Status"; Rec."Message Status")
            {
                ApplicationArea = All;
                Caption = 'Status';
                ToolTip = 'This shows the status of the error message based on the execution of recommended action.';
                StyleExpr = StyleText;
            }
        }

        moveafter("Recommended Action"; "Message Type")

        addfirst(FactBoxes)
        {
            part("Error Messages Card Part"; "Error Messages Card Part")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = ID = field(ID);
            }
        }
    }
    actions
    {
        addafter(OpenRelatedRecord)
        {
            action("Accept Recommended Action")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Accept recommended action';
                ToolTip = 'Use this action to apply the recommended action for selected error messages.';
                Image = Approve;

                trigger OnAction()
                var
                    TempErrorMessage: Record "Error Message" temporary;
                    ErrorMessagesActionHandler: Codeunit ErrorMessagesActionHandler;
                begin
                    TempErrorMessage.Copy(Rec, true);
                    CurrPage.SetSelectionFilter(TempErrorMessage);
                    ErrorMessagesActionHandler.ExecuteActions(TempErrorMessage);
                end;
            }
            action("Show All Errors")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Show all errors';
                ToolTip = 'Apply filter on message status to show all the error messages including fixed error messages.';
                Image = ClearFilter;
                Visible = ShowAllErrorVisible;

                trigger OnAction()
                begin
                    Rec.SetFilter("Message Status", '');
                    ShowAllErrorVisible := false;
                end;
            }
            action("Hide Fixed Errors")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Hide fixed errors';
                ToolTip = 'Apply filter on message status to hide all the fixed error messages.';
                Image = FilterLines;
                Visible = not ShowAllErrorVisible;

                trigger OnAction()
                begin
                    Rec.SetFilter("Message Status", '<>%1', Enum::"Error Message Status"::Fixed);
                    ShowAllErrorVisible := true;
                end;
            }
        }
        addfirst(Category_Process)
        {
            actionref(AcceptRecommendedAction_promoted; "Accept Recommended Action")
            {
            }

            group(FilterErrors)
            {
                ShowAs = SplitButton;
                Caption = 'Filter errors';

                actionref(Hide_fixed_promoted; "Hide Fixed Errors")
                {
                }
                actionref(Show_all_promoted; "Show All Errors")
                {
                }
            }
        }
    }

    var
        StyleText: Text[20];
        ShowAllErrorVisible: Boolean;

    trigger OnOpenPage()
    var
        TempErrorMessageFilters: Record "Error Message" temporary;
        FeatureTelemetry: Codeunit "Feature Telemetry";
        ErrorMessagesActionHandlerImpl: Codeunit ErrorMessagesActionHandlerImpl;
        CustomDimensions: Dictionary of [Text, Text];
    begin
        CurrPage."Error Messages Card Part".PAGE.SetRecords(Rec);

        TempErrorMessageFilters.CopyFilters(Rec);
        Rec.Reset();
        CustomDimensions.Add('TotalErrorsOnPage', Format(Rec.Count()));
        Rec.SetFilter("Error Msg. Fix Implementation", '<>%1', Enum::"Error Msg. Fix Implementation"::" ");
        Rec.SetFilter("Message Status", '<>%1', Rec."Message Status"::Fixed);
        CustomDimensions.Add('TotalFixableErrorsOnPage', Format(Rec.Count()));
        Rec.CopyFilters(TempErrorMessageFilters);
        FeatureTelemetry.LogUptake('0000LH4', ErrorMessagesActionHandlerImpl.GetFeatureTelemetryName(), Enum::"Feature Uptake Status"::Discovered, CustomDimensions);
    end;

    trigger OnAfterGetRecord()
    begin
        SetStyle();
    end;

    local procedure SetStyle()
    begin
        case Rec."Message Type" of
            Rec."Message Type"::Error:
                if Rec."Message Status" = Rec."Message Status"::Fixed then
                    StyleText := 'Standard'
                else
                    StyleText := 'Attention';
            Rec."Message Type"::Warning, Rec."Message Type"::Information:
                StyleText := 'None';
        end;
    end;
}