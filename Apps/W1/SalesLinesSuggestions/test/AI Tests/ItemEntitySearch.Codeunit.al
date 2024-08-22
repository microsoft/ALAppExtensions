namespace Microsoft.Sales.Document.Test;

using Microsoft.Sales.Document;
using System.TestTools.AITestToolkit;
using System.TestTools.TestRunner;

codeunit 139782 "Item Entity Search"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        IsInitialized: Boolean;

    local procedure Initialize()
    begin
        if IsInitialized then
            exit;
        // TODO: register capability and wait till items are indexed
        IsInitialized := true;
    end;

    [Test]
    procedure TestItemEntitySearch()
    var
        TempSalesLineAISuggestion: Record "Sales Line AI Suggestions" temporary;
        SLSSearch: Codeunit Search;
        AITestContext: Codeunit "AIT Test Context";
        Element: Codeunit "Test Input Json";
        TestOutputJson: Codeunit "Test Output Json";
        ActualItem: Codeunit "Test Output Json";
        ElementExists: Boolean;
        SearchStyle: Enum "Search Style";
        ExpectedConfidence: Enum "Search Confidence";
        i: Integer;
        ExpectedItems: List of [Text];
        ItemNoMismatchErr: Label 'Item No. does not match. Expected: %1, Actual: %2', Comment = '%1 = Expected Item No., %2 = Actual Item No.';
    begin
        Initialize();
        // [GIVEN] A question from the dataset, parameters for the Search API 
        // [WHEN] The Search API is called
        case AITestContext.GetInput().Element('SearchStyle').ValueAsText() of
            'Permissive':
                SearchStyle := SearchStyle::Permissive;
            'Balanced':
                SearchStyle := SearchStyle::Balanced;
            'Precise':
                SearchStyle := SearchStyle::Precise;
            else
                Error('Invalid Search Style');
        end;

        SLSSearch.SearchMultiple(
            AITestContext.GetInput().Element('ItemResultsArray').AsJsonToken().AsArray(),
            SearchStyle,
            AITestContext.GetInput().Element('Intent').ValueAsText(),
            AITestContext.GetQuestion().ValueAsText(),
            AITestContext.GetInput().Element('Top').ValueAsInteger(),
            AITestContext.GetInput().Element('MaximumQueryResultsToRank').ValueAsInteger(),
            AITestContext.GetInput().Element('IncludeSynonyms').ValueAsBoolean(),
            AITestContext.GetInput().Element('UseContextAwareRanking').ValueAsBoolean(),
            TempSalesLineAISuggestion,
            AITestContext.GetInput().Element('ItemNoFilter').ValueAsText()
        );

        // Log the results
        TestOutputJson.Initialize();
        TestOutputJson.AddArray('Actual');
        if TempSalesLineAISuggestion.FindSet() then
            repeat
                ActualItem.Initialize();
                ActualItem.Add('Item No.', TempSalesLineAISuggestion."No.");
                ActualItem.Add('Description', TempSalesLineAISuggestion.Description);
                ActualItem.Add('Confidence', TempSalesLineAISuggestion.Confidence.AsInteger());
                ActualItem.Add('Primary Search Terms', TempSalesLineAISuggestion.GetPrimarySearchTerms());
                ActualItem.Add('Additional Search Terms', TempSalesLineAISuggestion.GetAdditionalSearchTerms());
                ActualItem.Add('UoM', TempSalesLineAISuggestion."Unit of Measure Code");
                TestOutputJson.Element('Actual').Add(ActualItem.ToText());
            until TempSalesLineAISuggestion.Next() = 0;

        AITestContext.SetTestOutput(TestOutputJson.ToText());

        // [THEN] Search API returns expected number of results
        Assert.AreEqual(AITestContext.GetExpectedData().GetElementCount(), TempSalesLineAISuggestion.Count(), 'Number of expected results does not match the number of actual results');

        // [THEN] Search API returns expected results
        // Example -> "Expected": [{"Item No.": "1928-W", "Confidence": "High"},{"Item No.": "1964-W", "Confidence": "High"}]
        i := 0;
        if TempSalesLineAISuggestion.FindSet() then
            repeat
                // [THEN] Item No. is in the expected list
                Element := AITestContext.GetExpectedData().ElementAt(i).ElementExists('Item No.', ElementExists);
                if ElementExists then begin
                    ExpectedItems := Element.ValueAsText().Split('|');
                    Assert.IsTrue(ExpectedItems.Contains(TempSalesLineAISuggestion."No."), StrSubstNo(ItemNoMismatchErr, Element.ValueAsText(), TempSalesLineAISuggestion."No."));
                end;

                // [THEN] Confidence is as expected
                Element := AITestContext.GetExpectedData().ElementAt(i).ElementExists('Confidence', ElementExists);
                if ElementExists then begin
                    case AITestContext.GetExpectedData().ElementAt(i).Element('Confidence').ValueAsText() of
                        'High':
                            ExpectedConfidence := ExpectedConfidence::High;
                        'Medium':
                            ExpectedConfidence := ExpectedConfidence::Medium;
                        'Low':
                            ExpectedConfidence := ExpectedConfidence::Low;
                        'None':
                            ExpectedConfidence := ExpectedConfidence::None;
                        else
                            Error('Invalid Confidence');
                    end;
                    Assert.AreEqual(ExpectedConfidence, TempSalesLineAISuggestion.Confidence, 'Confidence does not match');
                end;
                i += 1;
            until TempSalesLineAISuggestion.Next() = 0;
    end;
}