page 20334 "Tax Insert Record Dialog"
{
    Caption = 'Insert Record';
    PageType = StandardDialog;
    DataCaptionExpression = IntoTableName;
    PopulateAllFields = true;
    SourceTable = "Tax Insert Record";
    layout
    {
        area(Content)
        {
            group("Source")
            {
                field(InsertIntoTableName; IntoTableName)
                {
                    Caption = 'Table Name';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the table name for Insert Record.';
                    trigger OnValidate();
                    begin
                        AppObjectHelper.SearchObject(ObjectType::Table, Rec."Table ID", IntoTableName)
                    end;

                    trigger OnLookup(var Text: Text): Boolean;
                    begin
                        AppObjectHelper.OpenObjectLookup(ObjectType::Table, Text, Rec."Table ID", IntoTableName);
                    end;
                }

                field("Run Trigger"; Rec."Run Trigger")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether Insert trigger code will run for table.';
                }
                field("Sub Ledger Group By"; Rec."Sub Ledger Group By")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the grouping of tax Ledger.';
                }
            }

            part("Insert Record Subform"; "Tax Insert Record Subform")
            {
                Caption = 'Field Mappings';
                ApplicationArea = Basic, Suite;
                SubPageView = SORTING("Sequence No.", "Field ID");
                SubPageLink = "Case ID" = Field("Case ID"), "Script ID" = Field("Script ID"), "Insert Record ID" = Field(ID), "Table ID" = Field("Table ID");
                ShowFilter = false;
            }
        }
    }

    var
        InsertRecord: Record "Tax Insert Record";
        AppObjectHelper: Codeunit "App Object Helper";
        ScriptSymbolsMgmt: Codeunit "Script Symbols Mgmt.";
        IntoTableName: Text[30];

    procedure SetCurrentRecord(var InsertRecord2: Record "Tax Insert Record");
    begin
        InsertRecord := InsertRecord2;

        TestRecord();

        Rec.FilterGroup := 2;
        Rec.SetRange("Case ID", InsertRecord."Case ID");
        Rec.SetRange("Script ID", InsertRecord."Script ID");
        Rec.SetRange(ID, InsertRecord.ID);
        Rec.FilterGroup := 0;

        ScriptSymbolsMgmt.SetContext(InsertRecord."Case ID", InsertRecord."Script ID");
    end;

    local procedure TestRecord();
    begin
        InsertRecord.TestField("Case ID");
        InsertRecord.TestField("Script ID");
        InsertRecord.TestField(ID);
    end;

    local procedure FormatLine();
    begin
        IntoTableName := AppObjectHelper.GetObjectName(ObjectType::Table, Rec."Table ID");
    end;

    trigger OnOpenPage();
    begin
        TestRecord();
    end;

    trigger OnAfterGetRecord();
    begin
        FormatLine();
    end;

    trigger OnAfterGetCurrRecord();
    begin
        FormatLine();
    end;
}