// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 4109 "Temp Blob List Impl."
{
    Access = Internal;

    var
    #pragma warning disable AA0073
        TempBlobRec: Record "Temp Blob" temporary;
    #pragma warning restore AA0073
        ObjectDoesNotExistErr: Label 'Object with index %1 does not exist.', Comment = '%1=Index of the object';
        InvalidNoObjectsRequestedErr: Label 'There are not enough objects available to fulfill the request.';

    procedure Exists(Index: Integer): Boolean
    begin
        exit(TempBlobRec.Get(Index));
    end;

    procedure "Count"(): Integer
    begin
        exit(TempBlobRec.Count());
    end;

    procedure Get(Index: Integer; var TempBlob: Codeunit "Temp Blob")
    begin
        // Not using Exists function from this codeunit as it is a reserved keyword
        if not TempBlobRec.Get(Index) then
            Error(ObjectDoesNotExistErr, Index);

        TempBlob.FromRecord(TempBlobRec, TempBlobRec.FieldNo(Blob));
    end;

    procedure Set(Index: Integer; TempBlob: Codeunit "Temp Blob"): Boolean
    begin
        if not TempBlobRec.Get(Index) then
            Error(ObjectDoesNotExistErr, Index);

        TempBlobRec."Primary Key" := Index;
        CopyBlob(TempBlob);
        exit(TempBlobRec.Modify());
    end;

    procedure RemoveAt(Index: Integer): Boolean
    var
        TempBlobList: Codeunit "Temp Blob List";
    begin
        if not TempBlobRec.Get(Index) then
            Error(ObjectDoesNotExistErr, Index);
        if TempBlobRec.Get(Index + 1) then
            GetRange(Index + 1, Count() - Index, TempBlobList);
        TempBlobRec.SetFilter("Primary Key", '>=%1', Index);
        TempBlobRec.DeleteAll();
        TempBlobRec.Reset();
        exit(AddRange(TempBlobList));
    end;

    procedure IsEmpty(): Boolean
    begin
        exit(TempBlobRec.IsEmpty());
    end;

    procedure Add(TempBlob: Codeunit "Temp Blob"): Boolean
    begin
        TempBlobRec."Primary Key" := Count() + 1;
        CopyBlob(TempBlob);
        exit(TempBlobRec.Insert());
    end;

    procedure AddRange(TempBlobList: Codeunit "Temp Blob List"): Boolean
    var
        TempBlob: Codeunit "Temp Blob";
        Index: Integer;
    begin
        if TempBlobList.IsEmpty() then
            exit(true);
        for Index := 1 to TempBlobList.Count() do begin
            TempBlobList.Get(Index, TempBlob);
            if not Add(TempBlob) then
                exit(false);
        end;

        exit(true);
    end;

    procedure GetRange(Index: Integer; ElemCount: Integer; var TempBlobListOut: Codeunit "Temp Blob List")
    var
        TempBlob: Codeunit "Temp Blob";
        TempBlobList: Codeunit "Temp Blob List";
        Number: Integer;
    begin
        if Index + ElemCount > Count() + 1 then
            Error(InvalidNoObjectsRequestedErr);

        TempBlobRec.SetFilter("Primary Key", '>=%1', Index);
        if not TempBlobRec.FindSet() then
            Error(ObjectDoesNotExistErr, Index);
        repeat
            Get(TempBlobRec."Primary Key", TempBlob);
            // TempBlobListOut parameter is only for output
            // new variable is needed to ensure the function behaves the same no matter the TempBlobListOut input
            TempBlobList.Add(TempBlob);
            Number += 1;
        until (TempBlobRec.Next() = 0) or (Number = ElemCount);
        TempBlobRec.Reset();
        TempBlobListOut := TempBlobList;
    end;

    local procedure CopyBlob(var TempBlob: Codeunit "Temp Blob")
    var
        RecordRef: RecordRef;
    begin
        Clear(TempBlobRec.Blob);
        RecordRef.GetTable(TempBlobRec);
        TempBlob.ToRecordRef(RecordRef, TempBlobRec.FieldNo(Blob));
        RecordRef.SetTable(TempBlobRec);
    end;
}

