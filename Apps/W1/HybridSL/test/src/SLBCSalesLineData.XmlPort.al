// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

using Microsoft.Sales.Document;

xmlport 147656 "SL BC Sales Line Data Temp"
{
    Caption = 'BC Sales Line data for import/export';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("Sales Line"; "Sales Line")
            {
                AutoSave = false;
                XmlName = 'SalesLine';
                UseTemporary = true;

                textelement(DocumentType)
                {
                }
                textelement(DocumentNo)
                {
                }
                textelement(LineNo)
                {
                }
                textelement(SellToCustomerNo)
                {
                }
                textelement(Type)
                {
                }
                textelement("No.")
                {
                }
                textelement(LocationCode)
                {
                }
                textelement(UnitOfMeasure)
                {
                }
                textelement(Quantity)
                {
                }
                textelement(UnitPrice)
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

                    Evaluate(TempSalesLine."Document Type", DocumentType);
                    TempSalesLine."Document No." := DocumentNo;
                    Evaluate(TempSalesLine."Line No.", LineNo);
                    TempSalesLine."Sell-to Customer No." := SellToCustomerNo;
                    if Type <> '' then
                        Evaluate(TempSalesLine.Type, Type);
                    TempSalesLine."No." := "No.";
                    TempSalesLine."Location Code" := LocationCode;
                    TempSalesLine."Unit of Measure Code" := UnitOfMeasure;
                    Evaluate(TempSalesLine.Quantity, Quantity);
                    Evaluate(TempSalesLine."Unit Price", UnitPrice);
                    TempSalesLine.Insert(false);
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        CaptionRow := true;
    end;

    procedure GetExpectedSalesLines(var NewTempSalesLine: Record "Sales Line" temporary)
    begin
        if TempSalesLine.FindSet() then begin
            repeat
                NewTempSalesLine.Copy(TempSalesLine);
                NewTempSalesLine.Insert();
            until TempSalesLine.Next() = 0;
        end;
    end;

    var
        CaptionRow: Boolean;
        TempSalesLine: Record "Sales Line" temporary;
}