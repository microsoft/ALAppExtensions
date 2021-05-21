// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 135004 "Feature Key Test Handler" implements "Feature Data Update"
{
    EventSubscriberInstance = Manual;

    procedure IsDataUpdateRequired(): Boolean;
    begin
        exit(true)
    end;

    procedure ReviewData();
    begin
        Message(IdImplemented + ' Data');
    end;

    procedure UpdateData(FeatureDataUpdateStatus: Record "Feature Data Update Status");
    begin
        if UpdateToFail then
            Error('Failed data update.');
    end;

    procedure AfterUpdate(FeatureDataUpdateStatus: Record "Feature Data Update Status");
    begin

    end;

    procedure GetTaskDescription() TaskDescription: Text;
    begin
        Exit(IdImplemented + '...');
    end;

    var
        IdImplemented: Text[50];
        UpdateToFail: Boolean;

    internal procedure Set(Id: Text[50]; ToFail: Boolean)
    begin
        IdImplemented := Id;
        UpdateToFail := ToFail;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Feature Management Facade", 'OnGetImplementation', '', false, false)]
    local procedure OnGetImplementation(FeatureDataUpdateStatus: Record "Feature Data Update Status"; var FeatureDataUpdate: Interface "Feature Data Update"; var ImplementedId: Text[50]);
    var
        FeatureKeyTestHandler: Codeunit "Feature Key Test Handler";
    begin
        if IdImplemented <> FeatureDataUpdateStatus."Feature Key" then begin
            ImplementedId := '';
            exit; // mock as not implemented
        end;

        FeatureKeyTestHandler.Set(FeatureDataUpdateStatus."Feature Key", UpdateToFail);
        FeatureDataUpdate := FeatureKeyTestHandler;
        ImplementedId := IdImplemented;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Feature Management Facade", 'OnBeforeScheduleTask', '', false, false)]
    local procedure OnBeforeScheduleTask(FeatureDataUpdateStatus: Record "Feature Data Update Status"; var DoNotScheduleTask: Boolean; var TaskId: Guid);
    begin
        DoNotScheduleTask := true;
        TaskID := CreateGuid();
    end;
}