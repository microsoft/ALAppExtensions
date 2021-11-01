XmlPort 31106 "Import Tariff Numbers CZL"
{
    Caption = 'Import Tariff Numbers';
    Direction = Import;
    Encoding = UTF8;
    PreserveWhiteSpace = true;

    schema
    {
        textelement(ciselnik)
        {
            MaxOccurs = Once;
            MinOccurs = Once;
            XmlName = 'ciselnik';
            textelement(nazev)
            {
                MaxOccurs = Once;
                MinOccurs = Zero;
                TextType = Text;
                XmlName = 'nazev';
            }
            textelement(data)
            {
                MaxOccurs = Unbounded;
                MinOccurs = Zero;
                XmlName = 'data';
                tableelement(TempTariffNumber; "Tariff Number")
                {
                    MaxOccurs = Unbounded;
                    MinOccurs = Once;
                    XmlName = 'radek';
                    SourceTableView = sorting("No.");
                    UseTemporary = true;
                    textelement(kn)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Once;
                        TextType = Text;
                        XmlName = 'KN';
                    }
                    textelement(platnost_od)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Once;
                        TextType = Text;
                        XmlName = 'OD';
                    }
                    textelement(platnost_do)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Once;
                        TextType = Text;
                        XmlName = 'DO';
                    }
                    textelement(popis)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Once;
                        TextType = Text;
                        XmlName = 'POPIS';
                    }
                    textelement(mj_i)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Once;
                        TextType = Text;
                        XmlName = 'MJ_I';
                    }
                    textelement(popisan)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Once;
                        TextType = Text;
                        XmlName = 'POPISAN';
                    }

                    trigger OnBeforeInsertRecord()
                    var
                        ValidFromDate: Date;
                        ValidToDate: Date;
                    begin
                        TempTariffNumber."No." := CopyStr(kn, 1, MaxStrlen(TempTariffNumber."No."));
                        if TempTariffNumber."No." = '' then
                            currXMLport.Skip();
                        if TempTariffNumber.Get(TempTariffNumber."No.") then
                            currXMLport.Skip();

                        if not Evaluate(ValidFromDate, platnost_od, 9) then
                            ValidFromDate := 0D;
                        if not Evaluate(ValidToDate, platnost_do, 9) then
                            ValidToDate := 0D;
                        if not IsPeriodValid(ValidFromDate, ValidToDate) then
                            currXMLport.Skip();

                        TempTariffNumber.Description := CopyStr(popis, 1, MaxStrlen(TempTariffNumber.Description));
                        TempTariffNumber."Description EN CZL" := CopyStr(popisan, 1, MaxStrlen(TempTariffNumber."Description EN CZL"));
                        TempTariffNumber."Suppl. Unit of Meas. Code CZL" := CopyStr(mj_i, 1, MaxStrlen(TempTariffNumber."Suppl. Unit of Meas. Code CZL"));

                        if GuiAllowed then begin
                            ValidDataRowCount += 1;
                            WindowDialog.Update(1, ValidDataRowCount);
                        end;
                    end;
                }
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        if ThresholdDate = 0D then
            Error(ValidToDateErr);
        if not HideDialog then
            if not ConfirmManagement.GetResponseOrDefault(StrSubStno(ConfirmUpdateQst, TempTariffNumber.FieldCaption("Statement Code CZL")), false) then
                Error(ImportAbortedErr);
        if GuiAllowed then
            WindowDialog.Open(ProgressDialogMsg);
    end;

    trigger OnPostXmlPort()
    var
        UpdateTariffNumber: Record "Tariff Number";
        InsertTariffNumber: Record "Tariff Number";
        UoMMappingDictionary: Dictionary of [Code[10], Code[10]];
        ImportResultMsg: Text;
        CurrentRecord: Integer;
        RecordCount: Integer;
        DeleteCount: Integer;
        UpdateCount: Integer;
        InsertCount: Integer;
    begin
        RecordCount := TempTariffNumber.Count();
        if RecordCount = 0 then
            Error(NothingToImportErr);

        GetTariffNumberUoMMapping(UoMMappingDictionary);

        // Delete existing records except ones with "Statement Code CZL"
        UpdateTariffNumber.Reset();
        UpdateTariffNumber.SetRange("Statement Code CZL", '');
        DeleteCount := UpdateTariffNumber.Count;
        UpdateTariffNumber.DeleteAll();

        // Insert new records or update existing
        TempTariffNumber.FindSet();
        repeat
            if GuiAllowed then begin
                CurrentRecord += 1;
                WindowDialog.Update(2, Round(CurrentRecord / RecordCount * 10000, 1));
            end;
            if UpdateTariffNumber.Get(TempTariffNumber."No.") then begin
                CopyFromTemp(UpdateTariffNumber, UoMMappingDictionary);
                UpdateTariffNumber.Modify(true);
                UpdateCount += 1;
            end else begin
                InsertTariffNumber.Init();
                InsertTariffNumber."No." := TempTariffNumber."No.";
                CopyFromTemp(InsertTariffNumber, UoMMappingDictionary);
                InsertTariffNumber.Insert(true);
                InsertCount += 1;
            end;
        until TempTariffNumber.Next() = 0;

        if GuiAllowed then begin
            WindowDialog.Close();
            ImportResultMsg := ImportSuccessfulMsg;
            AddResultCount(ImportResultMsg, DeleteCount, DeletedTxt);
            AddResultCount(ImportResultMsg, UpdateCount, UpdatedTxt);
            AddResultCount(ImportResultMsg, InsertCount, InsertedTxt);
            Message(ImportResultMsg);
        end;
    end;

    var
        ConfirmManagement: Codeunit "Confirm Management";
        WindowDialog: Dialog;
        ThresholdDate: Date;
        ValidDataRowCount: Integer;
        HideDialog: Boolean;
        ConfirmUpdateQst: Label 'The import updates the data for the Tariff Numbers that have the %1 field filled in. Other records will be deleted from the table and imported from the XML file. Do you want to continue?', Comment = '%1 = Statement Code field caption';
        ImportAbortedErr: Label 'The import of tariff numbers has been aborted.';
        ProgressDialogMsg: Label 'Importing records #1############\Processing @2@@@@@@@@@@@@', Comment = '#1 = an integer, a count of data rows,, @2 = progress';
        NothingToImportErr: Label 'There is nothing to import!';
        ValidToDateErr: Label 'You must enter Valid-to Date!';
        ImportSuccessfulMsg: Label 'Import has been successfully completed.';
        ChangeNotificationMsg: Label '\%1 records %2.', Comment = '%1 - an integer, a count of records. %2 - type of record change (delete,insert,modify)';
        DeletedTxt: Label 'deleted';
        UpdatedTxt: Label 'updated';
        InsertedTxt: Label 'inserted';
        DummyUoMTok: Label 'ZZZ';

    procedure SetThresholdDate(NewDate: Date)
    begin
        ThresholdDate := NewDate;
    end;

    local procedure IsPeriodValid(ValidFromDate: Date; ValidToDate: Date): Boolean
    begin
        exit(
          ((ValidFromDate <= ThresholdDate) or (ValidFromDate = 0D)) and
          ((ValidToDate >= ThresholdDate) or (ValidToDate = 0D)));
    end;

    local procedure GetTariffNumberUoMMapping(var MappingDictionary: Dictionary of [Code[10], Code[10]])
    var
        UnitofMeasure: Record "Unit of Measure";
        UnitofMeasureCode: Code[10];
    begin
        if UnitofMeasure.FindSet() then
            repeat
                if UnitofMeasure."Tariff Number UOM Code CZL" <> '' then
                    if not MappingDictionary.Get(UnitofMeasure."Tariff Number UOM Code CZL", UnitofMeasureCode) then
                        MappingDictionary.Add(UnitofMeasure."Tariff Number UOM Code CZL", UnitofMeasure.Code);
            until UnitofMeasure.Next() = 0;
    end;

    local procedure CopyFromTemp(var TariffNumber: Record "Tariff Number"; UoMMappingDictionary: Dictionary of [Code[10], Code[10]])
    var
        UnitofMeasureCode: Code[10];
    begin
        TariffNumber.Description := TempTariffNumber.Description;
        TariffNumber."Description EN CZL" := TempTariffNumber."Description EN CZL";
#if CLEAN18
        if (TempTariffNumber."Suppl. Unit of Meas. Code CZL" <> '') and (TempTariffNumber."Suppl. Unit of Meas. Code CZL" <> DummyUoMTok) then
            if UoMMappingDictionary.Get(TempTariffNumber."Suppl. Unit of Meas. Code CZL", UnitofMeasureCode) then begin
                TariffNumber."Suppl. Unit of Meas. Code CZL" := UnitofMeasureCode;
                TariffNumber."Supplementary Units" := true;
            end;
#else
        if (TempTariffNumber."Suppl. Unit of Meas. Code CZL" <> '') and (TempTariffNumber."Suppl. Unit of Meas. Code CZL" <> DummyUoMTok) then begin
            TariffNumber."Supplementary Units" := true;
            if UoMMappingDictionary.Get(TempTariffNumber."Suppl. Unit of Meas. Code CZL", UnitofMeasureCode) then
                TariffNumber."Suppl. Unit of Meas. Code CZL" := UnitofMeasureCode;
        end;
#endif
    end;

    local procedure AddResultCount(var ImportResultMsg: Text; RecCount: Integer; ChangeTypeText: Text)
    begin
        if RecCount > 0 then
            ImportResultMsg += StrSubstNo(ChangeNotificationMsg, RecCount, ChangeTypeText);
    end;

    procedure SetHideDialog(NewHideDialog: Boolean)
    begin
        HideDialog := NewHideDialog;
    end;
}