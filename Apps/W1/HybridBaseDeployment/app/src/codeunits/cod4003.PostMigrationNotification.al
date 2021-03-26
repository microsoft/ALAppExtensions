codeunit 4003 "Post Migration Notificaton"
{
    Permissions = TableData "My Notifications" = rimd;
    SingleInstance = true;

    var
        MyNotification: Record "My Notifications";
        SetpsRemainMsg: Label 'Post Migration steps are pending';
        OpenWorksheetActionLbl: Label 'Open Setup Checklist';
        DontShowAgainLbl: Label 'Don''t show me again';
        DismissNotificationLbl: Label 'Make sure you have completed all of the Post Migration Steps.';
        CLNotificationNameTxt: Label 'Post Migration Checklist notification';
        CLNotificationDescTxt: Label 'Show a notification when Post Migration Steps are pending.';

    procedure IsCLNotificationEnabled(): Boolean;
    begin
        exit(MyNotification.IsEnabled(GetNotificationGuid()));
    end;

    local procedure IsChecklistInComplete(): Boolean;
    var
        PostMigChecklist: Record "Post Migration Checklist";
    begin
        PostMigChecklist.Reset();
        PostMigChecklist.FilterGroup(-1);
        PostMigChecklist.SetFilter(Help, '%1', false);
        PostMigChecklist.SetFilter("Users Setup", '%1', false);
        PostMigChecklist.SetFilter("Disable Intelligent Cloud", '%1', false);
        PostMigChecklist.SetFilter("D365 Sales", '%1', false);
        PostMigChecklist.SetFilter("Define User Mappings", '%1', false);
        if PostMigChecklist.IsEmpty() then
            exit(false)
        else
            exit(true);
    end;

    procedure DisableNotifications(Notification: Notification)
    var
    begin
        MyNotification.InsertDefault(GetNotificationGuid(), CLNotificationNameTxt, CLNotificationDescTxt, false);
        MyNotification.Disable(GetNotificationGuid());
        Message(DismissNotificationLbl);
    end;

    procedure ShowChecklistNotification();
    var
        PostMigChecklist: Record "Post Migration Checklist";
    begin
        PostMigChecklist.Reset();
        if IsCLNotificationEnabled() and IsChecklistInComplete() then
            CreateNotification(GetNotificationGuid(), SetpsRemainMsg, NotificationScope::LocalScope, OpenWorksheetActionLbl, 'OpenSetupChecklist', DontShowAgainLbl, 'DisableNotifications');
    end;

    procedure CreateNotification(NotificationGUID: Guid; MessageText: Text; ICNotificationScope: NotificationScope; ActionText1: Text; ActionFunction1: Text; ActionText2: Text; ActionFunction2: Text);
    var
        ICNotification: Notification;
    begin
        ICNotification.Id := NotificationGUID;
        ICNotification.Message := MessageText;
        ICNotification.Scope := ICNotificationScope;
        ICNotification.AddAction(ActionText1, CODEUNIT::"Post Migration Notificaton", ActionFunction1);
        ICNotification.AddAction(ActionText2, CODEUNIT::"Post Migration Notificaton", ActionFunction2);
        ICNotification.Send();
    end;

    procedure OpenSetupChecklist(UpdateNotification: Notification);
    begin
        Page.Run(Page::"Post Migration Checklist");
    end;

    procedure GetNotificationGuid(): Guid
    begin
        exit('2954c1af-0f51-4697-b3a0-46ca44661de4');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Role Center Notification Mgt.", 'OnBeforeShowNotifications', '', false, false)]
    local procedure OnBeforeShowRoleCenterNotifications()
    begin
        ShowChecklistNotification();
    end;
}