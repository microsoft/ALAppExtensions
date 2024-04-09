// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Document;

using Microsoft.Sales.Customer;
#if not CLEAN22
using Microsoft.Service.Setup;
#endif

codeunit 11745 "Service Header Handler CZL"
{
#if not CLEAN22

    var
        ServiceMgtSetup: Record "Service Mgt. Setup";
#endif
    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnAfterInitRecord', '', false, false)]
    local procedure UpdateVatDateOnAfterInitRecord(var ServiceHeader: Record "Service Header")
    begin
#if not CLEAN22
#pragma warning disable AL0432
        if not ServiceHeader.IsReplaceVATDateEnabled() then begin
            ServiceMgtSetup.Get();
            case ServiceMgtSetup."Default VAT Date CZL" of
                ServiceMgtSetup."Default VAT Date CZL"::"Posting Date":
                    ServiceHeader."VAT Date CZL" := ServiceHeader."Posting Date";
                ServiceMgtSetup."Default VAT Date CZL"::"Document Date":
                    ServiceHeader."VAT Date CZL" := ServiceHeader."Document Date";
                ServiceMgtSetup."Default VAT Date CZL"::Blank:
                    ServiceHeader."VAT Date CZL" := 0D;
            end;
        end;
#pragma warning restore AL0432
#endif
        if ServiceHeader."Document Type" = ServiceHeader."Document Type"::"Credit Memo" then
            ServiceHeader."Credit Memo Type CZL" := ServiceHeader."Credit Memo Type CZL"::"Corrective Tax Document";
        ServiceHeader.Validate("Credit Memo Type CZL");
    end;
#if not CLEAN22
#pragma warning disable AL0432
    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnBeforeValidateEvent', 'Posting Date', false, false)]
    local procedure UpdateVatDateOnBeforePostingDateValidate(var Rec: Record "Service Header")
    begin
        if Rec.IsReplaceVATDateEnabled() then
            exit;
        ServiceMgtSetup.Get();
        if ServiceMgtSetup."Default VAT Date CZL" = ServiceMgtSetup."Default VAT Date CZL"::"Posting Date" then
            Rec.Validate("VAT Date CZL", Rec."Posting Date");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnBeforeValidateEvent', 'Document Date', false, false)]
    local procedure UpdateVatDateOnBeforeDocumentDateValidate(var Rec: Record "Service Header")
    begin
        if Rec.IsReplaceVATDateEnabled() then
            exit;
        ServiceMgtSetup.Get();
        if ServiceMgtSetup."Default VAT Date CZL" = ServiceMgtSetup."Default VAT Date CZL"::"Document Date" then
            Rec.Validate("VAT Date CZL", Rec."Document Date");
    end;
#pragma warning restore AL0432
#endif

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnAfterCopyCustomerFields', '', false, false)]
    local procedure UpdateRegNoOnAfterCopyCustomerFields(var ServiceHeader: Record "Service Header"; Customer: Record Customer)
    begin
        ServiceHeader."Registration No. CZL" := Customer.GetRegistrationNoTrimmedCZL();
        ServiceHeader."Tax Registration No. CZL" := Customer."Tax Registration No. CZL";
#if not CLEAN22
#pragma warning disable AL0432
        if Customer."Transaction Type CZL" <> '' then
            ServiceHeader."Transaction Type" := Customer."Transaction Type CZL";
        ServiceHeader."Transaction Specification" := Customer."Transaction Specification CZL";
        ServiceHeader."Transport Method" := Customer."Transport Method CZL";
#pragma warning restore AL0432
#endif
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnAfterCopyBillToCustomerFields', '', false, false)]
    local procedure UpdateUpdateBankInfoAndRegNosOnAfterCopyBillToCustomerFields(var ServiceHeader: Record "Service Header"; Customer: Record Customer)
    begin
        if ServiceHeader."Document Type" <> ServiceHeader."Document Type"::"Credit Memo" then
            ServiceHeader.Validate("Bank Account Code CZL", ServiceHeader.GetDefaulBankAccountNoCZL())
        else
            ServiceHeader.Validate("Bank Account Code CZL", Customer."Preferred Bank Account Code");
        ServiceHeader."Registration No. CZL" := Customer.GetRegistrationNoTrimmedCZL();
        ServiceHeader."Tax Registration No. CZL" := Customer."Tax Registration No. CZL";
        ServiceHeader."VAT Registration No." := Customer."VAT Registration No.";
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
#if not CLEAN22

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnUpdateServLineByChangedFieldName', '', false, false)]
    local procedure UpdateServLineByChangedFieldName(ServiceHeader: Record "Service Header"; var ServiceLine: Record "Service Line"; ChangedFieldName: Text[100])
    begin
        case ChangedFieldName of
#pragma warning disable AL0432
            ServiceHeader.FieldCaption("Physical Transfer CZL"):
                if (ServiceLine.Type = ServiceLine.Type::Item) and (ServiceLine."No." <> '') then begin
                    ServiceLine."Physical Transfer CZL" := ServiceHeader."Physical Transfer CZL";
#pragma warning disable AL0432
                    ServiceLine.Modify(true);
                end;
        end;
    end;
#endif

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnAfterValidateEvent', 'VAT Country/Region Code', false, false)]
    local procedure UpdateVATRegistrationNoCodeOnAfterVATCountryRegionCodeValidate(var Rec: Record "Service Header")
    var
        BillToCustomer: Record Customer;
    begin
        if Rec."Bill-to Customer No." <> '' then begin
            BillToCustomer.Get(Rec."Bill-to Customer No.");
            Rec."VAT Registration No." := BillToCustomer."VAT Registration No.";
        end;
    end;
}
