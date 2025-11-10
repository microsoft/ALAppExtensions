// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.API.V2;

using Microsoft.CRM.Contact;
using Microsoft.Sales.Customer;
using Microsoft.CRM.BusinessRelation;

page 30089 "APIV2 - CustContacts"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Customer Contact';
    EntitySetCaption = 'Customer Contacts';
    ChangeTrackingAllowed = true;
    DelayedInsert = true;
    EntityName = 'customerContact';
    EntitySetName = 'customerContacts';
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = Contact;
    Extensible = false;
    InsertAllowed = false;
    AboutText = 'Exposes customer contact person records, including names, job titles, email addresses, phone numbers, and links to associated customer accounts. Supports retrieval, update, and deletion operations (GET, PATCH, DELETE) to maintain and synchronize contact information with external CRM, sales automation, and customer service platforms. Ideal for integrations requiring up-to-date customer contact details and streamlined communication management, but creation of new contact records is not supported via this API.';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(email; Rec."E-Mail")
                {
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("E-Mail"));
                    end;
                }
                field(firstName; Rec."First Name")
                {
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("First Name"));
                    end;
                }
                field(lastName; Rec.Surname)
                {
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo(SurName));
                    end;
                }
                field(professionalTitle; Rec."Job Title")
                {
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Job Title"));
                    end;
                }
                field(customerId; CustomerId)
                {
                }
                field(customerName; Customer.Name)
                {
                    Editable = false;
                }
                field(primaryPhoneNumber; Rec."Phone No.")
                {
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Phone No."));
                    end;
                }
                part(pdfDocument; "APIV2 - PDF Document")
                {
                    Caption = 'PDF Document';
                    Multiplicity = ZeroOrOne;
                    EntityName = 'pdfDocument';
                    EntitySetName = 'pdfDocument';
                    SubPageLink = "Document Id" = field(SystemId), "Document Type" = const("Customer Statement");
                }
            }
        }
    }

    actions
    {
    }
    var
        Customer: Record Customer;
        TempFieldSet: Record System.Reflection.Field temporary;
        CustomerId: Guid;

    trigger OnAfterGetRecord()
    begin
        SetCalculatedFields();
    end;

    trigger OnModifyRecord(): Boolean
    var
        ChangedCustomer: Record Customer;
        ContactBusinessRelation: Record "Contact Business Relation";
        CustomerWithProvidedIdDoesNotExistErr: Label 'Customer with provided id - does not exist';
    begin
        if CustomerId <> Customer.SystemId then begin
            if not ChangedCustomer.GetBySystemId(CustomerId) then
                Error(CustomerWithProvidedIdDoesNotExistErr);
            ContactBusinessRelation.SetRange("Contact No.", Rec."Company No.");
            ContactBusinessRelation.SetRange("Link to Table", ContactBusinessRelation."Link to Table"::Customer);
            ContactBusinessRelation.SetRange("No.", Customer."No.");
            if ContactBusinessRelation.FindFirst() then begin
                ContactBusinessRelation.Validate("No.", ChangedCustomer."No.");
                ContactBusinessRelation.Modify(true);
            end;
        end;
        SetCalculatedFields();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        ClearCalculatedFields();
    end;

    local procedure SetCalculatedFields()
    var
        ContactBusinessRelation: Record "Contact Business Relation";
    begin
        Clear(Customer);
        ContactBusinessRelation.SetRange("Contact No.", Rec."Company No.");
        ContactBusinessRelation.SetRange("Link to Table", ContactBusinessRelation."Link to Table"::Customer);
        if ContactBusinessRelation.FindFirst() then begin
            Customer.Get(ContactBusinessRelation."No.");
            CustomerId := Customer.SystemId;
        end;
    end;

    local procedure RegisterFieldSet(FieldNo: Integer)
    begin
        if TempFieldSet.Get(Database::Contact, FieldNo) then
            exit;

        Clear(TempFieldSet);
        TempFieldSet.TableNo := Database::Contact;
        TempFieldSet.Validate("No.", FieldNo);
        TempFieldSet.Insert(true);
    end;

    local procedure ClearCalculatedFields()
    begin
        Clear(Customer);
        Clear(CustomerId);
    end;

    trigger OnOpenPage()
    begin
        Rec.SetRange(Type, Rec.Type::Person);
        Rec.SetRange("Contact Business Relation", Rec."Contact Business Relation"::Customer);
    end;
}
