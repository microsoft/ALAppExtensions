// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Shared.Error;

using Microsoft.Finance.Dimension;
using System.Utilities;
using System.Reflection;
codeunit 7904 "Dimension Code Must Be Blank" implements ErrorMessageFix
{
    Access = Internal;

    var
        TempDimSetEntryGbl: Record "Dimension Set Entry" temporary;
        DimSetEntryFixMustBeBlankAckTok: Label 'The %1 is cleared.', Comment = '%1 = "Dimension Value Code" caption';
        DimensionUseRequiredActionLbl: Label 'Clear the value';
        DimensionMismatchTitleErr: Label '%1 %2 isn''t valid.', Comment = '%1 = "Dimension Value Code" caption, %2 = Dim Code';

    procedure OnSetErrorMessageProps(var ErrorMessage: Record "Error Message" temporary);
    var
        DefaultDimension: Record "Default Dimension";
        DimensionSetEntry: Record "Dimension Set Entry";
    begin
        DimensionSetEntry.Get(ErrorMessage."Sub-Context Record ID");
        ErrorMessage.Validate(Title, StrSubstNo(DimensionMismatchTitleErr, DefaultDimension.FieldCaption("Dimension Value Code"), DimensionSetEntry."Dimension Value Code"));
        ErrorMessage.Validate("Recommended Action Caption", DimensionUseRequiredActionLbl);
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
        DefaultDimension.TestField("Value Posting", DefaultDimension."Value Posting"::"No Code");
        TempDimSetEntryGbl.SetRange("Dimension Code", DefaultDimension."Dimension Code");
        TempDimSetEntryGbl.FindFirst();

        // Delete the dimension set entry.
        TempDimSetEntryGbl.Delete();
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
        exit(StrSubstNo(DimSetEntryFixMustBeBlankAckTok, TempDimSetEntryGbl.FieldCaption("Dimension Value Code")));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Error Message Management", OnAddSubContextToLastErrorMessage, '', false, false)]
    local procedure OnAddSubContextToLastErrorMessage(Tag: Text; VariantRec: Variant; var ErrorMessage: Record "Error Message" temporary)
    var
        DimSetEntry: Record "Dimension Set Entry";
        RecRef: RecordRef;
        IErrorMessageFix: Interface ErrorMessageFix;
    begin
        if Tag <> Enum::"Error Msg. Fix Implementation".Names().Get(Enum::"Error Msg. Fix Implementation"::DimensionCodeMustBeBlank.AsInteger() + 1) then
            exit;

        if VariantRec.IsRecord then begin
            RecRef.GetTable(VariantRec);
            if RecRef.Number = Database::"Dimension Set Entry" then begin
                RecRef.SetTable(DimSetEntry);
                ErrorMessage.Validate("Sub-Context Record ID", DimSetEntry.RecordId);
                ErrorMessage.Validate("Sub-Context Field Number", DimSetEntry.FieldNo("Dimension Value Code"));
                ErrorMessage.Validate("Error Msg. Fix Implementation", Enum::"Error Msg. Fix Implementation"::DimensionCodeMustBeBlank);

                // Use the interface to set title and recommended action caption
                IErrorMessageFix := ErrorMessage."Error Msg. Fix Implementation";
                IErrorMessageFix.OnSetErrorMessageProps(ErrorMessage);
                ErrorMessage.Modify();
            end;
        end;
    end;
}