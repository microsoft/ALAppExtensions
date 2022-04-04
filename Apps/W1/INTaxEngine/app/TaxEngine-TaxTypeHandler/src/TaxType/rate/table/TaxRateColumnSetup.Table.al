table 20252 "Tax Rate Column Setup"
{
    Caption = 'Tax Rate Column Setup';
    DataClassification = EndUserIdentifiableInformation;
    Access = Public;
    Extensible = false;
    fields
    {
        field(1; "Tax Type"; Code[20])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Tax Type';
            TableRelation = "Tax Type".Code;
        }
        field(2; "Column ID"; Integer)
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Column ID';
            AutoIncrement = true;
        }
        field(3; "Column Name"; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Column Name';
            trigger OnValidate()
            begin
                GetColumnName(false);
            end;

            trigger OnLookup()
            begin
                GetColumnName(true);
            end;
        }
        field(4; "Attribute ID"; Integer)
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Attribute ID';
        }
        field(5; "Column Type"; Enum "Column Type")
        {
            Caption = 'Column Type';
            DataClassification = CustomerContent;
        }
        field(6; Sequence; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Sequence';
        }
        field(7; Type; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Type';
            InitValue = "Text";
            OptionMembers = Option,Text,Integer,Decimal,Boolean,Date;
            OptionCaption = 'Option,Text,Integer,Decimal,Boolean,Date';
        }
        field(9; "Linked Attribute ID"; Integer)
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Linked Attribute ID';
        }
        field(10; "Visible On Interface"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Visible On Interface';
        }
        field(11; "Allow Blank"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Allow Blank';
        }
    }

    keys
    {
        key(PK; "Tax Type", "Column ID")
        {
            Clustered = true;
        }
        key(Sequence; Sequence) { }
        key(ColumnName; "Column Name") { }
    }
    trigger OnInsert()
    var
        TaxTypeObjectHelper: Codeunit "Tax Type Object Helper";
    begin
        TaxTypeObjectHelper.OnBeforeValidateIfUpdateIsAllowed(Rec."Tax Type");
    end;

    trigger OnModify()
    var
        TaxTypeObjectHelper: Codeunit "Tax Type Object Helper";
    begin
        TaxTypeObjectHelper.OnBeforeValidateIfUpdateIsAllowed(Rec."Tax Type");
    end;

    trigger OnDelete()
    var
        TaxRate: Record "Tax Rate";
        TaxRateValue: Record "Tax Rate Value";
        TaxTypeObjectHelper: Codeunit "Tax Type Object Helper";
    begin
        TaxTypeObjectHelper.OnBeforeValidateIfUpdateIsAllowed(Rec."Tax Type");

        TaxRateValue.SetRange("Tax Type", "Tax Type");
        TaxRateValue.SetRange("Column ID", "Column ID");
        if TaxRateValue.IsEmpty then
            exit;

        TaxRateValue.DeleteAll();

        TaxRateValue.Reset();
        TaxRateValue.SetRange("Tax Type", "Tax Type");
        if TaxRateValue.IsEmpty() then begin
            TaxRate.SetRange("Tax Type", "Tax Type");
            if not TaxRate.IsEmpty() then
                TaxRate.DeleteAll();
        end;
    end;

    procedure UpdateTransactionKeys()
    var
        TaxRate: Record "Tax Rate";
        TaxRateFilter: Record "Tax Rate Filter";
        TempTaxRate: Record "Tax Rate" temporary;
        TempTaxRateValue: Record "Tax Rate Value" temporary;
        TaxSetupMatrixMgmt: Codeunit "Tax Setup Matrix Mgmt.";
        taxRateFilterMgmt: Codeunit "Tax Rate Filter Mgmt.";
        ConfigIDList: List of [Guid];
        ConfigID: Guid;
    begin
        InitTaxRateProgressWindow();
        UpdateTaxRateProgressWindow(TransferingRecordToTempLbl);
        TransferToTemp(TempTaxRate, TempTaxRateValue, ConfigIDList);
        TaxSetupMatrixMgmt.DeleteAllTaxRates("Tax Type", true);

        foreach ConfigID in ConfigIDList do begin
            UpdateTaxRateProgressWindow(UpdatingKeysValueLbl);
            InitilizeMissingTaxRateValue(TempTaxRateValue, "Tax Type", ConfigID);
            TempTaxRate.Get("Tax Type", ConfigID);
            TempTaxRate."Tax Setup ID" := TaxSetupMatrixMgmt.GenerateTaxSetupID(TempTaxRateValue, TempTaxRate.ID, TempTaxRate."Tax Type");
            TempTaxRate."Tax Rate ID" := TaxSetupMatrixMgmt.GenerateTaxRateID(TempTaxRateValue, TempTaxRate.ID, TempTaxRate."Tax Type");
            TempTaxRate.Modify();

            TaxRate.Init();
            TaxRate := TempTaxRate;
            UpdateTaxRateProgressWindow(ValidatingKeysValueLbl);
            TaxSetupMatrixMgmt.CheckForDuplicateSetID(TempTaxRate, ConfigID, "Tax Type", TempTaxRate."Tax Setup ID");
            TaxRate.Insert();

            TransferToMainRecord(TempTaxRateValue, ConfigID, Rec."Tax Type");
        end;

        TaxRateFilter.SetRange("Tax Type", Rec."Tax Type");
        if not TaxRateFilter.IsEmpty() then
            TaxRateFilter.DeleteAll();

        TaxRateFilterMgmt.UpdateTaxRateFilters(Rec."Tax Type");

        CloseTaxRateProgressWindow();
    end;

    local procedure InitilizeMissingTaxRateValue(var TempTaxRateValue: Record "Tax Rate Value" temporary; TaxType: Code[20]; ConfigID: Guid)
    var
        TaxRateColumnSetup: Record "Tax Rate Column Setup";
    begin
        TaxRateColumnSetup.SetCurrentKey(Sequence);
        TaxRateColumnSetup.SetRange("Tax Type", TaxType);
        if TaxRateColumnSetup.FindSet() then
            repeat
                TempTaxRateValue.Reset();
                TempTaxRateValue.SetRange("Tax Type", TaxType);
                TempTaxRateValue.SetRange("Config ID", ConfigID);
                TempTaxRateValue.SetRange("Column ID", TaxRateColumnSetup."Column ID");
                if TempTaxRateValue.IsEmpty() then
                    InitializeRateValueForNewColumnSetup(TempTaxRateValue, TaxRateColumnSetup, ConfigID);
            until TaxRateColumnSetup.Next() = 0;
    end;

    local procedure InitializeRateValueForNewColumnSetup(
        var TaxRateValue: Record "Tax Rate Value";
        TaxRateColumnSetup: Record "Tax Rate Column Setup";
        ConfigID: Guid)
    var
        TaxSetupMatrixMgmt: Codeunit "Tax Setup Matrix Mgmt.";
    begin
        TaxRateValue.Init();
        TaxRateValue."Config ID" := ConfigID;
        TaxRateValue.ID := CreateGuid();
        TaxRateValue."Tax Type" := TaxRateColumnSetup."Tax Type";
        TaxRateValue."Column ID" := TaxRateColumnSetup."Column ID";
        TaxRateValue."Column Type" := TaxRateColumnSetup."Column Type";
        TaxSetupMatrixMgmt.SetDefaultRateValues(TaxRateColumnSetup, TaxRateValue);
        TaxRateValue.Insert();
    end;

    local procedure TransferToTemp(
        var TempTaxRate: Record "Tax Rate" temporary;
        var TempTaxRateValue: Record "Tax Rate Value" temporary;
        var ConfigIDList: List of [Guid])
    var
        TaxRate: Record "Tax Rate";
        TaxRateValue: Record "Tax Rate Value";
    begin
        TaxRate.SetRange("Tax Type", "Tax Type");
        if TaxRate.FindSet() then
            repeat
                TempTaxRate.Init();
                TempTaxRate := TaxRate;
                TempTaxRate.Insert();
                ConfigIDList.Add(TempTaxRate.ID);
            until TaxRate.Next() = 0;

        TaxRateValue.SetRange("Tax Type", "Tax Type");
        if TaxRateValue.FindSet() then
            repeat
                TempTaxRateValue.Init();
                TempTaxRateValue := TaxRateValue;
                TempTaxRateValue.Insert();
            until TaxRateValue.Next() = 0;
    end;

    local procedure TransferToMainRecord(var TempTaxRateValue: Record "Tax Rate Value" temporary; ConfigID: Guid; TaxType: Code[20])
    var
        TaxRateValue: Record "Tax Rate Value";
    begin
        TempTaxRateValue.Reset();
        TempTaxRateValue.SetRange("Tax Type", TaxType);
        TempTaxRateValue.SetRange("Config ID", ConfigID);
        if TempTaxRateValue.FindSet() then
            repeat
                TaxRateValue.Init();
                TaxRateValue := TempTaxRateValue;
                TaxRateValue.Insert();
            until TempTaxRateValue.Next() = 0;
    end;

    local procedure GetColumnName(IsLookup: Boolean)
    var
        TaxComponent: Record "Tax Component";
        TaxAttribute: Record "Tax Attribute";
    begin
        ScriptSymbolsMgmt.SetContext("Tax Type", EmptyGuid, EmptyGuid);
        case "Column Type" of
            "Column Type"::Component:
                begin
                    if IsLookup then
                        ScriptSymbolsMgmt.OpenSymbolsLookup("Symbol Type"::Component, "Column Name", "Attribute ID", "Column Name")
                    else
                        ScriptSymbolsMgmt.SearchSymbol("Symbol Type"::Component, "Attribute ID", "Column Name");

                    if TaxComponent.Get("Tax Type", "Attribute ID") then
                        Type := TaxComponent.Type;
                end;
            "Column Type"::"Tax Attributes":
                begin
                    if IsLookup then
                        ScriptSymbolsMgmt.OpenSymbolsLookup("Symbol Type"::"Tax Attributes", "Column Name", "Attribute ID", "Column Name")
                    else
                        ScriptSymbolsMgmt.SearchSymbol("Symbol Type"::"Tax Attributes", "Attribute ID", "Column Name");

                    if TaxAttribute.Get("Tax Type", "Attribute ID") then
                        Type := TaxAttribute.Type;
                end;
        end;
    end;

    local procedure InitTaxRateProgressWindow()
    begin
        if not GuiAllowed() then
            exit;

        TaxRateDialog.Open(
            UpdatingKeysLbl +
            TaxTypeLbl +
            ValueLbl);
    end;

    local procedure UpdateTaxRateProgressWindow(Stage: Text)
    begin
        if not GuiAllowed() then
            exit;
        TaxRateDialog.Update(1, "Tax Type");
        TaxRateDialog.Update(2, Stage);
    end;

    local procedure CloseTaxRateProgressWindow()
    begin
        if not GuiAllowed() then
            exit;
        TaxRateDialog.close();
    end;

    var
        ScriptSymbolsMgmt: Codeunit "Script Symbols Mgmt.";
        EmptyGuid: Guid;
        TaxRateDialog: Dialog;
        UpdatingKeysLbl: Label 'Updating keys on Tax Rates\';
        TaxTypeLbl: Label 'Tax Type:              #1######\', Comment = '%1 = Tax Type';
        ValueLbl: Label 'Stage:              #2######', Comment = '%1 = Key Generation stage';
        TransferingRecordToTempLbl: Label 'Transfering Records to temporary';
        UpdatingKeysValueLbl: Label 'Updating keys';
        ValidatingKeysValueLbl: Label 'Validating keys';
}