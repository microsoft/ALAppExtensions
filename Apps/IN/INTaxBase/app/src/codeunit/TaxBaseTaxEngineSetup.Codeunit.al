codeunit 18551 "Tax Base Tax Engine Setup"
{
    procedure UpgradeUseCaseTree()
    var
        UseCaseTreeIndent: Codeunit "Use Case Tree-Indent";
    begin
        UseCaseTreeIndent.ReadUseCaseTree(GetTreeText());
    end;

    local procedure GetTreeText(): Text
    begin
        exit(UseCaseTreeLbl);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Engine Assisted Setup", 'OnSetupUseCaseTree', '', false, false)]
    local procedure OnSetupUseCaseTree()
    var
        UseCaseTreeIndent: Codeunit "Use Case Tree-Indent";
    begin
        UseCaseTreeIndent.ReadUseCaseTree(GetTreeText());
    end;

    var
        UseCaseTreeLbl: Label 'Use Case Tree Place holder';
}