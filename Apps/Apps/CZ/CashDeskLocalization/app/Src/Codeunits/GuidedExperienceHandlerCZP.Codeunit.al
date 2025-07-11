// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using Microsoft.Bank.BankAccount;
using System.Environment.Configuration;

codeunit 31055 "Guided Experience Handler CZP"
{
    Access = Internal;

    var
        GuidedExperience: Codeunit "Guided Experience";
        ManualSetupCategory: Enum "Manual Setup Category";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guided Experience", 'OnRegisterManualSetup', '', false, false)]
    local procedure OnRegisterManualSetup()
    begin
        RegisterCashDesks();
        RegisterCashDeskEvents();
        RegisterNominalValues();
        RegisterPaymentMethods();
    end;

    local procedure RegisterCashDesks()
    var
        CashDeskNameTxt: Label 'Cash Desks';
        CashDeskDescriptionTxt: Label 'Set up individual cash desks. For individual cash desk, you can set up No. Series, Cash desk users, etc.';
        CashDeskKeywordsTxt: Label 'Cash Desk';
    begin
        GuidedExperience.InsertManualSetup(CashDeskNameTxt, CashDeskNameTxt, CashDeskDescriptionTxt,
          10, ObjectType::Page, Page::"Cash Desk List CZP", ManualSetupCategory::"Cash Desk CZP", CashDeskKeywordsTxt);
    end;

    local procedure RegisterCashDeskEvents()
    var
        CashDeskEventNameTxt: Label 'Cash Desk Events';
        CashDeskEventDescriptionTxt: Label 'Define posting and VAT for cash events.';
        CashDeskEventKeywordsTxt: Label 'Cash Desk, Event, Receipt, Withdrawal';
    begin
        GuidedExperience.InsertManualSetup(CashDeskEventNameTxt, CashDeskEventNameTxt, CashDeskEventDescriptionTxt,
          5, ObjectType::Page, Page::"Cash Desk Events Setup CZP", ManualSetupCategory::"Cash Desk CZP", CashDeskEventKeywordsTxt);
    end;

    local procedure RegisterNominalValues()
    var
        CurrencyNominalValueNameTxt: Label 'Currency Nominal Values';
        CurrencyNominalValueDescriptionTxt: Label 'Define the currency values used in the cash registers.';
        CurrencyNominalValueKeywordsTxt: Label 'Cash Desk, Currency, Banknote, Coin';
    begin
        GuidedExperience.InsertManualSetup(CurrencyNominalValueNameTxt, CurrencyNominalValueNameTxt, CurrencyNominalValueDescriptionTxt,
          2, ObjectType::Page, Page::"Currency Nominal Values CZP", ManualSetupCategory::"Cash Desk CZP", CurrencyNominalValueKeywordsTxt);
    end;

    local procedure RegisterPaymentMethods()
    var
        CurrencyPaymentMethodNameTxt: Label 'Payment Methods';
        CurrencyPaymentMethodDescriptionTxt: Label 'Define the payment methods used in the documents.';
        CurrencyPaymentMethodKeywordsTxt: Label 'Payment, Cash Desk';
    begin
        GuidedExperience.InsertManualSetup(CurrencyPaymentMethodNameTxt, CurrencyPaymentMethodNameTxt, CurrencyPaymentMethodDescriptionTxt,
          5, ObjectType::Page, Page::"Payment Methods", ManualSetupCategory::"Cash Desk CZP", CurrencyPaymentMethodKeywordsTxt);
    end;
}
