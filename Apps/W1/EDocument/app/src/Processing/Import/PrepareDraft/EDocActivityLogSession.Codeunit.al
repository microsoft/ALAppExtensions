// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.Import;

using System.Log;

/// <summary>
/// Codeunit to manage the E-Document Activity Log Session.
/// This codeunit captures the activity log builder instances for different activities.
/// </summary>
codeunit 6175 "E-Doc. Activity Log Session"
{

    InherentPermissions = X;
    InherentEntitlements = X;
    Access = Internal;

    // We binds ourself to the event subscriber defined in this codeunit. 
    // Allowing us to capture events inside the e-document import logic, without having to pass around the state.
    // When SetSession is called, we bind, and all calls to SetX from any instance in the code, will be captured by the codeunit instance that called SetSession.
    EventSubscriberInstance = Manual;

    var
        ActivityLogInstances: Dictionary of [Text, Codeunit "Activity Log Builder"];


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"E-Doc. Activity Log Session", Get, '', false, false)]
    local procedure OnGet(ActivityLogName: Text; var ActivityLogBuilder: Codeunit "Activity Log Builder"; var Found: Boolean)
    begin
        Found := ActivityLogInstances.ContainsKey(ActivityLogName);
        if Found then
            ActivityLogBuilder := ActivityLogInstances.Get(ActivityLogName);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"E-Doc. Activity Log Session", Set, '', false, false)]
    local procedure OnSet(ActivityLogName: Text; ActivityLogBuilder: Codeunit "Activity Log Builder")
    begin
        ActivityLogInstances.Set(ActivityLogName, ActivityLogBuilder);
    end;

    [IntegrationEvent(false, false)]
    procedure Get(ActivityLogName: Text; var ActivityLogBuilder: Codeunit "Activity Log Builder"; var Found: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure Set(ActivityLogName: Text; ActivityLogBuilder: Codeunit "Activity Log Builder")
    begin
    end;

    procedure CreateSession(): Boolean
    begin
        exit(BindSubscription(this));
    end;

    procedure EndSession(): Boolean
    begin
        exit(UnbindSubscription(this));
    end;

    procedure CleanUpLogs()
    begin
        Clear(ActivityLogInstances);
    end;

    procedure DeferralTok(): Text
    begin
        exit('Deferral');
    end;

    procedure AccountNumberTok(): Text
    begin
        exit('AccountNumber');
    end;

    procedure ItemRefTok(): Text
    begin
        exit('ItemRef');
    end;

    procedure TextToAccountMappingTok(): Text
    begin
        exit('TextToAccountMapping');
    end;


}