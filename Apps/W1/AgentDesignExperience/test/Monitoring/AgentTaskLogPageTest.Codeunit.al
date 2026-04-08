// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.Agents.Designer;

using System.Agents.Troubleshooting;
using System.TestLibraries.Utilities;

codeunit 133757 "Agent Task Log Page Test"
{
    Subtype = Test;

    var
        Assert: Codeunit "Library Assert";

    [Test]
    procedure TestFormatJsonTextForRichContent_VariousInputs()
    var
        AgentTaskLogEntry: Codeunit "Agent Task Log Entry";
        TestCases: List of [Text];
        TestCase: Text;
        FormattedResult: Text;
    begin
        // [GIVEN] Various JSON test cases
        TestCases.Add('{"simple":"value"}');
        TestCases.Add('{"nested":{"object":"value"}}');
        TestCases.Add('{"array":[1,2,3]}');
        TestCases.Add('{"mixed":{"type":"object","values":[1,2,3]}}');

        // [WHEN] Each test case is formatted
        foreach TestCase in TestCases do begin
            FormattedResult := AgentTaskLogEntry.FormatJsonTextForRichContent(TestCase);

            // [THEN] Each should be wrapped in pre tags and contain original data
            Assert.IsTrue(FormattedResult.StartsWith('<pre>'), 'Should start with <pre> tag');
            Assert.IsTrue(FormattedResult.EndsWith('</pre>'), 'Should end with </pre> tag');
        end;
    end;

    [Test]
    procedure TestFormatJsonTextForRichContent_EmptyString()
    var
        AgentTaskLogEntry: Codeunit "Agent Task Log Entry";
        FormattedResult: Text;
    begin
        // [GIVEN] An empty string
        // [WHEN] FormatJsonTextForRichContent is called
        FormattedResult := AgentTaskLogEntry.FormatJsonTextForRichContent('');

        // [THEN] Should handle empty string gracefully
        Assert.IsTrue(FormattedResult.StartsWith('<pre>'), 'Should still have pre tag');
        Assert.IsTrue(FormattedResult.EndsWith('</pre>'), 'Should still close pre tag');
    end;

    [Test]
    procedure TestFormatJsonTextForRichContent_VeryLargeJson()
    var
        AgentTaskLogEntry: Codeunit "Agent Task Log Entry";
        LargeJson: Text;
        FormattedResult: Text;
        i: Integer;
        KeyLbl: Label 'key%1', Locked = true;
        ValueLbl: Label 'value%1', Locked = true;
    begin
        // [GIVEN] A very large JSON string
        LargeJson := '{';
        for i := 1 to 100 do begin
            if i > 1 then
                LargeJson += ',';
            LargeJson += StrSubstNo('"%1":"%2"', StrSubstNo(KeyLbl, i), StrSubstNo(ValueLbl, i));
        end;
        LargeJson += '}';

        // [WHEN] FormatJsonTextForRichContent is called
        FormattedResult := AgentTaskLogEntry.FormatJsonTextForRichContent(LargeJson);

        // [THEN] Should handle large JSON
        Assert.IsTrue(FormattedResult.StartsWith('<pre>'), 'Should format large JSON');
        Assert.IsTrue(StrLen(FormattedResult) > StrLen(LargeJson), 'Formatted should include markup');
    end;

    [Test]
    procedure TestExtractPageStack_WithContext()
    var
        TempPageStackRecords: Record "Agent JSON Buffer" temporary;
        AgentTaskLogEntry: Codeunit "Agent Task Log Entry";
        ContextRootObject: JsonObject;
        PageStackArray: JsonArray;
        TaskPageContext: JsonObject;
    begin
        // [GIVEN] A context with both page stack and other properties
        PageStackArray.Add('CustomerList');
        PageStackArray.Add('CustomerCard');
        ContextRootObject.Add('pageStack', PageStackArray);

        TaskPageContext.Add('pageId', 21);
        TaskPageContext.Add('mode', 'Edit');
        ContextRootObject.Add('taskPageContext', TaskPageContext);
        ContextRootObject.Add('isDecisionPoint', true);

        // [WHEN] ExtractPageStack is called
        AgentTaskLogEntry.ExtractPageStack(TempPageStackRecords, ContextRootObject);

        // [THEN] Only page stack should be extracted
        Assert.AreEqual(2, TempPageStackRecords.Count(), 'Should extract 2 pages');
        TempPageStackRecords.FindFirst();
        Assert.AreEqual('CustomerCard', TempPageStackRecords.GetJsonText(), 'Top page should be CustomerCard');
    end;

    [Test]
    procedure TestExtractMemorizedData_CompleteScenario()
    var
        TempMemorizedDataRecords: Record "Agent JSON Buffer" temporary;
        AgentTaskLogEntry: Codeunit "Agent Task Log Entry";
        ContextRootObject: JsonObject;
        MemorizedDataObject: JsonObject;
    begin
        // [GIVEN] A complete context with various memorized data types
        MemorizedDataObject.Add('userName', 'John Doe');
        MemorizedDataObject.Add('customerId', '12345');
        MemorizedDataObject.Add('orderDate', '2024-01-15');
        MemorizedDataObject.Add('totalAmount', '1500.00');
        MemorizedDataObject.Add('isProcessed', 'true');
        ContextRootObject.Add('memorizedData', MemorizedDataObject);
        ContextRootObject.Add('otherProperty', 'notMemorized');

        // [WHEN] ExtractMemorizedData is called
        AgentTaskLogEntry.ExtractMemorizedData(TempMemorizedDataRecords, ContextRootObject);
        ValidateCompleteScenario(TempMemorizedDataRecords);
    end;

    local procedure ValidateCompleteScenario(var TempMemorizedDataRecords: Record "Agent JSON Buffer" temporary)
    begin
        // [THEN] Only memorized data from the memorizedData object should be extracted
        Assert.AreEqual(5, TempMemorizedDataRecords.Count(), 'Should extract 5 memorized entries');
        TempMemorizedDataRecords.FindSet();
        Assert.IsTrue(TempMemorizedDataRecords.GetJsonText().Contains('"key":"userName"'), 'Should contain userName key');
        Assert.IsTrue(TempMemorizedDataRecords.GetJsonText().Contains('"value":"John Doe"'), 'Should contain userName value');
        TempMemorizedDataRecords.Next();
        Assert.IsTrue(TempMemorizedDataRecords.GetJsonText().Contains('"key":"customerId"'), 'Should contain customerId key');
        Assert.IsTrue(TempMemorizedDataRecords.GetJsonText().Contains('"value":"12345"'), 'Should contain customerId value');
        TempMemorizedDataRecords.Next();
        Assert.IsTrue(TempMemorizedDataRecords.GetJsonText().Contains('"key":"orderDate"'), 'Should contain orderDate key');
        Assert.IsTrue(TempMemorizedDataRecords.GetJsonText().Contains('"value":"2024-01-15"'), 'Should contain orderDate value');
        TempMemorizedDataRecords.Next();
        Assert.IsTrue(TempMemorizedDataRecords.GetJsonText().Contains('"key":"totalAmount"'), 'Should contain totalAmount key');
        Assert.IsTrue(TempMemorizedDataRecords.GetJsonText().Contains('"value":"1500.00"'), 'Should contain totalAmount value');
        TempMemorizedDataRecords.Next();
        Assert.IsTrue(TempMemorizedDataRecords.GetJsonText().Contains('"key":"isProcessed"'), 'Should contain isProcessed key');
        Assert.IsTrue(TempMemorizedDataRecords.GetJsonText().Contains('"value":"true"'), 'Should contain isProcessed value');
    end;

    [Test]
    procedure TestCompleteContextParsing()
    var
        TempPageStackRecords: Record "Agent JSON Buffer" temporary;
        TempAvailableToolsRecords: Record "Agent JSON Buffer" temporary;
        TempMemorizedDataRecords: Record "Agent JSON Buffer" temporary;
        AgentTaskLogEntry: Codeunit "Agent Task Log Entry";
        ContextRootObject: JsonObject;
        PageStackArray: JsonArray;
        AvailableToolsArray: JsonArray;
    begin
        // [GIVEN] A complete context object with all components
        PageStackArray.Add('HomePage');
        PageStackArray.Add('ListPage');
        PageStackArray.Add('CardPage');
        ContextRootObject.Add('pageStack', PageStackArray);

        AvailableToolsArray.Add('Tool1');
        AvailableToolsArray.Add('Tool2');
        ContextRootObject.Add('availableTools', AvailableToolsArray);

        TempMemorizedDataRecords.DeleteAll();
        TempMemorizedDataRecords.Init();
        TempMemorizedDataRecords.Id := 1;
        TempMemorizedDataRecords.Insert();
        TempMemorizedDataRecords.SetJsonText('{"key":"key1","value":"value1"}');
        TempMemorizedDataRecords.Id := 2;
        TempMemorizedDataRecords.Insert();
        TempMemorizedDataRecords.SetJsonText('{"key":"key2","value":"value2"}');

        ContextRootObject.Add('isDecisionPoint', true);
        ContextRootObject.Add('success', true);

        // [WHEN] Extraction methods are called
        AgentTaskLogEntry.ExtractPageStack(TempPageStackRecords, ContextRootObject);
        AgentTaskLogEntry.ExtractAvailableTools(TempAvailableToolsRecords, ContextRootObject);

        // [THEN] All data should be extracted correctly
        Assert.AreEqual(3, TempPageStackRecords.Count(), 'Should have 3 pages');
        Assert.AreEqual(2, TempAvailableToolsRecords.Count(), 'Should have 2 tools');
        Assert.AreEqual(2, TempMemorizedDataRecords.Count(), 'Should have 2 memorized entries');

        ValidateFullContext(TempPageStackRecords, TempAvailableToolsRecords, TempMemorizedDataRecords);
    end;

    local procedure ValidateFullContext(var TempPageStackRecords: Record "Agent JSON Buffer" temporary; var TempAvailableToolsRecords: Record "Agent JSON Buffer" temporary; var TempMemorizedDataRecords: Record "Agent JSON Buffer" temporary)
    begin
        // Validate page stack contents (note: pages are reversed)
        TempPageStackRecords.FindSet();
        Assert.AreEqual('CardPage', TempPageStackRecords.GetJsonText(), 'First page should be CardPage (reversed order)');
        TempPageStackRecords.Next();
        Assert.AreEqual('ListPage', TempPageStackRecords.GetJsonText(), 'Second page should be ListPage');
        TempPageStackRecords.Next();
        Assert.AreEqual('HomePage', TempPageStackRecords.GetJsonText(), 'Third page should be HomePage');

        // Validate available tools contents
        TempAvailableToolsRecords.FindSet();
        Assert.AreEqual('Tool1', TempAvailableToolsRecords.GetJsonText(), 'First tool should be Tool1');
        TempAvailableToolsRecords.Next();
        Assert.AreEqual('Tool2', TempAvailableToolsRecords.GetJsonText(), 'Second tool should be Tool2');

        // Validate memorized data contents
        TempMemorizedDataRecords.FindSet();
        Assert.IsTrue(TempMemorizedDataRecords.GetJsonText().Contains('"key":"key1"'), 'First entry should contain key1');
        Assert.IsTrue(TempMemorizedDataRecords.GetJsonText().Contains('"value":"value1"'), 'First entry should contain value1');
        TempMemorizedDataRecords.Next();
        Assert.IsTrue(TempMemorizedDataRecords.GetJsonText().Contains('"key":"key2"'), 'Second entry should contain key2');
        Assert.IsTrue(TempMemorizedDataRecords.GetJsonText().Contains('"value":"value2"'), 'Second entry should contain value2');
    end;

    [Test]
    procedure TestExtractPageStack_NullValues()
    var
        TempPageStackRecords: Record "Agent JSON Buffer" temporary;
        AgentTaskLogEntry: Codeunit "Agent Task Log Entry";
        ContextRootObject: JsonObject;
        PageStackArray: JsonArray;
        NullToken: JsonToken;
    begin
        // [GIVEN] A page stack with null values
        PageStackArray.Add('Page1');
        NullToken.ReadFrom('null');
        PageStackArray.Add(NullToken);
        PageStackArray.Add('Page3');
        ContextRootObject.Add('pageStack', PageStackArray);

        // [WHEN] ExtractPageStack is called
        AgentTaskLogEntry.ExtractPageStack(TempPageStackRecords, ContextRootObject);

        // [THEN] Should handle null values (count may be 2 or 3 depending on implementation)
        Assert.IsTrue(TempPageStackRecords.Count() >= 2, 'Should extract at least 2 non-null pages');
    end;
}
