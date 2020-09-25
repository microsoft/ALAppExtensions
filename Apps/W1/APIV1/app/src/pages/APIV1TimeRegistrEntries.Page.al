page 20041 "APIV1 - Time Registr. Entries"
{
    APIVersion = 'v1.0';
    Caption = 'timeRegistrationEntries', Locked = true;
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
                    Caption = 'employeeId', Locked = true;

                    trigger OnValidate()

                    begin
                        IF "Employee Id" = BlankGUID THEN BEGIN
                            "Employee No" := '';
                            EXIT;
                        END;

                        if HasFilter() then
                            if "Employee Id" <> GetFilter("Employee Id") then
                                Error(CannotChangeEmployeeIdErr);

                        IF NOT Employee.GetBySystemId("Employee Id") THEN
                            ERROR(EmployeeIdDoesNotMatchAnEmployeeErr);

                        "Employee No" := Employee."No.";
                    end;
                }
                field(employeeNumber; "Employee No")
                {
                    Caption = 'employeeNumber', Locked = true;
                    trigger OnValidate()
                    begin
                        IF Employee."No." <> '' THEN BEGIN
                            IF Employee."No." <> "Employee No" THEN
                                ERROR(EmployeeValuesDontMatchErr);
                            EXIT;
                        END;

                        IF "Employee No" = '' THEN BEGIN
                            "Employee Id" := BlankGUID;
                            EXIT;
                        END;

                        IF NOT Employee.GET("Employee No") THEN
                            ERROR(EmployeeNumberDoesNotMatchAnEmployeeErr);

                        if HasFilter() then
                            if Employee.SystemId <> GetFilter("Employee Id") then
                                Error(CannotChangeEmployeeNumberErr);

                        VALIDATE("Employee Id", Employee.SystemId);
                    end;

                }
                field(jobId; "job id")
                {
                    Caption = 'jobId', Locked = true;
                    trigger OnValidate()
                    begin
                        IF "Job Id" = BlankGUID THEN BEGIN
                            "Job No." := '';
                            EXIT;
                        END;

                        IF NOT Job.GetBySystemId("Job Id") THEN
                            ERROR(JobIdDoesNotMatchAJobErr);

                        "Job No." := Job."No.";
                    end;
                }
                field(jobNumber; "Job No.")
                {
                    Caption = 'jobNumber', Locked = true;
                    trigger OnValidate()
                    begin
                        IF Job."No." <> '' THEN BEGIN
                            IF Job."No." <> "Job No." THEN
                                ERROR(JobValuesDontMatchErr);
                            EXIT;
                        END;

                        IF "Job No." = '' THEN BEGIN
                            "Job Id" := BlankGUID;
                            EXIT;
                        END;

                        IF NOT Job.GET("Job No.") THEN
                            ERROR(JobNumberDoesNotMatchAJobErr);

                        VALIDATE("Job Id", Job.SystemId);
                    end;

                }
                field(absence; "Cause of Absence Code")
                {
                    Caption = 'absence', Locked = true;
                    Editable = false;
                }
                field(lineNumber; "Line No")
                {
                    Caption = 'lineNumber', Locked = true;
                    Editable = false;
                }
                field(date; Date)
                {
                    Caption = 'date', Locked = true;
                }
                field(quantity; Quantity)
                {
                    Caption = 'quantity', Locked = true;
                }
                field(status; Status)
                {
                    Caption = 'status', Locked = true;
                    Editable = false;
                }
                field(unitOfMeasureId; "Unit of Measure Id")
                {
                    Caption = 'unitOfMeasureId', Locked = true;
                    Editable = false;
                    ToolTip = 'Specifies Unit of Measure.';
                }
                field(unitOfMeasure; UnitOfMeasureJSON)
                {
                    Caption = 'unitOfMeasure', Locked = true;
                    Editable = false;
                    ODataEDMType = 'ITEM-UOM';
                    ToolTip = 'Specifies Unit of Measure.';
                }
                field(dimensions; DimensionsJSON)
                {
                    Caption = 'dimensions', Locked = true;
                    ODataEDMType = 'Collection(DIMENSION)';
                    ToolTip = 'Specifies Time registration Dimensions.';

                    trigger OnValidate()
                    begin
                        DimensionsSet := PreviousDimensionsJSON <> DimensionsJSON;
                    end;
                }
                field(id; Id)
                {
                    Caption = 'id', Locked = true;
                }
                field(lastModfiedDateTime; "Last Modified Date Time")
                {
                    Caption = 'lastModfiedDateTime', Locked = true;
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

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        ClearCalculatedFields();
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        PropagateDelete();
    end;

    trigger OnFindRecord(Which: Text): Boolean
    begin
        IF NOT LinesLoaded THEN BEGIN
            LoadRecords(GETFILTER(Id), GETFILTER(Date), GETFILTER("Employee Id"));
            IF NOT FINDFIRST() THEN
                EXIT(FALSE);
            LinesLoaded := TRUE;
        END;

        EXIT(TRUE);
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

        UpdateDimensions(false);
        PropagateInsert();
        SetCalculatedFields();
    end;

    trigger OnModifyRecord(): Boolean
    begin
        IF "Employee Id" <> xRec."Employee Id" THEN
            ERROR(CannotModifyEmployeeIdErr);

        IF Date <> xRec.Date THEN
            ERROR(CannotModifyDateErr);

        UpdateDimensions(true);
        PropagateModify();
        SetCalculatedFields();
    end;

    var
        Employee: Record Employee;
        Job: Record Job;
        LinesLoaded: Boolean;
        UnitOfMeasureJSON: Text;
        DimensionsJSON: Text;
        PreviousDimensionsJSON: Text;
        DimensionsSet: Boolean;
        BlankGUID: Guid;
        EmployeeIdDoesNotMatchAnEmployeeErr: Label 'The "employeeId" does not match to an Employee.', Locked = true;
        EmployeeValuesDontMatchErr: Label 'The employee values do not match to a specific Employee.', Locked = true;
        EmployeeNumberDoesNotMatchAnEmployeeErr: Label 'The "employeeNumber" does not match to an Employee.', Locked = true;
        JobIdDoesNotMatchAJobErr: Label 'The "jobId" does not match to a Job.', Locked = true;
        JobValuesDontMatchErr: Label 'The employee values do not match to a specific Employee.', Locked = true;
        JobNumberDoesNotMatchAJobErr: label 'The "jobNumber" does not match to a Job.', Locked = true;
        CannotModifyEmployeeIdErr: Label 'The employee ID cannot be modified.', Locked = true;
        CannotModifyDateErr: Label 'The date cannot be modified.', Locked = true;
        CannotChangeEmployeeIdErr: Label 'Value for employee ID cannot be modified.', Locked = true;
        CannotChangeEmployeeNumberErr: Label 'Value for employee number cannot be modified.', Locked = true;
        EmployeeIdOrNumberShouldBeSpecifiedErr: Label 'You must specify a Employee ID or Employee number to get the time registration entries.', Locked = true;

    local procedure SetCalculatedFields()
    var
        GraphMgtComplexTypes: Codeunit "Graph Mgt - Complex Types";
    begin
        DimensionsJSON := GraphMgtComplexTypes.GetDimensionsJSON("Dimension Set ID");
        UnitOfMeasureJSON := GraphMgtComplexTypes.GetUnitOfMeasureJSON("Unit of Measure Code");
        PreviousDimensionsJSON := DimensionsJSON;
    end;

    local procedure UpdateDimensions(LineExists: Boolean)
    var
        GraphMgtComplexTypes: Codeunit "Graph Mgt - Complex Types";
        NewDimensionSetId: Integer;
    begin
        if not DimensionsSet then
            exit;

        GraphMgtComplexTypes.GetDimensionSetFromJSON(DimensionsJSON, "Dimension Set ID", NewDimensionSetId);
        if "Dimension Set ID" <> NewDimensionSetId then begin
            "Dimension Set ID" := NewDimensionSetId;
            if LineExists then
                Modify();
        end;
    end;

    local procedure ClearCalculatedFields()
    begin
        Clear(DimensionsJSON);
        Clear(PreviousDimensionsJSON);
        Clear(DimensionsSet);
    end;
}
