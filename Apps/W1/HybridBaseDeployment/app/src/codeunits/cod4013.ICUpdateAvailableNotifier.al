codeunit 4013 "Intelligent Cloud Notifier"
{
    Permissions = tabledata "My Notifications" = rimd,
                  tabledata "Intelligent Cloud" = r;
    SingleInstance = true;

    var
        MyNotifications: Record "My Notifications";
        ICUpdateAvailableTxt: Label 'An update is available for the Cloud Migration.';
        OpenWizardTxt: Label 'Open Update Wizard';
        ICNotificationNameTxt: Label 'Cloud Migration Update notification';
        ICNotificationDescTxt: Label 'Show a notification when an update to the Cloud Migration is available.';

    local procedure IsICNotificationEnabled(): Boolean;
    begin
        exit(MyNotifications.IsEnabled(GetICNotificationGuid()));
    end;

    procedure ShowICUpdateNotification();
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        IntelligentCloud: Record "Intelligent Cloud";
    begin
        if not IntelligentCloud.Get() then
            exit;

        if not IntelligentCloud.Enabled then
            exit;

        if IsICNotificationEnabled() and IntelligentCloudSetup.UpdateAvailable() then
            CreateNotification(GetICNotificationGuid(), ICUpdateAvailableTxt, NotificationScope::LocalScope, OpenWizardTxt, 'OpenICUpdateWizard');
    end;

    procedure OpenICUpdateWizard(ICUpdateNotification: Notification);
    begin
        Page.Run(Page::"Intelligent Cloud Update");
    end;

    procedure GetICNotificationGuid(): Guid
    begin
        exit('767002cc-ed73-4a46-afe9-800633abc358');
    end;

    procedure CreateNotification(NotificationGUID: Guid; MessageText: Text; ICNotificationScope: NotificationScope; ActionText: Text; ActionFunction: Text);
    var
        ICNotification: Notification;
    begin
        ICNotification.Id := NotificationGUID;
        ICNotification.Message := MessageText;
        ICNotification.Scope := ICNotificationScope;
        ICNotification.AddAction(ActionText, Codeunit::"Intelligent Cloud Notifier", ActionFunction);
        ICNotification.Send();
    end;

    [EventSubscriber(ObjectType::Page, Page::"My Notifications", 'OnInitializingNotificationWithDefaultState', '', false, false)]
    local procedure OnInitializingNotificationWithDefaultState()
    begin
        MyNotifications.InsertDefault(GetICNotificationGuid(), ICNotificationNameTxt, ICNotificationDescTxt, true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Role Center Notification Mgt.", 'OnBeforeShowNotifications', '', false, false)]
    local procedure OnBeforeShowRoleCenterNotifications()
    begin
        ShowICUpdateNotification();
    end;
}

