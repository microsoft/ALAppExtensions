// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.SalesOrderAgent;

using Microsoft.Sales.Document;
using System.Agents;
using System.Environment.Configuration;

codeunit 4323 "SOA Awareness Notifications"
{
    Access = Internal;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Page, Page::"Sales Order", 'OnNewRecordEvent', '', false, false)]
    local procedure SalesOrderOnNewRecordEvent(var Rec: Record "Sales Header"; BelowxRec: Boolean; var xRec: Record "Sales Header")
    begin
        ProcessManualActionCounter();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Quote", 'OnNewRecordEvent', '', false, false)]
    local procedure SalesQuoteOnNewRecordEvent(var Rec: Record "Sales Header"; BelowxRec: Boolean; var xRec: Record "Sales Header")
    begin
        ProcessManualActionCounter();
    end;

    internal procedure IsBindingNeeded(): Boolean
    var
        MyNotifications: Record "My Notifications";
        SOASetup: Record "SOA Setup";
        AgentSession: Codeunit "Agent Session";
        AgentMetadataProvider: Enum "Agent Metadata Provider";
    begin
        if not MyNotifications.IsEnabled(GetSOAAwarenessNotificationId()) then
            exit(false);

        if AgentSession.IsAgentSession(AgentMetadataProvider) then
            exit(false);

        exit(SOASetup.IsEmpty());
    end;

    local procedure ProcessManualActionCounter()
    begin
        if SOARelatedManualActionCount < 4 then
            SOARelatedManualActionCount += 1
        else
            NotifyUserAboutSOA();
    end;

    local procedure NotifyUserAboutSOA()
    var
        MyNotifications: Record "My Notifications";
        SOAAwarenessNotification: Notification;
    begin
        if not MyNotifications.IsEnabled(GetSOAAwarenessNotificationId()) then
            exit;

        SOAAwarenessNotification.Id(GetSOAAwarenessNotificationId());
        SOAAwarenessNotification.Message(SOAAwarenessNotificationTxt);
        SOAAwarenessNotification.AddAction(LearnMoreLbl, Codeunit::"SOA Awareness Notifications", 'SOAAwarenessLearnMore');
        SOAAwarenessNotification.AddAction(DisableSOAAwarenessNotificationTxt, Codeunit::"SOA Awareness Notifications", 'DisableSOAAwarenessNotification');
        if SOAAwarenessNotification.Recall() then;
        SOAAwarenessNotification.Send();
    end;

    internal procedure SOAAwarenessLearnMore(var AwarenessNotification: Notification)
    begin
        HyperLink(SOAAwarenessLinkLbl);
    end;

    internal procedure DisableSOAAwarenessNotification(HostNotification: Notification)
    var
        MyNotifications: Record "My Notifications";
    begin
        if MyNotifications.Get(UserId(), GetSOAAwarenessNotificationId()) then
            MyNotifications.Disable(GetSOAAwarenessNotificationId())
        else
            MyNotifications.InsertDefault(GetSOAAwarenessNotificationId(), CopyStr(SOAAwarenessNotificationNameTxt, 1, 128),
                SOAAwarenessNotificationDescriptionTxt, false);
    end;

    local procedure GetSOAAwarenessNotificationId(): Guid;
    begin
        exit('502dd03f-4552-49af-8dab-6799258b926c');
    end;

    var
        SOAAwarenessNotificationNameTxt: Label 'Notify the user who creates quotes or orders manually that the Sales Order Agent can automate quote creation from customer emails';
        SOAAwarenessNotificationDescriptionTxt: Label 'Notification to users who manually create sales quotes or orders, informing them that they can enable the Sales Order Agent to automate creating quotes from customer email requests';
        SOAAwarenessNotificationTxt: Label 'You can activate the Sales Order Agent, which uses AI to automatically create and update quotes based on customer email requests.';
        DisableSOAAwarenessNotificationTxt: Label 'Don''t show again';
        LearnMoreLbl: Label 'Learn more';
        SOAAwarenessLinkLbl: Label 'https://go.microsoft.com/fwlink/?linkid=2344613', Locked = true;
        SOARelatedManualActionCount: Integer;
}