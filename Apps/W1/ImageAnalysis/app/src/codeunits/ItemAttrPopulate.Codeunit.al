// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

codeunit 2026 "Item Attr Populate"
{
    var
        ImageAnalyzerExtMgt: Codeunit "Image Analyzer Ext. Mgt.";
        NoAttributesIdentifiedTxt: Label 'Sorry, we didn''t spot any attributes in the image. This happens occasionally. For example, sometimes we need more contrast between the item and the background. If you want, try another image.';

    [EventSubscriber(ObjectType::Page, Page::"Item Picture", 'OnAfterActionEvent', 'ImportPicture', false, false)]
    procedure OnAfterImportPictureAnalyzePicture(var Rec: Record Item)
    begin
        AnalyzePicture(Rec);
    end;

    procedure AnalyzePicture(var ItemRec: Record Item): Boolean
    var
        MSImageAnalyzerTags: Record "MS - Image Analyzer Tags";
        ImageAnalysisResult: Codeunit "Image Analysis Result";
        ImageAnalyzerTagsPage: Page "Image Analysis Tags";
        ConfidenceThresholdPercent: Decimal;
        AnalysisType: Option Tags,Faces,Color;
    begin
        if ItemRec.Picture.Count() = 0 then
            exit(false);

        if not ImageAnalyzerExtMgt.AnalyzePicture(ItemRec.Picture.Item(ItemRec.Picture.Count()), ImageAnalysisResult, AnalysisType::Tags) then
            exit(false);

        BuildTagListPrepopulateCategoryAndAttributes(ItemRec, ImageAnalysisResult, MSImageAnalyzerTags, ConfidenceThresholdPercent);
        Commit(); // to make sure runmodal does not fail below

        // open page
        MSImageAnalyzerTags.Reset();
        if MSImageAnalyzerTags.IsEmpty() then begin
            Message(NoAttributesIdentifiedTxt);
            exit(true);
        end;

        ImageAnalyzerTagsPage.SetRecord(MSImageAnalyzerTags);
        ImageAnalyzerTagsPage.SetConfidencePercent(ConfidenceThresholdPercent);
        ImageAnalyzerTagsPage.LookupMode(true);
        if ImageAnalyzerTagsPage.RunModal() = "Action"::LookupOK then begin
            MSImageAnalyzerTags.Reset();
            MSImageAnalyzerTags.FindSet();
            MSImageAnalyzerTags.ApplyChanges(ImageAnalyzerTagsPage.GetItemDescription());
        end;

        // clear analysis results
        MSImageAnalyzerTags.Reset();
        MSImageAnalyzerTags.DeleteAll();
        exit(true);
    end;

    procedure BuildTagListPrepopulateCategoryAndAttributes(Item: Record Item; ImageAnalysisResult: Codeunit "Image Analysis Result"; var ImageAnalysisTags: Record "MS - Image Analyzer Tags"; var ConfidenceThresholdPercent: Decimal)
    var
        ImageAnalysisSetup: Record "Image Analysis Setup";
        ItemCategory: Record "Item Category";
        ItemAttributeValue: Record "Item Attribute Value";
        BestItemCategory: Record "Item Category";
        ImageAnalysisTagBlacklist: Record "MS - Img. Analyzer Blacklist";
        BestItemCategoryConfidence: Decimal;
        TagNb: Integer;
        FoundItemCategoryToPopulate: Boolean;
        CurrentTagName: Text;
        CurrentTagConfidencePercent: Decimal;
    begin
        // clear previous analysis results
        ImageAnalysisTags.Reset();
        ImageAnalysisTags.DeleteAll();

        if not ImageAnalysisSetup.Get() then
            exit;
        if not ImageAnalysisSetup."Image-Based Attribute Recognition Enabled" then
            exit;
        if ImageAnalysisResult.TagCount() = 0 then
            exit;

        ConfidenceThresholdPercent := ImageAnalysisSetup."Confidence Threshold";
        FoundItemCategoryToPopulate := false;

        for TagNb := 1 to ImageAnalysisResult.TagCount() do begin
            CurrentTagName := PrettifyUppercase(ImageAnalysisResult.TagName(TagNb));
            CurrentTagConfidencePercent := ImageAnalysisResult.TagConfidence(TagNb) * 100;
            if not ImageAnalysisTagBlacklist.Get(CurrentTagName) then begin // not blacklisted, add it to the buffer
                ImageAnalysisTags.Init();
                ImageAnalysisTags."Detected On Item No" := Item."No.";
                ImageAnalysisTags."Tag Name" := CopyStr(CurrentTagName, 1, MaxStrLen(ImageAnalysisTags."Tag Name"));
                ImageAnalysisTags."Tag Confidence" := CurrentTagConfidencePercent;
                if (CurrentTagConfidencePercent >= ConfidenceThresholdPercent) and GetFirstMatchingAvailableItemAttributeId(CurrentTagName, ItemAttributeValue) then begin
                    ImageAnalysisTags."Action To Perform" := ImageAnalysisTags."Action To Perform"::Attribute;
                    ImageAnalysisTags.SetAttributeValue(ItemAttributeValue);
                    ImageAnalysisTags.UpdateValueText();
                end;

                ImageAnalysisTags.Insert();
                if CurrentTagConfidencePercent >= ConfidenceThresholdPercent then
                    IdentifyItemCategory(CurrentTagName, ItemCategory, CurrentTagConfidencePercent, FoundItemCategoryToPopulate, BestItemCategory, BestItemCategoryConfidence);
            end;
        end;

        if FoundItemCategoryToPopulate then
            PopulateItemCategoryInBuffer(Item, BestItemCategory.Code, ImageAnalysisTags);
    end;

    local procedure IdentifyItemCategory(TagName: Text; var ItemCategory: Record "Item Category"; ItemConfidence: Decimal; var FoundItemCategoryToPopulate: Boolean; var BestItemCategory: Record "Item Category"; var BestItemCategoryConfidence: Decimal)
    var
        ItemCategoryManagement: Codeunit "Item Category Management";
    begin
        if not ItemCategoryManagement.DoesValueExistInItemCategories(CopyStr(TagName, 1, 20), ItemCategory) then
            exit;

        if not FoundItemCategoryToPopulate then begin
            // first time we find a suitable category
            BestItemCategory := ItemCategory;
            BestItemCategoryConfidence := ItemConfidence;
            FoundItemCategoryToPopulate := true;
            exit;
        end;

        if BestItemCategory.Indentation < ItemCategory.Indentation then begin
            BestItemCategory := ItemCategory;  // item category is closer to a leaf category
            BestItemCategoryConfidence := ItemConfidence;
        end
        else
            if (BestItemCategory.Indentation = ItemCategory.Indentation) and (BestItemCategoryConfidence < ItemConfidence) then begin
                BestItemCategory := ItemCategory; // item category has the same level in the category tree but the confidence is better
                BestItemCategoryConfidence := ItemConfidence;
            end;
    end;

    local procedure PopulateItemCategoryInBuffer(Item: Record Item; BestItemCategoryCode: Code[20]; var ImageAnalyzerTagsBuffer: Record "MS - Image Analyzer Tags")
    begin
        ImageAnalyzerTagsBuffer.SetFilter("Detected On Item No", Item."No.");
        ImageAnalyzerTagsBuffer.SetFilter("Tag Name", '@' + BestItemCategoryCode);
        ImageAnalyzerTagsBuffer.FindFirst();
        ImageAnalyzerTagsBuffer."Item Category Code" := BestItemCategoryCode;
        ImageAnalyzerTagsBuffer.Validate("Action To Perform", ImageAnalyzerTagsBuffer."Action To Perform"::Category);
        ImageAnalyzerTagsBuffer.Modify(true);
    end;

    procedure SetItemCategory(Item: Record Item; NewCategoryCode: Code[20])
    var
        ItemAttributeManagement: Codeunit "Item Attribute Management";
        OldCategory: Code[20];
    begin
        OldCategory := Item."Item Category Code";
        Item."Item Category Code" := NewCategoryCode;
        Item.Modify(true);

        ItemAttributeManagement.InheritAttributesFromItemCategory(Item, NewCategoryCode, OldCategory);
    end;

    local procedure GetFirstMatchingAvailableItemAttributeId(TagName: Text; var ItemAttributeValue: Record "Item Attribute Value"): Boolean
    var
        ImageAnalysisTags: Record "MS - Image Analyzer Tags";
        ItemAttributeManagement: Codeunit "Item Attribute Management";
    begin
        Clear(ItemAttributeValue);
        if not ItemAttributeManagement.DoesValueExistInItemAttributeValues(CopyStr(TagName, 1, 250), ItemAttributeValue) then
            exit;

        repeat
            if not ImageAnalysisTags.IsAttributeAlreadyAssigned(ItemAttributeValue."Attribute ID") then
                exit(true);
        until ItemAttributeValue.Next() = 0;

        Clear(ItemAttributeValue);
        exit(false);
    end;

    local procedure PrettifyUppercase(Txt: Text): Text
    begin
        if StrLen(Txt) <= 1 then
            exit(UpperCase(Txt));

        exit(StrSubstNo('%1%2', Uppercase(CopyStr(Txt, 1, 1)), LowerCase(CopyStr(Txt, 2))));
    end;
}