// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document.Attachment;

table 7277 "Attachment Mapping"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    TableType = Temporary;
    Access = Internal;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
        }
        field(2; "Column Name"; Text[2048])
        {
            Caption = 'Column Name';
            DataClassification = SystemMetadata;
        }
        field(3; "Column Type"; Enum "Column Type")
        {
            Caption = 'Column Type';
            DataClassification = SystemMetadata;
        }
        field(4; "Column Action"; Enum "Column Action")
        {
            Caption = 'Column Action';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            var
                TempAttachmentMapping: Record "Attachment Mapping" temporary;
            begin
                if Rec."Column Action" = xRec."Column Action" then
                    exit;

                if Rec."Column Action" = Rec."Column Action"::"Quantity Info." then begin
                    if Rec."Column Type" <> Rec."Column Type"::Number then
                        if not Confirm(MismatchColumnTypeQst, false, Rec.FieldCaption("Column Type")) then
                            Error(''); // Cancel the action
                    TempAttachmentMapping.Copy(Rec, true);
                    TempAttachmentMapping.SetFilter("Entry No.", '<> %1', Rec."Entry No.");
                    TempAttachmentMapping.SetRange("Column Action", TempAttachmentMapping."Column Action"::"Quantity Info.");
                    TempAttachmentMapping.ModifyAll("Column Action", Rec."Column Action"::Ignore);
                end;

                if Rec."Column Action" = Rec."Column Action"::"UoM Info." then begin
                    TempAttachmentMapping.Copy(Rec, true);
                    TempAttachmentMapping.SetFilter("Entry No.", '<> %1', Rec."Entry No.");
                    TempAttachmentMapping.SetRange("Column Action", TempAttachmentMapping."Column Action"::"UoM Info.");
                    TempAttachmentMapping.ModifyAll("Column Action", Rec."Column Action"::Ignore);
                end
            end;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }

    internal procedure IncrementEntryNumber()
    var
        TempAttachmentMappingPart: Record "Attachment Mapping" temporary;
    begin
        TempAttachmentMappingPart.Copy(Rec, true);
        if TempAttachmentMappingPart.FindLast() then
            Rec."Entry No." := TempAttachmentMappingPart."Entry No." + 1
        else
            Rec."Entry No." := 1;
    end;

    var
        MismatchColumnTypeQst: Label 'The %1 is not of type numeric. Do you want to continue?', Comment = '%1 = column type field caption';
}