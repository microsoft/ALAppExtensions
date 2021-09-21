// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Page to view addresses
/// </summary>
page 8944 "Email Address"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = Address;
    Caption = 'Suggested Contacts';
    Extensible = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Editable = false;
    ShowFilter = false;
    LinksAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Email Address"; "E-Mail Address")
                {
                    ApplicationArea = All;
                    ToolTip = 'E-Mail Address.';
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Name.';
                }
                field(Company; Company)
                {
                    ApplicationArea = All;
                    ToolTip = 'Company.';
                }
                field(Source; "Source Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Source Name.';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(ManualLookup)
            {
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Caption = 'More Addresses';
                ToolTip = 'Lookup.';
                ApplicationArea = All;
                Image = ShowList;

                trigger OnAction()
                var
                    EmailAddress: Codeunit "Address Book Impl";
                begin
                    EmailAddress.EmailAddressLookup(Rec)
                end;
            }
        }
    }

    internal procedure GetSelectedAddresses(var EmailAddress: Record Address)
    begin
        CurrPage.SetSelectionFilter(Rec);

        if not Rec.FindSet() then
            exit;

        repeat
            EmailAddress.TransferFields(Rec);
            EmailAddress.Insert();
        until Rec.Next() = 0;
    end;

    procedure InsertAddresses(var EmailAddress: Record Address)
    begin
        if EmailAddress.FindSet() then
            repeat
                Rec.Copy(EmailAddress);
                Rec.Insert();
            until EmailAddress.Next() = 0;
    end;
}