// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.Integration.Word;

using System.Integration.Word;
using System.TestLibraries.Utilities;
using System.TestLibraries.Security.AccessControl;

/// <summary>
/// Tests for Word Templates related tables.
/// </summary>
codeunit 130448 "Word Templates Cust Field Test"
{
    Subtype = Test;
    EventSubscriberInstance = Manual;

    var
        TempWordTemplateFieldGlobal: Record "Word Template Field" temporary;
        Assert: Codeunit "Library Assert";
        PermissionsMock: Codeunit "Permissions Mock";
        WordTemplatesCustFieldTest: Codeunit "Word Templates Cust Field Test";
        Initialized: Boolean;
        CustomFieldAlreadyExistErr: Label 'The custom field %1 already exists.', Comment = '%1 = the name of a custom field.';

    [Test]
    procedure TestGetCustomMergeFieldsNoSubscribers()
    var
        TempWordTemplateField: Record "Word Template Field" temporary;
        WordTemplateImpl: Codeunit "Word Template Impl.";
        MergeFields: List of [Text];
    begin
        PermissionsMock.Set('Word Templates Edit');

        // [Given] A list of merge fields
        MergeFields.Add('Test1');
        MergeFields.Add('Test2');

        // [WHEN] GetCustomMergeFields is called
        WordTemplateImpl.GetCustomMergeFields(18, '', MergeFields, TempWordTemplateField);

        // [THEN] The merge fields list is unchanged
        Assert.AreEqual(2, MergeFields.Count(), 'Wrong number of merge fields.');
        Assert.AreEqual('Test1', MergeFields.Get(1), 'Merge field value is wrong.');
        Assert.AreEqual('Test2', MergeFields.Get(2), 'Merge field value is wrong.');
    end;

    [Test]
    procedure TestGetCustomMergeFieldsWithSubscriber()
    var
        TempWordTemplateField: Record "Word Template Field" temporary;
        WordTemplateImpl: Codeunit "Word Template Impl.";
        MergeFields: List of [Text];
    begin
        Init();
        PermissionsMock.Set('Word Templates Edit');

        // [Given] A list of merge fields
        MergeFields.Add('Test1');
        MergeFields.Add('Test2');

        // [GIVEN] There are a subscriber adding fields
        WordTemplatesCustFieldTest.AddFieldToTemplate(18, 'Oxygen');
        WordTemplatesCustFieldTest.AddFieldToTemplate(18, 'Carbon');

        // [WHEN] GetCustomMergeFields is called
        WordTemplateImpl.GetCustomMergeFields(18, '', MergeFields, TempWordTemplateField);

        // [THEN] The merge fields list has the custom fields added and sorted by name
        Assert.AreEqual(4, MergeFields.Count(), 'Wrong number of merge fields.');
        Assert.AreEqual('Test1', MergeFields.Get(1), 'Merge field value is wrong.');
        Assert.AreEqual('Test2', MergeFields.Get(2), 'Merge field value is wrong.');
        Assert.AreEqual('CALC_Carbon', MergeFields.Get(3), 'Merge field value is wrong.');
        Assert.AreEqual('CALC_Oxygen', MergeFields.Get(4), 'Merge field value is wrong.');
    end;

    [Test]
    procedure TestGetCustomMergeFieldsCannotAddSameFieldTwice()
    var
        TempWordTemplateField: Record "Word Template Field" temporary;
        WordTemplatesCustFieldTest2: Codeunit "Word Templates Cust Field Test";
        WordTemplateImpl: Codeunit "Word Template Impl.";
        MergeFields: List of [Text];
    begin
        Init();
        BindSubscription(WordTemplatesCustFieldTest2);
        PermissionsMock.Set('Word Templates Edit');

        // [Given] A list of merge fields
        MergeFields.Add('Test1');
        MergeFields.Add('Test2');

        // [GIVEN] There are two subscribers adding the same field
        WordTemplatesCustFieldTest.AddFieldToTemplate(18, 'Saturn');
        WordTemplatesCustFieldTest2.AddFieldToTemplate(18, 'Saturn');

        // [WHEN] GetCustomMergeFields is called and there are no subscribers
        // [THEN] An exception is thrown
        asserterror WordTemplateImpl.GetCustomMergeFields(18, '', MergeFields, TempWordTemplateField);
        Assert.ExpectedError(StrSubstNo(CustomFieldAlreadyExistErr, 'Saturn'));
    end;

    local procedure Init()
    begin
        Clear(WordTemplatesCustFieldTest);

        if Initialized then
            exit;

        BindSubscription(WordTemplatesCustFieldTest);
    end;

    internal procedure AddFieldToTemplate(TableId: Integer; FieldName: Text[20])
    begin
        TempWordTemplateFieldGlobal."Table ID" := TableId;
        TempWordTemplateFieldGlobal."Field Name" := FieldName;
        TempWordTemplateFieldGlobal.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Word Template", 'OnGetCustomFieldNames', '', false, false)]
    local procedure OnGetCustomFieldNames(WordTemplateCustomField: Codeunit "Word Template Custom Field")
    begin
        TempWordTemplateFieldGlobal.Reset();
        TempWordTemplateFieldGlobal.SetRange("Table ID", WordTemplateCustomField.GetTableID());
        if TempWordTemplateFieldGlobal.FindSet() then
            repeat
                WordTemplateCustomField.AddField(CopyStr(TempWordTemplateFieldGlobal."Field Name", 1, 20));
            until TempWordTemplateFieldGlobal.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Word Template", 'OnGetCustomRecordValues', '', false, false)]
    local procedure OnGetCustomRecordValues(WordTemplateFieldValue: Codeunit "Word Template Field Value")
    begin
        TempWordTemplateFieldGlobal.Reset();
        TempWordTemplateFieldGlobal.SetRange("Table ID", WordTemplateFieldValue.GetRecord().Number());
        if TempWordTemplateFieldGlobal.FindSet() then
            repeat
                WordTemplateFieldValue.AddFieldValue(TempWordTemplateFieldGlobal."Field Name", 'Value: ' + TempWordTemplateFieldGlobal."Field Name");
            until TempWordTemplateFieldGlobal.Next() = 0;
    end;
}