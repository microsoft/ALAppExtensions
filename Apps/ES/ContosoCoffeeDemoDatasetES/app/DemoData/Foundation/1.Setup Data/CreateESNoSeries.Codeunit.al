codeunit 10841 "Create ES No. Series"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoNoSeries: codeunit "Contoso No Series";
    begin
        ContosoNoSeries.SetOverwriteData(true);
        ContosoNoSeries.InsertNoSeries(AutoCreditMemo(), AutoCreditMemoLbl, 'AUTCR010', 'AUTCR990', '', '', 1, Enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeries.InsertNoSeries(AutoInvoice(), AutoInvoiceLbl, 'AUTINV010', 'AUTINV990', '', '', 1, Enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeries.SetOverwriteData(false);
    end;

    procedure AutoCreditMemo(): Code[20]
    begin
        exit(AutoCreditMemoTok);
    end;

    procedure AutoInvoice(): Code[20]
    begin
        exit(AutoInvoiceTok);
    end;

    var
        AutoCreditMemoTok: Label 'AUT-CR', MaxLength = 20;
        AutoCreditMemoLbl: Label 'AutoCreditMemo', MaxLength = 100;
        AutoInvoiceTok: Label 'AUT-INV', MaxLength = 20;
        AutoInvoiceLbl: Label 'AutoInvoice', MaxLength = 100;
}