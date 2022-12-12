// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// This page shows the retention policy setup.
/// </summary>
page 3901 "Retention Policy Setup Card"
{
    PageType = Document;
    Caption = 'Retention Policy';
    SourceTable = "Retention Policy Setup";
    DataCaptionFields = "Table Id", "Table Caption", "Retention Period";
    PromotedActionCategories = 'New, Process, Report, Navigate';

    layout
    {
        area(Content)
        {
            group(General)
            {
                field(TableID; Rec."Table ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ID of the table to which the retention policy applies.';
                    Importance = Promoted;
                    ShowMandatory = true;
                }
                field(TableName; Rec."Table Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the table to which the retention policy applies.';
                    Importance = Additional;
                }

                field(TableCaption; Rec."Table Caption")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the caption of the table to which the retention policy applies. The caption is the translated, if applicable, name of the table.';
                    Importance = Promoted;
                }
            }
            group(RetentionPolicyGroup)
            {
                Caption = 'Retention Policy';

                field("Retention Period"; Rec."Retention Period")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies an identifier for the retention period.';
                    Editable = Rec."Apply to all records";
                    Importance = Promoted;
                    ShowMandatory = Rec."Apply to all records";
                }

                field(Manual; Rec.Manual)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the retention policy can only be run manually.';
                    Importance = Additional;
                }
                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the retention policy is enabled.';
                }
                field("Apply to all records"; Rec."Apply to all records")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the retention policy applies to all records in the table. If you want to specify criteria for the records to delete, this toggle must be turned off.';

                    trigger OnValidate()
                    begin
                        ShowExpiredRecordExpirationDate := not Rec."Apply to all records";
                    end;
                }
                field("Expired Record Count"; ExpiredRecordCount)
                {
                    ApplicationArea = All;
                    Caption = 'Expired Records';
                    ToolTip = 'Displays the number of expired records.';
                    Editable = false;
                    StyleExpr = ExpiredRecordCountStyleTxt;
                }
                field("Expired Record Expiration Date"; ExpiredRecordExpirationDate)
                {
                    ApplicationArea = All;
                    Caption = 'Expired Records Expiration Date';
                    ToolTip = 'Displays the earliest expiration date for which there are more expired records than the maximum to be deleted in a single run.';
                    Editable = false;
                    Visible = ShowExpiredRecordExpirationDate;
                    StyleExpr = ExpiredRecordCountStyleTxt;
                }
                field("Date Field No."; Rec."Date Field No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the date or datetime field on the table used to determine the age of a record.';
                    Editable = Rec."Apply to all records";
                    Importance = Additional;
                    ShowMandatory = true;
                }
                field("Date Field Name"; Rec."Date Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the date or datetime field on the table used to determine the age of a record.';
                    Importance = Additional;
                }
                field("Date Field Caption"; Rec."Date Field Caption")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the caption of the date or datetime field on the table used to determine the age of a record. The caption is the translated name of the field.';
                    Importance = Additional;
                }
            }
            part("Retention Policy Setup Lines"; "Retention Policy Setup Lines")
            {
                ApplicationArea = All;
                Caption = 'Record Retention Policy', Comment = 'Record as in ''a record in a table''.';
                SubPageLink = "Table ID" = Field("Table ID");
                Visible = NOT Rec."Apply to all records";
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(RetentionPeriods)
            {
                Caption = 'Retention Periods';
                ApplicationArea = All;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Category4;

                Image = CalendarMachine;
                Tooltip = 'Set up retention periods.';
                RunObject = Page "Retention Periods";
            }
            action(RetentionPolicyLog)
            {
                Caption = 'Retention Policy Log';
                ApplicationArea = All;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;

                Image = Log;
                Tooltip = 'View activity related to retention policies.';
                RunObject = Page "Retention Policy Log Entries";
            }
        }
        area(Processing)
        {
            action(ApplyManually)
            {
                Caption = 'Apply Manually';
                ApplicationArea = All;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                Image = TestDatabase;
                ToolTip = 'Apply the retention policy and delete all expired records in the table.';

                trigger OnAction()
                var
                    ApplyRetentionPolicy: Codeunit "Apply Retention Policy";
                begin
                    ApplyRetentionPolicy.ApplyRetentionPolicy(Rec, true);
                end;
            }
            action(RestoreAllowedTables)
            {
                Caption = 'Refresh allowed tables';
                ApplicationArea = All;
                Image = Refresh;
                ToolTip = 'Refreshes the list of tables that can be selected.';

                trigger OnAction()
                var
                    RetenPolAllowedTables: Codeunit "Reten. Pol. Allowed Tables";
                begin
                    RetenPolAllowedTables.OnRefreshAllowedTables();
                end;
            }
        }
    }

    var
        PBTNotification: Notification;
        PolicyNotEnabledQst: Label 'The retention policy is not enabled. Would you like to enable it now?';
        PrevEnabledState: Boolean;
        ExpiredRecordExpirationDate: Date;
        ExpiredRecordCount: Integer;
        BackgroundTaskId: Integer;
        ExpiredRecordCountStyleTxt: Text;
        ReadPermissionNotificationId: Guid;
        ShowExpiredRecordExpirationDate: Boolean;
        PBTNotificationMsg: Label 'The number of expired records is being calculated in the background. This may take a while.';
        PBTNotificationId: Guid;

    trigger OnOpenPage()
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        FeatureTelemetry.LogUptake('0000FVZ', 'Retention policies', Enum::"Feature Uptake Status"::Discovered);
        ShowExpiredRecordExpirationDate := not Rec."Apply to all records";
    end;

    trigger OnAfterGetCurrRecord()
    var
        RetentionPolicySetup: Record "Retention Policy Setup";
        RetentionPolicySetupImpl: Codeunit "Retention Policy Setup Impl.";
        ReadPermissionNotification: Notification;
        PageBackgroundParameters: Dictionary of [Text, Text];
    begin
        if not RetentionPolicySetup.GetBySystemId(SystemId) then
            exit;

        if not RetentionPolicySetupImpl.TableExists(Rec."Table Id") then
            exit;

        PageBackgroundParameters.Add(Rec.FieldName(SystemId), format(Rec.SystemId));
        RecallPBTNotification();
        CurrPage.EnqueueBackgroundTask(BackgroundTaskId, Codeunit::"PBT Expired Record Count", PageBackgroundParameters, PageBackgroundTaskTimeout());
        ShowPBTNotification();
        ExpiredRecordCount := 0;
        ExpiredRecordExpirationDate := 0D;
        ExpiredRecordCountStyleTxt := 'Subordinate';
        ShowExpiredRecordExpirationDate := not Rec."Apply to all records";
        PrevEnabledState := Rec.Enabled;

        if not IsNullGuid(ReadPermissionNotificationId) then begin
            ReadPermissionNotification.Id(ReadPermissionNotificationId);
            ReadPermissionNotification.Recall();
        end;
        ReadPermissionNotificationId := RetentionPolicySetupImpl.NotifyOnMissingReadPermission(Rec."Table Id");
    end;

    trigger OnPageBackgroundTaskCompleted(TaskId: Integer; Results: Dictionary of [Text, Text])
    var
        ExpiredRecordExpirationDateText: Text;
        ExpiredRecordCountText: Text;
    begin
        if BackgroundTaskId <> TaskId then
            exit;

        Results.Keys.Get(1, ExpiredRecordExpirationDateText);
        if not Evaluate(ExpiredRecordExpirationDate, ExpiredRecordExpirationDateText) then
            ExpiredRecordExpirationDate := 0D;
        Results.Values.Get(1, ExpiredRecordCountText);
        if not Evaluate(ExpiredRecordCount, ExpiredRecordCountText) then
            ExpiredRecordCount := 0;

        ExpiredRecordCountStyleTxt := 'None';
        RecallPBTNotification();
    end;

    trigger OnPageBackgroundTaskError(TaskId: Integer; ErrorCode: Text; ErrorText: Text; ErrorCallStack: Text; var IsHandled: Boolean)
    begin
        RecallPBTNotification();
        Error(ErrorText);
    end;

    local procedure PageBackgroundTaskTimeout(): Integer
    begin
        // maximum value in ms is 600.000
        exit(600000);
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        RetentionPolicySetup: Record "Retention Policy Setup";
    begin
        if CloseAction = CloseAction::Cancel then
            exit(true);

        if not RetentionPolicySetup.Get(Rec."Table Id") then // record was just deleted
            exit(true);

        if (not PrevEnabledState) and (not Rec.Enabled) then
            if Rec.WritePermission() then
                if Confirm(PolicyNotEnabledQst, false) then begin
                    Rec.Validate(Enabled, true);
                    CurrPage.SaveRecord();
                end;
        exit(true);
    end;

    local procedure ShowPBTNotification()
    begin
        if IsNullGuid(PBTNotificationId) then
            PBTNotificationId := CreateGuid();
        PBTNotification.Id := PBTNotificationId;
        PBTNotification.Message(PBTNotificationMsg);
        PBTNotification.Send();
    end;

    local procedure RecallPBTNotification()
    begin
        if IsNullGuid(PBTNotificationId) then
            exit;
        PBTNotification.Id := PBTNotificationId;
        PBTNotification.Recall();
    end;
}