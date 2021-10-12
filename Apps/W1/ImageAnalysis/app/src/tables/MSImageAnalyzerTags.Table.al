// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

table 2028 "MS - Image Analyzer Tags"
{
    ReplicateData = false;

    fields
    {
        field(1; "Detected On Item No"; Code[20])
        {
        }

        field(2; "Tag Confidence"; Decimal)
        {
            Caption = 'Confidence Score (%)';
        }

        field(3; "Tag Name"; Text[250])
        {
            Caption = 'Detected Attribute Name';
        }

        field(4; "Item Category Code"; Code[20])
        {
        }

        field(5; "Newly Created Item Category Code"; boolean)
        {
        }

        field(6; "Item Attribute Value Id"; Integer)
        {
        }

        field(7; "Action To Perform"; Option)
        {
            Caption = 'Action to Perform';
            OptionMembers = " ",Category,Attribute,Blacklist;
            OptionCaption = 'Ignore,Use as category,Use as attribute,Add to blocklist';

            trigger OnValidate()
            begin
                OnValidateAction();
            end;
        }

        field(8; "Details Text"; Text[250])
        {
            Caption = 'Details';
        }

        field(9; "Item Attribute Name Id"; Integer)
        {

        }
        field(10; "Item Attribute Name"; Text[250])
        {

        }

        field(11; "Item Attribute Value Name"; Text[250])
        {

        }
    }

    keys
    {
        key(PK; "Detected On Item No", "Tag Name")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Tag Name")
        {
        }
    }

    var
        ItemAttrPopulate: Codeunit "Item Attr Populate";
        ChooseItemAttributeTxt: Label 'Choose item attribute';
        SetOnlyOneTagAsItemCategoryErr: Label 'You can choose only one attribute as the item category.';
        DetailsTextForItemAttributeTxt: Label 'Item attribute: ''%1'' = ''%2''', Comment = '%1 is the item attribute name (ex ''Color''), %2 is the item attribute value (ex ''Blue'')';
        DetailsTextForItemCategoryTxt: Label 'Category: ''%1''', Comment = '%1 is the item attribute category code (ex ''FURNITURE'')';
        AttributeAlreadyAssignedErr: Label 'Attribute ''%1'' is already set.', Comment = '%1 is the attribute name (ex ''Color'')';

    local procedure OnValidateAction()
    var
        ItemCategory: Record "Item Category";
        ItemAttributeValue: Record "Item Attribute Value";
        ItemCategoryManagement: Codeunit "Item Category Management";
        ItemAttributeManagement: Codeunit "Item Attribute Management";
        ShortCategoryCode: Code[20];
    begin
        ClearLine();
        case "Action To Perform" of
            "Action To Perform"::Category:
                begin
                    if IsCategoryActionAlreadyChosen() then
                        Error(SetOnlyOneTagAsItemCategoryErr);

                    ShortCategoryCode := CopyStr("Tag Name", 1, MaxStrLen(ShortCategoryCode));
                    if not ItemCategoryManagement.DoesValueExistInItemCategories(ShortCategoryCode, ItemCategory) then begin
                        CreateItemCategory(ItemCategory, ShortCategoryCode);
                        "Newly Created Item Category Code" := true;
                    end;
                    "Item Category Code" := ItemCategory.Code;
                    UpdateValueText();
                end;

            "Action To Perform"::Attribute:
                begin
                    if ItemAttributeManagement.DoesValueExistInItemAttributeValues("Tag Name", ItemAttributeValue) then
                        if not IsAttributeAlreadyAssigned(ItemAttributeValue."Attribute ID") then
                            SetAttributeValue(ItemAttributeValue)
                        else
                            SelectItemAttribute()
                    else
                        SelectItemAttribute();
                    UpdateValueText();
                end;
        end; //case
        Modify();
        Commit();
    end;

    procedure SetAttributeValue(ItemAttributeValue: Record "Item Attribute Value")
    begin
        ItemAttributeValue.CalcFields("Attribute Name");
        "Item Attribute Value Id" := ItemAttributeValue.ID;
        "Item Attribute Value Name" := ItemAttributeValue.Value;
        "Item Attribute Name Id" := ItemAttributeValue."Attribute ID";
        "Item Attribute Name" := ItemAttributeValue."Attribute Name";
    end;

    procedure IsAttributeAlreadyAssigned(ItemAttributeId: Integer): Boolean
    var
        ImageAnalysisTags: Record "MS - Image Analyzer Tags";
    begin
        ImageAnalysisTags.Reset();
        ImageAnalysisTags.SetRange("Action To Perform", "Action To Perform"::Attribute);
        ImageAnalysisTags.SetRange("Item Attribute Name Id", ItemAttributeId);
        exit(not ImageAnalysisTags.IsEmpty());
    end;

    local procedure IsCategoryActionAlreadyChosen(): Boolean
    var
        ImageAnalysisTags: Record "MS - Image Analyzer Tags";
    begin
        ImageAnalysisTags.SetRange("Action To Perform", "Action To Perform"::Category);
        exit(not ImageAnalysisTags.IsEmpty());
    end;

    local procedure CreateItemCategory(var ItemCategory: Record "Item Category"; ShortCategoryCode: Code[20])
    begin
        ItemCategory.Reset();
        ItemCategory.Init();
        ItemCategory.Code := ShortCategoryCode;
        ItemCategory.Description := CopyStr("Tag Name", 1, MaxStrLen(ItemCategory.Description));
        ItemCategory.Insert();
    end;

    local procedure CreateItemAttributeValueIfNeeded(ItemAttribute: Record "Item attribute"; var ItemAttributeValue: Record "Item Attribute Value")
    begin
        ItemAttributeValue.SetFilter("Attribute ID", FORMAT(ItemAttribute.ID));
        ItemAttributeValue.SetFilter(Value, CopyStr("Tag Name", 1, MaxStrLen(ItemAttributeValue.Value)));
        if ItemAttributeValue.FindFirst() then
            exit;

        ItemAttributeValue.Reset();
        ItemAttributeValue.Init();
        ItemAttributeValue."Attribute ID" := ItemAttribute.ID;
        ItemAttributeValue.Value := CopyStr("Tag Name", 1, MaxStrLen(ItemAttributeValue.Value));
        ItemAttributeValue.Insert();
    end;

    procedure SelectItemAttribute()
    var
        ItemAttribute: Record "Item Attribute";
        ItemAttributeValue: Record "Item Attribute Value";
        ItemAttributes: Page "Item Attributes";
    begin
        ItemAttribute.Reset();
        ItemAttribute.SetFilter(Type, '%1|%2', ItemAttribute.Type::Option, ItemAttribute.Type::Text);
        ItemAttributes.SetTableView(ItemAttribute);
        ItemAttributes.LookupMode(true);
        if ItemAttributes.RunModal() = ACTION::LookupOK then begin
            ItemAttributes.GetRecord(ItemAttribute);

            if not IsAttributeAlreadyAssigned(ItemAttribute.ID) then begin
                "Item Attribute Name" := ItemAttribute.Name;
                "Item Attribute Name Id" := ItemAttribute.ID;

                CreateItemAttributeValueIfNeeded(ItemAttribute, ItemAttributeValue);
                "Item Attribute Value Id" := ItemAttributeValue.id;
                "Item Attribute Value Name" := ItemAttributeValue.Value;
            end else
                Error(StrSubstNo(AttributeAlreadyAssignedErr, ItemAttribute.Name));
        end;
    end;

    procedure UpdateValueText()
    begin
        case "Action To Perform" of
            "Action To Perform"::Category:
                "Details Text" := CopyStr(StrSubstNo(DetailsTextForItemCategoryTxt, "Item Category Code"), 1, MaxStrLen("Details Text"));

            "Action To Perform"::Attribute:
                if "Item Attribute Value Id" = 0 then
                    "Details Text" := ChooseItemAttributeTxt
                else
                    "Details Text" := CopyStr(StrSubstNo(DetailsTextForItemAttributeTxt, "Item Attribute Name", "Item Attribute Value Name"), 1, MaxStrLen("Details Text"));
        end;
    end;

    procedure ApplyChanges(ItemDescription: Text[100])
    var
        ImageAnalysisTags: Record "MS - Image Analyzer Tags";
    begin
        ImageAnalysisTags.Reset();
        ImageAnalysisTags.FindSet();

        repeat
            case ImageAnalysisTags."Action To Perform" of
                ImageAnalysisTags."Action To Perform"::Attribute:
                    ApplyAttributeToItem(ImageAnalysisTags);

                ImageAnalysisTags."Action To Perform"::Category:
                    ApplyCategoryToItem(ImageAnalysisTags);

                ImageAnalysisTags."Action To Perform"::Blacklist:
                    ApplyBlacklistTag(ImageAnalysisTags."Tag Name");
            end;
        until ImageAnalysisTags.Next() = 0;

        if ItemDescription <> '' then
            ApplyItemDescriptionToItem(ItemDescription);
    end;

    local procedure ApplyBlacklistTag(TagName: Text[250])
    var
        ImageAnalysisTagBlacklist: Record "MS - Img. Analyzer Blacklist";
    begin
        ImageAnalysisTagBlacklist.Init();
        ImageAnalysisTagBlacklist.TagName := TagName;
        ImageAnalysisTagBlacklist.Insert();
    end;

    local procedure ApplyAttributeToItem(ImageAnalysisTags: Record "MS - Image Analyzer Tags")
    var
        ItemAttributeValueMapping: Record "Item Attribute Value Mapping";
    begin
        if ItemAttributeValueMapping.Get(DATABASE::Item, ImageAnalysisTags."Detected On Item No", ImageAnalysisTags."Item Attribute Name Id") then begin
            ItemAttributeValueMapping."Item Attribute Value ID" := ImageAnalysisTags."Item Attribute Value Id";
            ItemAttributeValueMapping.Modify();
        end else begin
            ItemAttributeValueMapping.Init();
            ItemAttributeValueMapping."Table ID" := DATABASE::Item;
            ItemAttributeValueMapping."No." := ImageAnalysisTags."Detected On Item No";
            ItemAttributeValueMapping."Item Attribute ID" := ImageAnalysisTags."Item Attribute Name Id";
            ItemAttributeValueMapping."Item Attribute Value ID" := ImageAnalysisTags."Item Attribute Value Id";
            ItemAttributeValueMapping.Insert();
        end;
    end;

    local procedure ApplyCategoryToItem(ImageAnalysisTags: Record "MS - Image Analyzer Tags")
    var
        Item: Record Item;
    begin
        Item.Get(ImageAnalysisTags."Detected On Item No");
        ItemAttrPopulate.SetItemCategory(Item, ImageAnalysisTags."Item Category Code");
    end;

    local procedure ApplyItemDescriptionToItem(DescriptionText: Text[100])
    var
        ImageAnalysisTags: Record "MS - Image Analyzer Tags";
        Item: Record Item;
    begin
        //if we are here, we had some tags to analyze
        ImageAnalysisTags.FindFirst();

        Item.Get(ImageAnalysisTags."Detected On Item No");

        Item.Validate(Description, DescriptionText);
        Item.Modify();
    end;

    local procedure ClearLine()
    begin
        if "Newly Created Item Category Code" then
            UndoCategoryCreation("Item Category Code");

        Clear("Details Text");
        Clear("Item Category Code");
        Clear("Item Attribute Value Id");
        Clear("Item Attribute Name Id");
        Clear("Item Attribute Name");
        Clear("Item Attribute Value Name");
        Clear("Newly Created Item Category Code");
    end;

    local procedure UndoCategoryCreation(ItemCategoryCode: Code[20])
    var
        ItemCategory: Record "Item Category";
    begin
        if ItemCategory.Get(ItemCategoryCode) then
            ItemCategory.Delete();
    end;
}