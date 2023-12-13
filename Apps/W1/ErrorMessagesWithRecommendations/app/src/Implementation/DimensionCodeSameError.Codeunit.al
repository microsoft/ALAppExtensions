// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Shared.Error;

using Microsoft.Finance.Dimension;
using System.Utilities;
using System.Reflection;
codeunit 7903 "Dimension Code Same Error" implements ErrorMessageFix
{
    Access = Internal;

    var
        TempDimSetEntryGbl: Record "Dimension Set Entry" temporary;
        DimSetEntryFixUseSameCodeAckTok: Label 'The %1 is set to %2.', Comment = '%1 = "Dimension Value Code" caption, %2 = "Dimension Value Code" Value';
        DimensionUseRequiredActionLbl: Label 'Set the value to %1', Comment = '%1 = "Dimension Value Code" Value';
        DimensionMismatchTitleErr: Label '%1 %2 isn''t valid.', Comment = '%1 = "Dimension Value Code" caption, %2 = "Dimension Value Code" value';

    procedure OnSetErrorMessageProps(var ErrorMessage: Record "Error Message" temporary);
    var
        DefaultDimension: Record "Default Dimension";
        DimensionSetEntry: Record "Dimension Set Entry";
    begin
        DimensionSetEntry.Get(ErrorMessage."Sub-Context Record ID");
        DefaultDimension.Get(ErrorMessage."Record ID");
        ErrorMessage.Validate(Title, StrSubstNo(DimensionMismatchTitleErr, DefaultDimension.FieldCaption("Dimension Value Code"), DimensionSetEntry."Dimension Value Code"));
        ErrorMessage.Validate("Recommended Action Caption", StrSubstNo(DimensionUseRequiredActionLbl, DefaultDimension."Dimension Value Code"));
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
        TempDimSetEntryGbl.FindFirst();

        // Update the dimension value code for the dimensions set entry.
        TempDimSetEntryGbl.Validate("Dimension Value Code", DefaultDimension."Dimension Value Code");
        TempDimSetEntryGbl.Modify();
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
        exit(StrSubstNo(DimSetEntryFixUseSameCodeAckTok, TempDimSetEntryGbl.FieldCaption("Dimension Value Code"), TempDimSetEntryGbl."Dimension Value Code"));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Error Message Management", OnAddSubContextToLastErrorMessage, '', false, false)]
    local procedure OnAddSubContextToLastErrorMessage(Tag: Text; VariantRec: Variant; var ErrorMessage: Record "Error Message" temporary)
    var
        DimSetEntry: Record "Dimension Set Entry";
        RecRef: RecordRef;
        IErrorMessageFix: Interface ErrorMessageFix;
    begin
        if Tag <> Enum::"Error Msg. Fix Implementation".Names().Get(Enum::"Error Msg. Fix Implementation"::DimensionCodeSameError.AsInteger() + 1) then
            exit;

        if VariantRec.IsRecord then begin
            RecRef.GetTable(VariantRec);
            if RecRef.Number = Database::"Dimension Set Entry" then begin
                RecRef.SetTable(DimSetEntry);
                ErrorMessage.Validate("Sub-Context Record ID", DimSetEntry.RecordId);
                ErrorMessage.Validate("Sub-Context Field Number", DimSetEntry.FieldNo("Dimension Value Code"));
                ErrorMessage.Validate("Error Msg. Fix Implementation", Enum::"Error Msg. Fix Implementation"::DimensionCodeSameError);

                // Use the interface to set title and recommended action caption
                IErrorMessageFix := ErrorMessage."Error Msg. Fix Implementation";
                IErrorMessageFix.OnSetErrorMessageProps(ErrorMessage);
                ErrorMessage.Modify();
            end;
        end;
    end;
}