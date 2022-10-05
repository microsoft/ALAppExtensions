page 2684 "Data Search Setup (Field) List"
{
    Caption = 'Search Setup (Field) List';
    DataCaptionExpression = PageCaption;
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "Field";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'No.';
                    Editable = false;
                    Lookup = false;
                    ToolTip = 'Specifies the number of the field.';
                }
                field("Field Caption"; Rec."Field Caption")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Field Caption';
                    DrillDown = false;
                    Editable = false;
                    ToolTip = 'Specifies the caption of the field, that is, the name that will be shown in the user interface.';
                }
                field(FieldType; Rec."Type Name")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Field Type';
                    DrillDown = false;
                    Editable = false;
                    ToolTip = 'Specifies the type of the field.';
                }
                field("Enable Search"; SearchSetupField."Enable Search")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Enable search';
                    ToolTip = 'Specifies whether search is enabled for this field.';

                    trigger OnValidate()
                    begin
                        UpdateRec();
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ClearSetup)
            {
                ApplicationArea = All;
                Caption = 'Reset to default';
                ToolTip = 'Removes the field selection for this table and inserts the default.';
                Image = Restore;

                trigger OnAction()
                begin
                    if Confirm(ResetQst, false) then
                        InitDefaultSetup();
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        GetRec();
        PageCaption := Format(Rec.TableNo) + ' ' + Rec.TableName;
    end;

    trigger OnAfterGetRecord()
    begin
        GetRec();
    end;

    trigger OnOpenPage()
    var
        DataSearchSetupTable: Record "Data Search Setup (Table)";
    begin
        Rec.FilterGroup(2);
        Rec.SetRange(Class, Rec.Class::Normal);
        Rec.setrange(ObsoleteState, Rec.ObsoleteState::No);
        Rec.setfilter(Type, '%1|%2', Rec.Type::Code, Rec.Type::Text);
        Rec.FilterGroup(0);
        PageCaption := Format(Rec.TableNo) + ' ' + Rec.TableName;
        if DataSearchSetupTable.Get(Rec.TableNo) then
            InitDefaultSetup();
    end;

    var
        SearchSetupField: Record "Data Search Setup (Field)";
        PageCaption: Text[250];
        ResetQst: Label 'Do you want to remove the current setup and insert the default?';

    local procedure InitDefaultSetup()
    var
        DataSearchDefaults: codeunit "Data Search Defaults";
    begin
        DataSearchDefaults.AddTextFields(Rec.TableNo);
        DataSearchDefaults.AddIndexedFields(Rec.TableNo);
    end;

    local procedure UpdateRec()
    begin
        if not SearchSetupField."Enable Search" then begin
            if SearchSetupField.Delete() then;
        end else
            if not SearchSetupField.Modify() then
                SearchSetupField.Insert();
    end;

    local procedure GetRec()
    begin
        if not SearchSetupField.Get(Rec.TableNo, Rec."No.") then begin
            SearchSetupField.Init();
            SearchSetupField."Table No." := Rec.TableNo;
            SearchSetupField."Field No." := Rec."No.";
        end;
    end;
}

