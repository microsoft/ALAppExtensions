namespace Microsoft.API.V2;

using Microsoft.HumanResources.Employee;
using Microsoft.Projects.Project.Job;
using Microsoft.Integration.Graph;

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
                field(employeeId; Rec."Employee Id")
                {
                    Caption = 'Employee Id';

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
                            Error(EmployeeIdDoesNotMatchAnEmployeeErr);

                        Rec."Employee No" := Employee."No.";
                    end;
                }
                field(employeeNumber; Rec."Employee No")
                {
                    Caption = 'Employee No.';
                    trigger OnValidate()
                    begin
                        if Employee."No." <> '' then begin
                            if Employee."No." <> Rec."Employee No" then
                                Error(EmployeeValuesDontMatchErr);
                            exit;
                        end;

                        if Rec."Employee No" = '' then begin
                            Rec."Employee Id" := BlankGUID;
                            exit;
                        end;

                        if not Employee.Get(Rec."Employee No") then
                            Error(EmployeeNumberDoesNotMatchAnEmployeeErr);

                        if Rec.HasFilter() then
                            if Employee.SystemId <> Rec.GetFilter("Employee Id") then
                                Error(CannotChangeEmployeeNumberErr);

                        Rec.Validate("Employee Id", Employee.SystemId);
                    end;

                }
                field(jobId; Rec."job id")
                {
                    Caption = 'Job Id';
                    trigger OnValidate()
                    begin
                        if Rec."Job Id" = BlankGUID then begin
                            Rec."Job No." := '';
                            exit;
                        end;

                        if not Job.GetBySystemId(Rec."Job Id") then
                            Error(JobIdDoesNotMatchAJobErr);

                        Rec."Job No." := Job."No.";
                    end;
                }
                field(jobNumber; Rec."Job No.")
                {
                    Caption = 'Job No.';
                    trigger OnValidate()
                    begin
                        if Job."No." <> '' then begin
                            if Job."No." <> Rec."Job No." then
                                Error(JobValuesDontMatchErr);
                            exit;
                        end;

                        if Rec."Job No." = '' then begin
                            Rec."Job Id" := BlankGUID;
                            exit;
                        end;

                        if not Job.Get(Rec."Job No.") then
                            Error(JobNumberDoesNotMatchAJobErr);

                        Rec.Validate("Job Id", Job.SystemId);
                    end;
                }
                field(jobTaskNumber; Rec."Job Task No.")
                {
                    Caption = 'Job Task No.';
                }
                field(absence; Rec."Cause of Absence Code")
                {
                    Caption = 'Absence';
                    Editable = false;
                }
                field(lineNumber; Rec."Line No")
                {
                    Caption = 'Line No.';
                    Editable = false;
                }
                field(date; Rec.Date)
                {
                    Caption = 'Date';
                }
                field(quantity; Rec.Quantity)
                {
                    Caption = 'Quantity';
                }
                field(status; Rec.Status)
                {
                    Caption = 'Status';
                    Editable = false;
                }
                field(unitOfMeasureId; Rec."Unit of Measure Id")
                {
                    Caption = 'Unit Of Measure Id';
                    Editable = false;
                }
                field(unitOfMeasureCode; Rec."Unit of Measure Code")
                {
                    Caption = 'Unit Of Measure Code';
                    Editable = false;
                }
                field(id; Rec.Id)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(lastModfiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date Time';
                }
                part(dimensionSetLines; "APIV2 - Dimension Set Lines")
                {
                    Caption = 'Dimension Set Lines';
                    EntityName = 'dimensionSetLine';
                    EntitySetName = 'dimensionSetLines';
                    SubPageLink = "Parent Id" = field(Id), "Parent Type" = const("Time Registration Entry");
                }
            }
        }
    }

    actions
    {
    }

    trigger OnDeleteRecord(): Boolean
    begin
        Rec.PropagateDelete();
    end;

    trigger OnFindRecord(Which: Text): Boolean
    begin
        if not LinesLoaded then begin
            Rec.LoadRecords(Rec.GetFilter(Id), Rec.GetFilter(Date), Rec.GetFilter("Employee Id"));
            if not Rec.FindFirst() then
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

        Rec.PropagateInsert();
    end;

    trigger OnModifyRecord(): Boolean
    begin
        if Rec."Employee Id" <> xRec."Employee Id" then
            Error(CannotModifyEmployeeIdErr);

        if Rec.Date <> xRec.Date then
            Error(CannotModifyDateErr);

        Rec.PropagateModify();
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
