// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

table 31302 "Specific Movement CZ"
{
    Caption = 'Specific Movement';
    LookupPageID = "Specific Movements CZ";

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(5; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(10; "Description EN"; Text[100])
        {
            Caption = 'Description EN';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }

    var
        NegativeCodeTok: Label 'NN', MaxLength = 2, Locked = true;
        NegativeDescTxt: Label 'Negative declaration';
        NegativeDescENTxt: Label 'Negative declaration', Locked = true;
        StandardCodeTok: Label 'ST', MaxLength = 2, Locked = true;
        StandardDescTxt: Label 'Standard declaration';
        StandardDescENTxt: Label 'Standard declaration', Locked = true;

    procedure GetNegativeCode(): Code[2]
    begin
        exit(NegativeCodeTok);
    end;

    procedure GetStandardCode(): Code[2]
    begin
        exit(StandardCodeTok);
    end;

    procedure GetOrCreate(SpecificMovementCode: Code[10]): Boolean
    begin
        if not Get(SpecificMovementCode) then begin
            Init();
            Code := SpecificMovementCode;
            case SpecificMovementCode of
                GetNegativeCode():
                    begin
                        Description := NegativeDescTxt;
                        "Description EN" := NegativeDescENTxt;
                    end;
                GetStandardCode():
                    begin
                        Description := StandardDescTxt;
                        "Description EN" := StandardDescENTxt;
                    end;
            end;
            OnBeforeInsertSpecificMovement(Rec);
            Insert();
        end;
        exit(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertSpecificMovement(var SpecificMovement: Record "Specific Movement CZ")
    begin
    end;
}