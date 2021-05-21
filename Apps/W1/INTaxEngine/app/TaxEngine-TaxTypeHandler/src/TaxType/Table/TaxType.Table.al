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
        }
        field(4; "Accounting Period"; Text[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Accounting Period';
            TableRelation = "Tax Acc. Period Setup".Code;
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
        ConfirmTaxTypeDeleteQst: Label 'Deleting Tax Type will also delete its related configurations and use cases. Do you want to continue.';

    trigger OnDelete()
    var
        TaxEntity: Record "Tax Entity";
        TaxAttribute: Record "Tax Attribute";
        TaxComponent: Record "Tax Component";
        TaxRateColumnSetup: Record "Tax Rate Column Setup";
    begin
        if not HideDialog then
            if not confirm(ConfirmTaxTypeDeleteQst) then
                Error('');

        OnBeforeDeleteTaxType(Code); //This publisher will make sure that use cases are deleted before attributes.
        TaxEntity.SetRange("Tax Type", Code);
        if not TaxEntity.IsEmpty() then
            TaxEntity.DeleteAll(true);

        TaxAttribute.SetRange("Tax Type", Code);
        if not TaxAttribute.IsEmpty() then
            TaxAttribute.DeleteAll(true);

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

    [IntegrationEvent(false, false)]
    local procedure OnBeforeDeleteTaxType(TaxTypeCode: Code[20])
    begin
    end;
}