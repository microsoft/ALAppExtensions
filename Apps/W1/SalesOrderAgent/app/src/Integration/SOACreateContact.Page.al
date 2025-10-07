// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.SalesOrderAgent;

using Microsoft.CRM.Contact;

page 4406 "SOA Create Contact"
{
    PageType = StandardDialog;
    ApplicationArea = All;
    Caption = 'Create new contact';
    InherentEntitlements = X;
    InherentPermissions = X;

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field(Name; ContactName)
                {
                    ApplicationArea = All;
                    Caption = 'Name';
                    ToolTip = 'Specifies the name of the contact';
                }
                field(Email; ContactEmail)
                {
                    ApplicationArea = All;
                    Caption = 'Email';
                    ToolTip = 'Specifies the email of the contact';
                }
                field(ContactType; ContactTypeEnum)
                {
                    ApplicationArea = All;
                    Caption = 'Contact Type';
                    ToolTip = 'Specifies the type of the contact';
                }
            }
        }
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction in [Action::OK, Action::Yes, Action::LookupOK] then begin
#pragma warning disable AA0139
            Clear(GlobalContact);
            GlobalContact.Name := ContactName;
            GlobalContact."E-Mail" := ContactEmail;
#pragma warning restore AA0139
            GlobalContact.Type := ContactTypeEnum;
            GlobalContact.Insert(true);
            Commit();
            Page.RunModal(Page::"Contact Card", GlobalContact);
        end;
        exit(true);
    end;

    procedure SetGlobalVariables(NewContactName: Text; NewContactEmail: Text)
    begin
        ContactTypeEnum := "Contact Type"::Person;
        ContactName := NewContactName;
        ContactEmail := NewContactEmail;
    end;

    procedure GetContact(var NewContact: Record Contact)
    begin
        NewContact.Copy(GlobalContact);
    end;

    var
        GlobalContact: Record Contact;
        ContactName: Text;
        ContactEmail: Text;
        ContactTypeEnum: Enum "Contact Type";
}