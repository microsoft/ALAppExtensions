// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Item.Substitution;

codeunit 7343 "Notification Manager"
{
    Access = Internal;
    local procedure GetNotificationId(): Guid
    begin
        exit('285f56dd-9a4a-48e2-b51f-2c4eeae19c56');
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