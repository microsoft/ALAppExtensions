# Getting started:
You should create a demo data app to generate demonstration data, making it easier to showcase the features of your application. The recommended folder structure for the app is as follows:
```
.\
    App
    DemoData
    Test
```

Create an application in the `DemoData` folder and follow these steps:
### 1. Extend "Contoso Demo Data Module" Enum
Add your new module Enum, and point out to the implementation codeunit.
```
enumextension 50100 "Contoso Shoes" extends "Contoso Demo Data Module"
{
    value(50100; "Contoso Shoes")
    {
        Implementation = "Contoso Demo Data Module" = "Contoso Shoes Module";
    }
}
```
### 2. Implement the Interface
```
codeunit 50100 "Contoso Shoes Module" implements "Contoso Demo Data Module"
{
    procedure RunConfigurationPage();
    begin 
    end;

    procedure GetDependencies() Dependencies: List of [Enum "Contoso Demo Data Module"]
    begin
        Dependencies.Add(Enum::"Contoso Demo Data Module"::"Common Module");
    end;

    procedure CreateSetupData()
    begin
        Codeunit.Run(Codeunit::"Create Contoso Shoes Item Category");
        Codeunit.Run(Codeunit::"Create Contoso Shoes Unit of Measure");
    end;

    procedure CreateMasterData()
    begin
        Codeunit.Run(Codeunit::"Cearte Contoso Shoes Item");
        Codeunit.Run(Codeunit::"Create Contoso Shoes Size");
    end;
    procedure CreateTransactionalData();
    begin 
    end;

    procedure CreateHistoricalData();
    begin 
    end;
}
```


### 3. implement demo data codeunits
```
codeunit 5380 "Create Shoe Category"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoItem: Codeunit "Contoso Item";
    begin
        ContosoItem.InsertItemCategory(Sneakers(), SneakersLbl, '');
        ContosoItem.InsertItemCategory(Boots(), BootsLbl, '');
        ContosoItem.InsertItemCategory(Sandals(), SandalsLbl, '');
        ContosoItem.InsertItemCategory(Formal(), FormalLbl, '');

        ContosoItem.InsertItemCategory(Misc(), MiscellaneousLbl, '');
        ContosoItem.InsertItemCategory(Supplier(), ShoeSuppliesLbl, Misc());
    end;

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
}
```

### 4. Add configurations to your module (optional)
To allow the user to configure the module, you will need to add setup table and page. 
```
table 5282 "Module Setup"
{
    DataClassification = CustomerContent;
    InherentEntitlements = RMX;
    InherentPermissions = RMX;
    Extensible = false;
    DataPerCompany = true;
    ReplicateData = false;

    fields
    {
        field(1; "Primary Key"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Primary Key';
        }
        field(2; StartDate; Date)
        {
            Caption = 'Start Date';
            ToolTip = 'Specifies the start date for the scenario.';
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

    [InherentPermissions(PermissionObjectType::TableData, Database::"Module Setup", 'I')]
    internal procedure InitRecord()
    begin
        if Rec.Get() then
            exit;

        Rec.Insert();
    end;
}

```

```
page 5281 "Module Setup"
{
    PageType = Card;
    Caption = 'Module Setup';
    SourceTable = "Module Setup";
    Extensible = false;
    DeleteAllowed = false;
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            group("Setup Data")
            {
                field(StartDate; Rec.StartDate) { }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.InitRecord();
    end;
}

```
**Note:**

Remember to use the configured data from your configuration table

## Use coding patterns and helper codeunits
Follow coding patterns in [CodingPatterns](/Coding-Patterns.md)