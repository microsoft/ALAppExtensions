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
                field(id; SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(number; "No.")
                {
                    Caption = 'No.';
                }
                field(displayName; EmployeeDisplayName)
                {
                    Caption = 'Display Name';
                    Editable = false;
                }
                field(givenName; "First Name")
                {
                    Caption = 'Given Name';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("First Name"));
                    end;
                }
                field(middleName; "Middle Name")
                {
                    Caption = 'Middle Name';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Middle Name"));
                    end;
                }
                field(surname; "Last Name")
                {
                    Caption = 'Surname';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Last Name"));
                    end;
                }
                field(jobTitle; "Job Title")
                {
                    Caption = 'Job Title';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Job Title"));
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
                field(mobilePhone; "Mobile Phone No.")
                {
                    Caption = 'Mobile Phone No.';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Mobile Phone No."));
                    end;
                }
                field(email; "Company E-Mail")
                {
                    Caption = 'Email';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Company E-Mail"));
                    end;
                }
                field(personalEmail; "E-Mail")
                {
                    Caption = 'Personal Email';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("E-Mail"));
                    end;
                }
                field(employmentDate; "Employment Date")
                {
                    Caption = 'Employment Date';
                }
                field(terminationDate; "Termination Date")
                {
                    Caption = 'Termination Date';
                }
                field(status; Status)
                {
                    Caption = 'Status';
                }
                field(birthDate; "Birth Date")
                {
                    Caption = 'Birth Date';
                }
                field(statisticsGroupCode; "Statistics Group Code")
                {
                    Caption = 'Statistics Group Code';
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
                    SubPageLink = Id = Field(SystemId), "Parent Type" = const(Employee);
                }
                part(defaultDimensions; "APIV2 - Default Dimensions")
                {
                    Caption = 'Default Dimensions';
                    EntityName = 'defaultDimension';
                    EntitySetName = 'defaultDimensions';
                    SubPageLink = ParentId = Field(SystemId), "Parent Type" = const(Employee);
                }
                part(timeRegistrationEntries; "APIV2 - Time Registr. Entries")
                {
                    Caption = 'Time Registration Entries';
                    EntityName = 'timeRegistrationEntry';
                    EntitySetName = 'timeRegistrationEntries';
                    SubPageLink = "Employee Id" = Field(SystemId);
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
        Insert(true);

        EmployeeRecordRef.GetTable(Rec);
        GraphMgtGeneralTools.ProcessNewRecordFromAPI(EmployeeRecordRef, TempFieldSet, CurrentDateTime());
        EmployeeRecordRef.SetTable(Rec);

        Modify(true);
        SetCalculatedFields();
        exit(false);
    end;

    trigger OnModifyRecord(): Boolean
    var
        Employee: Record "Employee";
    begin
        Employee.GetBySystemId(SystemId);

        if "No." = Employee."No." then
            Modify(true)
        else begin
            Employee.TransferFields(Rec, false);
            Employee.Rename("No.");
            TransferFields(Employee);
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
        EmployeeDisplayName := StrSubstNo(EmployeeDisplayNameFormatTxt, "First Name", "Last Name");
    end;

    local procedure ClearCalculatedFields()
    begin
        Clear(SystemId);
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
