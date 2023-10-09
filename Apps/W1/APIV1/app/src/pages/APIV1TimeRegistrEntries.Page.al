namespace Microsoft.API.V1;

using Microsoft.HumanResources.Employee;
using Microsoft.Projects.Project.Job;
using Microsoft.Integration.Graph;

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
                field(employeeId; Rec."Employee Id")
                {
                    Caption = 'employeeId', Locked = true;

                    trigger OnValidate()

                    begin
                        if Rec."Employee Id" = BlankGUID then begin
                            Rec."Employee No" := '';
                            exit;
                        end;

                        if Rec.HasFilter() then
                            if Rec."Employee Id" <> Rec.GetFilter("Employee Id") then
                                Error(CannotChangeEmployeeIdErr);

                        if not Employee.GetBySystemId(Rec."Employee Id") then
                            error(EmployeeIdDoesNotMatchAnEmployeeErr);

                        Rec."Employee No" := Employee."No.";
                    end;
                }
                field(employeeNumber; Rec."Employee No")
                {
                    Caption = 'employeeNumber', Locked = true;
                    trigger OnValidate()
                    begin
                        if Employee."No." <> '' then begin
                            if Employee."No." <> Rec."Employee No" then
                                error(EmployeeValuesDontMatchErr);
                            exit;
                        end;

                        if Rec."Employee No" = '' then begin
                            Rec."Employee Id" := BlankGUID;
                            exit;
                        end;

                        if not Employee.GET(Rec."Employee No") then
                            error(EmployeeNumberDoesNotMatchAnEmployeeErr);

                        if Rec.HasFilter() then
                            if Employee.SystemId <> Rec.GetFilter("Employee Id") then
                                Error(CannotChangeEmployeeNumberErr);

                        Rec.Validate("Employee Id", Employee.SystemId);
                    end;

                }
                field(jobId; Rec."job id")
                {
                    Caption = 'jobId', Locked = true;
                    trigger OnValidate()
                    begin
                        if Rec."Job Id" = BlankGUID then begin
                            Rec."Job No." := '';
                            exit;
                        end;

                        if not Job.GetBySystemId(Rec."Job Id") then
                            error(JobIdDoesNotMatchAJobErr);

                        Rec."Job No." := Job."No.";
                    end;
                }
                field(jobNumber; Rec."Job No.")
                {
                    Caption = 'jobNumber', Locked = true;
                    trigger OnValidate()
                    begin
                        if Job."No." <> '' then begin
                            if Job."No." <> Rec."Job No." then
                                error(JobValuesDontMatchErr);
                            exit;
                        end;

                        if Rec."Job No." = '' then begin
                            Rec."Job Id" := BlankGUID;
                            exit;
                        end;

                        if not Job.GET(Rec."Job No.") then
                            error(JobNumberDoesNotMatchAJobErr);

                        Rec.Validate("Job Id", Job.SystemId);
                    end;

                }
                field(absence; Rec."Cause of Absence Code")
                {
                    Caption = 'absence', Locked = true;
                    Editable = false;
                }
                field(lineNumber; Rec."Line No")
                {
                    Caption = 'lineNumber', Locked = true;
                    Editable = false;
                }
                field(date; Rec.Date)
                {
                    Caption = 'date', Locked = true;
                }
                field(quantity; Rec.Quantity)
                {
                    Caption = 'quantity', Locked = true;
                }
                field(status; Rec.Status)
                {
                    Caption = 'status', Locked = true;
                    Editable = false;
                }
                field(unitOfMeasureId; Rec."Unit of Measure Id")
                {
                    Caption = 'unitOfMeasureId', Locked = true;
                    Editable = false;
                    ToolTip = 'Specifies Unit of Measure.';
                }
                field(unitOfMeasure; UnitOfMeasureJSON)
                {
                    Caption = 'unitOfMeasure', Locked = true;
                    Editable = false;
#pragma warning disable AL0667
                    ODataEDMType = 'ITEM-UOM';
#pragma warning restore
                    ToolTip = 'Specifies Unit of Measure.';
                }
                field(dimensions; DimensionsJSON)
                {
                    Caption = 'dimensions', Locked = true;
#pragma warning disable AL0667
                    ODataEDMType = 'Collection(DIMENSION)';
#pragma warning restore
                    ToolTip = 'Specifies Time registration Dimensions.';

                    trigger OnValidate()
                    begin
                        DimensionsSet := PreviousDimensionsJSON <> DimensionsJSON;
                    end;
                }
                field(id; Rec.Id)
                {
                    Caption = 'id', Locked = true;
                }
                field(lastModfiedDateTime; Rec."Last Modified Date Time")
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
        Rec.PropagateDelete();
    end;

    trigger OnFindRecord(Which: Text): Boolean
    begin
        if not LinesLoaded then begin
            Rec.LoadRecords(Rec.GetFilter(Id), Rec.GetFilter(Date), Rec.GetFilter("Employee Id"));
            if not Rec.FINDFIRST() then
                exit(false);
            LinesLoaded := true;
        end;

        exit(true);
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        if Rec."Employee Id" = BlankGUID then begin
            if not Rec.HasFilter() then
                Error(EmployeeIdOrNumberShouldBeSpecifiedErr);
            Rec.Validate("Employee Id", Rec.GetFilter("Employee Id"));
            Employee.GetBySystemId(Rec."Employee Id");
            Rec."Employee No" := Employee."No.";
        end;

        UpdateDimensions(false);
        Rec.PropagateInsert();
        SetCalculatedFields();
    end;

    trigger OnModifyRecord(): Boolean
    begin
        if Rec."Employee Id" <> xRec."Employee Id" then
            error(CannotModifyEmployeeIdErr);

        if Rec.Date <> xRec.Date then
            error(CannotModifyDateErr);

        UpdateDimensions(true);
        Rec.PropagateModify();
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
        DimensionsJSON := GraphMgtComplexTypes.GetDimensionsJSON(Rec."Dimension Set ID");
        UnitOfMeasureJSON := GraphMgtComplexTypes.GetUnitOfMeasureJSON(Rec."Unit of Measure Code");
        PreviousDimensionsJSON := DimensionsJSON;
    end;

    local procedure UpdateDimensions(LineExists: Boolean)
    var
        GraphMgtComplexTypes: Codeunit "Graph Mgt - Complex Types";
        NewDimensionSetId: Integer;
    begin
        if not DimensionsSet then
            exit;

        GraphMgtComplexTypes.GetDimensionSetFromJSON(DimensionsJSON, Rec."Dimension Set ID", NewDimensionSetId);
        if Rec."Dimension Set ID" <> NewDimensionSetId then begin
            Rec."Dimension Set ID" := NewDimensionSetId;
            if LineExists then
                Rec.Modify();
        end;
    end;

    local procedure ClearCalculatedFields()
    begin
        Clear(DimensionsJSON);
        Clear(PreviousDimensionsJSON);
        Clear(DimensionsSet);
    end;
}

