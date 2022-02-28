page 30041 "APIV2 - Time Registr. Entries"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Time Registration Entry';
    EntitySetCaption = 'Time Registration Entries';
    DelayedInsert = true;
    EntityName = 'timeRegistrationEntry';
    EntitySetName = 'timeRegistrationEntries';
    ODataKeyFields = Id;
    PageType = API;
    SourceTable = "Employee Time Reg Buffer";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(employeeId; "Employee Id")
                {
                    Caption = 'Employee Id';

                    trigger OnValidate()

                    begin
                        if "Employee Id" = BlankGUID then begin
                            "Employee No" := '';
                            exit;
                        end;

                        if HasFilter() then
                            if "Employee Id" <> GetFilter("Employee Id") then
                                Error(CannotChangeEmployeeIdErr);

                        if not Employee.GetBySystemId("Employee Id") then
                            Error(EmployeeIdDoesNotMatchAnEmployeeErr);

                        "Employee No" := Employee."No.";
                    end;
                }
                field(employeeNumber; "Employee No")
                {
                    Caption = 'Employee No.';
                    trigger OnValidate()
                    begin
                        if Employee."No." <> '' then begin
                            if Employee."No." <> "Employee No" then
                                Error(EmployeeValuesDontMatchErr);
                            exit;
                        end;

                        if "Employee No" = '' then begin
                            "Employee Id" := BlankGUID;
                            exit;
                        end;

                        if not Employee.Get("Employee No") then
                            Error(EmployeeNumberDoesNotMatchAnEmployeeErr);

                        if HasFilter() then
                            if Employee.SystemId <> GetFilter("Employee Id") then
                                Error(CannotChangeEmployeeNumberErr);

                        Validate("Employee Id", Employee.SystemId);
                    end;

                }
                field(jobId; "job id")
                {
                    Caption = 'Job Id';
                    trigger OnValidate()
                    begin
                        if "Job Id" = BlankGUID then begin
                            "Job No." := '';
                            exit;
                        end;

                        if not Job.GetBySystemId("Job Id") then
                            Error(JobIdDoesNotMatchAJobErr);

                        "Job No." := Job."No.";
                    end;
                }
                field(jobNumber; "Job No.")
                {
                    Caption = 'Job No.';
                    trigger OnValidate()
                    begin
                        if Job."No." <> '' then begin
                            if Job."No." <> "Job No." then
                                Error(JobValuesDontMatchErr);
                            exit;
                        end;

                        if "Job No." = '' then begin
                            "Job Id" := BlankGUID;
                            exit;
                        end;

                        if not Job.Get("Job No.") then
                            Error(JobNumberDoesNotMatchAJobErr);

                        Validate("Job Id", Job.SystemId);
                    end;
                }
                field(jobTaskNumber; "Job Task No.")
                {
                    Caption = 'Job Task No.';
                }
                field(absence; "Cause of Absence Code")
                {
                    Caption = 'Absence';
                    Editable = false;
                }
                field(lineNumber; "Line No")
                {
                    Caption = 'Line No.';
                    Editable = false;
                }
                field(date; Date)
                {
                    Caption = 'Date';
                }
                field(quantity; Quantity)
                {
                    Caption = 'Quantity';
                }
                field(status; Status)
                {
                    Caption = 'Status';
                    Editable = false;
                }
                field(unitOfMeasureId; "Unit of Measure Id")
                {
                    Caption = 'Unit Of Measure Id';
                    Editable = false;
                }
                field(unitOfMeasureCode; "Unit of Measure Code")
                {
                    Caption = 'Unit Of Measure Code';
                    Editable = false;
                }
                field(id; Id)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(lastModfiedDateTime; SystemModifiedAt)
                {
                    Caption = 'Last Modfied Date Time';
                }
                part(dimensionSetLines; "APIV2 - Dimension Set Lines")
                {
                    Caption = 'Dimension Set Lines';
                    EntityName = 'dimensionSetLine';
                    EntitySetName = 'dimensionSetLines';
                    SubPageLink = "Parent Id" = Field(Id), "Parent Type" = const("Time Registration Entry");
                }
            }
        }
    }

    actions
    {
    }

    trigger OnDeleteRecord(): Boolean
    begin
        PropagateDelete();
    end;

    trigger OnFindRecord(Which: Text): Boolean
    begin
        if not LinesLoaded then begin
            LoadRecords(GetFilter(Id), GetFilter(Date), GetFilter("Employee Id"));
            if not FindFirst() then
                exit(false);
            LinesLoaded := true;
        end;

        exit(true);
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        if "Employee Id" = BlankGUID then begin
            if not HasFilter() then
                Error(EmployeeIdOrNumberShouldBeSpecifiedErr);
            Validate("Employee Id", GetFilter("Employee Id"));
            Employee.GetBySystemId("Employee Id");
            "Employee No" := Employee."No.";
        end;

        PropagateInsert();
    end;

    trigger OnModifyRecord(): Boolean
    begin
        if "Employee Id" <> xRec."Employee Id" then
            Error(CannotModifyEmployeeIdErr);

        if Date <> xRec.Date then
            Error(CannotModifyDateErr);

        PropagateModify();
    end;

    var
        Employee: Record Employee;
        Job: Record Job;
        LinesLoaded: Boolean;
        BlankGUID: Guid;
        EmployeeIdDoesNotMatchAnEmployeeErr: Label 'The "employeeId" does not match to an Employee.', Comment = 'employeeId is a field name and should not be translated.';
        EmployeeValuesDontMatchErr: Label 'The employee values do not match to a specific Employee.';
        EmployeeNumberDoesNotMatchAnEmployeeErr: Label 'The "employeeNumber" does not match to an Employee.', Comment = 'employeeNumber is a field name and should not be translated.';
        JobIdDoesNotMatchAJobErr: Label 'The "jobId" does not match to a Job.', Comment = 'jobId is a field name and should not be translated.';
        JobValuesDontMatchErr: Label 'The employee values do not match to a specific Employee.';
        JobNumberDoesNotMatchAJobErr: label 'The "jobNumber" does not match to a Job.', Comment = 'jobNumber is a field name and should not be translated.';
        CannotModifyEmployeeIdErr: Label 'The "employeeId" cannot be modified.', Comment = 'employeeId is a field name and should not be translated.';
        CannotModifyDateErr: Label 'The date cannot be modified.';
        CannotChangeEmployeeIdErr: Label 'The value for "employeeId" cannot be modified.', Comment = 'employeeId is a field name and should not be translated.';
        CannotChangeEmployeeNumberErr: Label 'The value for employee number cannot be modified.';
        EmployeeIdOrNumberShouldBeSpecifiedErr: Label 'You must specify an Employee ID or Employee number to get the time registration entries.';
}
