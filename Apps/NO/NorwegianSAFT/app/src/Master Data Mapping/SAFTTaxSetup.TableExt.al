// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Setup;

using Microsoft.Finance.AuditFileExport;

tableextension 10679 "SAF-T Tax Setup" extends "VAT Posting Setup"
{
    fields
    {
        field(10670; "Sales SAF-T Tax Code"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Sales SAF-T Tax Code';
            Editable = false;

            trigger OnValidate()
            begin
                if "Sales SAF-T Tax Code" <> 0 then
                    VerifyTaxCodeExists("Sales SAF-T Tax Code");
            end;
        }
        field(10671; "Purchase SAF-T Tax Code"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Purchase SAF-T Tax Code';
            Editable = false;

            trigger OnValidate()
            begin
                if "Purchase SAF-T Tax Code" <> 0 then
                    VerifyTaxCodeExists("Purchase SAF-T Tax Code");
            end;
        }
        field(10672; "Sales SAF-T Standard Tax Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Sales SAF-T Standard Tax Code';
            TableRelation = "VAT Code";
            ObsoleteReason = 'Use the field "Sale VAT Reporting Code" in BaseApp W1.';
            ObsoleteState = Removed;
            ObsoleteTag = '26.0';
        }
        field(10673; "Purch. SAF-T Standard Tax Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Purchase SAF-T Standard Tax Code';
            TableRelation = "VAT Code";
            ObsoleteReason = 'Use the field "Purch. VAT Reporting Code" in BaseApp W1.';
            ObsoleteState = Removed;
            ObsoleteTag = '26.0';
        }
    }

    procedure AssignSAFTTaxCodes()
    var
        SAFTSetup: Record "SAF-T Setup";
    begin
        SAFTSetup.LockTable();
        if not SAFTSetup.Get() then begin
            SAFTSetup.Init();
            SAFTSetup.Insert();
        end;
        "Sales SAF-T Tax Code" := SAFTSetup."Last Tax Code" + 1;
        "Purchase SAF-T Tax Code" := "Sales SAF-T Tax Code" + 1;
        SAFTSetup."Last Tax Code" := "Purchase SAF-T Tax Code";
        SAFTSetup.Modify(true);
    end;

    local procedure VerifyTaxCodeExists(NewTaxCode: Integer)
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        VATPostingSetup.SetRange("Sales SAF-T Tax Code", NewTaxCode);
        if VATPostingSetup.FindFirst() then
            Error(
                AlreadyUsedErr, SAFTTaxCodeLbl, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", FieldCaption("Sales SAF-T Tax Code"));
        VATPostingSetup.SetRange("Sales SAF-T Tax Code");
        VATPostingSetup.SetRange("Purchase SAF-T Tax Code", NewTaxCode);
        if VATPostingSetup.FindFirst() then
            Error(
                AlreadyUsedErr, SAFTTaxCodeLbl, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", FieldCaption("Purchase SAF-T Tax Code"));
    end;

    var
        AlreadyUsedErr: Label '%1 is already used in VAT posting setup %2, %3, field %4', Comment = '%1 - name of the field, like SAF-T Tax Code. %2 - VAT Business Group Code. %3 - VAT Product Group Code';
        SAFTTaxCodeLbl: Label 'SAF-T Tax Code';
}
