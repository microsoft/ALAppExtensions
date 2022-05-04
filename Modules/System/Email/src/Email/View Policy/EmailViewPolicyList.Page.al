// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Page to display and control what view policies users have been assigned.
/// </summary>
page 8930 "Email View Policy List"
{
    AdditionalSearchTerms = 'Email Personalization,Email Preferences,Policies';
    ApplicationArea = All;
    Caption = 'User Email Policies';
    Extensible = false;
    DelayedInsert = true;
    PageType = List;
    SourceTable = "Email View Policy";
    UsageCategory = Administration;
    Permissions = tabledata "Email View Policy" = rimd,
                  tabledata User = r;

    AboutText = 'Email view policies control the emails a user can get access to.';
    AboutTitle = 'About email view policies';
    ContextSensitiveHelpPage = 'admin-how-setup-email#set-up-view-policies';

    layout
    {
        area(Content)
        {
            repeater(UserPolicies)
            {
                ShowCaption = false;
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                    Caption = 'User ID';
                    ToolTip = 'Specifies a unique identifier for the user.';
                    LookupPageId = "User Lookup";
                    Editable = not IsDefault;

                    AboutTitle = 'Pick a user';
                    AboutText = 'You can define an email view policy for a specific user. However, make sure you have a default policy, which is a line with a policy that is not assigned to a user.';
                }
                field("Policy"; Rec."Email View Policy")
                {
                    ApplicationArea = All;
                    ToolTip = 'Assigned email policy';
                    Editable = true;

                    AboutTitle = 'Specify a policy';
                    AboutText = 'Here, you assign a policy to the specified user by choosing a view policy from the list. If you''ve not added a user, then this policy becomes the default view policy.';
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        EmailViewPolicy: Codeunit "Email View Policy";
    begin
        EmailViewPolicy.CheckForDefaultEntry();
    end;

    trigger OnDeleteRecord(): Boolean
    var
        EmailViewPolicy: Codeunit "Email View Policy";
    begin
        exit(EmailViewPolicy.CheckIfCanDeleteRecord(Rec));
    end;

    trigger OnAfterGetCurrRecord()
    var
        EmailViewPolicy: Codeunit "Email View Policy";
        NullGuid: Guid;
    begin
        IsDefault := (Rec."User Security ID" = NullGuid) and (Rec."User ID" = EmailViewPolicy.GetDefaultUserId());
    end;

    var
        [InDataSet]
        IsDefault: Boolean;
}