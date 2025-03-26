# Coding Patterns

## Descriptive Methods
Use descriptive methods for reusable labels to ensure:

- **Data Consistency**: Ensures the same field data is inserted correctly across different tables, avoiding typos.
- **Translation Accuracy**: Translation can be difficult with limited context, leading to inconsistent translations of the same label across different documents. Defining a method for reusable labels eliminates such inconsistencies.

```
    procedure Sneakers(): Code[20]
    begin
        exit(SneakersTok);
    end;

    procedure Boots(): Code[20]
    begin
        exit(BootsTok);
    end;

    procedure Sandals(): Code[20]
    begin
        exit(SandalsTok);
    end;

    procedure Formal(): Code[20]
    begin
        exit(FormalTok);
    end;

    procedure Misc(): Code[20]
    begin
        exit(MiscTok);
    end;

    procedure Supplier(): Code[20]
    begin
        exit(SuppliersTok);
    end;

    var
        SneakersTok: Label 'SNEAKERS', MaxLength = 20;
        BootsTok: Label 'BOOTS', MaxLength = 20;
        SandalsTok: Label 'SANDALS', MaxLength = 20;
        FormalTok: Label 'FORMAL', MaxLength = 20;
        MiscTok: Label 'MISC', MaxLength = 20;
        SuppliersTok: Label 'SUPPLIERS', MaxLength = 20;
        SneakersLbl: Label 'Sneakers', MaxLength = 100;
        BootsLbl: Label 'Boots', MaxLength = 100;
        SandalsLbl: Label 'Sandals', MaxLength = 100;
        FormalLbl: Label 'Formal Shoes', MaxLength = 100;
        MiscellaneousLbl: Label 'Miscellaneous', MaxLength = 100;
        ShoeSuppliesLbl: Label 'Shoe Supplies', MaxLength = 100;
```

## Labels
Make sure to define your label correctly by specifying the maximum length and, if needed, adding a comment to explain the context of the label. This greatly helps with translation accuracy and consistency.

```
ShoeSuppliesLbl: Label 'Shoe Supplies', MaxLength = 100;
```


## Configuration

Contoso Demo Tool supports configuration for each modules, and it can be a powerful way to customize your demo data, either for localizations or for a specific theme you want to demo.

A general configuration for Contoso Demo Tool can be found at `table 4768 "Contoso Coffee Demo Data Setup"`, all modules are recommended to utilize those configurations. Each module's configuration is placed directly under each module's folder.

Although it is not a requirement to have a configuration for a module, we find it very beneficial especially for localization purposes.

### How to define a Configuration

Configuration consists of a setup table and a configuration page, they both should be placed directly under each module's folder. On `Contoso Demo Tool` page, select the desired module to configure, use the `Configure` action to open the configuration page.

Below code snippet shows an example implementation:

```
<!-- ManufacturingModule.Codeunit.al -->
...
    procedure RunConfigurationPage()
    begin
        Page.Run(Page::"Manufacturing Module Setup");
    end;

    procedure CreateSetupData()
    var
        ManufacturingDemoDataSetup: Record "Manufacturing Module Setup";
    begin
        ManufacturingDemoDataSetup.InitRecord();
        ...
    end;
...
```

Here are some tips for your implementation:

1. Follow similar structure as existing configurations for each modules.
2. Re-use the general configuration as much as possible. (if you find anything should be added there, please let us know)
3. Use `TableRelation` to enforce certain values. e.g. you scenario might rely on an Item being `Enum::"Item Type"::Inventory`. Some good example can be found in `table 4764 "Warehouse Module Setup"`.
4. Initialized you configuration as the first thing you in `CreateSetupData`.
5. Do not forget to check if the setup field is empty before assigning your default values. Otherwise, any customization will not take effect.
    ```
    ...
        if ManufacturingDemoDataSetup."Manufacturing Location" = '' then
            ManufacturingDemoDataSetup.Validate("Manufacturing Location", CommonLocation.MainLocation());
    ...
    ```
6. Put your configuration fields into meaningful groups on the Configuration Page.

### Configuration for Localizations

Configuration can help you in localizations. e.g. the general configuration has already been set to expected values in each localizations, so you can easily create a domestic customer in W1 for all localizations like `Customer.Validate("Country/Region Code", ContosoCoffeeDemoDataSetup."Country/Region Code")`.

```
<!-- ContosoDemoDataSetupUS.Codeunit.al -->

    [EventSubscriber(ObjectType::Table, Database::"Contoso Coffee Demo Data Setup", 'OnBeforeInsertEvent', '', false, false)]
    local procedure LocalDemoDataSetup(var Rec: Record "Contoso Coffee Demo Data Setup")
    begin
        Rec."Country/Region Code" := 'US';
        Rec."Company Type" := Rec."Company Type"::"Sales Tax";
    end;
```

## Dependency

Contoso Demo Tool is designed to support decencies between modules, so that you can leverage data generated by other modules.

For example, `Finance Module` has dependency on `Foundation Module`, the execution order will look like below. You can reference data generated in the previous steps (We can't enforce you to only reference data generated from previous steps. It is highly recommended that you use `Validate` instead of direct value assignment, so you don't reference data that doesn't exist yet).
1. "Setup Data" - Foundation
2. "Setup Data" - Finance
3. "Master Data" - Foundation
4. "Master Data" - Finance
5. ...

## Helper Codeunit

Helper codeunit is designed to help insert data into specific tables, while hiding some of the complexity, so that everyone can focus on building the demo scenarios. You can find a list of helper codeunit under the folder `DemoTool/Contoso Helpers/...`, check it out before you insert any demo data.

Take `GenProductPostingGroup` for example, the helper:
1. Takes care of `Company Type` for you, so the same code will work in both W1 and NA.
2. With the variables `Exists` and `OverwriteData`, the helper will not throw an error when the record already exists and provides the option to overwrite the data.

```
<!-- ContosoPostingGroup.Codeunit.al -->
...
    procedure InsertGenProductPostingGroup(ProductGroupCode: Code[20]; Description: Text[100]; DefaultVATProdPostingGroup: Code[20])
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        GenProductPostingGroup: Record "Gen. Product Posting Group";
        Exists: Boolean;
    begin
        ContosoCoffeeDemoDataSetup.Get();

        if GenProductPostingGroup.Get(ProductGroupCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        GenProductPostingGroup.Validate(Code, ProductGroupCode);
        GenProductPostingGroup.Validate(Description, Description);

        if ContosoCoffeeDemoDataSetup."Company Type" = ContosoCoffeeDemoDataSetup."Company Type"::VAT then
            GenProductPostingGroup.Validate("Def. VAT Prod. Posting Group", DefaultVATProdPostingGroup);

        if Exists then
            GenProductPostingGroup.Modify(true)
        else
            GenProductPostingGroup.Insert(true);
    end;
...
```

## Localization

Localizations are a huge part of Demo Data, you can find our existing localization apps `Contoso Coffee Demo Dataset (CountryOrRegion Code)`.

### More data in Localizations

It is straight forward to create additional demo data in localizations, as Contoso Demo Tool comes with some useful events. Subscribe to the event `OnAfterGeneratingDemoData` and you can populate additional demo data in the appropriate place. e.g. there are some additional Job Queue Categories in US localization, for Setup Data in Foundation module.

```
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnAfterGeneratingDemoData', '', false, false)]
    local procedure LocalizationContosoDemoData(Module: Enum "Contoso Demo Data Module"; ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case Module of
            Enum::"Contoso Demo Data Module"::Foundation:
                FoundationModule(ContosoDemoDataLevel);
            ...
        end;
    end;

    local procedure FoundationModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                begin
                    Codeunit.Run(Codeunit::"Create Job Queue Category US");
                    ...
        end;
    end;
```

### Less data in Localizations

For Demo Data comes from W1, but you do not want them in a specific localizations:

1. Try to use Configuration mentioned above to avoid creating those data (e.g. VAT Posting Groups in Sales Tax companies). This approach not only simplifies the localization, but also provides good performances.
2. If Configuration is not suitable for your scenarios, simply delete the delete the data you don't want. Remember to check if the deleted data is referenced anywhere.

### Modified data in Localizations

There are a few ways to modify the demo data in specific localizations, and each of them is suitable for difference scenarios:
1. Use OverWriteData from helper codeunit. It is a good option when the helper procedures take few parameters, it clearly shows the Primary Key is the same but certain fields are localized. e.g. Posting Groups in Germany have a different description.
    ```
        ContosoPostingGroup.SetOverwriteData(true);
        ContosoPostingGroup.InsertVATProductPostingGroup(CreateVATPostingGroups.Standard(), StandardVATDescriptionLbl);
        ContosoPostingGroup.InsertVATProductPostingGroup(CreateVATPostingGroups.Reduced(), ReducedVATDescriptionLbl);
        ContosoPostingGroup.SetOverwriteData(false);
    ```
2. Use `OnBeforeInsertEvent` trigger when more fields need to be modified. e.g. Vendor in Austria has different VATRegistrationNo, Post Codes and Address. Note: **`EventSubscriberInstance = Manual` is required because the event MUST NOT take effect outside the context of Contoso** and don't forget to `bind` and `unbind` the event.  
    ```
        [EventSubscriber(ObjectType::Table, Database::Vendor, 'OnBeforeInsertEvent', '', false, false)]
        local procedure OnBeforeInsertVendor(var Rec: Record Vendor)
        begin
            case Rec."No." of
                CreateVendor.ExportFabrikam():
                    ValidateVendorRecordFields(Rec, ExportFabrikamVatRegLbl, PostCodeGA31772Lbl, 'GA');
        ...
    ```
3. Simply Get the Record and do a Modify if it is a rare situation.

## GL account

GL Accounts follows a very different pattern comparing to other tables. Let's use HumanResources module for example:

1. `AddGLAccountsForLocalization()` will be called at the very beginning. Inside the procedure, you should add the GL Accounts for **W1** localization.
2. GL Account localization is done using `ContosoGLAccount.AddAccountForLocalization(AccountName, AccountNo)`, this creates a key-value pair in temporary `table 4769 "Contoso GL Account"` using the `AccountName` and `AccountNo`, i.e. 'Employees Payable' -> '5850'.
3. After the W1 GL Account is added, the event `OnAfterAddGLAccountsForLocalization()` is fired, so localization apps will have a chance to modify the `AccountNo` to the localized version. (e.g. in Canada localization `ContosoGLAccount.AddAccountForLocalization(HRGLAccount.EmployeesPayableName(), '23850');`)
4. When localization is done, the temporary table now stores the localized version of key-value pair.
5. Whenever `EmployeesPayable()` procedure is called, it will look up the `AccountNo` from the temporary table by its key `AccountName`, so it will give you the localized `AccountNo` for 'Employees Payable'

```
<!-- CreateHRGLAccount.Codeunit.al -->

    trigger OnRun()
    begin
        AddGLAccountsForLocalization();

        ContosoGLAccount.InsertGLAccount(EmployeesPayable(), EmployeesPayableName(), ...);
    end;

    local procedure AddGLAccountsForLocalization()
    begin
        ContosoGLAccount.AddAccountForLocalization(EmployeesPayableName(), '5850');

        OnAfterAddGLAccountsForLocalization();
    end;

    var
        ContosoGLAccount: Codeunit "Contoso GL Account";
        EmployeesPayableLbl: Label 'Employees Payable', MaxLength = 100;

    procedure EmployeesPayable(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EmployeesPayableName()));
    end;

    procedure EmployeesPayableName(): Text[100]
    begin
        exit(EmployeesPayableLbl);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAddGLAccountsForLocalization()
    begin
    end;
```