page 30071 "APIV2 - Contacts"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Contact';
    EntitySetCaption = 'Contacts';
    ChangeTrackingAllowed = true;
    DelayedInsert = true;
    EntityName = 'contact';
    EntitySetName = 'contacts';
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = Contact;
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(number; "No.")
                {
                    Caption = 'No.';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("No."));
                    end;
                }
                field(type; Type)
                {
                    Caption = 'Type';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo(Type));
                    end;
                }
                field(displayName; Name)
                {
                    Caption = 'Display Name';
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        if Name = '' then
                            Error(BlankContactNameErr);
                        RegisterFieldSet(FieldNo(Name));
                    end;
                }
                field(companyNumber; "Company No.")
                {
                    Caption = 'Company Number';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Company No."));
                    end;
                }
                field(companyName; "Company Name")
                {
                    Caption = 'Company Name';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Company Name"));
                    end;
                }
#if not CLEAN19
                field(businessRelation; "Business Relation")
                {
                    Caption = 'Business Relation';
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Replaced by the Contact Business Relation field.';
                    ObsoleteTag = '19.0';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Business Relation"));
                    end;
                }
#endif
                field(contactBusinessRelation; "Contact Business Relation")
                {
                    Caption = 'Business Relation';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Contact Business Relation"));
                    end;
                }
                field(addressLine1; Address)
                {
                    Caption = 'Address Line 1';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Address"));
                    end;
                }
                field(addressLine2; "Address 2")
                {
                    Caption = 'Address Line 2';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Address 2"));
                    end;
                }
                field(city; City)
                {
                    Caption = 'City';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("City"));
                    end;
                }
                field(state; County)
                {
                    Caption = 'State';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("County"));
                    end;
                }
                field(country; "Country/Region Code")
                {
                    Caption = 'Country/Region Code';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Country/Region Code"));
                    end;
                }
                field(postalCode; "Post Code")
                {
                    Caption = 'Post Code';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Post Code"));
                    end;
                }
                field(phoneNumber; "Phone No.")
                {
                    Caption = 'Phone No.';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Phone No."));
                    end;
                }
                field(mobilePhoneNumber; "Mobile Phone No.")
                {
                    Caption = 'Mobile Phone No.';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Mobile Phone No."));
                    end;
                }
                field(email; "E-Mail")
                {
                    Caption = 'Email';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("E-Mail"));
                    end;
                }
                field(website; "Home Page")
                {
                    Caption = 'Website';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Home Page"));
                    end;
                }
                field(searchName; "Search Name")
                {
                    Caption = 'Search Name';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Search Name"));
                    end;
                }
                field(privacyBlocked; "Privacy Blocked")
                {
                    Caption = 'Privacy Blocked';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Privacy Blocked"));
                    end;
                }
                field(taxRegistrationNumber; TaxRegistrationNumber)
                {
                    Caption = 'Tax Registration No.';

                    trigger OnValidate()
                    var
                        EnterpriseNoFieldRef: FieldRef;
                    begin
                        if IsEnterpriseNumber(EnterpriseNoFieldRef) then begin
                            if (Rec."Country/Region Code" <> BECountryCodeLbl) and (Rec."Country/Region Code" <> '') then begin
                                Rec.Validate("VAT Registration No.", TaxRegistrationNumber);
                                RegisterFieldSet(FieldNo("VAT Registration No."));
                            end else begin
                                EnterpriseNoFieldRef.Validate(TaxRegistrationNumber);
                                EnterpriseNoFieldRef.Record().SetTable(Rec);
                                RegisterFieldSet(FieldNo("VAT Registration No."));
                            end;
                        end else begin
                            Rec.Validate("VAT Registration No.", TaxRegistrationNumber);
                            RegisterFieldSet(FieldNo("VAT Registration No."));
                        end;
                    end;
                }
                field(lastInteractionDate; "Date of Last Interaction")
                {
                    Caption = 'Date of Last Interaction';
                    Editable = false;
                }
                field(lastModifiedDateTime; SystemModifiedAt)
                {
                    Caption = 'Last Modified Date';
                }
                part(picture; "APIV2 - Pictures")
                {
                    Caption = 'Picture';
                    Multiplicity = ZeroOrOne;
                    EntityName = 'picture';
                    EntitySetName = 'pictures';
                    SubPageLink = Id = Field(SystemId), "Parent Type" = const(Contact);
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        SetCalculatedFields();
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        Contact: Record Contact;
        ContactRecordRef: RecordRef;
    begin
        if Name = '' then
            Error(NotProvidedContactNameErr);

        Contact.SetRange("No.", "No.");
        if not Contact.IsEmpty() then
            Insert();

        Insert(true);

        ContactRecordRef.GetTable(Rec);
        GraphMgtGeneralTools.ProcessNewRecordFromAPI(ContactRecordRef, TempFieldSet, CurrentDateTime());
        ContactRecordRef.SetTable(Rec);

        Modify(true);
        SetCalculatedFields();
        exit(false);
    end;

    trigger OnModifyRecord(): Boolean
    var
        Contact: Record Contact;
    begin
        Contact.GetBySystemId(SystemId);

        if "No." = Contact."No." then
            Modify(true)
        else begin
            Contact.TransferFields(Rec, false);
            Contact.Rename("No.");
            TransferFields(Contact);
        end;

        SetCalculatedFields();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        ClearCalculatedFields();
    end;

    var
        TempFieldSet: Record 2000000041 temporary;
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
        TaxRegistrationNumber: Text[50];
        NotProvidedContactNameErr: Label 'A "displayName" must be provided.', Comment = 'displayName is a field name and should not be translated.';
        BlankContactNameErr: Label 'The blank "displayName" is not allowed.', Comment = 'displayName is a field name and should not be translated.';
        BECountryCodeLbl: Label 'BE', Locked = true;

    local procedure SetCalculatedFields()
    var
        EnterpriseNoFieldRef: FieldRef;
    begin
        if IsEnterpriseNumber(EnterpriseNoFieldRef) then begin
            if (Rec."Country/Region Code" <> BECountryCodeLbl) and (Rec."Country/Region Code" <> '') then
                TaxRegistrationNumber := Rec."VAT Registration No."
            else
                TaxRegistrationNumber := EnterpriseNoFieldRef.Value();
        end else
            TaxRegistrationNumber := Rec."VAT Registration No.";
    end;

    local procedure ClearCalculatedFields()
    begin
        Clear(SystemId);
        Clear(TaxRegistrationNumber);
        TempFieldSet.DeleteAll();
    end;

    local procedure RegisterFieldSet(FieldNo: Integer)
    begin
        if TempFieldSet.Get(Database::Contact, FieldNo) then
            exit;

        TempFieldSet.Init();
        TempFieldSet.TableNo := Database::Contact;
        TempFieldSet.Validate("No.", FieldNo);
        TempFieldSet.Insert(true);
    end;

    procedure IsEnterpriseNumber(var EnterpriseNoFieldRef: FieldRef): Boolean
    var
        ContactRecordRef: RecordRef;
    begin
        ContactRecordRef.GetTable(Rec);
        if ContactRecordRef.FieldExist(11310) then begin
            EnterpriseNoFieldRef := ContactRecordRef.Field(11310);
            exit((EnterpriseNoFieldRef.Type = FieldType::Text) and (EnterpriseNoFieldRef.Name = 'Enterprise No.'));
        end else
            exit(false);
    end;
}

