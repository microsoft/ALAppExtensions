namespace Microsoft.API.V2;

using Microsoft.Finance.Dimension;

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
    AboutText = 'Manages default dimension assignments for master records such as customers, vendors, items, and projects, enabling retrieval, creation, update, and deletion of dimension values and posting requirements. Supports automation and synchronization of financial categorization, ensuring consistent analytical tagging for accurate reporting and integration with external financial, ERP, or analytics systems.';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(parentType; Rec."Parent Type")
                {
                    Caption = 'Parent Type';
                }
                field(parentId; Rec.ParentId)
                {
                    Caption = 'Parent Id';
                }
                field(dimensionId; Rec.DimensionId)
                {
                    Caption = 'Dimension Id';
                }
                field(dimensionCode; Rec."Dimension Code")
                {
                    Caption = 'Dimension Code';
                    Editable = false;
                }
                field(dimensionValueId; Rec.DimensionValueId)
                {
                    Caption = 'Dimension Value Id';
                }
                field(dimensionValueCode; Rec."Dimension Value Code")
                {
                    Caption = 'Dimension Value Code';
                    Editable = false;
                }
                field(postingValidation; Rec."Value Posting")
                {
                    Caption = 'Posting Validation';
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date';
                    Editable = false;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        DefaultDimensionParentType: Enum "Default Dimension Parent Type";
        ParentIdFilter: Text;
        ParentTypeFilter: Text;
    begin
        if Rec."Parent Type" = Rec."Parent Type"::" " then begin
            ParentTypeFilter := Rec.GetFilter("Parent Type");
            if ParentTypeFilter = '' then
                Error(ParentNotSpecifiedErr);
            Evaluate(DefaultDimensionParentType, ParentTypeFilter);
            Rec.Validate("Parent Type", DefaultDimensionParentType);
        end;
        if IsNullGuid(Rec.ParentId) then begin
            ParentIdFilter := Rec.GetFilter(ParentId);
            if ParentIdFilter = '' then
                Error(ParentNotSpecifiedErr);
            Rec.Validate(ParentId, ParentIdFilter);
        end;
        exit(true);
    end;

    var
        ParentNotSpecifiedErr: Label 'You must get to the parent first to get to the default dimensions.';
}