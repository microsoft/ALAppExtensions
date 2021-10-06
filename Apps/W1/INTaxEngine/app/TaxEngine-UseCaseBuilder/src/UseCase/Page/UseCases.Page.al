page 20310 "Use Cases"
{
    PageType = List;
    SourceTable = "Tax Use Case";
    SourceTableView = sorting("Presentation Order");
    CardPageId = "Use Case Card";
    DataCaptionExpression = 'Tax Use Case';
    RefreshOnActivate = true;
    Editable = false;
    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                ShowAsTree = true;
                IndentationColumn = "Indentation Level";
                IndentationControls = Description;
                field(Description; Description)
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = DescriptionStyle;
                    ToolTip = 'Specifies the description of the tax use case.';
                }
                field("Tax Entity Name"; TaxEntityName)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Tax Entity Name';
                    StyleExpr = DescriptionStyle;
                    ToolTip = 'Specifies the source table considered for computing tax components.';
                }
                field(Enable; Enable)
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = DescriptionStyle;
                    ToolTip = 'Specifies if tax use case is enabled for usage.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(AddChildUseCase)
            {
                Caption = 'Add Child Use Case';
                ApplicationArea = Basic, Suite;
                Image = Hierarchy;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Adds a child use case to current use case.';
                trigger OnAction();
                var
                    UseCaseMgmt: Codeunit "Use Case Mgmt.";
                begin
                    UseCaseMgmt.CreateAndOpenChildUseCaseCard(Rec);
                end;
            }
            action(EnableSelected)
            {
                Caption = 'Enable Selected Cases';
                ToolTip = 'Enables selected use cases.';
                ApplicationArea = Basic, Suite;
                Image = EnableAllBreakpoints;
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction();
                var
                    UseCase: Record "Tax Use Case";
                    UseCaseMgmt: Codeunit "Use Case Mgmt.";
                begin
                    CurrPage.SETSELECTIONFILTER(UseCase);
                    UseCaseMgmt.EnableSelectedUseCases(UseCase);
                end;
            }
            action(DisableSelected)
            {
                Caption = 'Disable Selected Cases';
                ToolTip = 'Disables selected use cases.';
                ApplicationArea = Basic, Suite;
                Image = DisableAllBreakpoints;
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction();
                var
                    UseCase: Record "Tax Use Case";
                    UseCaseMgmt: Codeunit "Use Case Mgmt.";
                begin
                    CurrPage.SETSELECTIONFILTER(UseCase);
                    UseCaseMgmt.DisableSelectedUseCases(UseCase);
                end;
            }
            action(PostingSetup)
            {
                Caption = 'Posting Setup';
                ToolTip = 'Opens posting setup for this use case';
                ApplicationArea = Basic, Suite;
                Image = PostDocument;
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    UseCaseMgmt: Codeunit "Use Case Mgmt.";
                begin
                    UseCaseMgmt.OnAfterOpenPostingSetup(Rec);
                end;
            }
            action(ExportUseCase)
            {
                Caption = 'Export Use Case';
                ToolTip = 'Exports the use case to json file.';
                ApplicationArea = Basic, Suite;
                Image = "ExportFile";
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction();
                var
                    UseCase: Record "Tax Use Case";
                    UseCaseMgmt: Codeunit "Use Case Mgmt.";
                begin
                    CurrPage.SETSELECTIONFILTER(UseCase);
                    UseCaseMgmt.OnAfterExportUseCases(UseCase);
                end;
            }
            action(ImportUseCase)
            {
                Caption = 'Import Use Case';
                ToolTip = 'Imports the use case from json file.';
                ApplicationArea = Basic, Suite;
                Image = ImportCodes;
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction();
                var
                    i: Integer;
                begin
                    i := 0;
                    //blank OnAction created as we have a subscriber of this action in Use Case mgmt codeunit 
                    //and ruleset doesn't allow  to create a action without the OnAction trigger
                end;
            }
            action("ImportUseCaseFromLibrary")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Import Use Case from Library';
                Image = Import;
                ToolTip = 'Imports the Use Case from the set of library of use cases.';
                trigger OnAction()
                var
                    UseCaseExecution: Codeunit "Use Case Execution";
                begin
                    UseCaseExecution.OnImportUseCaseOnDemand(Rec."Tax Type", Rec.ID);
                    CurrPage.Update(true);
                end;
            }
            action(ArchivedLogs)
            {
                Caption = 'Archived Logs';
                ToolTip = 'Opens archival logs.';
                ApplicationArea = Basic, Suite;
                Image = Archive;
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction();
                var
                    i: Integer;
                begin
                    i := 0;
                    //blank OnAction created as we have a subscriber of this action in Use Case mgmt codeunit 
                    //and ruleset doesn't allow  to create a action without the OnAction trigger
                end;
            }
        }
    }
    trigger OnNewRecord(xbelowrecord: Boolean)
    begin
        "Tax Type" := GetRangeMax("Tax Type");
    end;

    trigger OnOpenPage()
    begin
        FilterTaxType := CopyStr(GetFilter("Tax Type"), 1, 20);
    end;

    trigger OnAfterGetCurrRecord()
    begin
        FormatLine();
    end;

    trigger OnAfterGetRecord()
    begin
        FormatLine();
    end;

    local procedure FormatLine()
    var
        UseCaseExecution: Codeunit "Use Case Execution";
    begin
        if "Tax Table ID" <> 0 then
            TaxEntityName := AppObjectHelper.GetObjectName(ObjectType::Table, "Tax Table ID")
        else
            TaxEntityName := '';

        if not UseCaseExecution.IsLeafUseCase(ID) then
            DescriptionStyle := 'Strong'
        else
            DescriptionStyle := 'Standard';
    end;

    var
        AppObjectHelper: Codeunit "App Object Helper";
        FilterTaxType: Code[20];
        TaxEntityName: Text[30];
        DescriptionStyle: Text;
}