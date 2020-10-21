// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Displays an account that was registered via the Microsoft 365 connector.
/// </summary>
page 4503 "Microsoft 365 Email Account"
{
    Caption = 'Microsoft 365 Email Account';
    SourceTable = "Email - Outlook Account";
    Permissions = tabledata "Email - Outlook Account" = rimd;
    PageType = Card;
    Extensible = false;
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            field(NameField; Rec.Name)
            {
                ApplicationArea = All;
                Caption = 'Account Name';
                ToolTip = 'The name of the account.';
                ShowMandatory = true;
                NotBlank = true;
            }
            field(EmailAddress; Rec."Email Address")
            {
                ApplicationArea = All;
                Caption = 'Email Address';
                ToolTip = 'Specifies the email address of the account.';
                ShowMandatory = true;
                NotBlank = true;
            }
        }
    }
}
