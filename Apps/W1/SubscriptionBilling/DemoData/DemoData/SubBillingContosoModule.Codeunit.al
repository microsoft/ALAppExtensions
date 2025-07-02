namespace Microsoft.SubscriptionBilling;

using Microsoft.DemoTool;

codeunit 8102 "Sub. Billing Contoso Module" implements "Contoso Demo Data Module"
{

    InherentEntitlements = X;
    InherentPermissions = X;

    procedure RunConfigurationPage()
    begin
        Page.Run(Page::"Sub. Billing Module Setup");
    end;

    procedure GetDependencies() Dependencies: List of [enum "Contoso Demo Data Module"]
    begin
        Dependencies.Add(Enum::"Contoso Demo Data Module"::"Common Module");
        Dependencies.Add(Enum::"Contoso Demo Data Module"::"Job Module");
    end;

    procedure CreateSetupData()
    var
        SubBillingModuleSetup: Record "Sub. Billing Module Setup";
    begin
        SubBillingModuleSetup.InitRecord();
        Codeunit.Run(Codeunit::"Create Sub. Bill. GL Account");
        Codeunit.Run(Codeunit::"Create Sub. Billing No. Series");
        Codeunit.Run(Codeunit::"Create Sub. Billing Setup");
        Codeunit.Run(Codeunit::"Create Sub. Bill. Contr. Types");
        Codeunit.Run(Codeunit::"Create Sub. Bill. Templates");
        Codeunit.Run(Codeunit::"Create Sub. Bill. Pr. U. Temp.");
        Codeunit.Run(Codeunit::"Update Sub. Bill. Post. Setup");
        Codeunit.Run(Codeunit::"Create Sub. Bill. Item Templ.");
    end;

    procedure CreateMasterData()
    begin
        Codeunit.Run(Codeunit::"Create Sub. Bill. Item");
        Codeunit.Run(Codeunit::"Create Sub. Bill. S. Template");
        Codeunit.Run(Codeunit::"Create Sub. Bill. Packages");
        Codeunit.Run(Codeunit::"Create Sub. Bill. Supplier");
        Codeunit.Run(Codeunit::"Create Sub. Bill. Supp. Ref.");
        Codeunit.Run(Codeunit::"Create Sub. Bill. Gen. Sett.");
    end;

    procedure CreateTransactionalData()
    begin
        Codeunit.Run(Codeunit::"Create Sub. Bill. Serv. Obj.");
        Codeunit.Run(Codeunit::"Create Sub. Bill. Cust. Contr.");
        Codeunit.Run(Codeunit::"Create Sub. Bill. Vend. Contr.");
        Codeunit.Run(Codeunit::"Create Sub. Bill. UD Subscr.");
        Codeunit.Run(Codeunit::"Create Sub. Bill. UD Import");
        Codeunit.Run(Codeunit::"Init Sub. Bill. Job Queue");
    end;

    procedure CreateHistoricalData()
    begin
    end;
}