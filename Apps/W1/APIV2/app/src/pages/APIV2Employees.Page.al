namespace Microsoft.API.V2;

using Microsoft.HumanResources.Employee;
using Microsoft.Integration.Graph;

page 30017 "APIV2 - Employees"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Employee';
    EntitySetCaption = 'Employees';
    DelayedInsert = true;
    EntityName = 'employee';
    EntitySetName = 'employees';
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = Employee;
    Extensible = false;

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
                field(number; Rec."No.")
                {
                    Caption = 'No.';
                }
                field(displayName; EmployeeDisplayName)
                {
                    Caption = 'Display Name';
                    Editable = false;
                }
                field(givenName; Rec."First Name")
                {
                    Caption = 'Given Name';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("First Name"));
                    end;
                }
                field(middleName; Rec."Middle Name")
                {
                    Caption = 'Middle Name';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Middle Name"));
                    end;
                }
                field(surname; Rec."Last Name")
                {
                    Caption = 'Surname';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Last Name"));
                    end;
                }
                field(jobTitle; Rec."Job Title")
                {
                    Caption = 'Job Title';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Job Title"));
                    end;
                }
                field(addressLine1; Rec.Address)
                {
                    Caption = 'Address Line 1';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Address"));
                    end;
                }
                field(addressLine2; Rec."Address 2")
                {
                    Caption = 'Address Line 2';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Address 2"));
                    end;
                }
                field(city; Rec.City)
                {
                    Caption = 'City';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("City"));
                    end;
                }
                field(state; Rec.County)
                {
                    Caption = 'State';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("County"));
                    end;
                }
                field(country; Rec."Country/Region Code")
                {
                    Caption = 'Country/Region Code';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Country/Region Code"));
                    end;
                }
                field(postalCode; Rec."Post Code")
                {
                    Caption = 'Post Code';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Post Code"));
                    end;
                }
                field(phoneNumber; Rec."Phone No.")
                {
                    Caption = 'Phone No.';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Phone No."));
                    end;
                }
                field(mobilePhone; Rec."Mobile Phone No.")
                {
                    Caption = 'Mobile Phone No.';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Mobile Phone No."));
                    end;
                }
                field(email; Rec."Company E-Mail")
                {
                    Caption = 'Email';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Company E-Mail"));
                    end;
                }
                field(personalEmail; Rec."E-Mail")
                {
                    Caption = 'Personal Email';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("E-Mail"));
                    end;
                }
                field(employmentDate; Rec."Employment Date")
                {
                    Caption = 'Employment Date';
                }
                field(terminationDate; Rec."Termination Date")
                {
                    Caption = 'Termination Date';
                }
                field(status; Rec.Status)
                {
                    Caption = 'Status';
                }
                field(birthDate; Rec."Birth Date")
                {
                    Caption = 'Birth Date';
                }
                field(statisticsGroupCode; Rec."Statistics Group Code")
                {
                    Caption = 'Statistics Group Code';
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date';
                }
                part(picture; "APIV2 - Pictures")
                {
                    Caption = 'Picture';
                    Multiplicity = ZeroOrOne;
                    EntityName = 'picture';
                    EntitySetName = 'pictures';
                    SubPageLink = Id = field(SystemId), "Parent Type" = const(Employee);
                }
                part(defaultDimensions; "APIV2 - Default Dimensions")
                {
                    Caption = 'Default Dimensions';
                    EntityName = 'defaultDimension';
                    EntitySetName = 'defaultDimensions';
                    SubPageLink = ParentId = field(SystemId), "Parent Type" = const(Employee);
                }
                part(timeRegistrationEntries; "APIV2 - Time Registr. Entries")
                {
                    Caption = 'Time Registration Entries';
                    EntityName = 'timeRegistrationEntry';
                    EntitySetName = 'timeRegistrationEntries';
                    SubPageLink = "Employee Id" = field(SystemId);
                }
                part(documentAttachments; "APIV2 - Document Attachments")
                {
                    Caption = 'Document Attachments';
                    EntityName = 'documentAttachment';
                    EntitySetName = 'documentAttachments';
                    SubPageLink = "Document Id" = field(SystemId), "Document Type" = const(Employee);
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
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
        EmployeeRecordRef: RecordRef;
    begin
        Rec.Insert(true);

        EmployeeRecordRef.GetTable(Rec);
        GraphMgtGeneralTools.ProcessNewRecordFromAPI(EmployeeRecordRef, TempFieldSet, CurrentDateTime());
        EmployeeRecordRef.SetTable(Rec);

        Rec.Modify(true);
        SetCalculatedFields();
        exit(false);
    end;

    trigger OnModifyRecord(): Boolean
    var
        Employee: Record "Employee";
    begin
        Employee.GetBySystemId(Rec.SystemId);

        if Rec."No." = Employee."No." then
            Rec.Modify(true)
        else begin
            Employee.TransferFields(Rec, false);
            Employee.Rename(Rec."No.");
            Rec.TransferFields(Employee);
        end;

        SetCalculatedFields();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        ClearCalculatedFields();
    end;

    var
        TempFieldSet: Record 2000000041 temporary;
        EmployeeDisplayName: Text;
        EmployeeDisplayNameFormatTxt: Label '%1 %2', Locked = true;


    local procedure SetCalculatedFields()
    begin
        EmployeeDisplayName := StrSubstNo(EmployeeDisplayNameFormatTxt, Rec."First Name", Rec."Last Name");
    end;

    local procedure ClearCalculatedFields()
    begin
        Clear(Rec.SystemId);
        TempFieldSet.DeleteAll();
    end;

    local procedure RegisterFieldSet(FieldNo: Integer)
    begin
        if TempFieldSet.Get(Database::Employee, FieldNo) then
            exit;

        TempFieldSet.Init();
        TempFieldSet.TableNo := Database::Employee;
        TempFieldSet.Validate("No.", FieldNo);
        TempFieldSet.Insert(true);
    end;
}
