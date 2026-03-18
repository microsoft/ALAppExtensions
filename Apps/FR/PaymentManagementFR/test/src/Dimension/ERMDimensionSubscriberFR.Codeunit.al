// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using System.Reflection;

codeunit 144000 "ERM Dimension Subscriber - FR"
{

    trigger OnRun()
    begin
    end;

    var
        LibraryDim: Codeunit "Library - Dimension";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Library - Dimension", 'OnVerifyShorcutDimCodesUpdatedOnDimSetIDValidationLocal', '', false, false)]
    local procedure VerifyShorcutDimCodesUpdatedOnDimSetIDValidation(var TempAllObj: Record AllObj temporary; DimSetID: Integer; GlobalDim1ValueCode: Code[20]; GlobalDim2ValueCode: Code[20])
    var
        PaymentHeader: Record "Payment Header FR";
    begin
        // Verifies local tables with "Dimension Set ID" field related to "Dimension Set Entry" and OnValidate trigger which updates shortcut dimensions

        LibraryDim.VerifyShorcutDimCodesUpdatedOnDimSetIDValidation(
          TempAllObj, PaymentHeader, PaymentHeader.FieldNo("Dimension Set ID"),
          PaymentHeader.FieldNo("Shortcut Dimension 1 Code"), PaymentHeader.FieldNo("Shortcut Dimension 2 Code"),
          DimSetID, GlobalDim1ValueCode, GlobalDim2ValueCode);
    end;
}

