codeunit 11745 "Service Header Handler CZL"
{
    var
        ServiceMgtSetup: Record "Service Mgt. Setup";

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnAfterInitRecord', '', false, false)]
    local procedure UpdateVatDateOnAfterInitRecord(var ServiceHeader: Record "Service Header")
    begin
        ServiceMgtSetup.Get();
        case ServiceMgtSetup."Default VAT Date CZL" of
            ServiceMgtSetup."Default VAT Date CZL"::"Posting Date":
                ServiceHeader."VAT Date CZL" := ServiceHeader."Posting Date";
            ServiceMgtSetup."Default VAT Date CZL"::"Document Date":
                ServiceHeader."VAT Date CZL" := ServiceHeader."Document Date";
            ServiceMgtSetup."Default VAT Date CZL"::Blank:
                ServiceHeader."VAT Date CZL" := 0D;
        end;

        if ServiceHeader."Document Type" = ServiceHeader."Document Type"::"Credit Memo" then
            ServiceHeader."Credit Memo Type CZL" := ServiceHeader."Credit Memo Type CZL"::"Corrective Tax Document";
        ServiceHeader.Validate("Credit Memo Type CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnBeforeValidateEvent', 'Posting Date', false, false)]
    local procedure UpdateVatDateOnBeforePostingDateValidate(var Rec: Record "Service Header")
    begin
        ServiceMgtSetup.Get();
        if ServiceMgtSetup."Default VAT Date CZL" = ServiceMgtSetup."Default VAT Date CZL"::"Posting Date" then
            Rec.Validate("VAT Date CZL", Rec."Posting Date");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnBeforeValidateEvent', 'Document Date', false, false)]
    local procedure UpdateVatDateOnBeforeDocumentDateValidate(var Rec: Record "Service Header")
    begin
        ServiceMgtSetup.Get();
        if ServiceMgtSetup."Default VAT Date CZL" = ServiceMgtSetup."Default VAT Date CZL"::"Document Date" then
            Rec.Validate("VAT Date CZL", Rec."Document Date");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnAfterCopyCustomerFields', '', false, false)]
    local procedure UpdateRegNoOnAfterCopyCustomerFields(var ServiceHeader: Record "Service Header"; Customer: Record Customer)
    begin
        ServiceHeader."Registration No. CZL" := Customer."Registration No. CZL";
        ServiceHeader."Tax Registration No. CZL" := Customer."Tax Registration No. CZL";
        if Customer."Transaction Type CZL" <> '' then
            ServiceHeader."Transaction Type" := Customer."Transaction Type CZL";
        ServiceHeader."Transaction Specification" := Customer."Transaction Specification CZL";
        ServiceHeader."Transport Method" := Customer."Transport Method CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnAfterCopyBillToCustomerFields', '', false, false)]
    local procedure UpdateUpdateBankInfoAndRegNosOnAfterCopyBillToCustomerFields(var ServiceHeader: Record "Service Header"; Customer: Record Customer)
    var
        CompanyInformation: Record "Company Information";
        ResponsibilityCenter: Record "Responsibility Center";
    begin
        if ServiceHeader."Document Type" <> ServiceHeader."Document Type"::"Credit Memo" then begin
            if ServiceHeader."Responsibility Center" = '' then begin
                CompanyInformation.Get();
                ServiceHeader.Validate("Bank Account Code CZL", CompanyInformation."Default Bank Account Code CZL");
            end else begin
                ResponsibilityCenter.Get(ServiceHeader."Responsibility Center");
                ServiceHeader.Validate("Bank Account Code CZL", ResponsibilityCenter."Default Bank Account Code CZL");
            end;
        end else
            ServiceHeader.Validate("Bank Account Code CZL", Customer."Preferred Bank Account Code");
        ServiceHeader."Registration No. CZL" := Customer."Registration No. CZL";
        ServiceHeader."Tax Registration No. CZL" := Customer."Tax Registration No. CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnBeforeValidateEvent', 'EU 3-Party Trade', false, false)]
    local procedure UpdateEU3PartyIntermedRoleOnBeforeEU3PartyTradeValidate(var Rec: Record "Service Header")
    begin
        if not Rec."EU 3-Party Trade" then
            Rec."EU 3-Party Intermed. Role CZL" := false;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnBeforeValidateEvent', 'Currency Code', false, false)]
    local procedure UpdateVatCurrencyCodeCZLOnBeforeCurrencyCodeValidate(var Rec: Record "Service Header")
    begin
        Rec.Validate("VAT Currency Code CZL", Rec."Currency Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnAfterValidateEvent', 'Currency Code', false, false)]
    local procedure UpdateVatCurrencyfactorCZLOnAfterCurrencyCodeValidate(var Rec: Record "Service Header"; var xRec: Record "Service Header"; CurrFieldNo: Integer)
    begin
        if CurrFieldNo <> Rec.FieldNo("Currency Code") then
            Rec.UpdateVATCurrencyFactorCZL()
        else
            if (Rec."Currency Code" <> xRec."Currency Code") or (Rec."Currency Code" <> '') then
                Rec.UpdateVATCurrencyFactorCZL();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnBeforeValidateEvent', 'Currency Factor', false, false)]
    local procedure UpdateVATCurrencyfactorCZLOnBeforeCurrencyFactorValidate(var Rec: Record "Service Header")
    begin
        Rec.UpdateVATCurrencyFactorCZL();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnBeforeValidateEvent', 'Customer Posting Group', false, false)]
    local procedure CheckPostingGroupChangeOnBeforeCustomerPostingGroupValidate(var Rec: Record "Service Header"; var xRec: Record "Service Header"; CurrFieldNo: Integer)
    var
        PostingGroupManagementCZL: Codeunit "Posting Group Management CZL";
    begin
        if CurrFieldNo = Rec.FieldNo("Customer Posting Group") then
            PostingGroupManagementCZL.CheckPostingGroupChange(Rec."Customer Posting Group", xRec."Customer Posting Group", Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnUpdateServLineByChangedFieldName', '', false, false)]
    local procedure UpdateServLineByChangedFieldName(ServiceHeader: Record "Service Header"; var ServiceLine: Record "Service Line"; ChangedFieldName: Text[100])
    begin
        case ChangedFieldName of
            ServiceHeader.FieldCaption("Physical Transfer CZL"):
                if (ServiceLine.Type = ServiceLine.Type::Item) and (ServiceLine."No." <> '') then begin
                    ServiceLine."Physical Transfer CZL" := ServiceHeader."Physical Transfer CZL";
                    ServiceLine.Modify(true);
                end;
        end;
    end;
}
