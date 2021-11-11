table 20258 "Tax Type"
{
    Caption = 'Tax Type';
    DataClassification = EndUserIdentifiableInformation;
    Access = Public;
    Extensible = false;
    fields
    {
        field(1; Code; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Code';
        }
        field(2; Description; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
        field(3; Enabled; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Enable';
            trigger OnValidate()
            begin
                if Rec.IsTemporary then
                    exit;

                if Enabled then
                    if Status <> Status::Released then
                        Error(TaxTypeStatusLbl, Status);
            end;
        }
        field(4; "Accounting Period"; Text[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Accounting Period';
            TableRelation = "Tax Acc. Period Setup".Code;
        }
        field(10; "Major Version"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Major Version';
        }
        field(11; "Minor Version"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Minor Version';
        }
        field(12; "Effective From"; DateTime)
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Effective From';
        }
        field(13; "Status"; Enum "Tax Type Status")
        {
            DataClassification = CustomerContent;
            Caption = 'Tax Type Status';
        }
        field(14; "Changed By"; Text[80])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Changed By';
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }

    var
        HideDialog: Boolean;
        SkipUseCaseDeletion: Boolean;
        ConfirmTaxTypeDeleteQst: Label 'Deleting Tax Type will also delete its related tax rates and use cases. Do you want to continue.';
        TaxTypeStatusLbl: Label 'You cannot enable a tax type with status %1', Comment = '%1 = Status';

    trigger OnDelete()
    var
        TaxEntity: Record "Tax Entity";
        TaxAttribute: Record "Tax Attribute";
        TaxComponent: Record "Tax Component";
        TaxRateColumnSetup: Record "Tax Rate Column Setup";
        ArchivalSingleInstance: Codeunit "Archival Single Instance";
    begin
        if not SkipUseCaseDeletion then begin
            if not HideDialog then
                if not confirm(ConfirmTaxTypeDeleteQst) then
                    Error('');

            OnBeforeDeleteTaxType(Code); //This publisher will make sure that use cases are deleted before attributes.
        end;

        TaxEntity.SetRange("Tax Type", Code);
        if not TaxEntity.IsEmpty() then
            TaxEntity.DeleteAll(true);

        ArchivalSingleInstance.SetSkipTaxAttributeDeletion(SkipUseCaseDeletion);
        TaxAttribute.SetRange("Tax Type", Code);
        if not TaxAttribute.IsEmpty() then
            TaxAttribute.DeleteAll(true);

        ArchivalSingleInstance.SetSkipTaxComponentDeletion(SkipUseCaseDeletion);
        TaxComponent.SetRange("Tax Type", Code);
        if not TaxComponent.IsEmpty() then
            TaxComponent.DeleteAll(true);

        TaxRateColumnSetup.SetRange("Tax Type", Code);
        if not TaxRateColumnSetup.IsEmpty() then
            TaxRateColumnSetup.DeleteAll(true);
    end;

    procedure SetHideDialog(NewHideDialog: Boolean)
    begin
        HideDialog := NewHideDialog;
    end;

    procedure SetSkipUseCaseDeletion(NewSkipUseCaseDeletion: Boolean)
    begin
        SkipUseCaseDeletion := NewSkipUseCaseDeletion;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeDeleteTaxType(TaxTypeCode: Code[20])
    begin
    end;
}