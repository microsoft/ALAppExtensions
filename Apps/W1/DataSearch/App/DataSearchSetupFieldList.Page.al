namespace Microsoft.Foundation.DataSearch;

using System.Reflection;
using System.Utilities;

page 2684 "Data Search Setup (Field) List"
{
    Caption = 'Enable fields for searching';
    DataCaptionExpression = SelectedPageCaption;
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = true;
    PageType = List;
    SourceTable = "Field";
    InherentEntitlements = X;
    InherentPermissions = X;

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
                    Caption = 'Field No.';
                    Editable = false;
                    Lookup = false;
                    ToolTip = 'Specifies the number of the field.';
                }
                field("Field Caption"; Rec."Field Caption")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Field Name';
                    DrillDown = false;
                    Editable = false;
                    ToolTip = 'Specifies the caption of the field, that is, the name that will be shown in the user interface.';

                    trigger OnAssistEdit()
                    begin
                        SearchSetupField."Enable Search" := not SearchSetupField."Enable Search";
                        UpdateRec();
                    end;
                }
                field(FieldType; Rec."Type Name")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Field Type';
                    DrillDown = false;
                    Editable = false;
                    Visible = false;
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
                field(TableCaption; GetTableCaption(Rec.TableNo))
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Table Name';
                    DrillDown = false;
                    Enabled = false;
                    Visible = ShowMultipleTables;
                    Style = Subordinate;
                    ToolTip = 'Specifies the caption of the field, that is, the name that will be shown in the user interface.';
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
        area(Promoted)
        {
            actionref(ClearSetup_Promoted; ClearSetup)
            {
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        GetRec();
        if SelectedPageCaption = '' then
            SelectedPageCaption := Format(Rec.TableNo) + ' ' + GetTableCaption(Rec.TableNo);
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
        ShowMultipleTables := StrPos(Rec.GetFilter(TableNo), '|') > 0;
        Rec.SetRange(Class, Rec.Class::Normal);
        Rec.setrange(ObsoleteState, Rec.ObsoleteState::No);
        Rec.setfilter(Type, '%1|%2', Rec.Type::Code, Rec.Type::Text);
        Rec.FilterGroup(0);
        if Rec.FindFirst() then;
        if SelectedPageCaption = '' then
            SelectedPageCaption := Format(Rec.TableNo) + ' ' + GetTableCaption(Rec.TableNo);
        if DataSearchSetupTable.Get(Rec.TableNo) then
            InitDefaultSetup();
    end;

    var
        SearchSetupField: Record "Data Search Setup (Field)";
        SelectedPageCaption: Text;
        PrevTableCaption: Text;
        PrevTableNo: Integer;
        ShowMultipleTables: Boolean;
        ResetQst: Label 'Do you want to remove the current setup and insert the default?';

    local procedure InitDefaultSetup()
    var
        IntegerRec: Record Integer;
        DataSearchDefaults: codeunit "Data Search Defaults";
    begin
        if ShowMultipleTables then begin
            Rec.FilterGroup(2);
            Rec.CopyFilter(TableNo, IntegerRec.Number);
            Rec.FilterGroup(0);
            if IntegerRec.GetFilter(Number) = '' then
                exit; // emergency brake to avoid 'infinite' loop
            if IntegerRec.FindSet() then
                repeat
                    DataSearchDefaults.AddDefaultFields(IntegerRec.Number);
                until IntegerRec.Next() = 0;
        end else
            DataSearchDefaults.AddDefaultFields(Rec.TableNo);
    end;

    internal procedure SetPageCaption(NewCaption: Text)
    begin
        SelectedPageCaption := NewCaption;
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

    local procedure GetTableCaption(TableNo: Integer): Text
    var
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        if TableNo = PrevTableNo then
            exit(PrevTableCaption);
        PrevTableNo := TableNo;
        PrevTableCaption := '';
        if TableNo <> 0 then
            if AllObjWithCaption.Get(AllObjWithCaption."Object Type"::Table, TableNo) then
                PrevTableCaption := AllObjWithCaption."Object Caption";
        exit(PrevTableCaption);
    end;
}

