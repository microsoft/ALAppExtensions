// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Page that enables a user to pick which new features to use
/// </summary>
page 2610 "Feature Management"
{
    PageType = List;
    Caption = 'Feature Management';
    ApplicationArea = All;
    UsageCategory = Administration;
    AdditionalSearchTerms = 'new features,feature key,opt in,turn off features,enable features,early access,preview';
    SourceTable = "Feature Key";
    PromotedActionCategories = 'New,Process,Report,Data Update';
    InsertAllowed = false;
    DeleteAllowed = false;
    LinksAllowed = false;
    Extensible = false;
    Permissions = tabledata "Feature Key" = rm,
                  tabledata "Feature Data Update Status" = r;

    layout
    {
        area(Content)
        {
            repeater(FeatureKeys)
            {
                field(FeatureDescription; Rec.Description)
                {
                    Caption = 'Feature';
                    ToolTip = 'The name of the new capability or change in design.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field(LearnMore; LearnMoreLbl)
                {
                    ShowCaption = false;
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Learn more';
                    ToolTip = 'View a detailed description of new capabilities and behaviors that are available when the feature is enabled (opens in a new tab).';

                    trigger OnDrillDown()
                    begin
                        Hyperlink(Rec."Learn More Link");
                    end;
                }
                field(MandatoryBy; Rec."Mandatory By")
                {
                    Caption = 'Automatically enabled from';
                    ToolTip = 'Specifies a future software version and approximate date when this feature is automatically enabled for all users and cannot be disabled. Until this future version, the feature is optional.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field(EnabledFor; Rec.Enabled)
                {
                    Caption = 'Enabled for';
                    ToolTip = 'Specifies whether the feature is enabled for all users or for none. The change takes effect the next time each user signs in.';
                    ApplicationArea = All;
                    Editable = (not "Is One Way") or (Enabled = Enabled::None);
                    StyleExpr = EnabledForStyle;

                    trigger OnValidate()
                    var
                        Confirmed: Boolean;
                    begin
                        case Rec.Enabled of
                            Rec.Enabled::None:
                                if Rec."Is One Way" then
                                    Error(OneWayAlreadyEnabledErr);
                            else begin
                                    if Rec."Is One Way" then
                                        Confirmed := Confirm(OneWayWarningMsg)
                                    else
                                        Confirmed := true;
                                    if not Confirmed then
                                        Error('');

                                    if not FeatureManagementFacade.Update(FeatureDataUpdateStatus) then
                                        Error('');
                                end;
                        end;
                        FeatureManagementFacade.AfterValidateEnabled(Rec);
                        UpdateStyle();
                        CurrPage.Update(true);
                    end;
                }
                field(TryItOut; TryItOut)
                {
                    Caption = 'Get started';
                    ApplicationArea = All;
                    Editable = false;
                    Enabled = "Can Try";
                    ToolTip = 'Starts a new session with the feature temporarily enabled (opens in a new tab). This does not affect any other users.';
                    trigger OnDrillDown()
                    begin
                        if Rec."Can Try" then begin
                            HyperLink(FeatureManagementFacade.GetFeatureKeyUrlForWeb(Rec.ID));
                            Message(TryItOutStartedMsg);
                        end;
                    end;
                }
                field(DataUpdateStatus; FeatureDataUpdateStatus."Feature Status")
                {
                    Caption = 'Current Company Status';
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the status of data update in the current company. Until it is complete the feature is not fully enabled in the current company.';
                    StyleExpr = DataUpdateStype;
                }
                field("Start Date\Time"; FeatureDataUpdateStatus."Start Date/Time")
                {
                    Caption = 'Update Start Date/Time';
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the earliest date and time when the data update task should be run.';
                }
                field("Task Id"; FeatureDataUpdateStatus."Task ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                    Editable = false;
                    ToolTip = 'Specifies the id of the scheduled task.';
                }
                field("Session Id"; FeatureDataUpdateStatus."Session ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                    Editable = false;
                    ToolTip = 'Specifies the session id where the task is being ran.';
                }
                field("Server Instance ID"; FeatureDataUpdateStatus."Server Instance ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                    Editable = false;
                    ToolTip = 'Specifies the serviec instance id where the task is being ran.';
                }
            }
        }
        area(factboxes)
        {
            part("Upcoming Changes FactBox"; "Upcoming Changes Factbox")
            {
                ApplicationArea = All;
            }
        }
    }
    actions
    {
        area(Processing)
        {
            group(DataUpdate)
            {
                Caption = 'Data Update';
                action(Schedule)
                {
                    Caption = 'Schedule';
                    ToolTip = 'Schedule or run the data update task in the current or background session.';
                    Image = Planning;
                    ApplicationArea = All;
                    Visible = CanSchedule;
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    trigger OnAction()
                    begin
                        FeatureManagementFacade.Update(FeatureDataUpdateStatus);
                    end;
                }
                action(ShowTaskLog)
                {
                    Caption = 'Show Log';
                    ToolTip = 'Show the error log entry.';
                    Image = Log;
                    ApplicationArea = All;
                    Visible = CanShowLog;
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    trigger OnAction()
                    begin
                        FeatureManagementFacade.OnShowTaskLog(FeatureDataUpdateStatus);
                    end;
                }
                action(CancelScheduling)
                {
                    Caption = 'Cancel Scheduled Job';
                    ToolTip = 'Cancel the scheduled data update task.';
                    Image = Cancel;
                    ApplicationArea = All;
                    Visible = CanCancelScheduling;
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    trigger OnAction()
                    begin
                        FeatureManagementFacade.CancelTask(FeatureDataUpdateStatus, True);
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        FeatureIDFilter: Text;
        IgnoreFilter: Boolean;
    begin
        OnOpenFeatureMgtPage(FeatureIDFilter, IgnoreFilter);
        if not IgnoreFilter and (FeatureIDFilter <> '') then begin
            Rec.FilterGroup(2);
            Rec.SetFilter(ID, FeatureIDFilter);
            Rec.FilterGroup(0);
        end;
    end;

    trigger OnAfterGetRecord()
    begin
        GetFeatureDataUpdateStatus();
        if Rec."Can Try" then
            TryItOut := TryItOutLbl
        else
            Clear(TryItOut);
    end;

    trigger OnAfterGetCurrRecord()
    begin
        GetFeatureDataUpdateStatus();
        if Rec."Can Try" then
            TryItOut := TryItOutLbl
        else
            Clear(TryItOut);
    end;

    var
        FeatureDataUpdateStatus: Record "Feature Data Update Status";
        FeatureManagementFacade: Codeunit "Feature Management Facade";
        LearnMoreLbl: Label 'Learn more';
        TryItOutLbl: Label 'Try it out';
        TryItOutStartedMsg: Label 'A new browser tab was opened for you to try out the feature. For now, the feature has been temporarily enabled for you only. It will remain enabled whenever you open Business Central in the browser, until you completely sign out or close the browser.';
        OneWayWarningMsg: Label 'After you enable this feature for all users, you cannot turn it off again. This is because the feature may include changes to your data and may initiate an upgrade of some database tables as soon as you enable it.\\We strongly recommend that you first enable and test this feature on a sandbox environment that has a copy of production data before doing this on a production environment.\\For detailed information about the impact of enabling this feature, you should choose No and use the Learn more link.\\Are you sure you want to enable this feature?';
        OneWayAlreadyEnabledErr: Label 'This feature has already been enabled and cannot be disabled.';
        TryItOut: Text;
        CanSchedule: Boolean;
        CanCancelScheduling: Boolean;
        CanShowLog: Boolean;
        EnabledForStyle: Text;
        DataUpdateStype: Text;

    local procedure GetFeatureDataUpdateStatus()
    begin
        FeatureManagementFacade.GetFeatureDataUpdateStatus(Rec, FeatureDataUpdateStatus);
        UpdateVisibility();
        UpdateStyle();
    end;

    local procedure IsFeatureEnabled(): Boolean;
    begin
        exit(Rec.Enabled = Rec.Enabled::"All Users");
    end;

    local procedure InitActionVisibility()
    begin
        CanSchedule := false;
        CanCancelScheduling := false;
        CanShowLog := false;
    end;

    local procedure UpdateVisibility()
    begin
        InitActionVisibility();
        if FeatureDataUpdateStatus."Data Update Required" and IsFeatureEnabled() then
            UpdateActionsVisibility(
                FeatureDataUpdateStatus."Feature Status", CanSchedule, CanCancelScheduling, CanShowLog);
    end;

    local procedure UpdateActionsVisibility(DataUpdateStatus: enum "Feature Status"; var CanSchedule: Boolean; var CanCancelScheduling: Boolean; var CanShowLog: Boolean);
    begin
        CanSchedule := false;
        CanCancelScheduling := false;
        CanShowLog := false;

        case DataUpdateStatus of
            DataUpdateStatus::Pending:
                CanSchedule := true;
            DataUpdateStatus::Scheduled:
                CanCancelScheduling := true;
            DataUpdateStatus::Updating:
                CanShowLog := true;
            DataUpdateStatus::Incomplete:
                begin
                    CanSchedule := true;
                    CanShowLog := true;
                end;
            DataUpdateStatus::Complete:
                CanShowLog := true;
        end;
    end;

    local procedure UpdateStyle()
    begin
        case Rec.Enabled of
            Rec.Enabled::"All Users":
                case FeatureDataUpdateStatus."Feature Status" of
                    FeatureDataUpdateStatus."Feature Status"::Enabled,
                    FeatureDataUpdateStatus."Feature Status"::Complete:
                        begin
                            EnabledForStyle := 'Favorable';
                            DataUpdateStype := 'Favorable';
                        end;

                    FeatureDataUpdateStatus."Feature Status"::Pending:
                        begin
                            EnabledForStyle := 'Ambiguous';
                            DataUpdateStype := 'Unfavorable';
                        end;
                    FeatureDataUpdateStatus."Feature Status"::Scheduled,
                    FeatureDataUpdateStatus."Feature Status"::Updating:
                        begin
                            EnabledForStyle := 'Ambiguous';
                            DataUpdateStype := 'StrongAccent';
                        end;
                    FeatureDataUpdateStatus."Feature Status"::Incomplete:
                        begin
                            EnabledForStyle := 'Unfavorable';
                            DataUpdateStype := 'Unfavorable';
                        end;
                end;
            Rec.Enabled::None:
                begin
                    EnabledForStyle := 'Subordinate';
                    DataUpdateStype := 'Subordinate';
                end;
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnOpenFeatureMgtPage(var FeatureIDFilter: Text; var IgnoreFilter: Boolean)
    begin
    end;
}