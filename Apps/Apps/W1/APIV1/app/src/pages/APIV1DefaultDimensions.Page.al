namespace Microsoft.API.V1;

using Microsoft.Finance.Dimension;

page 20056 "APIV1 - Default Dimensions"
{
    Caption = 'defaultDimension', Locked = true;
    DelayedInsert = true;
    ODataKeyFields = ParentId, DimensionId;
    PageType = ListPart;
    SourceTable = "Default Dimension";
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(parentId; Rec.ParentId)
                {
                    ApplicationArea = All;
                    Caption = 'parentId';
                    ToolTip = 'Specifies the parent id.';
                }
                field(dimensionId; Rec.DimensionId)
                {
                    ApplicationArea = All;
                    Caption = 'dimensionId';
                    ToolTip = 'Specifies the dimension id.';
                }
                field(dimensionCode; Rec."Dimension Code")
                {
                    ApplicationArea = All;
                    Caption = 'dimensionCode';
                    ToolTip = 'Specifies the dimension code.';
                    Editable = false;
                }
                field(dimensionValueId; Rec.DimensionValueId)
                {
                    ApplicationArea = All;
                    Caption = 'dimensionValueId';
                    ToolTip = 'Specifies the dimension value id.';
                }
                field(dimensionValueCode; Rec."Dimension Value Code")
                {
                    ApplicationArea = All;
                    Caption = 'dimensionValueCode';
                    ToolTip = 'Specifies the dimension value code.';
                    Editable = false;
                }
                field(postingValidation; Rec."Value Posting")
                {
                    ApplicationArea = All;
                    Caption = 'postingValidation';
                    ToolTip = 'Specifies the posting validation.';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    var
        ParentIdFilter: Text;
        FilterView: Text;
    begin
        if not ParentIdSpecifiedInGetRequest then begin
            FilterView := Rec.GetView();
            ParentIdFilter := Rec.GetFilter(ParentId);
            if ParentIdFilter = '' then
                Error(MissingParentIdErr);
            ParentIdSpecifiedInGetRequest := true;
            Rec.SetView(FilterView);
        end;
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        FilterView: Text;
        ParentIdFilter: Text;
    begin
        if IsNullGuid(Rec.ParentId) then begin
            FilterView := Rec.GetView();
            ParentIdFilter := Rec.GetFilter(ParentId);
            Rec.Validate(ParentId, ParentIdFilter);
            Rec.SetView(FilterView);
        end;
        exit(true);
    end;

    trigger OnModifyRecord(): Boolean
    begin
        if xRec.DimensionId <> Rec.DimensionId then
            Error(CannotModifyKeyFieldErr, 'dimensionId');
        if xRec.ParentId <> Rec.ParentId then
            Error(CannotModifyKeyFieldErr, 'parentId');
    end;

    var
        MissingParentIdErr: Label 'You must specify a parentId in order to get the default dimensions.', Locked = true;
        CannotModifyKeyFieldErr: Label 'You cannot change the value of the key field %1.', Locked = true;
        ParentIdSpecifiedInGetRequest: Boolean;
}


