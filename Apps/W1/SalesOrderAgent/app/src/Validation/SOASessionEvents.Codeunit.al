// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.SalesOrderAgent;

using System.Environment.Configuration;

codeunit 4304 "SOA Session Events"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    SingleInstance = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Initialization", OnAfterInitialization, '', false, false)]
    local procedure RegisterSubscribersOnAfterLogin()
    begin
        // Agent login must fail if we cannot register agent subscribers or if there are too many unpaid entries
        RegisterAgentEvents();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Initialization", OnAfterLogin, '', false, false)]
    local procedure RegisterSubscribersOnAfterLogout()
    begin
        // User events are used to track KPIs, user login must not be blocked
        RegisterUserSubscribers();
    end;

    local procedure RegisterAgentEvents()
    var
        AgentTaskID: BigInteger;
    begin
        if not GlobalSOAKPITrackAll.IsOrderTakerAgentSession(AgentTaskID) then
            exit;

        VerifyUnpaidEntries();
        SetupKPITrackingEvents();
        SetupItemSearchEvents();
        SetupFilteringEvents(AgentTaskID);
        SetupSOABillingEvents(AgentTaskID);
    end;

    local procedure RegisterUserSubscribers()
    var
        AgentTaskID: BigInteger;
        TrackChanges: Boolean;
    begin
        if GlobalSOAKPITrackAll.IsOrderTakerAgentSession(AgentTaskID) then
            exit;

        // Cover a case when a regular session is updating the work Agent did, if there is any work to track
        TrackChanges := GlobalSOAKPITrackAll.TrackChanges();
        if not TrackChanges then
            exit;

        BindUserEvents();
    end;

    internal procedure BindUserEvents()
    var
        SOAImpl: Codeunit "SOA Impl";
    begin
        if not BindSubscription(GlobalSOAKPITrackAll) then
            Session.LogMessage('0000O41', FailedToBindUserKPISubscriptionErr, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, SOAImpl.GetCustomDimensions());

        if not BindSubscription(GlobalSOAUserNotifications) then
            Session.LogMessage('0000ORY', FailedToBindUserNotificationErr, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, SOAImpl.GetCustomDimensions());
    end;

    local procedure SetupKPITrackingEvents()
    begin
        if BindSubscription(GlobalSOAKPITrackAll) then;
        if BindSubscription(GlobalSOAKPITrackAgents) then;
    end;

    local procedure SetupItemSearchEvents()
    begin
        if BindSubscription(GlobalSOAItemSearch) then;
        if BindSubscription(GlobalSOAVariantSearch) then;
    end;

    local procedure SetupSOABillingEvents(AgentTaskID: Integer)
    begin
        GlobalSOABillingEvents.SetAgentTaskID(AgentTaskID);
        BindSubscription(GlobalSOABillingEvents);
    end;

    local procedure SetupFilteringEvents(AgentTaskID: Integer)
    var
        SOAImpl: Codeunit "SOA Impl";
        DisableFilters: Boolean;
    begin
        GlobalSessionFilter.SetAgentTaskID(AgentTaskID);
        OnDisableContactAndCustomerFiltering(DisableFilters);
        if not DisableFilters then
            BindSubscription(GlobalSessionFilter)
        else
            Session.LogMessage('0000O33', ContactFilteringDisabledAgentTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, SOAImpl.GetCustomDimensions());
    end;

    [InternalEvent(false, false)]
    local procedure OnDisableContactAndCustomerFiltering(var DisableFilters: Boolean)
    begin
    end;

    local procedure VerifyUnpaidEntries()
    var
        SOABilling: Codeunit "SOA Billing";
    begin
        if SOABilling.TooManyUnpaidEntries() then
            Error(SOABilling.GetTooManyUnpaidEntriesMessage());
    end;

    var
        GlobalSOABillingEvents: Codeunit "SOA Billing Events";
        GlobalSessionFilter: Codeunit "SOA Session Filter";
        GlobalSOAItemSearch: Codeunit "SOA Item Search";
        GlobalSOAVariantSearch: Codeunit "SOA Variant Search";
        GlobalSOAKPITrackAgents: Codeunit "SOA - KPI Track Agents";
        GlobalSOAKPITrackAll: Codeunit "SOA - KPI Track All";
        GlobalSOAUserNotifications: Codeunit "SOA User Notifications";
        ContactFilteringDisabledAgentTxt: Label 'Contact and customer filtering is disabled for this agent through an event.', Locked = true;
        FailedToBindUserKPISubscriptionErr: Label 'Failed to bind subscription for User Agent KPI changes.', Locked = true;
        FailedToBindUserNotificationErr: Label 'Failed to bind subscription for User Agent Notifications.', Locked = true;
}