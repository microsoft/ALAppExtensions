// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary></summary>
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
                    ExtendedDatatype = EMail;
                    ToolTip = 'Specifies the email address of the recipient.';
                }
            }
        }
    }

    var
        EmailAddress: Text;

    procedure GetEmailAddress(): Text
    begin
        exit(EmailAddress);
    end;

    procedure SetEmailAddress(Address: Text)
    begin
        EmailAddress := Address;
    end;
}

