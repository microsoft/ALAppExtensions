// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.EPR;

codeunit 6264 "Sust. Item Mat. Comp.-Copy"
{
    TableNo = "Sust. Item Mat. Comp. Header";

    var
        CannotBeCopiedToItselfErr: Label 'The %1 cannot be copied to itself.', Comment = '%1 = Table Caption';
        StatusMustNotBeCertifiedErr: Label '%1 on %2 %3 must not be %4', Comment = '%1 = Field Caption, %2 = Table Caption, %3 = Item Material Composition No., %4 = Field Value';

    procedure CopyItemMatComposition(FromItemMatCompositionNo: Code[20]; ItemMatCompositionHeader: Record "Sust. Item Mat. Comp. Header")
    var
        FromItemMatCompositionLine: Record "Sust. Item Mat. Comp. Line";
        ToItemMatCompositionLine: Record "Sust. Item Mat. Comp. Line";
    begin
        if (ItemMatCompositionHeader."No." = FromItemMatCompositionNo) then
            Error(CannotBeCopiedToItselfErr, ItemMatCompositionHeader.TableCaption());

        if ItemMatCompositionHeader.Status = ItemMatCompositionHeader.Status::Certified then
            Error(
              StatusMustNotBeCertifiedErr,
              ItemMatCompositionHeader.FieldCaption(Status),
              ItemMatCompositionHeader.TableCaption(),
              ItemMatCompositionHeader."No.",
              ItemMatCompositionHeader.Status);

        ToItemMatCompositionLine.SetRange("Item Material Composition No.", ItemMatCompositionHeader."No.");
        ToItemMatCompositionLine.DeleteAll();

        FromItemMatCompositionLine.SetRange("Item Material Composition No.", FromItemMatCompositionNo);
        if FromItemMatCompositionLine.FindSet() then
            repeat
                ToItemMatCompositionLine.Init();
                ToItemMatCompositionLine := FromItemMatCompositionLine;
                ToItemMatCompositionLine."Item Material Composition No." := ItemMatCompositionHeader."No.";
                ToItemMatCompositionLine.Insert();
            until FromItemMatCompositionLine.Next() = 0;
    end;
}