page 30054 "APIV2 - Default Dimensions"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Default Dimension';
    EntitySetCaption = 'Default Dimensions';
    EntityName = 'defaultDimension';
    EntitySetName = 'defaultDimensions';
    DelayedInsert = true;
    PageType = API;
    SourceTable = "Default Dimension";
    Extensible = false;
    ODataKeyFields = SystemId;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(parentType; "Parent Type")
                {
                    Caption = 'Parent Type';
                }
                field(parentId; ParentId)
                {
                    Caption = 'Parent Id';
                }
                field(dimensionId; DimensionId)
                {
                    Caption = 'Dimension Id';
                }
                field(dimensionCode; "Dimension Code")
                {
                    Caption = 'Dimension Code';
                    Editable = false;
                }
                field(dimensionValueId; DimensionValueId)
                {
                    Caption = 'Dimension Value Id';
                }
                field(dimensionValueCode; "Dimension Value Code")
                {
                    Caption = 'Dimension Value Code';
                    Editable = false;
                }
                field(postingValidation; "Value Posting")
                {
                    Caption = 'Posting Validation';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        ParentIdFilter: Text;
        ParentTypeFilter: Text;
    begin
        if "Parent Type" = "Parent Type"::" " then begin
            ParentTypeFilter := GetFilter("Parent Type");
            if ParentTypeFilter = '' then
                Error(ParentNotSpecifiedErr);
            Validate("Parent Type", GetParentTypeFromFilter(ParentTypeFilter));
        end;
        if IsNullGuid(ParentId) then begin
            ParentIdFilter := GetFilter(ParentId);
            if ParentIdFilter = '' then
                Error(ParentNotSpecifiedErr);
            Validate(ParentId, ParentIdFilter);
        end;
        exit(true);
    end;

    var
        ParentNotSpecifiedErr: Label 'You must get to the parent first to get to the default dimensions.';

    local procedure GetParentTypeFromFilter(ParentTypeFilter: Text): Enum "Default Dimension Parent Type"
    begin
        case ParentTypeFilter of
            'Customer':
                exit("Parent Type"::Customer);
            'Employee':
                exit("Parent Type"::Employee);
            'Item':
                exit("Parent Type"::Item);
            'Vendor':
                exit("Parent Type"::Vendor);
        end;
    end;
}