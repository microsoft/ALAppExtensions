// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Inventory.Item;

tableextension 31326 "Intrastat Report Setup CZ" extends "Intrastat Report Setup"
{
    fields
    {
        field(31300; "No Item Charges in Int. CZ"; Boolean)
        {
            Caption = 'No Item Charges in Intrastat';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                ItemCharge: Record "Item Charge";
            begin
                ItemCharge.Reset();
                ItemCharge.SetRange("Incl. in Intrastat Amount CZ", true);
                if ItemCharge.FindFirst() then
                    Error(ItemChargeIncludedErr,
                      Rec.FieldCaption("No Item Charges in Int. CZ"),
                      ItemCharge.TableCaption(), ItemCharge.FieldCaption("Incl. in Intrastat Amount CZ"));
            end;
        }
        field(31305; "Transaction Type Mandatory CZ"; Boolean)
        {
            Caption = 'Transaction Type Mandatory';
            DataClassification = CustomerContent;
        }
        field(31306; "Transaction Spec. Mandatory CZ"; Boolean)
        {
            Caption = 'Transaction Spec. Mandatory';
            DataClassification = CustomerContent;
        }
        field(31307; "Transport Method Mandatory CZ"; Boolean)
        {
            Caption = 'Transport Method Mandatory';
            DataClassification = CustomerContent;
        }
        field(31308; "Shipment Method Mandatory CZ"; Boolean)
        {
            Caption = 'Shipment Method Mandatory';
            DataClassification = CustomerContent;
        }
        field(31310; "Intrastat Rounding Type CZ"; Enum "Intrastat Rounding Type CZ")
        {
            Caption = 'Intrastat Rounding Type';
            DataClassification = CustomerContent;
        }
        field(31315; "Def. Phys. Trans. - Returns CZ"; Boolean)
        {
            Caption = 'Default Phys. Trans. - Returns';
            DataClassification = CustomerContent;
        }
    }

    var
        ItemChargeIncludedErr: Label 'You cannot uncheck %1 until you have %2 with checked field %3.', Comment = '%1 = field caption, %2 = table caption of item charge; %3 = field caption';

    procedure GetRoundingDirectionCZ(): Text[1]
    begin
        Get();
        case "Intrastat Rounding Type CZ" of
            "Intrastat Rounding Type CZ"::Nearest:
                exit('=');
            "Intrastat Rounding Type CZ"::Up:
                exit('>');
            "Intrastat Rounding Type CZ"::Down:
                exit('<');
        end;
    end;

    procedure GetDefaultPhysicalTransferCZ(): Boolean
    begin
        if not Get() then
            exit(false);
        exit("Def. Phys. Trans. - Returns CZ");
    end;

    procedure GetDefaultTransactionTypeCZ(IsPhysicalTransfer: Boolean; IsCreditDocType: Boolean): Code[10]
    begin
        Get();
        if (IsCreditDocType and IsPhysicalTransfer) or
           (not IsCreditDocType and not IsPhysicalTransfer)
        then
            exit("Default Trans. - Return");
        exit("Default Trans. - Purchase");
    end;
}