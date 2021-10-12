page 30074 "APIV2 - Aut. Profiles"
{
    APIGroup = 'automation';
    APIPublisher = 'microsoft';
    APIVersion = 'v2.0';
    EntityCaption = 'Profile';
    EntitySetCaption = 'Profiles';
    DelayedInsert = true;
    EntityName = 'profile';
    EntitySetName = 'profiles';
    PageType = API;
    SourceTable = "All Profile";
    Extensible = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(profileId; "Profile ID")
                {
                    Caption = 'Profile Id';
                }
                field(applicationId; "App ID")
                {
                    Caption = 'Application Id';
                }
                field(scope; Scope)
                {
                    Caption = 'Scope';
                }
                field(source; "App Name")
                {
                    Caption = 'Source';
                }
                field(displayName; Caption)
                {
                    Caption = 'Display Name';
                }
                field(enabled; Enabled)
                {
                    Caption = 'Enabled';
                }
            }
        }
    }
}