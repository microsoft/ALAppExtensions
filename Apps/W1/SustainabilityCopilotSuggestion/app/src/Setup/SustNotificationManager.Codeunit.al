// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Copilot;

codeunit 6291 "Sust. Notification Manager"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    local procedure GetNotificationId(): Guid
    begin
        exit('45b0be68-4cd3-4c6f-a637-17f93d20a79f');
    end;

    procedure RecallNotification()
    var
        Notification: Notification;
    begin
        Notification.Id := GetNotificationId();
        Notification.Recall();
    end;

    procedure SendNotification(NotificationMessage: Text)
    var
        Notification: Notification;
    begin
        Notification.Id := GetNotificationId();
        Notification.Scope := NotificationScope::LocalScope;
        Notification.Recall();
        Notification.Message := NotificationMessage;
        Notification.Send();
    end;
}