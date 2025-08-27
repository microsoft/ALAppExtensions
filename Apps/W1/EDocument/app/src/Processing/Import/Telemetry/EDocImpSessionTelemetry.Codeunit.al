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
        if BindSubscription(this) then;
        Clear(Data);
        Clear(LineData);
        this.SetText('CurrentStatus', CurrentStatus.Names().Get(CurrentStatus.Ordinals.IndexOf(CurrentStatus.AsInteger())));
        this.SetText('DesiredStatus', DesiredStatus.Names().Get(DesiredStatus.Ordinals.IndexOf(DesiredStatus.AsInteger())));
    end;

    internal procedure Emit(EDocument: Record "E-Document")
    var
        Telemetry: Codeunit "Telemetry";
        SystemID, Session : Text;
    begin
        Session := LowerCase(CreateGuid()).Replace('}', '').Replace('{', '');
        SystemID := CreateSystemIdText(EDocument.SystemId);
        Data.Set('Session', Session);
        Data.Set(GetEDocSystemIdTok(), SystemID);
        Telemetry.LogMessage('0000PJD', 'E-Document Import Session', Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, Data);
        EmitLines(SystemID, Session);

        Clear(Data);
        Clear(LineData);
        if UnbindSubscription(this) then;
    end;

    local procedure EmitLines(SystemId: Text; Session: Text)
    var
        Telemetry: Codeunit "Telemetry";
        K: Guid;
        LineDataEntry: Dictionary of [Text, Text];
    begin
        foreach K in LineData.Keys() do begin
            if not LineData.Get(K, LineDataEntry) then
                continue;

            LineDataEntry.Set('Session', Session);
            LineDataEntry.Set(GetEDocSystemIdTok(), SystemID);
            LineDataEntry.Set(GetEDocLineSystemIdTok(), LowerCase(K).Replace('}', '').Replace('{', ''));
            Telemetry.LogMessage('0000PSQ', 'E-Document Import Session', Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, LineDataEntry);
        end;
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
        Data.Set("Key", Format("Value", 0, 9));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"E-Doc. Imp. Session Telemetry", SetLineBool, '', false, false)]
    local procedure OnSetLineBool(LineId: Guid; "Key": Text; "Value": Boolean)
    var
        EmptyDict: Dictionary of [Text, Text];
    begin
        if not LineData.ContainsKey(LineId) then
            LineData.Set(LineId, EmptyDict);

        LineData.Get(LineId).Set("Key", Format("Value", 0, 9));
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

    procedure CreateSystemIdText(SystemId: Guid): Text
    begin
        exit(LowerCase(SystemId).Replace('}', '').Replace('{', ''));
    end;

    procedure GetEDocSystemIdTok(): Text
    begin
        exit('E-Document System Id');
    end;

    procedure GetEDocLineSystemIdTok(): Text
    begin
        exit('E-Document Line System Id');
    end;

}