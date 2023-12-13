// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Shared.Error;

using Microsoft.Finance.Dimension;
using System.Utilities;
using System.Reflection;
codeunit 7906 "Dim. Code Same But Missing Err" implements ErrorMessageFix
{
    Access = Internal;

    var
        TempDimSetEntryGbl: Record "Dimension Set Entry" temporary;
        DimSetEntryFixUseSameCodeAckTok: Label 'The %1 %2 with %3 %4 is added.', Comment = '%1 = "Dimension Code" caption, %2 = "Dimension Code" value, %3 = "Dimension Value Code" caption, %4 = "Dimension Value Code" value';
        DimensionUseRequiredActionLbl: Label 'Add %1 dimension set', Comment = '%1 = "Dimension Code" value';
        DimensionMismatchTitleErr: Label 'A dimension set is required.';

    procedure OnSetErrorMessageProps(var ErrorMessage: Record "Error Message" temporary);
    var
        DefaultDimension: Record "Default Dimension";
    begin
        DefaultDimension.Get(ErrorMessage."Record ID");
        ErrorMessage.Validate(Title, StrSubstNo(DimensionMismatchTitleErr));
        ErrorMessage.Validate("Recommended Action Caption", StrSubstNo(DimensionUseRequiredActionLbl, DefaultDimension."Dimension Code"));
    end;

    procedure OnFixError(ErrorMessage: Record "Error Message" temporary): Boolean
    var
        DefaultDimension: Record "Default Dimension";
        DimensionManagement: Codeunit DimensionManagement;
        DataTypeManagement: Codeunit "Data Type Management";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        DimensionSetID: Integer;
    begin
        // Get the dimensions set entry which has the error.
        if RecRef.Get(ErrorMessage."Context Record ID") then
            if DataTypeManagement.FindFieldByName(RecRef, FieldRef, 'Dimension Set ID') then
                DimensionSetID := FieldRef.Value()
            else
                exit(false);
        DimensionManagement.GetDimensionSet(TempDimSetEntryGbl, DimensionSetID);

        // Get the default dimensions set
        DefaultDimension.Get(ErrorMessage."Record ID");

        // Check the fields of the default dimension set and the dimension set entry.
        DefaultDimension.TestField("Value Posting", DefaultDimension."Value Posting"::"Same Code");
        TempDimSetEntryGbl.SetRange("Dimension Code", DefaultDimension."Dimension Code");
        if not TempDimSetEntryGbl.IsEmpty() then
            exit(false);

        // Add the dimension value code to the dimensions set entry.
        TempDimSetEntryGbl.Init();
        TempDimSetEntryGbl.Validate("Dimension Code", DefaultDimension."Dimension Code");
        TempDimSetEntryGbl.Validate("Dimension Value Code", DefaultDimension."Dimension Value Code");
        TempDimSetEntryGbl.Insert();
        DimensionSetID := DimensionManagement.GetDimensionSetID(TempDimSetEntryGbl);

        // Update the source document with the new dimension set id.
        if RecRef.Get(ErrorMessage."Context Record ID") then
            if DataTypeManagement.FindFieldByName(RecRef, FieldRef, 'Dimension Set ID') then begin
                FieldRef.Validate(DimensionSetID);
                exit(RecRef.Modify());
            end;
    end;

    procedure OnSuccessMessage(): Text;
    begin
        exit(StrSubstNo(DimSetEntryFixUseSameCodeAckTok, TempDimSetEntryGbl.FieldCaption("Dimension Code"), TempDimSetEntryGbl."Dimension Code", TempDimSetEntryGbl.FieldCaption("Dimension Value Code"), TempDimSetEntryGbl."Dimension Value Code"));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Error Message Management", OnAddSubContextToLastErrorMessage, '', false, false)]
    local procedure OnAddSubContextToLastErrorMessage(Tag: Text; VariantRec: Variant; var ErrorMessage: Record "Error Message" temporary)
    var
        DimSetEntry: Record "Dimension Set Entry";
        DimSetId: Integer;
        IErrorMessageFix: Interface ErrorMessageFix;
    begin
        if Tag <> Enum::"Error Msg. Fix Implementation".Names().Get(Enum::"Error Msg. Fix Implementation"::DimensionCodeSameMissingDimCodeError.AsInteger() + 1) then
            exit;

        if VariantRec.IsInteger then begin
            DimSetId := VariantRec;
            if DimSetId > 0 then begin
                DimSetEntry.SetRange("Dimension Set ID", DimSetId);
                if DimSetEntry.FindFirst() then
                    ErrorMessage.Validate("Sub-Context Record ID", DimSetEntry.RecordId);
            end;
            ErrorMessage.Validate("Error Msg. Fix Implementation", Enum::"Error Msg. Fix Implementation"::DimensionCodeSameMissingDimCodeError);

            // Use the interface to set title and recommended action caption
            IErrorMessageFix := ErrorMessage."Error Msg. Fix Implementation";
            IErrorMessageFix.OnSetErrorMessageProps(ErrorMessage);
            ErrorMessage.Modify();
        end;
    end;
}