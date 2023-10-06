namespace Microsoft.API.V1;

using Microsoft.HumanResources.Employee;
using Microsoft.Integration.Graph;

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
                field(id; Rec.SystemId)
                {
                    Caption = 'id', Locked = true;
                    Editable = false;
                }
                field(number; Rec."No.")
                {
                    Caption = 'number', Locked = true;
                }
                field(displayName; EmployeeDisplayName)
                {
                    Caption = 'displayName', Locked = true;
                    Editable = false;
                }
                field(givenName; Rec."First Name")
                {
                    Caption = 'givenName', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("First Name"));
                    end;
                }
                field(middleName; Rec."Middle Name")
                {
                    Caption = 'middleName', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Middle Name"));
                    end;
                }
                field(surname; Rec."Last Name")
                {
                    Caption = 'surname', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Last Name"));
                    end;
                }
                field(jobTitle; Rec."Job Title")
                {
                    Caption = 'jobTitle', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Job Title"));
                    end;
                }
                field(address; PostalAddressJSON)
                {
                    Caption = 'address', Locked = true;
#pragma warning disable AL0667
                    ODataEDMType = 'POSTALADDRESS';
#pragma warning restore
                    ToolTip = 'Specifies the address for the employee.';
                }
                field(phoneNumber; Rec."Phone No.")
                {
                    Caption = 'phoneNumber', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Phone No."));
                    end;
                }
                field(mobilePhone; Rec."Mobile Phone No.")
                {
                    Caption = 'mobilePhone', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Mobile Phone No."));
                    end;
                }
                field(email; Rec."Company E-Mail")
                {
                    Caption = 'email', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Company E-Mail"));
                    end;
                }
                field(personalEmail; Rec."E-Mail")
                {
                    Caption = 'personalEmail', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("E-Mail"));
                    end;
                }
                field(employmentDate; Rec."Employment Date")
                {
                    Caption = 'employmentDate', Locked = true;
                }
                field(terminationDate; Rec."Termination Date")
                {
                    Caption = 'terminationDate', Locked = true;
                }
                field(status; Rec.Status)
                {
                    Caption = 'status', Locked = true;
                }
                field(birthDate; Rec."Birth Date")
                {
                    Caption = 'birthDate', Locked = true;
                }
                field(statisticsGroupCode; Rec."Statistics Group Code")
                {
                    Caption = 'statisticsGroupCode', Locked = true;
                }
                field(lastModifiedDateTime; Rec."Last Modified Date Time")
                {
                    Caption = 'lastModifiedDateTime', Locked = true;
                }
                part(picture; "APIV1 - Pictures")
                {
                    Caption = 'picture';
                    EntityName = 'picture';
                    EntitySetName = 'picture';
                    SubPageLink = Id = field(SystemId);
                }
                part(defaultDimensions; "APIV1 - Default Dimensions")
                {
                    Caption = 'Default Dimensions', Locked = true;
                    EntityName = 'defaultDimensions';
                    EntitySetName = 'defaultDimensions';
                    SubPageLink = ParentId = field(SystemId);
                }
                part(timeRegistrationEntries; "APIV1 - Time Registr. Entries")
                {
                    Caption = 'timeRegistrationEntries', Locked = true;
                    EntityName = 'timeRegistrationEntry';
                    EntitySetName = 'timeRegistrationEntries';
                    SubPageLink = "Employee Id" = field(SystemId);
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
        RecordRef: RecordRef;
    begin
        Rec.insert(true);

        GraphMgtEmployee.ProcessComplexTypes(Rec, PostalAddressJSON);

        RecordRef.GetTable(Rec);
        GraphMgtGeneralTools.ProcessNewRecordFromAPI(RecordRef, TempFieldSet, CURRENTDATETIME());
        RecordRef.SetTable(Rec);

        Rec.Modify(true);
        SetCalculatedFields();
        exit(false);
    end;

    trigger OnModifyRecord(): Boolean
    var
        Employee: Record "Employee";
        GraphMgtEmployee: Codeunit "Graph Mgt - Employee";
    begin
        Employee.GetBySystemId(Rec.SystemId);

        GraphMgtEmployee.ProcessComplexTypes(Rec, PostalAddressJSON);

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
        PostalAddressJSON: Text;
        EmployeeDisplayName: Text;
        EmployeeDisplayNameFormatTxt: Label '%1 %2', Locked = true;


    local procedure SetCalculatedFields()
    var
        GraphMgtEmployee: Codeunit "Graph Mgt - Employee";
    begin
        PostalAddressJSON := GraphMgtEmployee.PostalAddressToJSON(Rec);
        EmployeeDisplayName := STRSUBSTNO(EmployeeDisplayNameFormatTxt, Rec."First Name", Rec."Last Name");
    end;

    local procedure ClearCalculatedFields()
    begin
        CLEAR(Rec.SystemId);
        CLEAR(PostalAddressJSON);
        TempFieldSet.DELETEALL();
    end;

    local procedure RegisterFieldSet(FieldNo: Integer)
    begin
        if TempFieldSet.GET(DATABASE::Employee, FieldNo) then
            exit;

        TempFieldSet.INIT();
        TempFieldSet.TableNo := DATABASE::Employee;
        TempFieldSet.Validate("No.", FieldNo);
        TempFieldSet.insert(true);
    end;
}

