// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.Import;

using Microsoft.eServices.EDocument;
using System.Telemetry;

/// <summary>
/// E-Document Import Draft Document Session Telemetry.
/// Allows you to record events during the import of E-Document draft documents.
/// </summary>
codeunit 6122 "E-Doc. Imp. Session Telemetry"
{

    InherentPermissions = X;
    InherentEntitlements = X;
    Access = Internal;

    // We binds ourself to the event subscriber defined in this codeunit. 
    // Allowing us to capture events inside the e-document import logic, without having to pass around the state.
    // When SetSession is called, we bind, and all calls to SetX from any instance in the code, will be captured by the codeunit instance that called SetSession.
    EventSubscriberInstance = Manual;

    var
        Data: Dictionary of [Text, Text];
        LineData: Dictionary of [Guid, Dictionary of [Text, Text]];

    internal procedure SetSession(CurrentStatus: Enum "Import E-Doc. Proc. Status"; DesiredStatus: Enum "Import E-Doc. Proc. Status")
    begin
        Clear(Data);
        Clear(LineData);
        if BindSubscription(this) then;
        this.SetText('CurrentStatus', Format(CurrentStatus));
        this.SetText('DesiredStatus', Format(DesiredStatus));
    end;

    internal procedure Emit(EDocument: Record "E-Document")
    var
        Telemetry: Codeunit "Telemetry";
        K: Guid;
        LK, LV, SystemID : Text;
        LineDataEntry: Dictionary of [Text, Text];
    begin
        foreach K in LineData.Keys() do begin
            if not LineData.Get(K, LineDataEntry) then
                continue;

            foreach LK in LineDataEntry.Keys() do begin
                if not LineDataEntry.Get(LK, LV) then
                    continue;

                if Data.Add(Format(K) + '_' + LK, LV) then;
            end;
        end;

        SystemID := Format(EDocument.SystemId);
        SystemID := SystemID.Replace('}', '');
        SystemID := SystemID.Replace('{', '');
        Data.Set('E-Document System Id', SystemID);
        Telemetry.LogMessage('0000PJD', 'E-Document Import Session Run', Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, Data);
        if UnbindSubscription(this) then;
        Clear(Data);
        Clear(LineData);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"E-Doc. Imp. Session Telemetry", SetText, '', false, false)]
    local procedure OnSetText("Key": Text; "Value": Text)
    begin
        Data.Set("Key", "Value")
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"E-Doc. Imp. Session Telemetry", SetBool, '', false, false)]
    local procedure OnSetBool("Key": Text; "Value": Boolean)
    begin
        Data.Set("Key", Format("Value"))
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"E-Doc. Imp. Session Telemetry", SetLineBool, '', false, false)]
    local procedure OnSetLineBool(LineId: Guid; "Key": Text; "Value": Boolean)
    var
        EmptyDict: Dictionary of [Text, Text];
    begin
        if not LineData.ContainsKey(LineId) then
            LineData.Set(LineId, EmptyDict);

        LineData.Get(LineId).Set("Key", Format("Value"));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"E-Doc. Imp. Session Telemetry", SetLineText, '', false, false)]
    local procedure OnSetLineText(LineId: Guid; "Key": Text; "Value": Text)
    var
        EmptyDict: Dictionary of [Text, Text];
    begin
        if not LineData.ContainsKey(LineId) then
            LineData.Set(LineId, EmptyDict);

        LineData.Get(LineId).Set("Key", Value);
    end;

    [IntegrationEvent(false, false)]
    procedure SetText("Key": Text; "Value": Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure SetBool("Key": Text; "Value": Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure SetLineBool(LineId: Guid; "Key": Text; "Value": Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure SetLineText(LineId: Guid; "Key": Text; "Value": Text)
    begin
    end;


}