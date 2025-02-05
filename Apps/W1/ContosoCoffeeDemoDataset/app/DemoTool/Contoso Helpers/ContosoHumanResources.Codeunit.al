codeunit 5171 "Contoso Human Resources"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata Confidential = rim,
        tabledata "Misc. Article" = rim,
        tabledata "Employment Contract" = rim,
        tabledata "Grounds for Termination" = rim,
        tabledata "Cause of Inactivity" = rim,
        tabledata Union = rim,
        tabledata Relative = rim,
        tabledata "Employee Absence" = rim,
        tabledata "Employee Templ." = rim,
        tabledata Employee = rim,
        tabledata "Cause of Absence" = rim,
        tabledata "Human Resource Unit of Measure" = rim,
        tabledata "Employee Posting Group" = rim,
        tabledata "Employee Qualification" = rim,
        tabledata "Employee Relative" = rim,
        tabledata Qualification = rim,
        tabledata "Employee Statistics Group" = rim,
        tabledata "Misc. Article Information" = rim,
        tabledata "Confidential Information" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertConfidential(Code: Code[10]; Description: Text[100])
    var
        Confidential: Record Confidential;
        Exists: Boolean;
    begin
        if Confidential.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        Confidential.Validate(Code, Code);
        Confidential.Validate(Description, Description);

        if Exists then
            Confidential.Modify(true)
        else
            Confidential.Insert(true);
    end;

    procedure InsertMiscellaneousArticle(Code: Code[10]; Description: Text[100])
    var
        MiscellaneousArticle: Record "Misc. Article";
        Exists: Boolean;
    begin
        if MiscellaneousArticle.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        MiscellaneousArticle.Validate(Code, Code);
        MiscellaneousArticle.Validate(Description, Description);

        if Exists then
            MiscellaneousArticle.Modify(true)
        else
            MiscellaneousArticle.Insert(true);
    end;

    procedure InsertEmploymentContract(Code: Code[10]; Description: Text[100])
    var
        EmployeeContact: Record "Employment Contract";
        Exists: Boolean;
    begin
        if EmployeeContact.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        EmployeeContact.Validate(Code, Code);
        EmployeeContact.Validate(Description, Description);

        if Exists then
            EmployeeContact.Modify(true)
        else
            EmployeeContact.Insert(true);
    end;

    procedure InsertGroundsForTermination(Code: Code[10]; Description: Text[100])
    var
        GroundsForTermination: Record "Grounds for Termination";
        Exists: Boolean;
    begin
        if GroundsForTermination.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        GroundsForTermination.Validate(Code, Code);
        GroundsForTermination.Validate(Description, Description);

        if Exists then
            GroundsForTermination.Modify(true)
        else
            GroundsForTermination.Insert(true);
    end;

    procedure InsertCauseOfInactivity(Code: Code[10]; Description: Text[100])
    var
        CauseOfInactivity: Record "Cause of Inactivity";
        Exists: Boolean;
    begin
        if CauseOfInactivity.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        CauseOfInactivity.Validate(Code, Code);
        CauseOfInactivity.Validate(Description, Description);

        if Exists then
            CauseOfInactivity.Modify(true)
        else
            CauseOfInactivity.Insert(true);
    end;

    procedure InsertUnion(Code: Code[10]; Name: Text[100])
    var
        Union: Record Union;
        Exists: Boolean;
    begin
        if Union.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        Union.Validate(Code, Code);
        Union.Validate(Name, Name);

        if Exists then
            Union.Modify(true)
        else
            Union.Insert(true);
    end;

    procedure InsertRelative(RelativeCode: Code[10]; Description: Text[100])
    var
        Relative: Record Relative;
        Exists: Boolean;
    begin
        if Relative.Get(RelativeCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        Relative.Validate(Code, RelativeCode);
        Relative.Validate(Description, Description);

        if Exists then
            Relative.Modify(true)
        else
            Relative.Insert(true);
    end;

    procedure InsertEmployeeAbsence(EmployeeNo: Code[20]; FromDate: Date; ToDate: Date; CauseOfAbsenceCode: Code[10]; Quantity: Decimal; UnitOfMeasureCode: Code[10])
    var
        EmployeeAbsence: Record "Employee Absence";
    begin
        EmployeeAbsence.Validate("Employee No.", EmployeeNo);

        EmployeeAbsence.Validate("From Date", FromDate);
        EmployeeAbsence.Validate("To Date", ToDate);

        EmployeeAbsence.Validate("Cause of Absence Code", CauseOfAbsenceCode);
        EmployeeAbsence.Validate(Quantity, Quantity);
        EmployeeAbsence.Validate("Unit of Measure Code", UnitOfMeasureCode);

        EmployeeAbsence.Insert(true);
    end;

    procedure InsertEmployeeTemplate(Code: Code[20]; Description: Text[100]; Gender: Enum "Employee Gender"; EmployeePostingGroupCode: Code[20])
    var
        EmployeeTemplate: Record "Employee Templ.";
        Exists: Boolean;
    begin
        if EmployeeTemplate.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        EmployeeTemplate.Validate(Code, Code);
        EmployeeTemplate.Validate(Description, Description);
        EmployeeTemplate.Validate("Employee Posting Group", EmployeePostingGroupCode);
        EmployeeTemplate.Validate(Gender, Gender);

        if Exists then
            EmployeeTemplate.Modify(true)
        else
            EmployeeTemplate.Insert(true);
    end;

    procedure InsertEmployee(No: Code[20]; FirstName: Text[30]; LastName: Text[30]; Title: Text[30]; PostingGroupCode: Code[20]; EmploymentContractCode: Code[10]; StatisticsGroupCode: Code[10]; UnionCode: Code[10]; Sex: Enum "Employee Gender"; Picture: Codeunit "Temp Blob")
    var
        Employee: Record Employee;
        ObjInStream: InStream;
        Exists: Boolean;
    begin
        if Employee.Get(No) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        Employee.Validate("No.", No);
        Employee.Validate("First Name", FirstName);
        Employee.Validate("Last Name", LastName);
        Employee.Validate("Job Title", Title);
        Employee.Validate("Gender", Sex);
        Employee.Validate("Employee Posting Group", PostingGroupCode);
        Employee.Validate("Emplymt. Contract Code", EmploymentContractCode);
        Employee.Validate("Statistics Group Code", StatisticsGroupCode);
        Employee.Validate("Union Code", UnionCode);

        if Picture.HasValue() then begin
            Picture.CreateInStream(ObjInStream);
            Employee.Image.ImportStream(ObjInStream, Employee.FullName());
        end;

        if Exists then
            Employee.Modify(true)
        else
            Employee.Insert(true);
    end;

    procedure InsertCauseOfAbsence(Code: Code[10]; Description: Text[100]; UnitOfMeasureCode: Code[10])
    var
        CauseOfAbsence: Record "Cause of Absence";
        Exists: Boolean;
    begin
        if CauseOfAbsence.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        CauseOfAbsence.Validate(Code, Code);
        CauseOfAbsence.Validate(Description, Description);
        CauseOfAbsence.Validate("Unit of Measure Code", UnitOfMeasureCode);

        if Exists then
            CauseOfAbsence.Modify(true)
        else
            CauseOfAbsence.Insert(true);
    end;

    procedure InsertHumanResourcesUom(Code: Code[10]; QtyParam: Decimal)
    var
        HumanResourceUOM: Record "Human Resource Unit of Measure";
        Exists: Boolean;
    begin
        if HumanResourceUOM.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        HumanResourceUOM.Validate(Code, Code);
        HumanResourceUOM.Validate("Qty. per Unit of Measure", QtyParam);

        if Exists then
            HumanResourceUOM.Modify(true)
        else
            HumanResourceUOM.Insert(true);
    end;

    procedure UpdateEmployeeDetails(No: Code[20]; BirthDate: Date; EmploymentDate: Date; Address: Text[100]; PostCode: Code[20]; InternalPhoneNo: Text[30]; MobilePhoneNo: Text[30]; PhoneNo: Text[30]; Email: Text[80]; SocialSecurityNo: Text[30]; UnitNo: Text[30])
    var
        Employee: Record Employee;
    begin
        Employee.Get(No);
        Employee.Validate("Birth Date", BirthDate);
        Employee.Validate("Employment Date", EmploymentDate);
        Employee.Validate(Address, Address);
        Employee.Validate("Post Code", PostCode);
        Employee.Validate(Extension, InternalPhoneNo);
        Employee.Validate("Mobile Phone No.", MobilePhoneNo);
        Employee.Validate("Phone No.", PhoneNo);
        Employee.Validate("Social Security No.", SocialSecurityNo);

        if Email <> '' then
            Employee.Validate("E-Mail", Email)
        else
            Employee.Validate("E-Mail", StrSubstNo(EmpEmailLbl, LowerCase(Employee."No.")));

        Employee.Modify(true);
    end;

    procedure InsertEmployeePostingGroup(PostingGroupCode: Code[20]; PayableAccount: Code[20])
    var
        EmployeePostingGroup: Record "Employee Posting Group";
        Exists: Boolean;
    begin
        if EmployeePostingGroup.Get(PostingGroupCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        EmployeePostingGroup.Validate(Code, PostingGroupCode);
        EmployeePostingGroup.Validate("Payables Account", PayableAccount);

        if Exists then
            EmployeePostingGroup.Modify(true)
        else
            EmployeePostingGroup.Insert(true)
    end;

    procedure InsertEmployeeQualification(EmployeeNo: Code[20]; QualificationCode: Code[10]; FromDate: Date; ToDate: Date; Type: Option; InstitutionCompany: Text[30])
    var
        EmployeeQualification: Record "Employee Qualification";
    begin
        EmployeeQualification.Validate("Employee No.", EmployeeNo);
        EmployeeQualification.Validate("Line No.", GetEmployeeQualificationNextLineNo(EmployeeNo));
        EmployeeQualification.Validate("Qualification Code", QualificationCode);
        EmployeeQualification.Validate("From Date", FromDate);
        EmployeeQualification.Validate("To Date", ToDate);
        EmployeeQualification.Validate(Type, Type);
        EmployeeQualification.Validate("Institution/Company", InstitutionCompany);
        EmployeeQualification.Insert(true);
    end;

    procedure InsertEmployeeRelative(EmployeeNo: Code[20]; RelativeCode: Code[10]; FirstName: Text[30]; BirthDate: Date; Age: Integer)
    var
        EmployeeRelative: Record "Employee Relative";
        RecordRef: RecordRef;
        FieldRef: FieldRef;
    begin
        EmployeeRelative.Validate("Employee No.", EmployeeNo);
        EmployeeRelative.Validate("Line No.", GetEmployeeRelativeNextLineNo(EmployeeNo));
        EmployeeRelative.Validate("Relative Code", RelativeCode);

        EmployeeRelative.Validate("Birth Date", DMY2Date(Date2DMY(BirthDate, 1), Date2DMY(BirthDate, 2), (Date2DMY(BirthDate, 3) - Age)));
        EmployeeRelative.Insert(true);

        // This is needed because of ES localization on field 4
        RecordRef.GetTable(EmployeeRelative);
        FieldRef := RecordRef.Field(4);
        FieldRef.Value := FirstName;
        RecordRef.Modify(true);
    end;

    procedure InsertEmployeeStatisticsGroup(Code: Code[10]; Description: Text[100])
    var
        EmployeeStatisticsGroup: Record "Employee Statistics Group";
        Exists: Boolean;
    begin
        if EmployeeStatisticsGroup.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        EmployeeStatisticsGroup.Validate(Code, Code);
        EmployeeStatisticsGroup.Validate(Description, Description);

        if Exists then
            EmployeeStatisticsGroup.Modify(true)
        else
            EmployeeStatisticsGroup.Insert(true);
    end;

    procedure InsertQualification(Code: Code[10]; Description: Text[100])
    var
        Qualification: Record Qualification;
        Exists: Boolean;
    begin
        if Qualification.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        Qualification.Validate(Code, Code);
        Qualification.Validate(Description, Description);

        if Exists then
            Qualification.Modify(true)
        else
            Qualification.Insert(true);
    end;

    procedure InsertMiscArticleInformation(EmployeeNo: Code[20]; MiscArticleCode: Text[100])
    var
        MiscArticleInformation: Record "Misc. Article Information";
    begin
        MiscArticleInformation.Validate("Employee No.", EmployeeNo);
        MiscArticleInformation.Validate("Misc. Article Code", MiscArticleCode);
        MiscArticleInformation.Insert(true);
    end;

    procedure InsertConfidentialInformation(EmployeeNo: Code[20]; ConfidentialCode: Code[10])
    var
        ConfidentialInformation: Record "Confidential Information";
    begin
        ConfidentialInformation.Validate("Employee No.", EmployeeNo);
        ConfidentialInformation.Validate("Confidential Code", ConfidentialCode);
        ConfidentialInformation.Validate("Line No.", GetConfidentialNextLineNo(EmployeeNo, ConfidentialCode));
        ConfidentialInformation.Insert(true);
    end;

    local procedure GetEmployeeRelativeNextLineNo(EmployeeNo: Code[20]): Integer
    var
        EmployeeRelative: Record "Employee Relative";
    begin
        EmployeeRelative.SetRange("Employee No.", EmployeeNo);
        if EmployeeRelative.FindLast() then
            exit(EmployeeRelative."Line No." + 10000)
        else
            exit(10000);
    end;

    local procedure GetEmployeeQualificationNextLineNo(EmployeeNo: Code[20]): Integer
    var
        EmployeeQualification: Record "Employee Qualification";
    begin
        EmployeeQualification.SetRange("Employee No.", EmployeeNo);
        EmployeeQualification.SetCurrentKey("Line No.");

        if EmployeeQualification.FindLast() then
            exit(EmployeeQualification."Line No." + 10000)
        else
            exit(10000);
    end;

    local procedure GetConfidentialNextLineNo(EmployeeNo: Code[20]; ConfidentialCode: Code[10]): Integer
    var
        ConfidentialInformation: Record "Confidential Information";
    begin
        ConfidentialInformation.SetRange("Employee No.", EmployeeNo);
        ConfidentialInformation.SetRange("Confidential Code", ConfidentialCode);
        ConfidentialInformation.SetCurrentKey("Line No.");

        if ConfidentialInformation.FindLast() then
            exit(ConfidentialInformation."Line No." + 10000)
        else
            exit(10000);
    end;

    var
#pragma warning disable AA0240
        EmpEmailLbl: Label '%1@cronous.com', Locked = true;
#pragma warning restore AA0240
}