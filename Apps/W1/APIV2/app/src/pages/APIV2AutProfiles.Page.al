namespace Microsoft.API.V2;

using System.Reflection;

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
                field(profileId; Rec."Profile ID")
                {
                    Caption = 'Profile Id';
                }
                field(applicationId; Rec."App ID")
                {
                    Caption = 'Application Id';
                }
                field(scope; Rec.Scope)
                {
                    Caption = 'Scope';
                }
                field(source; Rec."App Name")
                {
                    Caption = 'Source';
                }
                field(displayName; Rec.Caption)
                {
                    Caption = 'Display Name';
                }
                field(enabled; Rec.Enabled)
                {
                    Caption = 'Enabled';
                }
            }
        }
    }
}