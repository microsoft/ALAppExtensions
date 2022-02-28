// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Page to display and control what policies user have been assigned.
/// </summary>
page 8930 "Email View Policy List"
{
    AboutText = 'Email view policies control the emails a user can get access to.';
    AboutTitle = 'About email view policies';
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
                    ToolTip = 'Specifies the user’s unique identifier.';
                    LookupPageId = "User Lookup";
                }
                field("Policy"; Rec."Email View Policy")
                {
                    ApplicationArea = All;
                    ToolTip = 'Assigned email policy';
                    Editable = true;
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


}