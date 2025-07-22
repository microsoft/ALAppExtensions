// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoTool.Helpers;

using Microsoft.Inventory.Intrastat;
using Microsoft.Foundation.UOM;

xmlport 31221 "Import Tariff Numbers CZ"
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
                    textelement(mj_i)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Once;
                        TextType = Text;
                        XmlName = 'MJ_I';
                    }
                    textelement(trida)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Once;
                        TextType = Text;
                        XmlName = 'TRIDA';
                    }
                    textelement(tridarim)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Once;
                        TextType = Text;
                        XmlName = 'TRIDARIM';
                    }
                    textelement(popis)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Once;
                        TextType = Text;
                        XmlName = 'POPIS';
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
                        TempTariffNumber."Suppl. Unit of Measure" := CopyStr(mj_i, 1, MaxStrlen(TempTariffNumber."Suppl. Unit of Measure"));
                    end;
                }
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        if ThresholdDate = 0D then
            ThresholdDate := WorkDate();
    end;

    trigger OnPostXmlPort()
    var
        TariffNumber: Record "Tariff Number";
        UoMMappingDictionary: Dictionary of [Code[10], Code[10]];
    begin
        if TempTariffNumber.Count() = 0 then
            exit;

        GetTariffNumberUoMMapping(UoMMappingDictionary);

        // Delete existing records except ones with "Statement Code CZL"
        TariffNumber.Reset();
        TariffNumber.SetRange("Statement Code CZL", '');
        TariffNumber.DeleteAll();
        TariffNumber.Reset();

        // Insert new records or update existing
        TempTariffNumber.FindSet();
        repeat
            if TariffNumber.Get(TempTariffNumber."No.") then begin
                CopyFromTemp(TariffNumber, UoMMappingDictionary);
                TariffNumber.Modify(true);
            end else begin
                TariffNumber.Init();
                TariffNumber."No." := TempTariffNumber."No.";
                CopyFromTemp(TariffNumber, UoMMappingDictionary);
                TariffNumber.Insert(true);
            end;
        until TempTariffNumber.Next() = 0;
    end;

    var
        ThresholdDate: Date;

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
        ImportTariffNumbersCZL: XmlPort "Import Tariff Numbers CZL";
        UnitofMeasureCode: Code[10];
    begin
        TariffNumber.Description := TempTariffNumber.Description;
        TariffNumber."Description EN CZL" := TempTariffNumber."Description EN CZL";
        if TempTariffNumber."Suppl. Unit of Measure" = '' then
            exit;
        if TempTariffNumber."Suppl. Unit of Measure" = ImportTariffNumbersCZL.GetDummyUoMToken() then
            exit;
        if UoMMappingDictionary.Get(TempTariffNumber."Suppl. Unit of Measure", UnitofMeasureCode) then begin
            TariffNumber."Suppl. Unit of Measure" := UnitofMeasureCode;
            TariffNumber."Supplementary Units" := true;
        end;
    end;
}
