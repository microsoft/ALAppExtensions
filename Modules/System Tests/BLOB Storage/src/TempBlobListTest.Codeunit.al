// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.Utilities;

using System.Utilities;
using System.TestLibraries.Utilities;
using System.TestLibraries.Security.AccessControl;

codeunit 135032 "Temp Blob List Test"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    var
        Assert: Codeunit "Library Assert";
        PermissionsMock: Codeunit "Permissions Mock";
        Any: Codeunit Any;
        ElementNotAddedErr: Label 'The element was not added.';
        ElementNotRemovedErr: Label 'The element was not removed.';
        ElementDoesNotExistErr: Label 'An element with the given index does not exist.';
        ElementIsNotSupposedToExistErr: Label 'An element with the given index is not supposed to exist.';
        IncorrectCountErr: Label 'The count of objects in the list is not correct.';
        RangeNotAddedErr: Label 'The range of TempBlob objects was not added to the list.';
        UnexpectedDataErr: Label 'The data in the BLOB was unexpected.';
        ElementCountMustBePositiveErr: Label 'Element count must be positive.';
        ObjectDoesNotExistErr: Label 'Object with index %1 does not exist.', Comment = '%1: The index of the missing element.';

    [Test]
    procedure ExistsTest()
    var
        TempBlobList: Codeunit "Temp Blob List";
        TempBlob: Codeunit "Temp Blob";
    begin
        // [SCENARIO] The objects in the list can be found.

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Blob Storage Exec');

        // [WHEN] Exists is called with an index less than one.
        // [THEN] The error is thrown.
        Assert.IsFalse(TempBlobList.Exists(-1), ElementIsNotSupposedToExistErr);
        Assert.IsFalse(TempBlobList.Exists(0), ElementIsNotSupposedToExistErr);

        // [WHEN] The list is empty.
        // [THEN] There is no element at the first index, so the error is thrown.
        Assert.IsFalse(TempBlobList.Exists(1), ElementIsNotSupposedToExistErr);

        // [GIVEN] TempBlob is added to the list.
        Assert.IsTrue(TempBlobList.Add(TempBlob), ElementNotAddedErr);

        // [THEN] The first index holds an element.
        Assert.IsTrue(TempBlobList.Exists(1), ElementDoesNotExistErr);

        // [GIVEN] TempBlob is added to the list again.
        Assert.IsTrue(TempBlobList.Add(TempBlob), ElementNotAddedErr);

        // [THEN] The second index holds an element.
        Assert.IsTrue(TempBlobList.Exists(2), ElementDoesNotExistErr);

        // [GIVEN] An element at the second index is removed.
        Assert.IsTrue(TempBlobList.RemoveAt(2), ElementNotRemovedErr);

        // [THEN] There is no element at the second index.
        Assert.IsFalse(TempBlobList.Exists(2), ElementIsNotSupposedToExistErr);
    end;

    [Test]
    procedure CountTest()
    var
        TempBlobList: Codeunit "Temp Blob List";
        TempBlobList2: Codeunit "Temp Blob List";
        TempBlob: Codeunit "Temp Blob";
    begin
        // [SCENARIO] The total number of objects in the list can be obtained.

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Blob Storage Exec');

        // [WHEN] The list is empty.
        // [THEN] The count is zero.
        Assert.AreEqual(0, TempBlobList.Count(), 'Empty list should have size 0.');

        // [GIVEN] Two TempBlob objects are added to the list.
        Assert.IsTrue(TempBlobList.Add(TempBlob), ElementNotAddedErr);
        Assert.IsTrue(TempBlobList.Add(TempBlob), ElementNotAddedErr);

        // [THEN] The count is two.
        Assert.AreEqual(2, TempBlobList.Count(), IncorrectCountErr);

        // [GIVEN] Two TempBlob objects from the original list are added to another list.
        Assert.IsTrue(TempBlobList2.AddRange(TempBlobList), RangeNotAddedErr);

        // [THEN] The count is also two for the other list.
        Assert.AreEqual(2, TempBlobList2.Count(), IncorrectCountErr);

        // [GIVEN] One element was removed from the list.
        Assert.IsTrue(TempBlobList.RemoveAt(1), ElementNotRemovedErr);

        // [THEN] The count is one.
        Assert.AreEqual(1, TempBlobList.Count(), IncorrectCountErr);
    end;

    [Test]
    procedure GetTest()
    var
        TempBlobList: Codeunit "Temp Blob List";
        TempBlob: Codeunit "Temp Blob";
        TempBlobOut: Codeunit "Temp Blob";
    begin
        // [SCENARIO] A particular object can be obtained from the list.

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Blob Storage Exec');

        // [WHEN] The list is empty.
        // [THEN] It is not possible to get the first element, so the error is thrown.
        asserterror TempBlobList.Get(1, TempBlobOut);
        Assert.ExpectedError(StrSubstNo(ObjectDoesNotExistErr, 1));

        // [GIVEN] Some data is written to a TempBlob object and it is added to the list.
        WriteDataToBlob('Test text', TempBlob);
        Assert.IsTrue(TempBlobList.Add(TempBlob), ElementNotAddedErr);

        // [THEN] The same data can be retrieved from the list at the first index.
        TempBlobList.Get(1, TempBlobOut);
        Assert.AreEqual('Test text', ReadDataFromBlob(TempBlobOut), UnexpectedDataErr);

        // [GIVEN] The only TempBlob element is removed from the list.
        Assert.IsTrue(TempBlobList.RemoveAt(1), ElementNotRemovedErr);

        // [THEN] It is not possible to retrieve the first element, so the error is thrown.
        asserterror TempBlobList.Get(1, TempBlobOut);
        Assert.ExpectedError(StrSubstNo(ObjectDoesNotExistErr, 1));
    end;

    [Test]
    procedure SetTest()
    var
        TempBlobList: Codeunit "Temp Blob List";
        TempBlob: Codeunit "Temp Blob";
        TempBlobReplacement: Codeunit "Temp Blob";
        TempBlobOut: Codeunit "Temp Blob";
    begin
        // [SCENARIO] A particular object in the list can be changed.

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Blob Storage Exec');

        // [WHEN] The list is empty.
        // [THEN] It's not possible to set the first element, so the error is thrown.
        asserterror TempBlobList.Set(1, TempBlob);
        Assert.ExpectedError(StrSubstNo(ObjectDoesNotExistErr, 1));

        // [GIVEN] Different data is written to the TempBlob and TempBlobReplacement variables.
        WriteDataToBlob('Original test text', TempBlob);
        WriteDataToBlob('Replacement test text', TempBlobReplacement);

        // [GIVEN] TempBlob variable is added to the list and then replaced by the TempBlobReplacement variable.
        Assert.IsTrue(TempBlobList.Add(TempBlob), ElementNotAddedErr);
        Assert.IsTrue(TempBlobList.Set(1, TempBlobReplacement), 'Setting the element failed.');

        // [THEN] The data at the first index is from the TempBlobReplacement variable.
        TempBlobList.Get(1, TempBlobOut);
        Assert.AreEqual('Replacement test text', ReadDataFromBlob(TempBlobOut), UnexpectedDataErr);
    end;

    [Test]
    procedure RemoveAtTest()
    var
        TempBlobList: Codeunit "Temp Blob List";
        TempBlob1: Codeunit "Temp Blob";
        TempBlob2: Codeunit "Temp Blob";
        TempBlob3: Codeunit "Temp Blob";
        TempBlobOut: Codeunit "Temp Blob";
    begin
        // [SCENARIO] Elements can be removed from the list.

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Blob Storage Exec');

        // [GIVEN] TempBlob objects contain unique data.
        WriteDataToBlob('First', TempBlob1);
        WriteDataToBlob('Second', TempBlob2);
        WriteDataToBlob('Third', TempBlob3);

        // [GIVEN] These objects are added to the list.
        Assert.IsTrue(TempBlobList.Add(TempBlob1), ElementNotAddedErr);
        Assert.IsTrue(TempBlobList.Add(TempBlob2), ElementNotAddedErr);
        Assert.IsTrue(TempBlobList.Add(TempBlob3), ElementNotAddedErr);

        // [WHEN] The middle object is deleted.
        Assert.IsTrue(TempBlobList.RemoveAt(2), ElementNotRemovedErr);

        // [THEN] The first object can still be retrieved.
        TempBlobList.Get(1, TempBlobOut);
        Assert.AreEqual('First', ReadDataFromBlob(TempBlobOut), UnexpectedDataErr);

        // [THEN] The object with the index three no longer exists.
        asserterror TempBlobList.Get(3, TempBlobOut);
        Assert.ExpectedError(StrSubstNo(ObjectDoesNotExistErr, 3));

        // [THEN] The object with the index two contains the data from the third TempBlob.
        TempBlobList.Get(2, TempBlobOut);
        Assert.AreEqual('Third', ReadDataFromBlob(TempBlobOut), UnexpectedDataErr);

        // [WHEN] The first object is deleted.
        Assert.IsTrue(TempBlobList.RemoveAt(1), ElementNotRemovedErr);

        // [THEN] The object with the index one contains the data from the third TempBlob.
        TempBlobList.Get(1, TempBlobOut);
        Assert.AreEqual('Third', ReadDataFromBlob(TempBlobOut), UnexpectedDataErr);

        // [WHEN] A non existing object is deleted.
        // [THEN] The error is thrown.
        asserterror TempBlobList.RemoveAt(2);
        Assert.ExpectedError(StrSubstNo(ObjectDoesNotExistErr, 2));
    end;

    [Test]
    procedure IsEmptyTest()
    var
        TempBlobList: Codeunit "Temp Blob List";
        TempBlob: Codeunit "Temp Blob";
    begin
        // [SCENARIO] The list can be checked if it is empty.

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Blob Storage Exec');

        // [WHEN] The list is empty.
        // [THEN] IsEmpty returns 'true'.
        Assert.IsTrue(TempBlobList.IsEmpty(), 'IsEmpty should return TRUE on the just initialized list.');

        // [GIVEN] Two TempBlob objects are added to the list.
        Assert.IsTrue(TempBlobList.Add(TempBlob), ElementNotAddedErr);
        Assert.IsTrue(TempBlobList.Add(TempBlob), ElementNotAddedErr);

        // [THEN] IsEmpty returns 'false'.
        Assert.IsFalse(TempBlobList.IsEmpty(), 'IsEmpty should return FALSE on the non-empty list.');

        // [GIVEN] Both TempBlob objects are removed.
        Assert.IsTrue(TempBlobList.RemoveAt(1), 'Removal of the element was unsuccessful.');
        Assert.IsTrue(TempBlobList.RemoveAt(1), 'Removal of the element was unsuccessful.');

        // [THEN] The list is empty again.
        Assert.IsTrue(TempBlobList.IsEmpty(), 'IsEmpty should return TRUE on the empty list.');
    end;

    [Test]
    procedure AddTest()
    var
        TempBlobList: Codeunit "Temp Blob List";
        TempBlob1: Codeunit "Temp Blob";
        TempBlob2: Codeunit "Temp Blob";
        TempBlob3: Codeunit "Temp Blob";
        TempBlobOut1: Codeunit "Temp Blob";
        TempBlobOut2: Codeunit "Temp Blob";
        TempBlobOut3: Codeunit "Temp Blob";
    begin
        // [SCENARIO] Elements can be added to the list.

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Blob Storage Exec');

        // [GIVEN] Different data is written to three TempBlob objects.
        WriteDataToBlob('First', TempBlob1);
        WriteDataToBlob('Second', TempBlob2);
        WriteDataToBlob('Third', TempBlob3);

        // [THEN] The TempBlob objects can be added to the list.
        Assert.IsTrue(TempBlobList.Add(TempBlob1), ElementNotAddedErr);
        Assert.IsTrue(TempBlobList.Add(TempBlob2), ElementNotAddedErr);
        Assert.IsTrue(TempBlobList.Add(TempBlob3), ElementNotAddedErr);

        // [GIVEN] TempBlob objects at the indices 1, 2 and 3 are retrieved.
        TempBlobList.Get(1, TempBlobOut1);
        TempBlobList.Get(2, TempBlobOut2);
        TempBlobList.Get(3, TempBlobOut3);

        // [THEN] The retrieved TempBlob objects have the same content as the original objects, 
        // so elements are located in the list in the order in which they were added.
        Assert.AreEqual(ReadDataFromBlob(TempBlob1), ReadDataFromBlob(TempBlobOut1), UnexpectedDataErr);
        Assert.AreEqual(ReadDataFromBlob(TempBlob2), ReadDataFromBlob(TempBlobOut2), UnexpectedDataErr);
        Assert.AreEqual(ReadDataFromBlob(TempBlob3), ReadDataFromBlob(TempBlobOut3), UnexpectedDataErr);
    end;

    [Test]
    procedure AddRange()
    var
        TempBlobList: Codeunit "Temp Blob List";
        TempBlobListDest: Codeunit "Temp Blob List";
        TempBlob1: Codeunit "Temp Blob";
        TempBlob2: Codeunit "Temp Blob";
        TempBlobOut1: Codeunit "Temp Blob";
        TempBlobOut2: Codeunit "Temp Blob";
    begin
        // [SCENARIO] The range of elements from another list can be added to the current list.

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Blob Storage Exec');

        // [GIVEN] An empty list is added to the empty destination list.
        Assert.IsTrue(TempBlobListDest.AddRange(TempBlobList), RangeNotAddedErr);

        // [THEN] The destination list is still empty.
        Assert.IsTrue(TempBlobListDest.IsEmpty(), 'The list should be empty after adding zero elements.');

        // [GIVEN] Different data is written to two TempBlob objects, and they are added to the list.
        WriteDataToBlob('First', TempBlob1);
        WriteDataToBlob('Second', TempBlob2);
        Assert.IsTrue(TempBlobList.Add(TempBlob1), ElementNotAddedErr);
        Assert.IsTrue(TempBlobList.Add(TempBlob2), ElementNotAddedErr);

        // [THEN] These TempBlob objects can be added to the destination list.
        Assert.IsTrue(TempBlobListDest.AddRange(TempBlobList), RangeNotAddedErr);

        // [GIVEN] TempBlob objects at the indices 1 and 2 are retrieved from the destination list.
        TempBlobListDest.Get(1, TempBlobOut1);
        TempBlobListDest.Get(2, TempBlobOut2);

        // [THEN] The data is the same in the original and retrieved TempBlob objects.
        Assert.AreEqual(ReadDataFromBlob(TempBlob1), ReadDataFromBlob(TempBlobOut1), UnexpectedDataErr);
        Assert.AreEqual(ReadDataFromBlob(TempBlob2), ReadDataFromBlob(TempBlobOut2), UnexpectedDataErr);

        // [GIVEN] All the elements from the list are added at the end of the same list.
        Assert.IsTrue(TempBlobList.AddRange(TempBlobList), RangeNotAddedErr);

        // [THEN] There are four elements in the list.
        Assert.AreEqual(4, TempBlobList.Count(), IncorrectCountErr);
    end;

    [Test]
    procedure GetRange()
    var
        TempBlobList: Codeunit "Temp Blob List";
        TempBlobListDest: Codeunit "Temp Blob List";
        TempBlob1: Codeunit "Temp Blob";
        TempBlob2: Codeunit "Temp Blob";
        TempBlob3: Codeunit "Temp Blob";
        TempBlobOut2: Codeunit "Temp Blob";
        TempBlobOut3: Codeunit "Temp Blob";
    begin
        // [SCENARIO] The range of elements can retrieved from the list.

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Blob Storage Exec');

        // [GIVEN] Different data is written to three TempBlob objects, and they are added to the list.
        WriteDataToBlob('First', TempBlob1);
        WriteDataToBlob('Second', TempBlob2);
        WriteDataToBlob('Third', TempBlob3);

        Assert.IsTrue(TempBlobList.Add(TempBlob1), ElementNotAddedErr);
        Assert.IsTrue(TempBlobList.Add(TempBlob2), ElementNotAddedErr);
        Assert.IsTrue(TempBlobList.Add(TempBlob3), ElementNotAddedErr);

        // [THEN] A specific range can be retrieved (for example, two elements starting from the second index).
        TempBlobList.GetRange(2, 2, TempBlobListDest);

        // [GIVEN] The first two elements are retrieved from the destination list.
        TempBlobListDest.Get(1, TempBlobOut2);
        TempBlobListDest.Get(2, TempBlobOut3);

        // [THEN] The content of the second and third TempBlob objects in the original list is the same
        // as the content of the first and second TempBlob objects in the destination list.
        Assert.AreEqual(ReadDataFromBlob(TempBlob2), ReadDataFromBlob(TempBlobOut2), UnexpectedDataErr);
        Assert.AreEqual(ReadDataFromBlob(TempBlob3), ReadDataFromBlob(TempBlobOut3), UnexpectedDataErr);
    end;

    [Test]
    procedure RemoveAtVerifyRemainingList()
    var
        TempBlobList: Codeunit "Temp Blob List";
        BlobListData: List of [Text];
    begin
        // [SCENARIO] Remove a single element from a blob list

        PermissionsMock.Set('Blob Storage Exec');

        // [GIVEN] A BLOB list with 4 elements
        BlobListData := InitializeTempBlobListWithRandomData(TempBlobList, 4);

        // [WHEN] Remove element No. 2 from list BLOB list
        TempBlobList.RemoveAt(2);

        // [THEN] The BLOB list contains 3 elements. Elements 1, 3, and 4 are in the list.
        Assert.AreEqual(3, TempBlobList.Count(), IncorrectCountErr);
        Assert.AreEqual(BlobListData.Get(1), GetBlobListElementContent(TempBlobList, 1), UnexpectedDataErr);
        Assert.AreEqual(BlobListData.Get(3), GetBlobListElementContent(TempBlobList, 2), UnexpectedDataErr);
        Assert.AreEqual(BlobListData.Get(4), GetBlobListElementContent(TempBlobList, 3), UnexpectedDataErr);
    end;

    [Test]
    procedure RemoveRange()
    var
        TempBlobList: Codeunit "Temp Blob List";
        BlobListData: List of [Text];
    begin
        // [SCENARIO] Remove a range of elements from a blob list

        PermissionsMock.Set('Blob Storage Exec');

        // [GIVEN] A BLOB list with 8 elements
        BlobListData := InitializeTempBlobListWithRandomData(TempBlobList, 8);

        // [WHEN] Remove range from the temp blob list. Removing 4 elements starting from index 3.
        TempBlobList.RemoveRange(3, 4);

        // [THEN] The BLOB list contains 4 elements. Elements 1, 2, 7, and 8 are in the list.
        Assert.AreEqual(4, TempBlobList.Count(), IncorrectCountErr);
        Assert.AreEqual(BlobListData.Get(1), GetBlobListElementContent(TempBlobList, 1), UnexpectedDataErr);
        Assert.AreEqual(BlobListData.Get(2), GetBlobListElementContent(TempBlobList, 2), UnexpectedDataErr);
        Assert.AreEqual(BlobListData.Get(7), GetBlobListElementContent(TempBlobList, 3), UnexpectedDataErr);
        Assert.AreEqual(BlobListData.Get(8), GetBlobListElementContent(TempBlobList, 4), UnexpectedDataErr);
    end;

    [Test]
    procedure RemoveRangeElementCountOutOfRange()
    var
        TempBlobList: Codeunit "Temp Blob List";
        BlobListData: List of [Text];
    begin
        // [SCENARIO] Remove a range of elements from a blob list when the number to be deleted is outside of the list boundaries
        PermissionsMock.Set('Blob Storage Exec');

        // [GIVEN] A BLOB list with 5 elements
        BlobListData := InitializeTempBlobListWithRandomData(TempBlobList, 5);

        // [WHEN] Delete 8 list elements starting from index 3
        TempBlobList.RemoveRange(3, 8);

        // [THEN] Operation is successful, the list contains two elements: 1 and 2
        Assert.AreEqual(2, TempBlobList.Count(), IncorrectCountErr);
        Assert.AreEqual(BlobListData.Get(1), GetBlobListElementContent(TempBlobList, 1), UnexpectedDataErr);
        Assert.AreEqual(BlobListData.Get(2), GetBlobListElementContent(TempBlobList, 2), UnexpectedDataErr);
    end;

    [Test]
    procedure RemoveElementsFromHead()
    var
        TempBlobList: Codeunit "Temp Blob List";
        BlobListData: List of [Text];
    begin
        // [SCENARIO] Remove a range of elements from the head of the list
        PermissionsMock.Set('Blob Storage Exec');

        // [GIVEN] A BLOB list with 5 elements
        BlobListData := InitializeTempBlobListWithRandomData(TempBlobList, 5);

        // [WHEN] Delete 3 list elements starting from index 1
        TempBlobList.RemoveRange(1, 3);

        // [THEN] Operation is successful, the list contains two elements: 4 and 5
        Assert.AreEqual(2, TempBlobList.Count(), IncorrectCountErr);
        Assert.AreEqual(BlobListData.Get(4), GetBlobListElementContent(TempBlobList, 1), UnexpectedDataErr);
        Assert.AreEqual(BlobListData.Get(5), GetBlobListElementContent(TempBlobList, 2), UnexpectedDataErr);
    end;

    [Test]
    procedure RemoveAllElementsFromBlobList()
    var
        TempBlobList: Codeunit "Temp Blob List";
    begin
        // [SCENARIO] Clear the list by removing all elements starting from index 1

        PermissionsMock.Set('Blob Storage Exec');

        // [GIVEN] A BLOB list with 8 elements
        InitializeTempBlobListWithRandomData(TempBlobList, Any.IntegerInRange(5, 8));

        // [WHEN] Remove 8 elements starting from 1
        TempBlobList.RemoveRange(1, TempBlobList.Count());

        // [THEN] The list contains 0 elements
        Assert.AreEqual(0, TempBlobList.Count(), IncorrectCountErr);
    end;

    [Test]
    procedure RemoveRangeZeroElementCount()
    var
        TempBlobList: Codeunit "Temp Blob List";
    begin
        // [SCENARIO] RemoveRange throws an error if the number of elements to remove is 0

        PermissionsMock.Set('Blob Storage Exec');

        // [GIVEN] A BLOB list with 4 elements
        InitializeTempBlobListWithRandomData(TempBlobList, 4);

        // [WHEN] Remove 0 elements from list BLOB list starting from position 2
        asserterror TempBlobList.RemoveRange(2, 0);

        // [THEN] Error is thrown: Element count must be positive
        Assert.ExpectedError(ElementCountMustBePositiveErr);
    end;

    [Test]
    procedure RemoveElementNoZero()
    var
        TempBlobList: Codeunit "Temp Blob List";
    begin
        // [SCENARIO] RemoveAt throws an error when the index of the element to be removed is 0

        PermissionsMock.Set('Blob Storage Exec');

        // [GIVEN] A BLOB list with 4 elements
        InitializeTempBlobListWithRandomData(TempBlobList, 4);

        // [WHEN] Remove element No. 0 from list BLOB list
        asserterror TempBlobList.RemoveAt(0);

        // [THEN] Error is thrown: Element with index 0 does not exist
        Assert.ExpectedError(StrSubstNo(ObjectDoesNotExistErr, 0));
    end;

    [Test]
    procedure RemoveRangeWithNegativeElementCount()
    var
        TempBlobList: Codeunit "Temp Blob List";
    begin
        // [SCENARIO] RemoveRange throws an error when the number of elements to be removed is negative

        PermissionsMock.Set('Blob Storage Exec');

        // [GIVEN] A BLOB list with 4 elements
        InitializeTempBlobListWithRandomData(TempBlobList, 4);

        // [WHEN] Call RemoveRange with ElementCount = -1
        asserterror TempBlobList.RemoveRange(2, -1);

        // [THEN] Error is thrown: Element count must be positive
        Assert.ExpectedError(ElementCountMustBePositiveErr);
    end;

    local procedure InitializeTempBlobListWithRandomData(var TempBlobList: Codeunit "Temp Blob List"; Length: Integer): List of [Text]
    var
        TempBlob: Codeunit "Temp Blob";
        BlobListData: List of [Text];
        I: Integer;
    begin
        for I := 1 to Length do begin
            BlobListData.Add(Any.AlphabeticText(100));
            WriteDataToBlob(BlobListData.Get(I), TempBlob);
            TempBlobList.Add(TempBlob);
        end;

        exit(BlobListData);
    end;

    local procedure WriteDataToBlob(Data: Text; var TempBlob: Codeunit "Temp Blob")
    var
        OutStream: OutStream;
    begin
        TempBlob.CreateOutStream(OutStream);
        OutStream.Write(Data);
    end;

    local procedure ReadDataFromBlob(TempBlob: Codeunit "Temp Blob") Data: Text
    var
        InStream: InStream;
    begin
        TempBlob.CreateInStream(InStream);
        InStream.Read(Data);
    end;

    local procedure GetBlobListElementContent(TempBlobList: Codeunit "Temp Blob List"; Index: Integer): Text
    var
        TempBlob: Codeunit "Temp Blob";
    begin
        TempBlobList.Get(Index, TempBlob);
        exit(ReadDataFromBlob(TempBlob));
    end;
}
