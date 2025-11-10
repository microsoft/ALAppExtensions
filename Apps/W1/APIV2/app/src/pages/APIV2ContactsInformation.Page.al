namespace Microsoft.API.V2;

using Microsoft.CRM.Contact;

page 30072 "APIV2 - Contacts Information"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Contact Information';
    EntitySetCaption = 'Contacts Information';
    DelayedInsert = true;
    EntityName = 'contactInformation';
    EntitySetName = 'contactsInformation';
    ODataKeyFields = "Contact Id";
    PageType = API;
    SourceTable = "Contact Information Buffer";
    SourceTableTemporary = true;
    Extensible = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    AboutText = 'Exposes a read-only list of contact records, including contact identifiers, names, contact type (company or person), and their association to related entities such as customers, vendors, bank accounts, and employees. Supports GET operations for querying and filtering contact data, enabling external CRM, marketing, or service applications to reference and synchronize contact-to-entity relationships while maintaining Business Central as the authoritative source. Ideal for integrations that require up-to-date contact context without access to personal details like address, phone, or email information.';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(contactId; Rec."Contact Id")
                {
                    Caption = 'Contact Id';
                }
                field(contactNumber; Rec."Contact No.")
                {
                    Caption = 'Contact No.';
                }
                field(contactName; Rec."Contact Name")
                {
                    Caption = 'Contact Name';
                }
                field(contactType; Rec."Contact Type")
                {
                    Caption = 'Contact Type';
                }
                field(relatedId; Rec."Related Id")
                {
                    Caption = 'Related Id';
                }
                field(relatedType; Rec."Related Type")
                {
                    Caption = 'Related Type';
                    Editable = false;
                }
                part(contacts; "APIV2 - Contacts")
                {
                    Caption = 'Contacts';
                    Multiplicity = ZeroOrOne;
                    EntityName = 'contact';
                    EntitySetName = 'contacts';
                    SubPageLink = SystemId = field("Contact Id");
                }
            }
        }
    }

    trigger OnFindRecord(Which: Text): Boolean
    var
        RelatedIdFilter: Text;
        RelatedTypeFilter: Text;
        FilterView: Text;
    begin
        RelatedIdFilter := Rec.GetFilter("Related Id");
        RelatedTypeFilter := Rec.GetFilter("Related Type");
        if RelatedIdFilter = '' then begin
            Rec.FilterGroup(4);
            RelatedIdFilter := Rec.GetFilter("Related Id");
            RelatedTypeFilter := Rec.GetFilter("Related Type");
            Rec.FilterGroup(0);
            if (RelatedIdFilter = '') or (RelatedTypeFilter = '') then
                Error(FiltersNotSpecifiedErrorLbl);
        end;
        if RecordsLoaded then
            exit(true);
        FilterView := Rec.GetView();
        Rec.LoadDataFromFilters(RelatedIdFilter, RelatedTypeFilter);
        Rec.SetView(FilterView);
        if not Rec.FindFirst() then
            exit(false);
        RecordsLoaded := true;
        exit(true);
    end;

    var
        RecordsLoaded: Boolean;
        FiltersNotSpecifiedErrorLbl: Label 'id type not specified.';
}