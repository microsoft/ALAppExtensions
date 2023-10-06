namespace Microsoft.Integration.Shopify;

using System.Environment.Configuration;

codeunit 30211 "Shpfy Shop Mgt."
{
    var
        DontShowThisAgainMsg: Label 'Don''t show this again.';
        ExpirationNotificationMsg: Label 'The Shopify API used by your current Shopify connector will go out of support on %1. Please upgrade the Shopify connector and your Business Central environment.', Comment = '%1 - expiry date';
        BlockedNotificationMsg: Label 'The Shopify API used by your current Shopify connector is no longer supported. To continue using the Shopify connector, please upgrade the Shopify connector and your Business Central environment.';
        ExpirationNotificationNameTok: Label 'Notify user of Shopify connector going out of support.';
        ExpirationNotificationDescTok: Label 'Show a notification informing the user that Shopify connector going out of support.';
        BlockedNotificationNameTok: Label 'Notify user of Shopify connector is out of support.';
        BlockedNotificationDescTok: Label 'Show a notification informing the user that Shopify connector is out of support.';

    internal procedure IsEnabled(): Boolean
    var
        Shop: Record "Shpfy Shop";
    begin
        if not Shop.ReadPermission() then
            exit(false);

        Shop.SetRange(Enabled, true);
        exit(not Shop.IsEmpty());
    end;

    [EventSubscriber(ObjectType::Report, Report::"Copy Company", 'OnAfterCreatedNewCompanyByCopyCompany', '', false, false)]
    local procedure HandleOnAfterCreatedNewCompanyByCopyCompany(NewCompanyName: Text[30])
    var
        Shop: Record "Shpfy Shop";
    begin
        Shop.ChangeCompany(NewCompanyName);
        Shop.ModifyAll(Enabled, false);
    end;

    internal procedure SendExpirationNotification(ExpiryDate: Date)
    var
        ExpirationNotification: Notification;
    begin
        ExpirationNotification.Id := GetExpirationNotificationId();
        ExpirationNotification.Message := StrSubstNo(ExpirationNotificationMsg, Format(ExpiryDate));
        ExpirationNotification.Scope := NotificationScope::LocalScope;
        ExpirationNotification.AddAction(DontShowThisAgainMsg, Codeunit::"Shpfy Shop Mgt.", 'DisableExpirationNotification');
        ExpirationNotification.Send();
    end;

    internal procedure SendBlockedNotification()
    var
        BlockedNotification: Notification;
    begin
        BlockedNotification.Id := GetBlockedNotificationId();
        BlockedNotification.Message := BlockedNotificationMsg;
        BlockedNotification.Scope := NotificationScope::LocalScope;
        BlockedNotification.AddAction(DontShowThisAgainMsg, Codeunit::"Shpfy Shop Mgt.", 'DisableBlockedNotification');
        BlockedNotification.Send();
    end;

    local procedure GetExpirationNotificationId(): Guid
    begin
        exit('89b04070-dfda-435b-9e28-7370fd019d1b');
    end;

    local procedure GetBlockedNotificationId(): Guid
    begin
        exit('ab9b0be3-4755-4e72-bcbd-b0b19b453d10');
    end;

    procedure DisableExpirationNotification(Notification: Notification)
    var
        MyNotifications: Record "My Notifications";
    begin
        if MyNotifications.WritePermission() then
            if not MyNotifications.Disable(GetExpirationNotificationId()) then
                MyNotifications.InsertDefault(GetExpirationNotificationId(), ExpirationNotificationNameTok, ExpirationNotificationDescTok, false);
    end;

    procedure DisableBlockedNotification(Notification: Notification)
    var
        MyNotifications: Record "My Notifications";
    begin
        if MyNotifications.WritePermission() then
            if not MyNotifications.Disable(GetBlockedNotificationId()) then
                MyNotifications.InsertDefault(GetBlockedNotificationId(), BlockedNotificationNameTok, BlockedNotificationDescTok, false);
    end;
}