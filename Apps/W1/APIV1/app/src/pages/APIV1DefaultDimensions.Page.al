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
                field(parentId; ParentId)
                {
                    ApplicationArea = All;
                    Caption = 'parentId';
                    ToolTip = 'Specifies the parent id.';
                }
                field(dimensionId; DimensionId)
                {
                    ApplicationArea = All;
                    Caption = 'dimensionId';
                    ToolTip = 'Specifies the dimension id.';
                }
                field(dimensionCode; "Dimension Code")
                {
                    ApplicationArea = All;
                    Caption = 'dimensionCode';
                    ToolTip = 'Specifies the dimension code.';
                    Editable = false;
                }
                field(dimensionValueId; DimensionValueId)
                {
                    ApplicationArea = All;
                    Caption = 'dimensionValueId';
                    ToolTip = 'Specifies the dimension value id.';
                }
                field(dimensionValueCode; "Dimension Value Code")
                {
                    ApplicationArea = All;
                    Caption = 'dimensionValueCode';
                    ToolTip = 'Specifies the dimension value code.';
                    Editable = false;
                }
                field(postingValidation; "Value Posting")
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
            FilterView := GetView();
            ParentIdFilter := GetFilter(ParentId);
            if ParentIdFilter = '' then
                Error(MissingParentIdErr);
            ParentIdSpecifiedInGetRequest := true;
            SetView(FilterView);
        end;
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        FilterView: Text;
        ParentIdFilter: Text;
    begin
        if IsNullGuid(ParentId) then begin
            FilterView := GetView();
            ParentIdFilter := GetFilter(ParentId);
            Validate(ParentId, ParentIdFilter);
            SetView(FilterView);
        end;
        exit(true);
    end;

    trigger OnModifyRecord(): Boolean
    begin
        if xRec.DimensionId <> DimensionId then
            Error(CannotModifyKeyFieldErr, 'dimensionId');
        if xRec.ParentId <> ParentId then
            Error(CannotModifyKeyFieldErr, 'parentId');
    end;

    var
        MissingParentIdErr: Label 'You must specify a parentId in order to get the default dimensions.', Locked = true;
        CannotModifyKeyFieldErr: Label 'You cannot change the value of the key field %1.', Locked = true;
        ParentIdSpecifiedInGetRequest: Boolean;
}

