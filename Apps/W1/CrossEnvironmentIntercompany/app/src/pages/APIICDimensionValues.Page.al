namespace Microsoft.Intercompany.CrossEnvironment;

using Microsoft.Intercompany.Dimension;

page 30403 "API - IC Dimension Values"
{
    PageType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'intercompany';
    APIVersion = 'v1.0';
    EntityName = 'intercompanyDimensionValue';
    EntitySetName = 'intercompanyDimensionValues';
    EntityCaption = 'Intercompany Dimension Value';
    EntitySetCaption = 'Intercompany Dimension Values';
    SourceTable = "IC Dimension Value";
    DelayedInsert = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    ODataKeyFields = SystemId;
    Extensible = false;
    Editable = false;
    DataAccessIntent = ReadOnly;

    layout
    {
        area(Content)
        {
            repeater(Records)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                }
                field(dimensionCode; Rec."Dimension Code")
                {
                    Caption = 'Dimension Code';
                }
                field(code; Rec.Code)
                {
                    Caption = 'Code';
                }
                field(name; Rec.Name)
                {
                    Caption = 'Name';
                }
                field(dimensionValueType; Rec."Dimension Value Type")
                {
                    Caption = 'Dimension Value Type';
                }
                field(dimensionValueTypeIndex; DimensionValueTypeIndex)
                {
                    Caption = 'Dimension Value Type Index';
                }
                field(blocked; Rec.Blocked)
                {
                    Caption = 'Blocked';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        DimensionValueTypeIndex := Rec."Dimension Value Type";
    end;

    var
        DimensionValueTypeIndex: Integer;
}