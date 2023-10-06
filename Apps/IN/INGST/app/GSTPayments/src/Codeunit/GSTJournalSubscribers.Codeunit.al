// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Payments;

using Microsoft.Finance.GeneralLedger.Journal;

codeunit 18245 "GST Journal Subscribers"
{
    var
        GSTJournalValidations: Codeunit "GST Journal Validations";
        GSTJournalLineValidations: Codeunit "GST Journal Line Validations";

    //Bank Charge Subscribers
    [EventSubscriber(ObjectType::Table, Database::"Bank Charge", 'OnAfterValidateEvent', 'GST Group Code', False, False)]
    local procedure ValidateGSTGroupCodeBankCharge(var Rec: Record "Bank Charge")
    begin
        GSTJournalValidations.GSTGroupCodeBankCharge(rec);
    end;

    //Bank Charge Deemed Value Setup - Subscribers
    [EventSubscriber(ObjectType::Table, Database::"Bank Charge Deemed Value Setup", 'OnAfterValidateEvent', 'Lower Limit', False, False)]
    local procedure ValidateLowerLimit(var Rec: Record "Bank Charge Deemed Value Setup")
    begin

        GSTJournalValidations.LowerLimit(rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bank Charge Deemed Value Setup", 'OnAfterValidateEvent', 'Upper Limit', False, False)]
    local procedure ValidateUpperLimit(
        var Rec: Record "Bank Charge Deemed Value Setup";
        var xRec: Record "Bank Charge Deemed Value Setup")
    begin
        GSTJournalValidations.Upperlimit(rec, xRec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bank Charge Deemed Value Setup", 'OnAfterDeleteEvent', '', False, False)]
    local procedure ValidateBankChargeDeemedDelete(var Rec: Record "Bank Charge Deemed Value Setup")
    begin
        GSTJournalValidations.BankChargeDeemedDelete(rec);
    end;

    //Journal Bank Charges Subscribers
    [EventSubscriber(ObjectType::Table, Database::"Journal Bank Charges", 'OnAfterValidateEvent', 'Bank Charge', false, false)]
    local procedure ValidateBankCharge(var Rec: Record "Journal Bank Charges")
    begin
        GSTJournalValidations.JnlBankCharge(rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Journal Bank Charges", 'OnAfterValidateEvent', 'Amount', false, false)]
    local procedure ValidatejnlAmount(var Rec: Record "Journal Bank Charges")
    begin
        GSTJournalValidations.JnlBankChargeAmount(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Journal Bank Charges", 'OnAfterValidateEvent', 'GST Group Code', false, false)]
    local procedure ValidateJnlBankChargeGSTGroupCode(var Rec: Record "Journal Bank Charges")
    begin
        GSTJournalValidations.JnlBankChargeGSTGroupCode(rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Journal Bank Charges", 'OnAfterValidateEvent', 'LCY', false, false)]
    local procedure validateLcy(var Rec: Record "Journal Bank Charges")
    begin
        Rec.Validate(amount, Rec.amount);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Journal Bank Charges", 'OnAfterValidateEvent', 'GST Document Type', false, false)]
    local procedure ValidateGSTDocumentType(var Rec: Record "Journal Bank Charges")
    begin
        GSTJournalValidations.JnlBankChargeGSTDocumentType(rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'Order Address Code', false, false)]
    local procedure ValidateOrderAddressCode(var Rec: Record "Gen. Journal Line")
    begin
        GSTJournalLineValidations.OrderAddressCode(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Journal Bank Charges", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterInsertEventCheckMultipleBankCharge(var Rec: Record "Journal Bank Charges")
    begin
        if Rec.IsTemporary() then
            exit;

        GSTJournalValidations.CheckMultipleBankCharge(Rec);
    end;
}
