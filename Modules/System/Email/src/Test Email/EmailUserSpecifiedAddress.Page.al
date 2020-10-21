// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// A page to enter an email address.
/// </summary>
page 8884 "Email User-Specified Address"
{
    Caption = 'Enter Email Address';
    PageType = StandardDialog;

    layout
    {
        area(content)
        {
            group(EmailAddressGroup)
            {
                ShowCaption = false;
                field(EmailAddressField; EmailAddress)
                {
                    ApplicationArea = Basic, Suite, Invoicing;
                    Caption = 'Email Address';
                    ToolTip = 'Specifies the email address of the recipient.';
                    ShowMandatory = true;
                    NotBlank = true;
                    ExtendedDatatype = EMail;

                    trigger OnValidate()
                    var
                        EmailAccount: Codeunit "Email Account";
                    begin
                        EmailAccount.ValidateEmailAddress(EmailAddress);
                    end;
                }
            }
        }
    }

    var
        EmailAddress: Text;

    /// <summary>
    /// Gets the email address that has been entered.
    /// </summary>
    /// <returns>An email address</returns>
    procedure GetEmailAddress(): Text
    begin
        exit(EmailAddress);
    end;

    /// <summary>
    /// Sets the inital value to be displayed.
    /// </summary>
    /// <param name="Address">The value to be prefilled</param>
    procedure SetEmailAddress(Address: Text)
    begin
        EmailAddress := Address;
    end;
}

