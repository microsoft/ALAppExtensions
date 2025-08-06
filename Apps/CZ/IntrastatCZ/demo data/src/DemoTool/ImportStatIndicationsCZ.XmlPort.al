// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoTool.Helpers;

using Microsoft.Inventory.Intrastat;

xmlport 31225 "Import Stat. Indications CZ"
{
    Caption = 'Import Statistic Indications';
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
                tableelement(StatisticIndicationCZ; "Statistic Indication CZ")
                {
                    MaxOccurs = Unbounded;
                    MinOccurs = Once;
                    XmlName = 'radek';

                    textelement(kn)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Once;
                        TextType = Text;
                        XmlName = 'KN';
                    }
                    textelement(stazna)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Once;
                        TextType = Text;
                        XmlName = 'STAZNA';
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
                        StatisticIndicationCZ."Tariff No." := CopyStr(kn, 1, MaxStrlen(StatisticIndicationCZ."Tariff No."));
                        StatisticIndicationCZ.Code := CopyStr(stazna, 1, MaxStrlen(StatisticIndicationCZ.Code));
                        if StatisticIndicationCZ.Code = '' then
                            currXMLport.Skip();
                        if StatisticIndicationCZ.Get(StatisticIndicationCZ.Code) then
                            currXMLport.Skip();

                        if not Evaluate(ValidFromDate, platnost_od, 9) then
                            ValidFromDate := 0D;
                        if not Evaluate(ValidToDate, platnost_do, 9) then
                            ValidToDate := 0D;
                        if not IsPeriodValid(ValidFromDate, ValidToDate) then
                            currXMLport.Skip();

                        StatisticIndicationCZ.Description := CopyStr(popis, 1, MaxStrlen(StatisticIndicationCZ.Description));
                        StatisticIndicationCZ."Description EN" := CopyStr(popisan, 1, MaxStrlen(StatisticIndicationCZ."Description EN"));
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
}
