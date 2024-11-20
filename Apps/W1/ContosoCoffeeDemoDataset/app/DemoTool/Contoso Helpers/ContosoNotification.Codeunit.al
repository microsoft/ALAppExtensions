codeunit 5399 "Contoso Notification"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Notification Setup" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;


    procedure InsertNotification(UserID: Code[50]; NotificationType: Enum "Notification Entry Type"; NotificationMethod: Enum "Notification Method Type")
    var
        NotificationSetup: Record "Notification Setup";
        Exists: Boolean;
    begin
        if NotificationSetup.Get(UserID, NotificationType) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        NotificationSetup."User ID" := UserID;
        NotificationSetup.Validate("Notification Type", NotificationType);
        NotificationSetup.Validate("Notification Method", NotificationMethod);

        if Exists then
            NotificationSetup.Modify(true)
        else
            NotificationSetup.Insert(true);
    end;
}