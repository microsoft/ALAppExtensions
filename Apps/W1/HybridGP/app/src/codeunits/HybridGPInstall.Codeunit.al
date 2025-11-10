namespace Microsoft.DataMigration.GP;

using Microsoft.DataMigration;

codeunit 40904 "Hybrid GP Install"
{
    Access = Internal;
    Subtype = Install;

    trigger OnInstallAppPerDatabase()
    begin
        RegisterValidator();
        RegisterTests();
    end;

    local procedure RegisterValidator()
    var
        MigrationValidatorRegistry: Record "Migration Validator Registry";
        GPMigrationValidator: Codeunit "GP Migration Validator";
        HybridGPWizard: Codeunit "Hybrid GP Wizard";
        ValidatorCode: Code[20];
        MigrationType: Text[250];
        ValidatorCodeunitId: Integer;
    begin
        ValidatorCode := GPMigrationValidator.GetValidatorCode();
        MigrationType := HybridGPWizard.ProductId();
        ValidatorCodeunitId := Codeunit::"GP Migration Validator";
        if not MigrationValidatorRegistry.Get(ValidatorCode) then begin
            MigrationValidatorRegistry.Validate("Validator Code", ValidatorCode);
            MigrationValidatorRegistry.Validate("Migration Type", MigrationType);
            MigrationValidatorRegistry.Validate(Description, ValidatorDescriptionLbl);
            MigrationValidatorRegistry.Validate("Codeunit Id", ValidatorCodeunitId);
            MigrationValidatorRegistry.Insert(true);
        end;
    end;

    local procedure RegisterTests()
    begin
        AddTest('ACCOUNTEXISTS', 'G/L Account', 'Missing Account');
        AddTest('ACCOUNTNAME', 'G/L Account', 'Name');
        AddTest('ACCOUNTTYPE', 'G/L Account', 'Account Type');
        AddTest('ACCOUNTCATEGORY', 'G/L Account', 'Account Category');
        AddTest('ACCOUNTDEBCRED', 'G/L Account', 'Debit/Credit');
        AddTest('ACCOUNTSUBCATEGORY', 'G/L Account', 'Account Subcategory');
        AddTest('ACCOUNTINCBAL', 'G/L Account', 'Income/Balance');
        AddTest('ACCOUNTBALANCE', 'G/L Account', 'Balance');
        AddTest('STATACCOUNTEXISTS', 'Statistical Account', 'Missing Account');
        AddTest('STATACCOUNTNAME', 'Statistical Account', 'Name');
        AddTest('STATACCOUNTDIM1', 'Statistical Account', 'Dimension 1');
        AddTest('STATACCOUNTDIM2', 'Statistical Account', 'Dimension 2');
        AddTest('STATACCOUNTBALANCE', 'Statistical Account', 'Balance');
        AddTest('BANKACCOUNTEXISTS', 'Bank Account', 'Missing Bank Account');
        AddTest('BANKACCOUNTNAME', 'Bank Account', 'Name');
        AddTest('BANKACCOUNTNO', 'Bank Account', 'Bank Account No.');
        AddTest('BANKACCOUNTADDR', 'Bank Account', 'Address');
        AddTest('BANKACCOUNTADDR2', 'Bank Account', 'Address 2');
        AddTest('BANKACCOUNTCITY', 'Bank Account', 'City');
        AddTest('BANKACCOUNTCOUNTY', 'Bank Account', 'County (State)');
        AddTest('BANKACCOUNTPOSTCODE', 'Bank Account', 'Post Code');
        AddTest('BANKACCOUNTPHN', 'Bank Account', 'Phone');
        AddTest('BANKACCOUNTFAX', 'Bank Account', 'Fax');
        AddTest('BANKACCOUNTTRANSITNO', 'Bank Account', 'Transit No.');
        AddTest('BANKACCOUNTBRANCHNO', 'Bank Account', 'Bank Branch No.');
        AddTest('BANKACCOUNTBALANCE', 'Bank Account', 'Balance');
        AddTest('CUSTOMEREXISTS', 'Customer', 'Missing Customer');
        AddTest('CUSTOMERNAME', 'Customer', 'Name');
        AddTest('CUSTOMERPOSTINGGROUP', 'Customer', 'Customer Posting Group');
        AddTest('CUSTOMERADDR', 'Customer', 'Address');
        AddTest('CUSTOMERADDR2', 'Customer', 'Address 2');
        AddTest('CUSTOMERCITY', 'Customer', 'City');
        AddTest('CUSTOMERPHN', 'Customer', 'Phone');
        AddTest('CUSTOMERFAX', 'Customer', 'Fax');
        AddTest('CUSTOMERNAME2', 'Customer', 'Name 2');
        AddTest('CUSTOMERCREDITLMT', 'Customer', 'Credit Limit');
        AddTest('CUSTOMERCONTACT', 'Customer', 'Contact');
        AddTest('CUSTOMERSALESPERSON', 'Customer', 'Sales Person');
        AddTest('CUSTOMERSHIPMETHOD', 'Customer', 'Shipment Method');
        AddTest('CUSTOMERPMTTERMS', 'Customer', 'Payment Terms');
        AddTest('CUSTOMERTERRITORY', 'Customer', 'Territory');
        AddTest('CUSTOMERTAXAREA', 'Customer', 'Tax Area');
        AddTest('CUSTOMERTAXLIABLE', 'Customer', 'Tax Liable');
        AddTest('CUSTOMERBALANCE', 'Customer', 'Balance');
        AddTest('SHIPADDREXISTS', 'Customer - Ship-to Address', 'Missing address');
        AddTest('SHIPADDRNAME', 'Customer - Ship-to Address', 'Name');
        AddTest('SHIPADDRADDR', 'Customer - Ship-to Address', 'Address');
        AddTest('SHIPADDRADDR2', 'Customer - Ship-to Address', 'Address 2');
        AddTest('SHIPADDRCITY', 'Customer - Ship-to Address', 'City');
        AddTest('SHIPADDRPOSTCODE', 'Customer - Ship-to Address', 'Post Code');
        AddTest('SHIPADDRPHN', 'Customer - Ship-to Address', 'Phone');
        AddTest('SHIPADDRFAX', 'Customer - Ship-to Address', 'Fax');
        AddTest('SHIPADDRCONTACT', 'Customer - Ship-to Address', 'Contact');
        AddTest('SHIPADDRSHIPMETHOD', 'Customer - Ship-to Address', 'Shipment Method');
        AddTest('SHIPADDRCOUNTY', 'Customer - Ship-to Address', 'County (State)');
        AddTest('SHIPADDRTAXAREA', 'Customer - Ship-to Address', 'Tax Area');
        AddTest('ITEMEXISTS', 'Item', 'Missing Item');
        AddTest('ITEMTYPE', 'Item', 'Type');
        AddTest('ITEMDESC', 'Item', 'Description');
        AddTest('ITEMDESC2', 'Item', 'Description 2');
        AddTest('ITEMSEARCHDESC', 'Item', 'Search Description');
        AddTest('ITEMPOSTINGGROUP', 'Item', 'Inventory Posting Group');
        AddTest('ITEMUNITLISTPRICE', 'Item', 'Unit List Price');
        AddTest('ITEMUNITCOST', 'Item', 'Unit Cost');
        AddTest('ITEMSTANDARDCOST', 'Item', 'Standard Cost');
        AddTest('ITEMCOSTMETHOD', 'Item', 'Costing Method');
        AddTest('ITEMBASEUOFM', 'Item', 'Base Unit of Measure');
        AddTest('ITEMPURCHUOFM', 'Item', 'Purch. Unit of Measure');
        AddTest('ITEMTRACKINGCODE', 'Item', 'Item Tracking Code');
        AddTest('ITEMINVENTORY', 'Item', 'Inventory');
        AddTest('POEXISTS', 'Purchase Order', 'Missing Purchase Order');
        AddTest('POBUYFROMVEND', 'Purchase Order', 'Buy-from Vendor No.');
        AddTest('POPAYTOVEND', 'Purchase Order', 'Pay-to Vendor No.');
        AddTest('PODOCDATE', 'Purchase Order', 'Document Date');
        AddTest('POLINEEXISTS', 'Purchase Order - Line', 'Missing PO Line');
        AddTest('POLINEQTY', 'Purchase Order - Line', 'Quantity');
        AddTest('POLINEQTYRECV', 'Purchase Order - Line', 'Quantity Received');
        AddTest('VENDOREXISTS', 'Vendor', 'Missing Vendor');
        AddTest('VENDORNAME', 'Vendor', 'Name');
        AddTest('VENDORNAME2', 'Vendor', 'Name 2');
        AddTest('VENDORPOSTINGGROUP', 'Vendor', 'Vendor Posting Group');
        AddTest('VENDORPREFBANKACCT', 'Vendor', 'Preferred Bank Account');
        AddTest('VENDORADDR', 'Vendor', 'Address');
        AddTest('VENDORADDR2', 'Vendor', 'Address 2');
        AddTest('VENDORCITY', 'Vendor', 'City');
        AddTest('VENDORPHN', 'Vendor', 'Phone');
        AddTest('VENDORFAX', 'Vendor', 'Fax');
        AddTest('VENDORCONTACT', 'Vendor', 'Contact');
        AddTest('VENDORSHIPMETHOD', 'Vendor', 'Shipment Method');
        AddTest('VENDORPMTTERMS', 'Vendor', 'Payment Terms');
        AddTest('VENDORTERRITORY', 'Vendor', 'Territory');
        AddTest('VENDORTAXAREA', 'Vendor', 'Tax Area');
        AddTest('VENDORTAXLIABLE', 'Vendor', 'Tax Liable');
        AddTest('VENDORBALANCE', 'Vendor', 'Balance');
        AddTest('ORDERADDREXISTS', 'Vendor - Order Address', 'Missing address');
        AddTest('ORDERADDRNAME', 'Vendor - Order Address', 'Name');
        AddTest('ORDERADDRADDR', 'Vendor - Order Address', 'Address');
        AddTest('ORDERADDRADDR2', 'Vendor - Order Address', 'Address 2');
        AddTest('ORDERADDRCITY', 'Vendor - Order Address', 'City');
        AddTest('ORDERADDRPOSTCODE', 'Vendor - Order Address', 'Post Code');
        AddTest('ORDERADDRPHN', 'Vendor - Order Address', 'Phone');
        AddTest('ORDERADDRFAX', 'Vendor - Order Address', 'Fax');
        AddTest('ORDERADDRCOUNTY', 'Vendor - Order Address', 'County (State)');
        AddTest('ORDERADDRCONTACT', 'Vendor - Order Address', 'Contact');
        AddTest('REMITADDREXISTS', 'Vendor - Remit Address', 'Missing address');
        AddTest('REMITADDRNAME', 'Vendor - Remit Address', 'Name');
        AddTest('REMITADDRADDR', 'Vendor - Remit Address', 'Address');
        AddTest('REMITADDRADDR2', 'Vendor - Remit Address', 'Address 2');
        AddTest('REMITADDRCITY', 'Vendor - Remit Address', 'City');
        AddTest('REMITADDRPOSTCODE', 'Vendor - Remit Address', 'Post Code');
        AddTest('REMITADDRPHN', 'Vendor - Remit Address', 'Phone');
        AddTest('REMITADDRFAX', 'Vendor - Remit Address', 'Fax');
        AddTest('REMITADDRCOUNTY', 'Vendor - Remit Address', 'County (State)');
        AddTest('REMITADDRCONTACT', 'Vendor - Remit Address', 'Contact');
    end;

    local procedure AddTest(Code: Code[30]; Entity: Text[50]; Description: Text)
    var
        MigrationValidationTest: Record "Migration Validation Test";
        GPMigrationValidator: Codeunit "GP Migration Validator";
    begin
        if not MigrationValidationTest.Get(Code, GPMigrationValidator.GetValidatorCode()) then begin
            MigrationValidationTest.Validate(Code, Code);
            MigrationValidationTest.Validate("Validator Code", GPMigrationValidator.GetValidatorCode());
            MigrationValidationTest.Validate(Entity, Entity);
            MigrationValidationTest.Validate("Test Description", Description);
            MigrationValidationTest.Insert(true);
        end;
    end;

    var
        ValidatorDescriptionLbl: Label 'GP migration validator', MaxLength = 250;
}