// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

codeunit 7279 "Notification Manager"
{
    Access = Internal;
    local procedure GetNotificationId(): Guid
    begin
        exit('8f3bd624-bac8-4ef2-8555-606e1f534b50');
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