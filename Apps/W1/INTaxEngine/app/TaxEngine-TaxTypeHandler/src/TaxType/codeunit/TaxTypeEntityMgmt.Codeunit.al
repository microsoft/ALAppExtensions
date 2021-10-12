codeunit 20240 "Tax Type Entity Mgmt."
{
    local procedure ValidateTaxType(TaxType: Record "Tax Type"; xTaxType: Record "Tax Type")
    begin
        if not CompanyInfoExist() then
            exit;

        if (not xTaxType.Enabled) and (TaxType.Enabled) then begin
            TaxType.TestField(Status, TaxType.Status::Released);
            exit;
        end;

        if (TaxType.Status = TaxType.Status::Released) and (xTaxType.Status = xTaxType.Status::Draft) then
            exit;

        CheckStatus(TaxType);
    end;

    local procedure ValidateTaxType(TaxTypeCode: Code[20])
    var
        TaxType: Record "Tax Type";
    begin
        if not CompanyInfoExist() then
            exit;

        if not TaxType.Get(TaxTypeCode) then
            exit;

        CheckStatus(TaxType);
    end;

    local procedure CompanyInfoExist(): Boolean
    var
        CompanyInformation: Record "Company Information";
    begin
        exit(CompanyInformation.Get());
    end;

    local procedure CheckStatus(TaxType: Record "Tax Type")
    begin
        if TaxType.Status = TaxType.Status::Released then
            Error(CannotChangeReleasedTaxTypeErr, TaxType.Description);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Tax Type", 'OnBeforeModifyEvent', '', false, false)]
    local procedure OnBeforeModifyTaxType(var Rec: Record "Tax Type"; var xRec: Record "Tax Type"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;

        if not RunTrigger then
            exit;

        if Format(Rec) = Format(xRec) then
            exit;

        ValidateTaxType(Rec, xRec);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Type Object Helper", 'OnBeforeValidateIfUpdateIsAllowed', '', false, false)]
    local procedure OnBeforeValidateIfUpdateIsAllowed(TaxType: Code[20])
    begin
        ValidateTaxType(TaxType);
    end;

    var
        CannotChangeReleasedTaxTypeErr: Label 'You cannot change configuration on Released tax type : %1', Comment = '%1 = tax type dscription';
}