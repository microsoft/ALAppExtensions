/// <summary>
/// Provides utility functions for creating and managing human resource entities in test scenarios, including employees, employee absence, and HR setup.
/// </summary>
codeunit 131901 "Library - Human Resource"
{

    trigger OnRun()
    begin
    end;

    var
        LibraryUtility: Codeunit "Library - Utility";
        LibraryERM: Codeunit "Library - ERM";
        FirstNameTxt: Label 'First Name';
        NameTxt: Label 'Name';

    procedure CreateAlternativeAddress(var AlternativeAddress: Record "Alternative Address"; EmployeeNo: Code[20])
    begin
        AlternativeAddress.Init();
        AlternativeAddress.Validate("Employee No.", EmployeeNo);
        AlternativeAddress.Validate(
          Code,
          CopyStr(
            LibraryUtility.GenerateRandomCode(AlternativeAddress.FieldNo(Code), DATABASE::"Alternative Address"),
            1,
            LibraryUtility.GetFieldLength(DATABASE::"Alternative Address", AlternativeAddress.FieldNo(Code))));
        AlternativeAddress.Insert(true);
    end;

    procedure CreateEmployee(var Employee: Record Employee)
    begin
        Employee.Init();
        Employee.Validate("Employee Posting Group", FindEmployeePostingGroup());
        Employee.Insert(true);
        UpdateEmployeeName(Employee);
        Employee.Modify(true);
    end;

    procedure CreateEmployeeNo(): Code[20]
    var
        Employee: Record Employee;
    begin
        CreateEmployee(Employee);
        exit(Employee."No.");
    end;

    procedure CreateEmployeeNoWithBankAccount(): Code[20]
    var
        Employee: Record Employee;
    begin
        CreateEmployeeWithBankAccount(Employee);
        exit(Employee."No.");
    end;

    procedure CreateEmployeeWithBankAccount(var Employee: Record Employee)
    var
        EmployeePostingGroup: Record "Employee Posting Group";
    begin
        CreateEmployee(Employee);
        Employee."Bank Account No." := LibraryUtility.GenerateGUID();
        Employee.IBAN := LibraryUtility.GenerateGUID();
        Employee."SWIFT Code" := LibraryUtility.GenerateGUID();
        Employee."Bank Branch No." := LibraryUtility.GenerateGUID();
        EmployeePostingGroup.Init();
        EmployeePostingGroup.Validate(Code, LibraryUtility.GenerateGUID());
        EmployeePostingGroup.Validate("Payables Account", LibraryERM.CreateGLAccountNoWithDirectPosting());
        EmployeePostingGroup.Insert(true);
        Employee.Validate("Employee Posting Group", EmployeePostingGroup.Code);
        Employee.Modify(true);
    end;

    procedure CreateMiscArticle(var MiscArticle: Record "Misc. Article")
    begin
        MiscArticle.Init();
        MiscArticle.Validate(
          Code,
          CopyStr(
            LibraryUtility.GenerateRandomCode(MiscArticle.FieldNo(Code), DATABASE::"Misc. Article"),
            1,
            LibraryUtility.GetFieldLength(DATABASE::"Misc. Article", MiscArticle.FieldNo(Code))));
        MiscArticle.Validate(Description, MiscArticle.Code);
        MiscArticle.Insert(true);
    end;

    procedure CreateMiscArticleInformation(var MiscArticleInformation: Record "Misc. Article Information"; EmployeeNo: Code[20]; MiscArticleCode: Code[10])
    var
        RecRef: RecordRef;
    begin
        MiscArticleInformation.Init();
        MiscArticleInformation.Validate("Employee No.", EmployeeNo);
        MiscArticleInformation.Validate("Misc. Article Code", MiscArticleCode);
        RecRef.GetTable(MiscArticleInformation);
        MiscArticleInformation.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, MiscArticleInformation.FieldNo("Line No.")));
        MiscArticleInformation.Insert(true);
    end;

    procedure CreateEmployeeQualification(var EmployeeQualification: Record "Employee Qualification"; EmployeeNo: Code[20])
    var
        RecRef: RecordRef;
    begin
        EmployeeQualification.Init();
        EmployeeQualification.Validate("Employee No.", EmployeeNo);
        RecRef.GetTable(EmployeeQualification);
        EmployeeQualification.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, EmployeeQualification.FieldNo("Line No.")));
        EmployeeQualification.Insert(true);
    end;

    procedure CreateEmployeeAbsence(var EmployeeAbsence: Record "Employee Absence")
    begin
        EmployeeAbsence.Init();
        EmployeeAbsence.Insert(true);
    end;

    procedure CreateEmployeeRelative(var EmployeeRelative: Record "Employee Relative"; EmployeeNo: Code[20])
    var
        RecRef: RecordRef;
    begin
        EmployeeRelative.Init();
        EmployeeRelative.Validate("Employee No.", EmployeeNo);
        RecRef.GetTable(EmployeeRelative);
        EmployeeRelative.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, EmployeeRelative.FieldNo("Line No.")));
        EmployeeRelative.Insert(true);
    end;

    procedure CreateEmployeeStatGroup(var EmployeeStatisticsGroup: Record "Employee Statistics Group")
    begin
        EmployeeStatisticsGroup.Init();
        EmployeeStatisticsGroup.Validate(
          Code,
          CopyStr(
            LibraryUtility.GenerateRandomCode(EmployeeStatisticsGroup.FieldNo(Code), DATABASE::"Employee Statistics Group"),
            1,
            LibraryUtility.GetFieldLength(DATABASE::"Employee Statistics Group", EmployeeStatisticsGroup.FieldNo(Code))));
        EmployeeStatisticsGroup.Validate(Description, EmployeeStatisticsGroup.Code);
        EmployeeStatisticsGroup.Insert(true);
    end;

    procedure CreateEmploymentContract(var EmploymentContract: Record "Employment Contract")
    begin
        EmploymentContract.Init();
        EmploymentContract.Validate(
          Code,
          CopyStr(
            LibraryUtility.GenerateRandomCode(EmploymentContract.FieldNo(Code), DATABASE::"Employment Contract"),
            1,
            LibraryUtility.GetFieldLength(DATABASE::"Employment Contract", EmploymentContract.FieldNo(Code))));
        EmploymentContract.Validate(Description, EmploymentContract.Code);
        EmploymentContract.Insert(true);
    end;

    procedure CreateConfidential(var Confidential: Record Confidential)
    begin
        Confidential.Init();
        Confidential.Validate(
          Code,
          CopyStr(
            LibraryUtility.GenerateRandomCode(Confidential.FieldNo(Code), DATABASE::Confidential),
            1,
            LibraryUtility.GetFieldLength(DATABASE::Confidential, Confidential.FieldNo(Code))));
        Confidential.Validate(Description, Confidential.Code);
        Confidential.Insert(true);
    end;

    procedure CreateConfidentialInformation(var ConfidentialInformation: Record "Confidential Information"; EmployeeNo: Code[20]; ConfidentialCode: Code[10])
    var
        RecRef: RecordRef;
    begin
        ConfidentialInformation.Init();
        ConfidentialInformation.Validate("Employee No.", EmployeeNo);
        ConfidentialInformation.Validate("Confidential Code", ConfidentialCode);
        RecRef.GetTable(ConfidentialInformation);
        ConfidentialInformation.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, ConfidentialInformation.FieldNo("Line No.")));
        ConfidentialInformation.Insert(true);
    end;

    procedure CreateQualification(var Qualification: Record Qualification)
    begin
        Qualification.Init();
        Qualification.Validate(
          Code,
          CopyStr(
            LibraryUtility.GenerateRandomCode(Qualification.FieldNo(Code), DATABASE::Qualification),
            1,
            LibraryUtility.GetFieldLength(DATABASE::Qualification, Qualification.FieldNo(Code))));
        Qualification.Validate(Description, Qualification.Code);
        Qualification.Insert(true);
    end;

    procedure CreateRelative(var Relative: Record Relative)
    begin
        Relative.Init();
        Relative.Validate(
          Code,
          CopyStr(
            LibraryUtility.GenerateRandomCode(Relative.FieldNo(Code), DATABASE::Relative),
            1,
            LibraryUtility.GetFieldLength(DATABASE::Relative, Relative.FieldNo(Code))));
        Relative.Validate(Description, Relative.Code);
        Relative.Insert(true);
    end;

    procedure CreateUnion(var Union: Record Union)
    begin
        Union.Init();
        Union.Validate(
          Code,
          CopyStr(
            LibraryUtility.GenerateRandomCode(Union.FieldNo(Code), DATABASE::Union),
            1,
            LibraryUtility.GetFieldLength(DATABASE::Union, Union.FieldNo(Code))));
        Union.Validate(Name, Union.Code);
        Union.Insert(true);
    end;

    local procedure UpdateEmployeeName(var Employee: Record Employee)
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
    begin
        RecRef.GetTable(Employee);
        if LibraryUtility.CheckFieldExistenceInTable(DATABASE::Employee, NameTxt) then
            FieldRef := RecRef.Field(LibraryUtility.FindFieldNoInTable(DATABASE::Employee, NameTxt))
        else
            FieldRef := RecRef.Field(LibraryUtility.FindFieldNoInTable(DATABASE::Employee, FirstNameTxt));
        FieldRef.Validate(Employee."No.");  // Validating Name as No. because value is not important.
        RecRef.SetTable(Employee);
    end;

    procedure SetupEmployeeNumberSeries(): Code[10]
    var
        HumanResourcesSetup: Record "Human Resources Setup";
    begin
        HumanResourcesSetup.Get();
        if HumanResourcesSetup."Employee Nos." = '' then
            HumanResourcesSetup.Validate("Employee Nos.", LibraryUtility.GetGlobalNoSeriesCode());
        HumanResourcesSetup.Modify(true);
        exit(HumanResourcesSetup."Employee Nos.");
    end;

    procedure CreateEmployeePostingGroup(var EmployeePostingGroup: Record "Employee Posting Group")
    begin
        EmployeePostingGroup.Init();
        EmployeePostingGroup.Validate(Code,
          LibraryUtility.GenerateRandomCode(EmployeePostingGroup.FieldNo(Code), Database::"Employee Posting Group"));
        EmployeePostingGroup.Validate("Payables Account", LibraryERM.CreateGLAccountNo());
        EmployeePostingGroup.Validate("Debit Rounding Account", LibraryERM.CreateGLAccountNo());
        EmployeePostingGroup.Validate("Credit Rounding Account", LibraryERM.CreateGLAccountNo());
        EmployeePostingGroup.Validate("Debit Curr. Appln. Rndg. Acc.", LibraryERM.CreateGLAccountNo());
        EmployeePostingGroup.Validate("Credit Curr. Appln. Rndg. Acc.", LibraryERM.CreateGLAccountNo());
        EmployeePostingGroup.Insert(true);
    end;

    procedure FindEmployeePostingGroup(): Code[20]
    var
        EmployeePostingGroup: Record "Employee Posting Group";
    begin
        if not EmployeePostingGroup.FindFirst() then
            CreateEmployeePostingGroup(EmployeePostingGroup);
        exit(EmployeePostingGroup.Code);
    end;

    procedure CreateAltEmployeePostingGroup(ParentCode: Code[20]; AltCode: Code[20])
    var
        AltEmployeePostingGroup: Record "Alt. Employee Posting Group";
    begin
        AltEmployeePostingGroup.Init();
        AltEmployeePostingGroup."Employee Posting Group" := ParentCode;
        AltEmployeePostingGroup."Alt. Employee Posting Group" := AltCode;
        AltEmployeePostingGroup.Insert();
    end;
}
