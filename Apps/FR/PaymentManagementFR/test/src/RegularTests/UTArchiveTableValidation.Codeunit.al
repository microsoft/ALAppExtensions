// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

codeunit 144031 "UT Archive Table Validation"
{
    Subtype = Test;
    TestPermissions = Disabled;
    TestType = Uncategorized;
#if not CLEAN28
    EventSubscriberInstance = Manual;
#endif

    trigger OnRun()
    begin
    end;

    var
        Assert: Codeunit Assert;

    [Test]
    procedure CompareArchiveTables()
    begin
        CompareTables(DATABASE::"Payment Header FR", DATABASE::"Payment Header Archive FR");
        CompareTables(DATABASE::"Payment Line FR", DATABASE::"Payment Line Archive FR");
    end;

    local procedure CompareTables(TableId1: Integer; TableId2: Integer)
    var
        RecRef1: RecordRef;
        RecRef2: RecordRef;
        FieldRef1: FieldRef;
        FieldRef2: FieldRef;
        FieldIndex: Integer;
    begin
        RecRef1.Open(TableId1);
        RecRef2.Open(TableId2);

        for FieldIndex := 1 to RecRef1.FieldCount do begin
            FieldRef1 := RecRef1.FieldIndex(FieldIndex);
            if RecRef2.FieldExist(FieldRef1.Number) then begin
                FieldRef2 := RecRef2.Field(FieldRef1.Number);

                Assert.AreEqual(FieldRef1.Name, FieldRef2.Name, FieldRef2.Name);
                Assert.AreEqual(FieldRef1.Length, FieldRef2.Length, FieldRef2.Name);
            end;
        end;

        RecRef2.Close();
        RecRef1.Close();
    end;

#if not CLEAN28
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Payment Management Feature FR", OnAfterCheckFeatureEnabled, '', false, false)]
    local procedure OnAfterCheckFeatureEnabled(var IsEnabled: Boolean)
    begin
        IsEnabled := true;
    end;
#endif
}

