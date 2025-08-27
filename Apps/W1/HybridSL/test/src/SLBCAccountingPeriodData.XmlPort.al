// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

using Microsoft.Foundation.Period;

xmlport 147610 "SL BC Accounting Period Data"
{
    Caption = 'Accounting Period data for import/export';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("Accounting Period"; "Accounting Period")
            {
                AutoSave = false;
                XmlName = 'AccountingPeriod';
                UseTemporary = true;

                textelement("StartingDate")
                {
                }
                textelement(Name)
                {
                }
                textelement("NewFiscalYear")
                {
                }
                textelement("Closed")
                {
                }
                textelement("DateLocked")
                {
                }
                textelement("AverageCostCalcType")
                {
                }
                textelement("AverageCostPeriod")
                {
                }

                trigger OnPreXmlItem()
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;
                end;

                trigger OnBeforeInsertRecord()
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;

                    Evaluate(TempAccountingPeriod."Starting Date", StartingDate);
                    TempAccountingPeriod.Name := Name;
                    Evaluate(TempAccountingPeriod."New Fiscal Year", NewFiscalYear);
                    Evaluate(TempAccountingPeriod.Closed, Closed);
                    Evaluate(TempAccountingPeriod."Date Locked", DateLocked);
                    Evaluate(TempAccountingPeriod."Average Cost Calc. Type", AverageCostCalcType);
                    Evaluate(TempAccountingPeriod."Average Cost Period", AverageCostPeriod);
                    TempAccountingPeriod.Insert(false);
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        CaptionRow := true;
    end;

    procedure GetExpectedAccountingPeriods(var NewTempAccountingPeriod: Record "Accounting Period" temporary)
    begin
        if TempAccountingPeriod.FindSet() then begin
            repeat
                NewTempAccountingPeriod.Copy(TempAccountingPeriod);
                NewTempAccountingPeriod.Insert();
            until TempAccountingPeriod.Next() = 0;
        end;
    end;

    var
        CaptionRow: Boolean;
        TempAccountingPeriod: Record "Accounting Period" temporary;
}