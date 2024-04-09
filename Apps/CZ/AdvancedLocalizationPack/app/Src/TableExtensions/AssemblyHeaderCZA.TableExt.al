// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Assembly.Document;

using Microsoft.Finance.GeneralLedger.Setup;
using System.Utilities;

tableextension 31258 "Assembly Header CZA" extends "Assembly Header"
{
    fields
    {
        field(31060; "Gen. Bus. Posting Group CZA"; Code[20])
        {
            Caption = 'Gen. Bus. Posting Group';
            TableRelation = "Gen. Business Posting Group";
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                AssemblyLine: Record "Assembly Line";
                ConfirmManagement: Codeunit "Confirm Management";
                ChangeFieldQst: Label 'Do you want change %1 from %2 to %3 in all lines?', Comment = '%1 = Gen. Bus. Posting Group CZA FieldCaption, %2 = xRec Gen. Bus. Posting Group CZA, %3 = Gen. Bus. Posting Group CZA';
            begin
                if Rec."Gen. Bus. Posting Group CZA" = xRec."Gen. Bus. Posting Group CZA" then
                    exit;
                AssemblyLine.SetRange("Document Type", Rec."Document Type");
                AssemblyLine.SetRange("Document No.", Rec."No.");
                AssemblyLine.SetFilter(Type, '<>%1', AssemblyLine.Type::" ");
                if AssemblyLine.IsEmpty() then
                    exit;

                if CurrFieldNo = FieldNo("Gen. Bus. Posting Group CZA") then
                    if GuiAllowed() then
                        if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(ChangeFieldQst, FieldCaption("Gen. Bus. Posting Group CZA"),
                                                                      xRec."Gen. Bus. Posting Group CZA", Rec."Gen. Bus. Posting Group CZA"), true)
                        then
                            exit;

                AssemblyLine.ModifyAll("Gen. Bus. Posting Group CZA", Rec."Gen. Bus. Posting Group CZA");
            end;
        }
    }
}
