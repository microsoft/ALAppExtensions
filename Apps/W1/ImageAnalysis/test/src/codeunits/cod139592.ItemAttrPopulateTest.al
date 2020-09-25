// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

codeunit 139592 "Item Attr Populate Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        NotificationHandled: Boolean;


    [Test]
    procedure TestPopulateAttributeAndCategory()
    var
        ImageAnalysisTags: Record "MS - Image Analyzer Tags";
        Item: Record Item;
        ImageAnalysisTagBlacklist: Record "MS - Img. Analyzer Blacklist";
        ImageAnalysisResult: Codeunit "Image Analysis Result";
        ItemAttrPopulate: Codeunit "Item Attr Populate";
        JsonManagement: Codeunit "JSON Management";
        ConfidencePercent: Decimal;
        AnalysisType: Option Tags,Faces,Color;
        UpdatedDescription: Text[100];
    begin
        // [Scenario] Check the item is populated correctly in a success case
        // [Given] An item and an analysis result with high confidence for color and chair
        Initialize();
        CreateTestItem(Item);

        JsonManagement.InitializeObject('{"tags":[{"name":"furniture","confidence":0.998513400554657},{"name":"seat","confidence":0.99785393476486206},' +
      '{"name":"chair","confidence":0.978925347328186},{"name":"blue","confidence":0.90790148973464966}],"requestId":"2c15a4c1-9271-4584-a30e-342d7fdf206b"' +
      ',"metadata":{"width":500,"height":600,"format":"Jpeg"},"faces":[],"color":{"dominantColorForeground":"White","dominantColorBackground":"White",' +
      '"dominantColors":["White","Blue"],"accentColor":"0D48BE","isBWImg":false}}');
        ImageAnalysisResult.SetJson(JsonManagement, AnalysisType::Tags);

        // [When] We try to populate the tags table
        ItemAttrPopulate.BuildTagListPrepopulateCategoryAndAttributes(Item, ImageAnalysisResult, ImageAnalysisTags, ConfidencePercent);

        // [Then] The tags  populated as expected, and the item is unchanged for now
        ImageAnalysisTags.Reset();
        ImageAnalysisTags.SetRange("Action To Perform", ImageAnalysisTags."Action To Perform"::Category);
        Assert.IsTrue(ImageAnalysisTags.FindFirst(), 'Expected one tag to be prepopulated with category as Action to perform.');
        Assert.AreEqual('CHAIR', ImageAnalysisTags."Item Category Code", StrSubstNo('Item category code should have been set to Chair in the tags table, but was %1', ImageAnalysisTags."Item Category Code"));
        Assert.AreEqual('Category: ''CHAIR''', ImageAnalysisTags."Details Text", 'Details text not as expected for category.');

        ImageAnalysisTags.Reset();
        ImageAnalysisTags.SetRange("Action To Perform", ImageAnalysisTags."Action To Perform"::Attribute);
        Assert.IsTrue(ImageAnalysisTags.FindFirst(), 'Expected one tag to be prepopulated with Attribute as Action to perform.');
        Assert.IsTrue(IsTagValueBlue(ImageAnalysisTags), 'Expected the color blue to be set in the tags table.');
        Assert.AreEqual('Item attribute: ''Color'' = ''Blue''', ImageAnalysisTags."Details Text", 'Details text not as expected for color.');

        Item.Get(Item.RecordId());
        Assert.IsTrue(Item."Item Category Code" = '', StrSubstNo('Item category code should not have been set, but was %1', Item."Item Category Code"));
        Assert.IsFalse(IsItemBlue(Item), 'Expected the color not to be set for the item.');

        /*
        // [When] the user presses Cancel in the tags page
        ImageAnalyzerTagsTestPage.OpenEdit();
        ImageAnalyzerTagsTestPage.Cancel.Invoke();

        // [Then] The item is not modified, as expected
        Item.Get(Item.RecordId());
        Assert.IsTrue(Item."Item Category Code" = '',StrSubstNo('Item category code should not have been set, but was %1',Item."Item Category Code"));
        Assert.IsFalse(IsItemBlue(Item),'Expected the color not to be set for the item.');

        // [When] the user modifies the description and presses OK in the tags page
        ImageAnalyzerTagsTestPage.OpenEdit();
        ImageAnalyzerTagsTestPage.Next();
        ImageAnalyzerTagsTestPage.DetailsText.Drilldown();
        ImageAnalyzerTagsTestPage.OK.Invoke();
        */
        // [When] the user modifies the description and presses OK in the tags page
        UpdatedDescription := CopyStr(Item.Description + ' Blue', 1, MaxStrLen(UpdatedDescription));
        ImageAnalysisTags.ApplyChanges(UpdatedDescription);

        // [Then] The item is populated as expected
        Item.Get(Item.RecordId());
        Assert.IsTrue(Item."Item Category Code" = 'CHAIR', StrSubstNo('Item category code should have been updated to Chair, but was %1', Item."Item Category Code"));
        Assert.IsTrue(IsItemBlue(Item), 'Expected the color blue to be set for the item.');
        Assert.AreEqual('Test item Blue', Item.Description, 'Item description not as expected.');

        /*
        // [When] the user modifies the description and presses OK in the tags page
        ImageAnalyzerTagsTestPage.OpenEdit();
        ImageAnalyzerTagsTestPage.Next();
        ImageAnalyzerTagsTestPage.ActionToPerform.SetValue(ImageAnalysisTags."Action To Perform"::Blacklist);
        ImageAnalyzerTagsTestPage.OK.Invoke();
        */

        // [When] the user modifies the description and presses OK in the tags page
        ImageAnalysisTags.Reset();
        ImageAnalysisTags.SetRange("Tag Name", 'Blue');
        ImageAnalysisTags.FindFirst();
        ImageAnalysisTags."Action To Perform" := ImageAnalysisTags."Action To Perform"::"Blacklist";
        ImageAnalysisTags.Modify();
        ImageAnalysisTags.ApplyChanges(Item.Description);

        // [Then] The item is unchanged, and the tag is added to the blacklist
        Item.Get(Item.RecordId());
        Assert.IsTrue(Item."Item Category Code" = 'CHAIR', StrSubstNo('Item category code should have been updated to Chair, but was %1', Item."Item Category Code"));
        Assert.IsTrue(IsItemBlue(Item), 'Expected the color blue to be set for the item.');
        Assert.AreEqual('Test item Blue', Item.Description, 'Item description not as expected.');
        ImageAnalysisTagBlacklist.Reset();
        ImageAnalysisTagBlacklist.FindFirst();
        Assert.AreEqual('Blue', ImageAnalysisTagBlacklist.TagName, 'Expected Blue to be added to the blacklist.');


        Cleanup(Item);
    end;

    [Test]
    procedure TestPopulateNothingLowConfidence()
    var
        ImageAnalysisTags: Record "MS - Image Analyzer Tags";
        Item: Record Item;
        ImageAnalysisResult: Codeunit "Image Analysis Result";
        ItemAttrPopulate: Codeunit "Item Attr Populate";
        JsonManagement: Codeunit "JSON Management";
        ConfidencePercent: Decimal;
        AnalysisType: Option Tags,Faces,Color;
    begin
        // [Scenario] Check the item is not populated correctly in a success case
        // [Given] An item and an analysis result with low confidence for everything
        Initialize();
        CreateTestItem(Item);

        JsonManagement.InitializeObject('{"tags":[{"name":"furniture","confidence":0.098513400554657},{"name":"seat","confidence":0.09785393476486206},' +
      '{"name":"chair","confidence":0.078925347328186},{"name":"blue","confidence":0.00790148973464966}],"requestId":"2c15a4c1-9271-4584-a30e-342d7fdf206b"' +
      ',"metadata":{"width":500,"height":600,"format":"Jpeg"}}');
        ImageAnalysisResult.SetJson(JsonManagement, AnalysisType::Tags);

        // [When] We try to populate the item
        ItemAttrPopulate.BuildTagListPrepopulateCategoryAndAttributes(Item, ImageAnalysisResult, ImageAnalysisTags, ConfidencePercent);

        // [Then] The item is not populated, as expected
        ImageAnalysisTags.Reset();
        Assert.AreEqual(4, ImageAnalysisTags.Count(), 'Expected tags to be added to the tags table, even if low confidence');
        ImageAnalysisTags.SetRange("Action To Perform", ImageAnalysisTags."Action To Perform"::" ");
        ImageAnalysisTags.FindSet();
        Assert.AreEqual(4, ImageAnalysisTags.Count(), 'Expected all 4 tags to be set to ignore by default because of low confidence.');

        Item.Get(Item.RecordId());
        Assert.IsTrue(Item."Item Category Code" = '', StrSubstNo('Item category code should not have been set, but was %1', Item."Item Category Code"));
        Assert.IsFalse(IsItemBlue(Item), 'Expected the color not to be set for the item.');

        Cleanup(Item);
    end;

    local procedure Initialize()
    var
        ImageAnalysisSetup: Record "Image Analysis Setup";
    begin
        NotificationHandled := false;
        ImageAnalysisSetup.DeleteAll();
        ImageAnalysisSetup.GetSingleInstance();
        ImageAnalysisSetup."Image-Based Attribute Recognition Enabled" := true;
        ImageAnalysisSetup.Modify();
    end;

    local procedure CreateTestItem(var Item: Record Item)
    begin
        Item.Reset();
        Item.SetFilter(Description, 'Test item');
        Item.DeleteAll();

        Item.Init();
        Item.Description := 'Test item';
        Item.Insert(true);
    end;

    local procedure IsItemBlue(Item: Record Item): Boolean
    var
        ItemAttributeValue: Record "Item Attribute Value";
        ItemAttributeValueMapping: Record "Item Attribute Value Mapping";
    begin
        ItemAttributeValue.Reset();
        ItemAttributeValue.SetRange(Value, 'Blue');
        ItemAttributeValue.FindSet();
        exit(ItemAttributeValueMapping.GET(DATABASE::Item, Item."No.", ItemAttributeValue."Attribute ID") and (ItemAttributeValueMapping."Item Attribute Value ID" = ItemAttributeValue.ID));
    end;

    local procedure IsTagValueBlue(ImageAnalysisTags: Record "MS - Image Analyzer Tags"): Boolean
    var
        ItemAttributeValue: Record "Item Attribute Value";
    begin
        ItemAttributeValue.Reset();
        ItemAttributeValue.SetRange(Value, 'Blue');
        ItemAttributeValue.FindSet();
        exit((ImageAnalysisTags."Item Attribute Name Id" = ItemAttributeValue."Attribute ID") and (ImageAnalysisTags."Item Attribute Value Id" = ItemAttributeValue.ID));
    end;

    procedure Cleanup(Item: Record Item)
    var
        ItemAttributeValueMapping: Record "Item Attribute Value Mapping";
        ImageAnalysisSetup: Record "Image Analysis Setup";
        ImageAnalysisTagBlacklist: Record "MS - Img. Analyzer Blacklist";
    begin
        ItemAttributeValueMapping.Reset();
        ItemAttributeValueMapping.SetRange("Table ID", DATABASE::Item);
        ItemAttributeValueMapping.SetRange("No.", Item."No.");
        ItemAttributeValueMapping.DeleteAll();
        Item.Delete();

        ImageAnalysisSetup.DeleteAll();
        ImageAnalysisTagBlacklist.DeleteAll();
    end;

}
