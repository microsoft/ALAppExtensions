page 20298 "Use Case Tree"
{
    Caption = 'Use Case Tree';
    DataCaptionFields = Code;
    DelayedInsert = true;
    PageType = List;
    SourceTable = "Use Case Tree Node";
    UsageCategory = Lists;
    ApplicationArea = Basic, Suite;
    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                IndentationColumn = NameIndent;
                IndentationControls = Name;
                ShowCaption = false;
                field("Code"; rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                    Style = Strong;
                    StyleExpr = Emphasize;
                    ToolTip = 'Specifies the code for the use case tree node.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = Basic, Suite;
                    Style = Strong;
                    StyleExpr = Emphasize;
                    ToolTip = 'Specifies a descriptive name for the use case tree node.';
                }
                field("Node Type"; Rec."Node Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the purpose of the use case tree node.';
                }
                field("Tax Entity Name"; TaxEntityName)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Tax Entity Name';
                    ToolTip = 'Specifies the source table considered for computing tax components.';
                    trigger OnValidate()
                    var
                        AppObjHelper: Codeunit "App Object Helper";
                        UseCaseTreeConditionMgmt: Codeunit "Use Case Tree Condition Mgmt.";
                        UseCaseTreeIndent: Codeunit "Use Case Tree-Indent";
                        EmptyGuid: Guid;
                    begin
                        if TaxEntityName = '' then begin
                            Rec."Table ID" := 0;
                            TaxEntityName := '0';
                            Rec."Use Case ID" := EmptyGuid;
                        end;

                        AppObjHelper.SearchObject(ObjectType::Table, Rec."Table ID", TaxEntityName);
                        if TaxEntityName = '' then
                            UseCaseTreeConditionMgmt.SetTablesCondition(Rec, '');

                        UseCaseTreeIndent.ValidateAndUpdateTableName(Rec);
                        CurrPage.SaveRecord();
                        FormatLine();
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        AppObjHelper: Codeunit "App Object Helper";
                    begin
                        AppObjHelper.OpenObjectLookup(ObjectType::Table, Text, Rec."Table ID", TaxEntityName);
                        CurrPage.SaveRecord();
                        FormatLine();
                    end;
                }
                field(Condition; StrSubstNo(ConditionLbl, ConditionText))
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the condition to execute the use case.';
                    Caption = 'Condition';
                    Editable = false;
                    StyleExpr = true;
                    Style = Subordinate;
                    trigger OnAssistEdit()
                    var
                        UseCaseTreeConditionMgmt: Codeunit "Use Case Tree Condition Mgmt.";
                    begin
                        Rec.TestField("Table ID");
                        ConditionText := '';
                        UseCaseTreeConditionMgmt.OpendynamicRequestPage(Rec);
                        ConditionText := GetConditionAsDisplayText();
                    end;
                }
                field(UseCaseName; UseCaseName)
                {
                    Caption = 'Use Case Name';
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the name of the attached use case.';
                    trigger OnDrillDown()
                    var
                        TaxUseCase: Record "Tax Use Case";
                    begin
                        Rec.TestField("Table ID");
                        Rec.TestField("Node Type", Rec."Node Type"::"Use Case");

                        TaxUseCase.SetRange("Tax Table ID", Rec."Table ID");
                        if Page.RunModal(Page::"Use Case List", TaxUseCase) = Action::LookupOK then begin
                            UseCaseName := TaxUseCase.Description;
                            Rec."Use Case ID" := TaxUseCase.ID;

                            if Rec.Name = '' then
                                Rec.Name := CopyStr(TaxUseCase.Description, 1, 250);
                        end;
                    end;
                }
                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies that the related record is blocked from being used in use case execution.';
                }
                field("Is Tax Type Root"; Rec."Is Tax Type Root")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies that the tree node is root of the tax type.';
                }
                field("Tax Type"; Rec."Tax Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the tax type for the below heirarchy.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action("Indent Nodes")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Indent Nodes';
                    Image = Indent;
                    RunObject = Codeunit "Use Case Tree-Indent";
                    RunPageOnRec = true;
                    ToolTip = 'Indent nodes between a Begin and the matching End one level to make the list easier to read.';
                }
                action("ImportUseCaseFromLibrary")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Import Use Case from Library';
                    Image = Indent;
                    ToolTip = 'Imports the Use Case from the set of library of use cases.';
                    trigger OnAction()
                    var
                        UseCaseExecution: Codeunit "Use Case Execution";
                    begin
                        UseCaseExecution.OnImportUseCaseOnDemand(Rec."Tax Type", Rec."Use Case ID");
                        CurrPage.Update(true);
                    end;
                }
                action("Export Nodes")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Export Nodes';
                    Image = Indent;
                    ToolTip = 'Indent nodes between a Begin and the matching End one level to make the list easier to read.';
                    trigger OnAction()
                    var
                        UseCaseTreeNode: Record "Use Case Tree Node";
                        UseCaseTreeIndent: Codeunit "Use Case Tree-Indent";
                    begin
                        CurrPage.SetSelectionFilter(UseCaseTreeNode);
                        UseCaseTreeIndent.ExportNodes(UseCaseTreeNode);
                    end;
                }
                action("Import Nodes")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Import Nodes';
                    Image = Import;
                    ToolTip = 'Indent nodes between a Begin and the matching End one level to make the list easier to read.';
                    trigger OnAction()
                    var
                        UseCaseTreeIndent: Codeunit "Use Case Tree-Indent";
                    begin
                        UseCaseTreeIndent.ImportNodes();
                        CurrPage.Update(true);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        NameIndent := 0;
        FormatLine();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        NameIndent := 0;
        FormatLine();
    end;

    var
        [InDataSet]
        Emphasize: Boolean;
        [InDataSet]
        NameIndent: Integer;
        ConditionText: Text;
        TaxEntityName: Text[30];
        UseCaseName: Text[2000];
        ObjectIDNotFoundErr: Label 'Error : Table ID %1 not found', Comment = '%1=Table Id';
        ConditionLbl: Label 'Condition : %1', Comment = '%1 = condtion as text';
        ExitMsg: Label 'Always';
        UseCaseNotImportedLbl: Label 'Use case is not Imported.';

    local procedure FormatLine()
    var
        UseCase: Record "Tax Use Case";
        AppObjHelper: Codeunit "App Object Helper";
        EmptyGuid: Guid;
    begin
        Emphasize := Rec."Node Type" <> Rec."Node Type"::"Use Case";
        NameIndent := Rec.Indentation;

        ConditionText := '';
        if Rec."Table Id" <> 0 then
            ConditionText := GetConditionAsDisplayText();

        if Rec."Table ID" <> 0 then
            TaxEntityName := AppObjHelper.GetObjectName(ObjectType::Table, Rec."Table ID")
        else
            TaxEntityName := '';

        if Rec."Use Case ID" <> EmptyGuid then begin
            if UseCase.Get(Rec."Use Case ID") then
                UseCaseName := UseCase.Description
            else
                UseCaseName := UseCaseNotImportedLbl;
        end else
            UseCaseName := '';
    end;

    local procedure GetConditionAsDisplayText(): Text
    var
        Allobj: Record AllObj;
        RecordRef: RecordRef;
        IStream: InStream;
        ConditionText2: Text;
    begin
        if Not Allobj.Get(Allobj."Object Type"::Table, Rec."Table Id") then
            exit(StrSubstNo(ObjectIDNotFoundErr, Rec."Table Id"));
        RecordRef.OPEN(Rec."Table ID");
        Rec.CalcFields(Condition);
        if not Rec.Condition.HasValue() then
            exit(ExitMsg);

        Rec.Condition.CreateInStream(IStream);
        IStream.read(ConditionText2);
        RecordRef.SetView(ConditionText2);
        if RecordRef.GetFilters() <> '' then
            exit(RecordRef.GetFilters());
        RecordRef.Close();
    end;
}