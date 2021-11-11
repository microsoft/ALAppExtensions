codeunit 20294 "Use Case Mgmt."
{
    procedure OpenTableRelationDialog(CaseID: Guid; ID: Guid);
    var
        TaxTableRelation: Record "Tax Table Relation";
        TaxTableRelationDialog: Page "Tax Table Relation Dialog";
    begin
        TaxTableRelation.GET(CaseID, ID);
        TaxTableRelationDialog.SetCurrentRecord(TaxTableRelation);
        TaxTableRelationDialog.RunModal();
    end;

    procedure OpenComponentExprDialog(CaseID: Guid; ID: Guid);
    var
        TaxComponentExpression: Record "Tax Component Expression";
        TaxComponentExprDialog: Page "Tax Component Expr. Dialog";
    begin
        TaxComponentExpression.GET(CaseID, ID);
        TaxComponentExprDialog.SetCurrentRecord(TaxComponentExpression);
        TaxComponentExprDialog.RunModal();
    end;

    procedure CreateAndOpenChildUseCaseCard(FromUseCase: Record "Tax Use Case")
    var
        ToUseCase: Record "Tax Use Case";
        UseCase: Record "Tax Use Case";
        PresentationOrder: Integer;
    begin
        ToUseCase.Init();
        ToUseCase."Tax Type" := FromUseCase."Tax Type";
        ToUseCase."Tax Table ID" := FromUseCase."Tax Table ID";
        ToUseCase.ID := CreateGuid();
        ToUseCase."Parent Use Case ID" := FromUseCase.ID;
        ToUseCase.Description := 'Copy of ' + copystr(FromUseCase.Description, 1, 1024);
        ToUseCase.Insert(true);

        IndentUseCases(EmptyGuid, PresentationOrder);
        UseCase.Get(ToUseCase.ID);

        page.Run(Page::"Use Case Card", UseCase);
    end;

    procedure IndentUseCases(CaseID: Guid; var PresentationOrder: Integer)
    var
        UseCase: Record "Tax Use Case";
    begin
        UseCase.SetRange("Parent Use Case ID", CaseID);
        if UseCase.FindSet() then
            repeat
                PresentationOrder += 1;
                UseCase."Presentation Order" := PresentationOrder;
                UseCase.Modify();
                IndentUseCases(UseCase.ID, PresentationOrder);
            until UseCase.Next() = 0;
    end;

    procedure EnableSelectedUseCases(var TaxUseCase: Record "Tax Use Case")
    begin
        if TaxUseCase.FindSet() then
            repeat
                if TaxUseCase.Status <> TaxUseCase.Status::Released then
                    TaxUseCase.Validate(Status, TaxUseCase.Status::Released);

                TaxUseCase.Validate(Enable, true);
                TaxUseCase.Modify(true);
            until TaxUseCase.Next() = 0;
    end;

    procedure DisableSelectedUseCases(var TaxUseCase: Record "Tax Use Case")
    begin
        if TaxUseCase.FindSet() then
            repeat
                TaxUseCase.Validate(Status, TaxUseCase.Status::Draft);
                TaxUseCase.Validate(Enable, false);
                TaxUseCase.Modify(true);
            until TaxUseCase.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Tax Types", 'OnAfterActionEvent', 'UseCases', false, false)]
    local procedure OnAfterActionUseCases(var Rec: Record "Tax Type")
    var
        TaxUseCase: Record "Tax Use Case";
    begin
        TaxUseCase.FilterGroup(4);
        TaxUseCase.SetRange("Tax Type", Rec.Code);
        TaxUseCase.FilterGroup(0);
        Page.Run(Page::"Use Cases", TaxUseCase);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Tax Type", 'OnAfterActionEvent', 'UseCases', false, false)]
    local procedure OnAfterActionTaxTypeUseCases(var Rec: Record "Tax Type")
    var
        TaxUseCase: Record "Tax Use Case";
    begin
        TaxUseCase.FilterGroup(4);
        TaxUseCase.SetRange("Tax Type", Rec.Code);
        TaxUseCase.FilterGroup(0);
        Page.Run(Page::"Use Cases", TaxUseCase);
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterExportUseCases(var TaxUseCase: Record "Tax Use Case")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterOpenPostingSetup(var TaxUseCase: Record "Tax Use Case")
    begin
    end;

    var
        EmptyGuid: Guid;
}