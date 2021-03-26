page 20017 "APIV1 - Employees"
{
    APIVersion = 'v1.0';
    Caption = 'employees', Locked = true;
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
                    Caption = 'id', Locked = true;
                    Editable = false;
                }
                field(number; "No.")
                {
                    Caption = 'number', Locked = true;
                }
                field(displayName; EmployeeDisplayName)
                {
                    Caption = 'displayName', Locked = true;
                    Editable = false;
                }
                field(givenName; "First Name")
                {
                    Caption = 'givenName', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FIELDNO("First Name"));
                    end;
                }
                field(middleName; "Middle Name")
                {
                    Caption = 'middleName', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FIELDNO("Middle Name"));
                    end;
                }
                field(surname; "Last Name")
                {
                    Caption = 'surname', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FIELDNO("Last Name"));
                    end;
                }
                field(jobTitle; "Job Title")
                {
                    Caption = 'jobTitle', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FIELDNO("Job Title"));
                    end;
                }
                field(address; PostalAddressJSON)
                {
                    Caption = 'address', Locked = true;
                    ODataEDMType = 'POSTALADDRESS';
                    ToolTip = 'Specifies the address for the employee.';
                }
                field(phoneNumber; "Phone No.")
                {
                    Caption = 'phoneNumber', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FIELDNO("Phone No."));
                    end;
                }
                field(mobilePhone; "Mobile Phone No.")
                {
                    Caption = 'mobilePhone', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FIELDNO("Mobile Phone No."));
                    end;
                }
                field(email; "Company E-Mail")
                {
                    Caption = 'email', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FIELDNO("Company E-Mail"));
                    end;
                }
                field(personalEmail; "E-Mail")
                {
                    Caption = 'personalEmail', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FIELDNO("E-Mail"));
                    end;
                }
                field(employmentDate; "Employment Date")
                {
                    Caption = 'employmentDate', Locked = true;
                }
                field(terminationDate; "Termination Date")
                {
                    Caption = 'terminationDate', Locked = true;
                }
                field(status; Status)
                {
                    Caption = 'status', Locked = true;
                }
                field(birthDate; "Birth Date")
                {
                    Caption = 'birthDate', Locked = true;
                }
                field(statisticsGroupCode; "Statistics Group Code")
                {
                    Caption = 'statisticsGroupCode', Locked = true;
                }
                field(lastModifiedDateTime; "Last Modified Date Time")
                {
                    Caption = 'lastModifiedDateTime', Locked = true;
                }
                part(picture; "APIV1 - Pictures")
                {
                    Caption = 'picture';
                    EntityName = 'picture';
                    EntitySetName = 'picture';
                    SubPageLink = Id = FIELD(SystemId);
                }
                part(defaultDimensions; "APIV1 - Default Dimensions")
                {
                    Caption = 'Default Dimensions', Locked = true;
                    EntityName = 'defaultDimensions';
                    EntitySetName = 'defaultDimensions';
                    SubPageLink = ParentId = FIELD(SystemId);
                }
                part(timeRegistrationEntries; "APIV1 - Time Registr. Entries")
                {
                    Caption = 'timeRegistrationEntries', Locked = true;
                    EntityName = 'timeRegistrationEntry';
                    EntitySetName = 'timeRegistrationEntries';
                    SubPageLink = "Employee Id" = FIELD(SystemId);
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
        GraphMgtEmployee: Codeunit "Graph Mgt - Employee";
        RecRef: RecordRef;
    begin
        INSERT(TRUE);

        GraphMgtEmployee.ProcessComplexTypes(Rec, PostalAddressJSON);

        RecRef.GETTABLE(Rec);
        GraphMgtGeneralTools.ProcessNewRecordFromAPI(RecRef, TempFieldSet, CURRENTDATETIME());
        RecRef.SETTABLE(Rec);

        MODIFY(TRUE);
        SetCalculatedFields();
        EXIT(FALSE);
    end;

    trigger OnModifyRecord(): Boolean
    var
        Employee: Record "Employee";
        GraphMgtEmployee: Codeunit "Graph Mgt - Employee";
    begin
        Employee.GetBySystemId(SystemId);

        GraphMgtEmployee.ProcessComplexTypes(Rec, PostalAddressJSON);

        IF "No." = Employee."No." THEN
            MODIFY(TRUE)
        ELSE BEGIN
            Employee.TRANSFERFIELDS(Rec, FALSE);
            Employee.RENAME("No.");
            TRANSFERFIELDS(Employee);
        END;

        SetCalculatedFields();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        ClearCalculatedFields();
    end;

    var
        TempFieldSet: Record 2000000041 temporary;
        PostalAddressJSON: Text;
        EmployeeDisplayName: Text;
        EmployeeDisplayNameFormatTxt: Label '%1 %2', Locked = true;


    local procedure SetCalculatedFields()
    var
        GraphMgtEmployee: Codeunit "Graph Mgt - Employee";
    begin
        PostalAddressJSON := GraphMgtEmployee.PostalAddressToJSON(Rec);
        EmployeeDisplayName := STRSUBSTNO(EmployeeDisplayNameFormatTxt, "First Name", "Last Name");
    end;

    local procedure ClearCalculatedFields()
    begin
        CLEAR(SystemId);
        CLEAR(PostalAddressJSON);
        TempFieldSet.DELETEALL();
    end;

    local procedure RegisterFieldSet(FieldNo: Integer)
    begin
        IF TempFieldSet.GET(DATABASE::Employee, FieldNo) THEN
            EXIT;

        TempFieldSet.INIT();
        TempFieldSet.TableNo := DATABASE::Employee;
        TempFieldSet.VALIDATE("No.", FieldNo);
        TempFieldSet.INSERT(TRUE);
    end;
}
