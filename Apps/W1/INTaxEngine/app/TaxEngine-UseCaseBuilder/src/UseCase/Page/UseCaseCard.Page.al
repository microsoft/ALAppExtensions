page 20308 "Use Case Card"
{
    PageType = Card;
    SourceTable = "Tax Use Case";
    DataCaptionExpression = Description;
    RefreshOnActivate = true;
    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                Caption = 'General';
                field(Description; Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description of the tax use case.';
                    MultiLine = true;
                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Tax Entity Name"; TaxEntityName)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Tax Entity Name';
                    ToolTip = 'Specifies the source table considered for computing tax components.';
                    trigger OnValidate()
                    begin
                        TaxTypeObjectHelper.SearchTaxTypeTable("Tax Table ID", TaxEntityName, "Tax Type", true);
                        CurrPage.SaveRecord();
                        FormatLine();
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        TaxTypeObjectHelper.OpenTaxTypeTransactionTableLookup("Tax Table ID", TaxEntityName, Text, "Tax Type");
                        CurrPage.SaveRecord();
                        FormatLine();
                    end;
                }
                field(Condition; StrSubstNo(ConditionLbl, ConditionText))
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the condition to execute the use case.';
                    ShowCaption = false;
                    Caption = 'Condition';
                    Editable = false;
                    StyleExpr = true;
                    Style = Subordinate;
                    trigger OnDrillDown()
                    begin
                        if IsNullGuid(ID) then begin
                            Init();
                            Insert(true);
                            Commit();
                            CurrPage.Update(false);
                        end;

                        if IsNullGuid("Condition ID") then
                            "Condition ID" := ScriptEntityMgmt.CreateCondition(ID, EmptyGuid);
                        Commit();
                        ConditionMgmt.OpenConditionsDialog(ID, EmptyGuid, "Condition ID");

                        Validate("Condition ID");
                        CurrPage.Update(true);
                    end;
                }
                field(Status; Status)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the effective date of the use case.';
                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field(Enable; Enable)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if tax use case is enabled for usage.';
                }
            }
            group(VersionControl)
            {
                Caption = 'Version';
                field(Version; VersionTxt)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the version of the use case.';
                }
                field("Effective From"; "Effective From")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the effective date of the use case.';
                }
                field("Changed By"; "Changed By")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the changed by of the use case.';
                }
            }
            part(OpenTaxAttributesMapping; "Use Case Attribute Mapping")
            {
                Caption = 'Map Attributes';
                ApplicationArea = Basic, Suite;
                SubPageLink = "Tax Type" = field("Tax Type"), "Case ID" = field(ID);
                Enabled = Description <> '';
            }
            part(OpenRateColumnMapping; "Use Case Rate Column Relation")
            {
                Caption = 'Map Column Values To Find Tax Rates';
                ApplicationArea = Basic, Suite;
                SubPageLink = "Case ID" = field(ID);
                Enabled = Description <> '';
            }
            part(OpenComponentCalculation; "Component Calculation Dialog")
            {
                Caption = 'Component Formula';
                ApplicationArea = Basic, Suite;
                SubPageLink = "Case ID" = field(ID);
                Enabled = Description <> '';
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ComputationScript)
            {
                Caption = 'Computation Script';
                ToolTip = 'Specifies the Script for Computing variables, adding validations based on the tax use case.';
                ApplicationArea = Basic, Suite;
                Image = PostDocument;
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    ScriptContext: Record "Script Context";
                begin
                    ScriptContext.FilterGroup(4);
                    ScriptContext.SetRange("Case ID", Rec.ID);
                    ScriptContext.SetRange(ID, Rec."Computation Script ID");
                    ScriptContext.FilterGroup(0);
                    Page.Run(Page::"Script Context", ScriptContext);
                end;
            }
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
                    UseCase.SetRange(ID, Rec.ID);
                    UseCaseMgmt.OnAfterExportUseCases(UseCase);
                end;
            }
            action(CopyUseCase)
            {
                Caption = 'Copy Use Case';
                ToolTip = 'Creates a copy of the use case.';
                ApplicationArea = Basic, Suite;
                Image = ImportCodes;
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction();
                var
                    i: Integer;
                begin
                    i := 0;
                    //blank OnAction created as we have a subscriber of this action in Use Case Archival mgmt codeunit 
                    //and ruleset doesn't allow  to create a action without the OnAction trigger
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
                    //blank OnAction created as we have a subscriber of this action in Use Case Archival mgmt codeunit 
                    //and ruleset doesn't allow  to create a action without the OnAction trigger
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        ShowTaxAttributePart := not IsNullGuid("Parent Use Case ID");
        FormatLine();
        UpdateVersion();
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        if GetRangeMax("Tax Type") <> '' then
            "Tax Type" := GetRangeMax("Tax Type");
    end;

    trigger OnAfterGetRecord()
    begin
        FormatLine();
        UpdateVersion();
    end;

    local procedure FormatLine()
    begin
        if not IsNullGuid("Condition ID") then
            ConditionText := ScriptSerialization.ConditionToString(ID, EmptyGuid, "Condition ID")
        else
            ConditionText := '<Always>';

        if "Tax Type" = '' then
            "Tax Type" := GetRangeMax("Tax Type");

        if "Tax Table ID" <> 0 then
            TaxEntityName := AppObjectHelper.GetObjectName(ObjectType::Table, "Tax Table ID")
        else
            TaxEntityName := '';
    end;

    local procedure UpdateVersion()
    begin
        if IsNullGuid("ID") then
            VersionTxt := ''
        else
            VersionTxt := StrSubstNo(VersionLbl, "Major Version", "Minor Version");
    end;

    var
        AppObjectHelper: Codeunit "App Object Helper";
        TaxTypeObjectHelper: Codeunit "Tax Type Object Helper";
        ScriptSerialization: Codeunit "Script Serialization";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        ConditionMgmt: Codeunit "Condition Mgmt.";
        EmptyGuid: Guid;
        ShowTaxAttributePart: Boolean;
        ConditionText: Text;
        TaxEntityName: Text[30];
        VersionTxt: Text;
        ConditionLbl: Label 'Condition : %1', Comment = '%1 = condtion as text';
        VersionLbl: Label '%1.%2', Comment = '%1 - Major Version, %2 - Minor Version';
}