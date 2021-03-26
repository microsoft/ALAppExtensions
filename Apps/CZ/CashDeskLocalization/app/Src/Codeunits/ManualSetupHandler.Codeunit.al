codeunit 31055 "Manual Setup Handler CZP"
{
    var
        Info: ModuleInfo;
        ManualSetupCategory: Enum "Manual Setup Category";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Manual Setup", 'OnRegisterManualSetup', '', false, false)]
    local procedure OnRegisterManualSetup(var Sender: Codeunit "Manual Setup")
    begin
        RegisterCashDesk(Sender);
        RegisterCashDeskEvent(Sender);
        RegisterNominalValue(Sender);
        RegisterPaymentMethod(Sender);
    end;

    local procedure RegisterCashDesk(var ManualSetup: Codeunit "Manual Setup")
    var
        CashDeskNameTxt: Label 'Cash Desks';
        CashDeskDescriptionTxt: Label 'Set up individual cash desks. For individual cash desk, you can set up No. Series, Cash desk users, etc.';
        CashDeskKeywordsTxt: Label 'Cash Desk';
    begin
        NavApp.GetCurrentModuleInfo(Info);
        ManualSetup.Insert(CashDeskNameTxt, CashDeskDescriptionTxt,
          CashDeskKeywordsTxt, Page::"Cash Desk List CZP",
          Info.Id(), ManualSetupCategory::Finance);
    end;

    local procedure RegisterCashDeskEvent(var ManualSetup: Codeunit "Manual Setup")
    var
        CashDeskEventNameTxt: Label 'Cash Desk Events';
        CashDeskEventDescriptionTxt: Label 'Define posting and VAT for cash events.';
        CashDeskEventKeywordsTxt: Label 'Cash Desk, Event, Receipt, Withdrawal';
    begin
        NavApp.GetCurrentModuleInfo(Info);
        ManualSetup.Insert(CashDeskEventNameTxt, CashDeskEventDescriptionTxt,
          CashDeskEventKeywordsTxt, Page::"Cash Desk Events Setup CZP",
          Info.Id(), ManualSetupCategory::Finance);
    end;

    local procedure RegisterNominalValue(var ManualSetup: Codeunit "Manual Setup")
    var
        CurrencyNominalValueNameTxt: Label 'Currency Nominal Values';
        CurrencyNominalValueDescriptionTxt: Label 'Define the currency values used in the cash registers.';
        CurrencyNominalValueKeywordsTxt: Label 'Cash Desk, Currency, Banknote, Coin';
    begin
        NavApp.GetCurrentModuleInfo(Info);
        ManualSetup.Insert(CurrencyNominalValueNameTxt, CurrencyNominalValueDescriptionTxt,
          CurrencyNominalValueKeywordsTxt, Page::"Currency Nominal Values CZP",
          Info.Id(), ManualSetupCategory::Finance);
    end;

    local procedure RegisterPaymentMethod(var ManualSetup: Codeunit "Manual Setup")
    var
        CurrencyPaymentMethodNameTxt: Label 'Payment Methods';
        CurrencyPaymentMethodDescriptionTxt: Label 'Define the payment methods used in the documents.';
        CurrencyPaymentMethodKeywordsTxt: Label 'Payment, Cash Desk';
    begin
        NavApp.GetCurrentModuleInfo(Info);
        ManualSetup.Insert(CurrencyPaymentMethodNameTxt, CurrencyPaymentMethodDescriptionTxt,
          CurrencyPaymentMethodKeywordsTxt, Page::"Payment Methods",
          Info.Id(), ManualSetupCategory::Finance);
    end;
}
