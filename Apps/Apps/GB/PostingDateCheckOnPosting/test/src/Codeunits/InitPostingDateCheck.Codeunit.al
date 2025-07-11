namespace Microsoft.SalesPurch.Setup;

using Microsoft.Purchases.Setup;
using Microsoft.Sales.Setup;
codeunit 144000 "Init Posting Date Check"
{

    Subtype = Test;
    TestPermissions = Disabled;

    [Test]
    procedure PurchSetupInitialDefaultCheckOnPostingMethod()
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
    begin
        PurchasesPayablesSetup.Delete();
        PurchasesPayablesSetup.Init();
        PurchasesPayablesSetup.Insert();

        PurchasesPayablesSetup.TestField(
            PurchasesPayablesSetup."Posting Date Check on Posting", true);
    end;

    [Test]
    procedure SalesSetupInitialDefaultCheckOnPostingMethod()
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        SalesReceivablesSetup.Delete();
        SalesReceivablesSetup.Init();
        SalesReceivablesSetup.Insert();

        SalesReceivablesSetup.TestField(
            SalesReceivablesSetup."Posting Date Check on Posting", true);
    end;

    [Test]
    procedure PurchSetupModifyCheckOnPostingMethod()
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
    begin
        PurchasesPayablesSetup.Get();
        PurchasesPayablesSetup."Posting Date Check on Posting" := false;
        PurchasesPayablesSetup.Modify();

        PurchasesPayablesSetup.TestField(
            PurchasesPayablesSetup."Posting Date Check on Posting", false);
    end;

    [Test]
    procedure PurchSetupValidateCheckOnPostingMethod()
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
    begin
        PurchasesPayablesSetup.Get();
        PurchasesPayablesSetup.Validate("Posting Date Check on Posting", false);

        PurchasesPayablesSetup.TestField(
            PurchasesPayablesSetup."Posting Date Check on Posting", false);
    end;

    [Test]
    procedure SalesSetupModifyCheckOnPostingMethod()
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        SalesReceivablesSetup.Get();
        SalesReceivablesSetup."Posting Date Check on Posting" := false;
        SalesReceivablesSetup.Modify();

        SalesReceivablesSetup.TestField(
            SalesReceivablesSetup."Posting Date Check on Posting", false);
    end;

    [Test]
    procedure SalesSetupValidateCheckOnPostingMethod()
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        SalesReceivablesSetup.Get();
        SalesReceivablesSetup.Validate("Posting Date Check on Posting", false);

        SalesReceivablesSetup.TestField(
            SalesReceivablesSetup."Posting Date Check on Posting", false);
    end;
}
