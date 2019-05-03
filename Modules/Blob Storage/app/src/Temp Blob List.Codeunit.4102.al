// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 4102 "Temp Blob List"
{

    trigger OnRun()
    begin
    end;

    var
        TempBlobListImpl: Codeunit "Temp Blob List Impl.";

    procedure Exists(Index: Integer): Boolean
    begin
        // <summary>
        // Check if an element with the given index exists.
        // </summary>
        // <param name="Index">The index of the TempBlob in the list.</param>
        // <returns>True if an element at the given index exists.</returns>
        exit(TempBlobListImpl.Exists(Index))
    end;

    procedure "Count"(): Integer
    begin
        // <summary>
        // Returns the number of elements in the list.
        // </summary>
        // <returns>The number of elements in the list.</returns>
        exit(TempBlobListImpl.Count)
    end;

    procedure Get(Index: Integer;var TempBlob: Codeunit "Temp Blob")
    begin
        // <summary>
        // Get an element from the list at any given position.
        // </summary>
        // <error>The index is larger than the number of elements in the list or less than one.</error>
        // <param name="Index">The index of the TempBlob in the list.</param>
        // <param name="TempBlob">The TempBlob to return.</param>
        // <returns>An element from the list at any given position.</returns>
        TempBlobListImpl.Get(Index,TempBlob);
    end;

    procedure Set(Index: Integer;TempBlob: Codeunit "Temp Blob"): Boolean
    begin
        // <summary>
        // Set an element at the given index from the parameter TempBlob.
        // </summary>
        // <error>The index is larger than the number of elements in the list or less than one.</error>
        // <param name="Index">The index of the TempBlob in the list.</param>
        // <param name="TempBlob">The TempBlob to set.</param>
        // <returns>True if successful.</returns>
        exit(TempBlobListImpl.Set(Index,TempBlob));
    end;

    procedure RemoveAt(Index: Integer): Boolean
    begin
        // <summary>
        // Remove the element at a specified location from a non-empty list.
        // </summary>
        // <error>The index is larger than the number of elements in the list or less than one.</error>
        // <param name="Index">The index of the TempBlob in the list.</param>
        // <returns>True if successful.</returns>
        exit(TempBlobListImpl.RemoveAt(Index));
    end;

    procedure IsEmpty(): Boolean
    begin
        // <summary>
        // Return true if the list is empty, otherwise return false.
        // </summary>
        // <returns>True if the list is empty.</returns>
        exit(TempBlobListImpl.IsEmpty);
    end;

    procedure Add(TempBlob: Codeunit "Temp Blob"): Boolean
    begin
        // <summary>
        // Adds a TempBlob to the end of the list.
        // </summary>
        // <param name="TempBlob">The TempBlob to add.</param>
        // <returns>True if successful.</returns>
        exit(TempBlobListImpl.Add(TempBlob));
    end;

    procedure AddRange(TempBlobList: Codeunit "Temp Blob List"): Boolean
    begin
        // <summary>
        // Adds the elements of the specified TempBlobList to the end of the current TempBlobList object.
        // </summary>
        // <param name="TempBlobList">The TempBlob list to add.</param>
        // <returns>True if successful.</returns>
        exit(TempBlobListImpl.AddRange(TempBlobList));
    end;

    procedure GetRange(Index: Integer;ElemCount: Integer;var TempBlobListOut: Codeunit "Temp Blob List")
    begin
        // <summary>
        // Get a copy of a range of elements in the list starting from index,
        // </summary>
        // <error>The index is larger than the number of elements in the list or less than one.</error>
        // <error>The range to return in not within the range of the list.</error>
        // <param name="Index">The index of the first object.</param>
        // <param name="ElemCount">The number of objects to be returned.</param>
        // <param name="TempBlobListOut">The TempBlobList to be returned passed as a VAR.</param>
        TempBlobListImpl.GetRange(Index,ElemCount,TempBlobListOut);
    end;
}

