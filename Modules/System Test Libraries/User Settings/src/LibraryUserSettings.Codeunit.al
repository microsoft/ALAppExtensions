codeunit 132000 "Library - User Settings"
{
    procedure ClearAllSettings()
    var
        UserPersonalization: Record "User Personalization";
        ExtraSettings: Record "Extra Settings";
    begin
        UserPersonalization.DeleteAll();
        ExtraSettings.DeleteAll();
    end;

    procedure ClearUserSettings(UserSID: Guid)
    var
        UserPersonalization: Record "User Personalization";
        ExtraSettings: Record "Extra Settings";
    begin
        if UserPersonalization.Get(UserSID) then
            UserPersonalization.Delete();
        if ExtraSettings.Get(UserSID) then
            ExtraSettings.Delete();
    end;

    procedure ClearCurrentUserSettings()
    begin
        ClearUserSettings(UserSecurityId())
    end;
}