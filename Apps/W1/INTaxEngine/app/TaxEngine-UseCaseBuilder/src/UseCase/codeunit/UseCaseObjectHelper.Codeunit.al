codeunit 20295 "Use Case Object Helper"
{
    procedure GetUseCaseID(UseCaseName: Text[2000]): Guid;
    var
        UseCase: Record "Tax Use Case";
        InvalidParentUseCaseErr: Label 'Parent Use Case :%1 does not exist', Comment = '%1= Parent Use Case Description';
    begin
        if UseCaseName = '' then
            exit(EmptyGuid);

        UseCase.SetRange(Description, UseCaseName);
        if not UseCase.FindFirst() then
            Error(InvalidParentUseCaseErr, UseCaseName);

        exit(UseCase.ID);
    end;

    procedure GetUseCaseName(CaseID: Guid): Text[2000];
    var
        UseCase: Record "Tax Use Case";
    begin
        if IsNullGuid(CaseID) then
            exit('');

        UseCase.SetRange(ID, CaseID);
        if UseCase.FindFirst() then
            exit(UseCase.Description);

        exit('');
    end;

    var
        EmptyGuid: Guid;
}